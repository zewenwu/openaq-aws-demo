module "ecr_kms_key" {
  count  = var.enable_kms_encryption ? 1 : 0
  source = "../aws-kmskey"

  alias_name           = local.ecr_key_name
  key_type             = "service"
  append_random_suffix = true
  description          = "ECR encryption KMS key for: ${var.repository_name}"
  tags                 = var.tags

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.active.account_id]
    aws_service_names  = ["ecr.${data.aws_region.active.name}.amazonaws.com"]
  }
}
