
### Lambda execution role
resource "aws_iam_role" "lambda_exec" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json

  tags = merge({
    Name = local.lambda_role_name
  }, var.tags)
}

data "aws_iam_policy_document" "lambda_exec" {
  version = "2012-10-17"

  statement {
    sid = "LambdaExecutionRole"

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

### Base policy
resource "aws_iam_policy" "base_policy" {
  name        = "${var.function_name}-lambda-base-policy"
  description = "IAM policy to allow lambda to push logs to CW, push traces to X-Ray and attach itself to a VPC"

  policy = data.aws_iam_policy_document.base_policy.json
}

data "aws_iam_policy_document" "base_policy" {
  version = "2012-10-17"

  statement {
    sid = "LambdaLogGroupPermissions"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:*",
    ]
  }

  statement {
    sid = "LambdaVPCPermissions"

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeInstances",
      "ec2:AttachNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    sid = "LambdaXRayPermissions"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  dynamic "statement" {
    for_each = var.dead_letter_config_arn == "" ? [] : [true]
    content {
      sid = "LambdaDeadLetterConfigPermission"
      actions = [
        local.is_dead_letter_queue_sns_type ? "sns:Publish" :
        local.is_dead_letter_queue_sqs_type ? "sqs:SendMessage" : null
      ]
      effect    = "Allow"
      resources = [var.dead_letter_config_arn]
    }
  }
}

resource "aws_iam_role_policy_attachment" "base_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.base_policy.arn
}

### Secrets
# Add a policy to the Lambda function execution role so that Lambda can pull secrets from SecretsManager
resource "aws_iam_policy" "lambda_execution_secret" {
  count       = signum(length(var.secrets))
  name        = "${var.function_name}-lambda-secret-policy"
  description = "IAM policy to allow lambda function to pull the Lambda secret from SecretsManager"

  policy = data.aws_iam_policy_document.lambda_execution_secret[0].json
}

data "aws_iam_policy_document" "lambda_execution_secret" {
  count   = signum(length(var.secrets))
  version = "2012-10-17"

  statement {
    sid       = "LambdaSecretManagerPermission"
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [
      aws_secretsmanager_secret.lambda_secret[0].arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution_secret" {
  count      = signum(length(var.secrets))
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_execution_secret[0].arn
}

### Additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = var.lambda_policy_arns
  role       = aws_iam_role.lambda_exec.name
  policy_arn = each.value
}
