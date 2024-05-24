output "bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "The ID of the S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.bucket.arn
  description = "The Amazon Resource Name (ARN) of the S3 bucket."
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.bucket.bucket_domain_name
  description = "The domain name of the S3 bucket."
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.bucket
  description = "The name of the S3 bucket."
}

### KMS key
output "bucket_kms_key_id" {
  value       = var.enable_kms_encryption ? module.bucket_kms_key[0].key_id : null
  description = "The ID of the KMS key used for the S3 bucket."
}

output "bucket_kms_key_arn" {
  value       = var.enable_kms_encryption ? module.bucket_kms_key[0].key_arn : null
  description = "The Amazon Resource Name (ARN) of the KMS key used for the S3 bucket."
}

### Consumer policy
output "consumer_policy_arn" {
  value       = aws_iam_policy.consumer.arn
  description = "The Amazon Resource Name (ARN) of the IAM policy for the consumer."
}