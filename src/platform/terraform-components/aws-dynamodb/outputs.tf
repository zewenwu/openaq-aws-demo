output "table_name" {
  value       = aws_dynamodb_table.table.id
  description = "The name of the table."
}

output "table_arn" {
  value       = aws_dynamodb_table.table.arn
  description = "The Amazon Resource Name (ARN) of the table."
}

output "table_kms_key_id" {
  value       = var.enable_kms_encryption ? module.table_kms_key[0].key_id : null
  description = "The ID of the KMS key used for the DynamoDB table."
}

output "table_kms_key_arn" {
  value       = var.enable_kms_encryption ? module.table_kms_key[0].key_arn : null
  description = "The Amazon Resource Name (ARN) of the KMS key used for the DynamoDB table."
}

### Consumer policy
output "consumer_policy_arn" {
  value       = aws_iam_policy.consumer.arn
  description = "The Amazon Resource Name (ARN) of the IAM policy for the consumer."
}
