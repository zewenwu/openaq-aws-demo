resource "aws_s3_bucket" "log_bucket" {
  count = var.server_access_logging_enabled ? 1 : 0

  bucket        = "${local.bucket_log_bucket_name}${var.append_random_suffix ? "-${random_string.random_suffix.result}" : ""}"
  force_destroy = var.force_s3_destroy

  tags = merge({
    Name = local.bucket_log_bucket_name
  }, var.tags)
}

# Remove ACLs
resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  count = var.server_access_logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "log_bucket" {
  count = var.server_access_logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "log_bucket" {
  count = var.server_access_logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id
  versioning_configuration {
    status = "Disabled"
  }
}

# Link the bucket to the log bucket.
resource "aws_s3_bucket_logging" "bucket_logging_link" {
  count = var.server_access_logging_enabled ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.log_bucket[0].id
  target_prefix = "log/"
}
