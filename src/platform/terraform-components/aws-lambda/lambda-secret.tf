resource "aws_secretsmanager_secret" "lambda_secret" {
  count                   = signum(length(var.secrets))
  name                    = local.lambda_secret_name
  kms_key_id              = null
  recovery_window_in_days = 30
}

resource "aws_secretsmanager_secret_version" "lambda_secret" {
  count         = signum(length(var.secrets))
  secret_id     = aws_secretsmanager_secret.lambda_secret[0].id
  secret_string = jsonencode(var.secrets)
}
