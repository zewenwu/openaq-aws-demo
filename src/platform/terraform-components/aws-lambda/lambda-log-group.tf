resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 30
  kms_key_id        = null

  tags = merge({
    Name = var.function_name
  }, var.tags)
}
