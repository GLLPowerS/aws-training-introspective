module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.37"

  role_name             = "AmazonEKS_EBS_CSI_DriverRole"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Project = "introspect"
  }
}

# Ensure the AWS managed EBS CSI driver policy is attached (covers required EC2 actions for the addon).
resource "aws_iam_role_policy_attachment" "ebs_csi_managed" {
  role       = module.ebs_csi_irsa.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Ensure the CSI driver role has required EC2 describe permissions (covers missing ec2:DescribeAvailabilityZones).
resource "aws_iam_role_policy" "ebs_csi_describe" {
  name = "AmazonEKS_EBS_CSI_Describe"
  role = module.ebs_csi_irsa.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}
