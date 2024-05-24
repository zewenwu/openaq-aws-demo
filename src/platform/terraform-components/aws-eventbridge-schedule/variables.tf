### Schedule
variable "schedule_info" {
  description = <<EOF
[Required] Object containing Schedule name and description.
EOF
  type = object({
    name        = string
    state       = string
    description = string
    start_date  = string
    end_date    = string
  })
}

variable "schedule_group_name" {
  description = <<EOF
The name of the schedule group. This is used to group schedules together.
EOF
  type        = string
}

variable "schedule_expression" {
  description = <<EOF
The schedule expression, which can be a rate-based, 
cron-based, or one-time expression.
EOF
  type        = string
  default     = "cron(0 0 * * ? *)" # Run daily at midnight
}

variable "schedule_expression_timezone" {
  description = "The timezone for the schedule expression."
  type        = string
  default     = "UTC"
}

variable "schedule_policy_arns" {
  description = <<EOF
Policy ARNs to be attached to schedule execution role 
that will be invoked for its target.
Map key is logical policy name and value is policy ARN. 
e.g {<logical_policy_name>: <policyARN>}
EOF
  type        = map(string)
  default     = {}
}

### Schedule Target
variable "target_info" {
  description = <<EOF
[Required] Object containing Target Arn, and an universal input.
EOF
  type = object({
    arn      = string
    input    = map(string)
  })
}

### Metadata
variable "tags" {
  description = "Tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(string)
  default     = {}
}

