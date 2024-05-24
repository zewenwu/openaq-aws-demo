module "table_kms_key" {
  count = var.enable_kms_encryption ? 1 : 0
  source = "../aws-kmskey"

  alias_name           = local.table_key_name
  key_type             = "service"
  append_random_suffix = true
  description          = "DynamoDB table encryption KMS key"
  tags                 = var.tags

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = concat(["dynamodb.${data.aws_region.active.name}.amazonaws.com"], var.table_kms_allow_additional_principals)
  }
}
