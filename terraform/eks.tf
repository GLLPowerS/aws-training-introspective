locals {
  computed_cluster_access_entries = concat(
    var.cluster_access_entries,
    var.add_current_caller_access ? [{
      principal_arn = data.aws_caller_identity.current.arn
      policy_arns   = var.current_caller_policy_arns
    }] : []
  )
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = var.cluster_name
  kubernetes_version = "1.34"
  enable_irsa     = true

  # Allow reaching the API server from outside the VPC (adjust CIDR to your IP for tighter access)
  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Skip KMS key creation to avoid extra permissions; set to true or supply an existing key if you want secrets encryption.
  create_kms_key = false
  # Explicitly disable custom encryption config to avoid provider_key_arn lookups when no KMS key is supplied.
  encryption_config = null

  # Avoid creating a log group if one already exists
  # create_cloudwatch_log_group = true
  # cluster_enabled_log_types   = []

  # enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.medium"]
    }
  }

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # Manage EKS access entries (replaces legacy aws-auth mappings) so specified IAM principals get the requested policies at cluster scope.
  access_entries = {
    for entry in local.computed_cluster_access_entries :
    "access-${replace(replace(replace(entry.principal_arn, ":", "-"), "/", "-"), "*", "-")}" => {
      principal_arn = entry.principal_arn
      policy_associations = {
        for idx, policy_arn in entry.policy_arns :
        format("policy-%d", idx) => {
          policy_arn = policy_arn
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_api_server_4000 = {
      description              = "Allow ingress to port 4000 from kube apiserver"
      protocol                 = "tcp"
      from_port                = 4000
      to_port                  = 4000
      type                     = "ingress"
      source_security_group_id = module.eks.cluster_security_group_id
    }
  }
  
  tags = {
    Project = "introspect"
  }
}
