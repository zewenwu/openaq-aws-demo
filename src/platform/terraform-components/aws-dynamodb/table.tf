resource "aws_dynamodb_table" "table" {
  name                        = var.table_name
  table_class                 = "STANDARD"
  billing_mode                = var.billing_mode_info["mode"]
  read_capacity               = var.billing_mode_info["mode"] == "PROVISIONED" ? var.billing_mode_info["read_capacity"] : 0
  write_capacity              = var.billing_mode_info["mode"] == "PROVISIONED" ? var.billing_mode_info["write_capacity"] : 0
  deletion_protection_enabled = var.deletion_protection_enabled
  hash_key                    = var.hash_key_info["name"]
  range_key                   = var.range_key_info["name"] == "" ? null : var.range_key_info["name"]

  attribute {
    name = var.hash_key_info["name"]
    type = var.hash_key_info["type"]
  }

  dynamic "attribute" {
    for_each = var.range_key_info["name"] == "" ? [] : [1]
    content {
      name = var.range_key_info["name"]
      type = var.range_key_info["type"]
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_kms_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = module.table_kms_key[0].key_arn
    }
  }

  ttl {
    attribute_name = var.ttl_attribute_name
    enabled        = var.ttl_attribute_name == "" ? false : true
  }

  tags = var.tags
}
