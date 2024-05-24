
### Lambda
variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "function_description" {
  description = "Lambda function description"
  type        = string
}

variable "publish" {
  description = <<EOF
Whether to publish creation/change as new Lambda Function Version.
EOF
  type        = bool
  default     = true
}

variable "deploy_package_info" {
  description = <<EOF
Object containing information about the deployment package, which can be
either a absolute path of an existing zip-file containing source code,
an S3 path referencing an existing zip-file in S3,
or a Docker image uri referencing an exiting Docker image hosted in ECR.
EOF
  type = object({
    type      = string
    file_path = optional(string)
    runtime   = optional(string)
    handler   = optional(string)
    s3_bucket = optional(string)
    s3_key    = optional(string)
    image_uri = optional(string)
  })
  validation {
    condition = (
      var.deploy_package_info.type == "file" && var.deploy_package_info.file_path != null 
      && var.deploy_package_info.runtime != null && var.deploy_package_info.handler != null ||
      var.deploy_package_info.type == "s3" && var.deploy_package_info.s3_bucket != null && var.deploy_package_info.s3_key != null 
      && var.deploy_package_info.runtime != null && var.deploy_package_info.handler != null ||
      var.deploy_package_info.type == "docker" && var.deploy_package_info.image_uri != null
    )
    error_message = "For type \"file\", file_path is required. For type \"s3\", s3_bucket and s3_key are required. For type \"docker\", image_uri is required."
  }
}

variable "allowed_actions" {
  description = <<EOF
  List of Lambda actions which are allowed 
  for same account principals for the consumer policy
  EOF
  type        = list(string)
  default = [
    "lambda:GetFunction",
    "lambda:InvokeFunction",
    "lambda:ListVersionsByFunction",
  ]
}

variable "lambda_policy_arns" {
  description = <<EOF
Policy ARNs to be attached to lambda execution role. 
Map key is logical policy name and value is policy ARN. 
e.g {<logical_policy_name>: <policyARN>}
EOF
  type        = map(string)
  default     = {}
}

variable "environment_variables" {
  description = <<EOF
A map that defines environment variables for the Lambda Function.
EOF
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = <<EOF
Map of secret name(as reflected in Secrets Manager) 
and secret JSON string for its value.
EOF
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = <<EOF
Optional VPC config. Provide list of subnet_ids and security_group_ids
EOF
  type = object({
    vpc_subnet_ids         = list(string)
    vpc_security_group_ids = list(string)
  })
  default = {
    vpc_subnet_ids         = []
    vpc_security_group_ids = []
  }
}

### Lambda Performance
variable "reserved_concurrent_executions" {
  description = <<EOF
The amount of reserved concurrent executions for this Lambda Function. 
A value of 0 disables Lambda Function from being triggered and 
-1 removes any concurrency limitations. 
Defaults to Unreserved Concurrency Limits -1.
EOF
  type        = number
  default     = -1
}

variable "timeout" {
  description = <<EOF
The amount of time your Lambda Function has to run in seconds.
EOF
  type        = number
  default     = 10
}

variable "memory" {
  description = <<EOF
Amount of memory(in MB) the Lambda Function can use at runtime. 
A value from 128 MB to 3,008 MB, in 64 MB increments.
EOF
  type        = number
  default     = 128
}

variable "tracing_mode" {
  description = <<EOF
Tracing mode of the Lambda Function. 
Valid value can be either PassThrough or Active.
EOF
  type        = string
  default     = "Active"
}

variable "dead_letter_config_arn" {
  description = <<EOF
(Optional) ARN of an SNS topic or SQS queue to notify when an invocation fails.
EOF
  type        = string
  default     = ""
}

### Metadata
variable "tags" {
  description = <<EOF
[Optional] Custom tags which can be passed on to the AWS resources. 
They should be key value pairs having distinct keys
EOF
  type        = map(string)
  default     = {}
}
