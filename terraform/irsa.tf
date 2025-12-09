locals {
  oidc_provider       = module.eks.oidc_provider
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_host  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  sns_sqs_policy_arn  = var.sns_sqs_policy_arn != "" ? var.sns_sqs_policy_arn : aws_iam_policy.sns_sqs.arn

  product_irsa_arn = var.create_irsa_roles ? aws_iam_role.product_irsa[0].arn : var.product_irsa_role_arn
  order_irsa_arn   = var.create_irsa_roles ? aws_iam_role.order_irsa[0].arn : var.order_irsa_role_arn
}

data "aws_iam_policy_document" "product_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${var.serviceaccount_namespace}:${var.product_service_sa}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "order_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${var.serviceaccount_namespace}:${var.order_service_sa}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "product_irsa" {
  count              = var.create_irsa_roles ? 1 : 0
  name               = "introspect-product-service-irsa"
  assume_role_policy = data.aws_iam_policy_document.product_assume.json
  managed_policy_arns = [local.sns_sqs_policy_arn]
  tags = {
    Project = "introspect"
  }
}

resource "aws_iam_role" "order_irsa" {
  count              = var.create_irsa_roles ? 1 : 0
  name               = "introspect-order-service-irsa"
  assume_role_policy = data.aws_iam_policy_document.order_assume.json
  managed_policy_arns = [local.sns_sqs_policy_arn]
  tags = {
    Project = "introspect"
  }
}
