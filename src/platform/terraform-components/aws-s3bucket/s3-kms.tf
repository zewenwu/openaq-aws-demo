module "bucket_kms_key" {
  count = var.enable_kms_encryption ? 1 : 0
  source = "../aws-kmskey"

  alias_name           = local.bucket_key_name
  key_type             = "service"
  append_random_suffix = true
  description          = "S3 data bucket encryption KMS key"
  tags                 = var.tags

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = concat(["s3.${data.aws_region.active.name}.amazonaws.com"], var.bucket_kms_allow_additional_principals)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse_kms" {
  count = var.enable_kms_encryption ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.bucket_kms_key[0].key_arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled = true
  }
}
