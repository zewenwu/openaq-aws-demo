data "aws_caller_identity" "main" {}

data "aws_region" "active" {}

locals {
  bucket_key_name             = "${var.bucket_name}-key"
  bucket_log_bucket_name      = "${var.bucket_name}-log"
  bucket_consumer_policy_name = "${var.bucket_name}-consumer-policy"
}

resource "random_string" "random_suffix" {
  length  = var.bucket_suffix_length
  upper   = false
  lower   = true
  numeric = true
  special = false
}
