resource "aws_dynamodb_resource_policy" "policy" {
  count  = var.apply_table_policy ? 1 : 0
  resource_arn = aws_dynamodb_table.table.arn
  policy = var.full_override_table_policy_document
}
