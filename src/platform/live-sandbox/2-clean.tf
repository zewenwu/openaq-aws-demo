module "clean_ecr" {
  source = "../terraform-components/aws-ecr"

  repository_name         = "lambda-clean"
  repository_force_delete = true

  pull_access_principal_arns = []
  push_access_principal_arns = []

  image_expiry_rule = {
    expire_type = "count"
    count       = 10
  }

  is_immutable_image    = false
  enable_kms_encryption = false
  public_docker_image   = "public.ecr.aws/lambda/python:3.12"

  tags = local.tags
}

module "clean_lambda" {
  source = "../terraform-components/aws-lambda"

  function_name                  = "lambda-clean"
  function_description           = "This Lambda function will ingest data from the raw S3 bucket into the clean DynamoDB table."
  reserved_concurrent_executions = -1
  timeout                        = 30
  memory                         = 128

  publish = true

  deploy_package_info = {
    type      = "docker"
    image_uri = "${module.clean_ecr.repository_url}:latest"
  }

  allowed_actions = [
    "lambda:GetFunction",
    "lambda:InvokeFunction",
    "lambda:ListVersionsByFunction",
  ]
  lambda_policy_arns = {
    "raw_bucket_consumer"  = module.raw_bucket.consumer_policy_arn
    "clean_table_consumer" = module.clean_table.consumer_policy_arn
  }

  environment_variables = {
    "DYNAMODB_TABLE_NAME" = module.clean_table.table_name
    "REGION_NAME"         = data.aws_region.active.name
  }

  secrets = {}

  vpc_config = {
    vpc_subnet_ids         = []
    vpc_security_group_ids = []
  }

  tags = local.tags
}

module "clean_table" {
  source = "../terraform-components/aws-dynamodb"

  table_name = "table-clean"
  billing_mode_info = {
    mode           = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 10
  }

  allowed_actions = [
    "dynamodb:PutItem",
    "dynamodb:GetItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:Scan",
    "dynamodb:Query"
  ]

  deletion_protection_enabled = false

  hash_key_info = {
    name = "location"
    type = "S"
  }
  range_key_info = {
    name = "lastUpdated"
    type = "S"
  }
  ttl_attribute_name = "expireAt"

  apply_table_policy                    = false
  full_override_table_policy_document   = "{}"
  enable_kms_encryption                 = false
  table_kms_allow_additional_principals = []

  tags = local.tags
}
