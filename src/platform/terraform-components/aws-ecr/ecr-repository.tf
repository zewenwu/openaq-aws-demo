# ECR repository
resource "aws_ecr_repository" "main" {
  name         = var.repository_name
  force_delete = var.repository_force_delete

  encryption_configuration {
    encryption_type = var.enable_kms_encryption ? "KMS" : "AES256"
    kms_key         = var.enable_kms_encryption ? module.ecr_kms_key[0].key_arn : null
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = var.is_immutable_image ? "IMMUTABLE" : "MUTABLE"

  tags = merge({
    Name = var.repository_name
  }, var.tags)
}
