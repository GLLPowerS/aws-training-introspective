locals {
  aws_otel_collector_irsa_role_arn = var.create_aws_otel_collector_irsa_role ? aws_iam_role.aws_otel_collector_irsa[0].arn : var.aws_otel_collector_irsa_role_arn
}

data "aws_iam_policy_document" "aws_otel_collector_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:observability:aws-otel-collector"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_otel_collector_irsa" {
  count              = var.create_aws_otel_collector_irsa_role ? 1 : 0
  name               = "introspect-aws-otel-collector-irsa"
  assume_role_policy = data.aws_iam_policy_document.aws_otel_collector_assume.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
  ]

  tags = {
    Project = "introspect"
  }
}
