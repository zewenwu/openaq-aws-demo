### S3 Bucket
variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "append_random_suffix" {
  description = "Append random string as suffix? (true/false)"
  type        = bool
  default     = true
}

variable "bucket_suffix_length" {
  description = "Length of suffix string for bucket name"
  type        = number
  default     = 4
}

variable "force_s3_destroy" {
  description = "Force destruction of the S3 bucket when the stack is deleted"
  type        = string
  default     = false
}

variable "allowed_actions" {
  description = "List of S3 actions which are allowed for same account principals for the consumer policy"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]
}

variable "folder_names" {
  description = "List of folder names to be created in the S3 bucket. Will create .keep file in each folder. Sub-folders are also supported, use S3 standard forward slash as folder separator"
  type        = list(string)
  default     = []
}

variable "versioning_enabled" {
  description = "Should versioning be enabled? (true/false)"
  type        = bool
  default     = false
}

variable "expiration_days" {
  description = "Number of days after which data will be automatically destroyed. Defaults to 0 meaning expiration is disabled"
  type        = number
  default     = 0
}

### S3 Bucket Policy
variable "apply_bucket_policy" {
  description = "Whether to apply pre-defined bucket policy."
  type        = bool
  default     = true
}
variable "full_override_bucket_policy_document" {
  description = "[Optional] Bucket Policy JSON document. Bucket Policy Statements will be fully overriden"
  type        = string
  default     = "{}"
}

### S3 Logging
variable "server_access_logging_enabled" {
  description = "Should server access logging be enabled? (true/false)"
  type        = bool
  default     = false
}

### S3 Encryption with KMS key
variable "enable_kms_encryption" {
  description = "Enable S3 bucket encryption with KMS key? (true/false)"
  type        = bool
  default     = false
}

variable "bucket_kms_allow_additional_principals" {
  description = "[Optional] Additional Bucket KMS Policy Principals."
  type        = list(string)
  default     = []
}

### S3 Bucket Notification
variable "enable_bucket_notification" {
  description = "Enable S3 bucket notification configuration? (true/false)"
  type        = bool
  default     = false
}

variable "bucket_notification_info" {
  description = <<EOF
[Optional] Object containing S3 notifications configuration.
Users can configure Lambda functions, SQS queues, and SNS topics as targets 
and S3 notification events, prefix, and suffix filters.
EOF
  type = object({
    events               = list(string)
    filter_prefix        = string
    filter_suffix        = string
    lambda_function_arns = list(string)
    sqs_queue_arns       = list(string)
    sns_topic_arns       = list(string)
  })
  default = {
    events               = ["s3:ObjectCreated:*"]
    filter_prefix        = ""
    filter_suffix        = ""
    lambda_function_arns = []
    sqs_queue_arns       = []
    sns_topic_arns       = []
  }
}

### S3 Static Website Hosting
variable "enable_static_website_hosting" {
  description = "Enable S3 static website hosting? (true/false)"
  type        = bool
  default     = false
}

### Metadata
variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(any)
  default     = {}
}
