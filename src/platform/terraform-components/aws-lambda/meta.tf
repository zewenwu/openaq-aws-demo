data "aws_caller_identity" "active" {}

data "aws_region" "active" {}

locals {
  lambda_role_name            = "${var.function_name}-lambda-exec-role"
  lambda_consumer_policy_name = "${var.function_name}-lambda-consumer-policy"
  lambda_secret_name          = "${var.function_name}-lambda-secret-${random_string.secret_name_suffix.result}"

  # Create a map of secret name and secret arn
  lambda_secret_name_map = try(length(var.secrets) > 0 ? {
    LAMBDA_SECRET_NAME = local.lambda_secret_name
    LAMBDA_SECRET_ARN  = aws_secretsmanager_secret.lambda_secret[0].arn
  } : null, null)

  # Add secret name and ARN to environment variables to make secret name accessible to the lambda.
  environment_variables = merge(local.lambda_secret_name_map, var.environment_variables)

  # Dead letter queue
  is_dead_letter_queue_configured = var.dead_letter_config_arn != ""
  # Look for :SNS: or :sns: in the arn
  is_dead_letter_queue_sns_type = length(regexall("(?i).:sns:.", var.dead_letter_config_arn)) > 0
  # Look for :SQS: or :sqs: in the arn
  is_dead_letter_queue_sqs_type = length(regexall("(?i).:sqs:.", var.dead_letter_config_arn)) > 0
}

resource "random_string" "secret_name_suffix" {
  length  = 5
  special = false
}
