output "repository_url" {
  description = "URL for the ecr repository"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_arn" {
  description = "URL for the ecr repository"
  value       = aws_ecr_repository.main.arn
}

output "repository_name" {
  description = "Name of the ecr repository"
  value       = aws_ecr_repository.main.name
}

### KMS key
output "repository_kms_key_id" {
  value       = var.enable_kms_encryption ? module.ecr_kms_key[0].key_id : null
  description = "The ID of the KMS key used for the ECR repository."
}

output "repository_kms_key_arn" {
  value       = var.enable_kms_encryption ? module.ecr_kms_key[0].key_arn : null
  description = "The Amazon Resource Name (ARN) of the KMS key used for the ECR repository."
}
