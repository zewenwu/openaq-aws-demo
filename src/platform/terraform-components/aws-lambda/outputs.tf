output "lambda_info" {
  description = "The name, ARN, invoke ARN, Version Number of the Lambda Function"
  value = {
    name         = aws_lambda_function.function.function_name
    arn          = aws_lambda_function.function.arn
    invoke_arn   = aws_lambda_function.function.invoke_arn
    version      = aws_lambda_function.function.version
  }
}

output "lambda_consumer_policy_arn" {
  description = "The ARN of the Lambda Consumer Policy."
  value = length(var.allowed_actions) > 0 ? aws_iam_policy.consumer[0].arn : null
}
