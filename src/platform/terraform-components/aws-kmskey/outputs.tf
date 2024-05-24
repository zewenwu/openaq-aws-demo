output "key_arn" {
  description = "The ARN of the KMS key"
  value       = var.key_type == "service" ? aws_kms_key.service_key[0].arn : aws_kms_key.direct_key[0].arn
}

output "key_id" {
  description = "The ID of the KMS key"
  value       = var.key_type == "service" ? aws_kms_key.service_key[0].key_id : aws_kms_key.direct_key[0].key_id
}
