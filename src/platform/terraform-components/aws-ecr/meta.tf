data "aws_caller_identity" "active" {}

data "aws_region" "active" {}

locals {
  ecr_name     = var.repository_name
  ecr_key_name = "${var.repository_name}-key"
}
