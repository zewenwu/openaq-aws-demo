
### Raw Zone
output "raw_schedule_lambda_name" {
  value       = module.raw_schedule_lambda.schedule_info.name
  description = "The name of the schedule for the raw Lambda function."
}

output "raw_ecr_name" {
  value       = module.raw_ecr.repository_name
  description = "The name of the ECR repository for the raw Lambda function."
}

output "raw_lambda_name" {
  value       = module.raw_lambda.lambda_info.name
  description = "The name of the raw Lambda function."
}

output "raw_bucket_name" {
  value       = module.raw_bucket.bucket_name
  description = "The name of the raw S3 bucket."
}

### Clean Zone
output "clean_ecr_name" {
  value       = module.clean_ecr.repository_name
  description = "The name of the ECR repository for the clean Lambda function."
}

output "clean_lambda_name" {
  value       = module.clean_lambda.lambda_info.name
  description = "The name of the clean Lambda function."
}

output "clean_dynamodb_table_name" {
  value       = module.clean_table.table_name
  description = "The name of the clean DynamoDB table."
}

### Refined Zone
output "refined_schedule_lambda_name" {
  value       = module.refined_schedule_lambda.schedule_info.name
  description = "The name of the schedule for the refined Lambda function."
}

output "refined_ecr_name" {
  value       = module.refined_ecr.repository_name
  description = "The name of the ECR repository for the refined Lambda function."
}

output "refined_lambda_name" {
  value       = module.refined_lambda.lambda_info.name
  description = "The name of the refined Lambda function."
}

output "refined_bucket_name" {
  value       = module.refined_bucket.bucket_name
  description = "The name of the refined S3 bucket."
}
