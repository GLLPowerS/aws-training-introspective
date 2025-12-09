resource "aws_iam_policy" "sns_sqs" {
  name        = "introspect-sns-sqs-pubsub"
  description = "SNS/SQS access for Dapr pubsub"
  policy      = file("../infra/iam-policies/sns-sqs-pubsub-policy.json")

  tags = {
    Project = "introspect"
  }
}
