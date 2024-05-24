### ECR repository
variable "repository_name" {
  description = "Name to give to the ECR repository"
  type        = string
}

variable "repository_force_delete" {
  description = "If set to true, the ECR repository will be deleted even if it contains images"
  type        = bool
  default     = false
}

variable "pull_access_principal_arns" {
  description = "Principals to set to the repository policy to gain Pull access to the repo"
  type        = list(string)
}

variable "push_access_principal_arns" {
  description = "Principals to set to the repository policy to gain Push access to the repo"
  type        = list(string)
}

variable "image_expiry_rule" {
  description = "Set image expiry config to garbage collect old images. Consider pricing, service limits while setting the limit. Set expire_type is by `count` or by `age`."
  type = object({
    expire_type = string # By Age or Count
    count       = number # days count or image count
  })
  validation {
    condition     = contains(["age", "count"], lower(var.image_expiry_rule.expire_type))
    error_message = "Allowed values for image_expiry_rule by \"age\", \"count\"."
  }
}

variable "is_immutable_image" {
  description = "Set to true to enable immutable image. `latest` tag will not work for immutable images, refer AWS documentation and Readme for further details."
  type        = bool
  default     = true
}

### KMS Key
variable "enable_kms_encryption" {
  description = "Set to true to enable KMS encryption for the ECR repository"
  type        = bool
  default     = false
}

### Public Docker Image Pull
variable "public_docker_image" {
  description = "[Optional] The url of the public Docker image to pull from the internet and push to the ECR repository. If empty, the ECR will have no prepopulated image."
  type        = string
  default     = ""
}

### Metadata
variable "tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys"
  type        = map(any)
  default     = {}
}
