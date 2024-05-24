data "aws_caller_identity" "main" {}

data "aws_region" "active" {}

locals {
  table_key_name             = "${var.table_name}-key"
  table_consumer_policy_name = "${var.table_name}-consumer-policy"
}
