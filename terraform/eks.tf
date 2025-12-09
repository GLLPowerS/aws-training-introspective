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
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  enable_irsa     = true

  # Allow reaching the API server from outside the VPC (adjust CIDR to your IP for tighter access)
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Skip KMS key creation to avoid extra permissions; set to true or supply an existing key if you want secrets encryption.
  create_kms_key = false
  # Explicitly disable encryption config to avoid provider_key_arn lookups when no KMS key is supplied.
  cluster_encryption_config = []

  # Avoid creating a log group if one already exists
  # create_cloudwatch_log_group = true
  # cluster_enabled_log_types   = []

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

  cluster_addons = {
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

  tags = {
    Project = "introspect"
  }
}
