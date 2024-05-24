resource "aws_kms_key" "service_key" {
  count                   = local.service_key_count
  description             = var.description
  enable_key_rotation     = true
  deletion_window_in_days = var.deletion_window

  policy = data.aws_iam_policy_document.kms_key_policy_via_service[0].json

  tags = merge({
    Alias = var.alias_name
  }, var.tags)
}

resource "aws_kms_alias" "service_key" {
  count         = local.service_key_count
  name          = "alias/${local.alias_name}"
  target_key_id = aws_kms_key.service_key[0].key_id

}

data "aws_iam_policy_document" "kms_key_policy_via_service" {
  count = local.service_key_count
  # Root user will have permissions to manage the CMK, 
  # but do not have permissions to use the CMK in cryptographic operations. 
  # https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#cryptographic-operations
  statement {
    sid       = "Allow Admin"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Allow Cryptography"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = var.service_key_info.aws_service_names
    }

    dynamic "condition" {
      for_each = local.kms_conditions

      content {
        test     = condition.value.test
        variable = condition.value.variable
        values   = condition.value.values
      }
    }
  }
}
