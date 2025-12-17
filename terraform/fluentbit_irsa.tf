locals {
  fluent_bit_irsa_role_arn = var.create_fluent_bit_irsa_role ? aws_iam_role.fluent_bit_irsa[0].arn : var.fluent_bit_irsa_role_arn
}

data "aws_iam_policy_document" "fluent_bit_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:kube-system:aws-for-fluent-bit"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "fluent_bit_cloudwatch_logs" {
  count       = var.create_fluent_bit_irsa_role ? 1 : 0
  name        = "introspect-fluent-bit-cloudwatch-logs"
  description = "CloudWatch Logs write access for aws-for-fluent-bit"
  policy      = file("iam-policies/fluent-bit-cloudwatch-logs-policy.json")

  tags = {
    Project = "introspect"
  }
}

resource "aws_iam_role" "fluent_bit_irsa" {
  count              = var.create_fluent_bit_irsa_role ? 1 : 0
  name               = "introspect-aws-for-fluent-bit-irsa"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume.json

  tags = {
    Project = "introspect"
  }
}

resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch_logs" {
  count      = var.create_fluent_bit_irsa_role ? 1 : 0
  role       = aws_iam_role.fluent_bit_irsa[0].name
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch_logs[0].arn
}
