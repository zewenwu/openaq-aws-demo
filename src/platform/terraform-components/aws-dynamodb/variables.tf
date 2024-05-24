### DynamoDB Table
variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "billing_mode_info" {
  description = "Info block about the billing mode for the DynamoDB table. Mode can be PROVISIONED or PAY_PER_REQUEST. If mode is PROVISIONED, read_capacity and write_capacity should be provided."
  type        = map(string)
  default = {
    mode           = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 20
  }
}

variable "allowed_actions" {
  description = "List of DynamoDB actions which are allowed for same account principals for the consumer policy"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]
}

variable "deletion_protection_enabled" {
  description = "Whether to enable deletion protection on the DynamoDB table"
  type        = bool
  default     = false
}

### DynamoDB Table Attributes
variable "hash_key_info" {
  description = "Info block about attribute to use as the hash (partition) key and its type"
  type        = map(string)
  default = {
    name = "id"
    type = "S"
  }
}

variable "range_key_info" {
  description = "Info block about attribute to use as the range (sort) key and its type"
  type        = map(string)
  default = {
    name = ""
    type = ""
  }
}

variable "ttl_attribute_name" {
  description = "The name of the attribute to use as the Time To Live (TTL) attribute"
  type        = string
  default     = ""
}

### DynamoDB Table Resource Policy
variable "apply_table_policy" {
  description = "Whether to apply pre-defined bucket policy."
  type        = bool
  default     = true
}
variable "full_override_table_policy_document" {
  description = "[Optional] Bucket Policy JSON document. Bucket Policy Statements will be fully overriden"
  type        = string
  default     = "{}"
}

### DynamoDB Table Encryption with KMS key
variable "enable_kms_encryption" {
  description = "Enable DynamoDB table encryption with KMS key? (true/false)"
  type        = bool
  default     = false
}

variable "table_kms_allow_additional_principals" {
  description = "[Optional] Additional Table KMS Key Policy Principals."
  type        = list(string)
  default     = []
}

### Metadata
variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}
