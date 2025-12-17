locals {
  project_tags = {
    Project = "introspect"
  }
}

resource "aws_sns_topic" "pubsub" {
  count = var.create_pubsub_infra ? 1 : 0

  name = var.pubsub_topic_name

  tags = local.project_tags
}

resource "aws_sqs_queue" "pubsub" {
  count = var.create_pubsub_infra ? 1 : 0

  name = var.pubsub_queue_name

  # When the queue already exists, AWS requires the CreateQueue call to be idempotent
  # (effective attributes must match) or it fails with QueueAlreadyExists.
  message_retention_seconds      = var.pubsub_queue_message_retention_seconds
  visibility_timeout_seconds     = var.pubsub_queue_visibility_timeout_seconds
  receive_wait_time_seconds      = 0
  max_message_size               = 262144
  delay_seconds                  = 0

  tags = local.project_tags
}

data "aws_iam_policy_document" "pubsub_queue_policy" {
  count = var.create_pubsub_infra ? 1 : 0

  statement {
    sid     = "AllowSnsSendMessage"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    resources = [aws_sqs_queue.pubsub[0].arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.pubsub[0].arn]
    }
  }
}

resource "aws_sqs_queue_policy" "pubsub" {
  count = var.create_pubsub_infra ? 1 : 0

  queue_url = aws_sqs_queue.pubsub[0].id
  policy    = data.aws_iam_policy_document.pubsub_queue_policy[0].json
}

resource "aws_sns_topic_subscription" "pubsub" {
  count = var.create_pubsub_infra ? 1 : 0

  topic_arn = aws_sns_topic.pubsub[0].arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.pubsub[0].arn

  # Dapr's SNS/SQS pubsub component expects the standard SNS JSON envelope in SQS.
  # Enabling raw message delivery would break parsing.
  raw_message_delivery = false

  depends_on = [aws_sqs_queue_policy.pubsub]
}
