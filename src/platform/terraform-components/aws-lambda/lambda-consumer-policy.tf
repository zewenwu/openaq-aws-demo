resource "aws_iam_policy" "consumer" {
  count  = length(var.allowed_actions) > 0 ? 1 : 0
  name   = local.lambda_consumer_policy_name
  policy = data.aws_iam_policy_document.consumer[0].json
}

data "aws_iam_policy_document" "consumer" {
  count = length(var.allowed_actions) > 0 ? 1 : 0
  statement {
    sid     = "AllowActionsOnLambda"
    effect  = "Allow"
    actions = var.allowed_actions
    resources = [
      aws_lambda_function.function.arn
    ]
  }
}
