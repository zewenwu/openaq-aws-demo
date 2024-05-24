resource "aws_iam_policy" "consumer" {
  name   = local.bucket_consumer_policy_name
  policy = data.aws_iam_policy_document.consumer.json
}

data "aws_iam_policy_document" "consumer" {

  dynamic "statement" {
    for_each = length(var.allowed_actions) > 0 ? [1] : []
    content {
      sid     = "AllowActionsOnS3"
      effect  = "Allow"
      actions = var.allowed_actions
      resources = [
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*",
      ]
    }
  }
}
