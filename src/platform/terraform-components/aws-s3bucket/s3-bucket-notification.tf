resource "aws_s3_bucket_notification" "bucket_notification" {
  count       = var.enable_bucket_notification ? 1 : 0
  bucket      = aws_s3_bucket.bucket.id
  eventbridge = false

  dynamic "lambda_function" {
    for_each = var.bucket_notification_info.lambda_function_arns
    content {
      lambda_function_arn = lambda_function.value
      events              = var.bucket_notification_info.events
      filter_prefix       = var.bucket_notification_info.filter_prefix
      filter_suffix       = var.bucket_notification_info.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.bucket_notification_info.sqs_queue_arns
    content {
      queue_arn     = sqs_queue.value
      events        = var.bucket_notification_info.events
      filter_prefix = var.bucket_notification_info.filter_prefix
      filter_suffix = var.bucket_notification_info.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = var.bucket_notification_info.sns_topic_arns
    content {
      topic_arn     = sns_topic.value
      events        = var.bucket_notification_info.events
      filter_prefix = var.bucket_notification_info.filter_prefix
      filter_suffix = var.bucket_notification_info.filter_suffix
    }
  }
}
