resource "aws_s3_bucket_policy" "policy" {
  count  = var.apply_bucket_policy ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = var.enable_static_website_hosting ? data.aws_iam_policy_document.public_static_website_read[0].json : (var.enable_kms_encryption ? data.aws_iam_policy_document.kms_policy[0].json : var.full_override_bucket_policy_document)
}

/*
  Provide access to the bucket only from the same account where the bucket resides.
  The S3 bucket policy has significant complexity. The goals are as follows:

    * Require that all content uploaded uses AWS KMS encryption
    * Require that only our specific KMS BYOK key is used

  The ability to use the bucket is controlled by `deny` statements:

    1. Deny upload when our specific KMS key ID is not provided ('PutObject')
    2. Deny upload when server side encryption is not SSE-KMS ('PutObject')
*/
data "aws_iam_policy_document" "kms_policy" {
  count = var.apply_bucket_policy && var.enable_kms_encryption ? 1 : 0

  statement {
    sid       = "DenyS3UploadForNotSpecificKMS"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [module.bucket_kms_key[0].key_arn]
    }
  }
}

data "aws_iam_policy_document" "public_static_website_read" {
  count = var.apply_bucket_policy && var.enable_static_website_hosting ? 1 : 0
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.bucket.arn}/*"]
    actions   = ["s3:GetObject"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
