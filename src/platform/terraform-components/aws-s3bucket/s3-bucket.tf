resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}${var.append_random_suffix ? "-${random_string.random_suffix.result}" : ""}"
  force_destroy = var.force_s3_destroy

  tags = merge({
    Name = var.bucket_name
  }, var.tags)
}

# Remove ACLs
resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.enable_static_website_hosting ? false : true
  block_public_policy     = var.enable_static_website_hosting ? false : true
  ignore_public_acls      = var.enable_static_website_hosting ? false : true
  restrict_public_buckets = var.enable_static_website_hosting ? false : true
}

# Static website hosting
resource "aws_s3_bucket_website_configuration" "bucket" {
  count  = var.enable_static_website_hosting ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}
