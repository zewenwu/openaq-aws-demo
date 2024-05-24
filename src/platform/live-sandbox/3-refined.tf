module "refined_schedule_lambda" {
  source = "../terraform-components/aws-eventbridge-schedule"

  schedule_info = {
    name        = "lambda-refined-schedule"
    state       = "ENABLED"
    description = "This Schedule will trigger the Refined Lambda function."
    start_date  = null
    end_date    = null
  }
  schedule_group_name          = "default"
  schedule_expression          = "rate(10 minutes)"
  schedule_expression_timezone = "UTC"

  schedule_policy_arns = {
    "refined_lambda_policy" = module.refined_lambda.lambda_consumer_policy_arn
  }

  target_info = {
    arn      = module.refined_lambda.lambda_info.arn
    role_arn = module.refined_lambda.lambda_consumer_policy_arn
    input    = {}
  }

  tags = local.tags
}

module "refined_ecr" {
  source = "../terraform-components/aws-ecr"

  repository_name         = "lambda-refined"
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

module "refined_lambda" {
  source = "../terraform-components/aws-lambda"

  function_name                  = "lambda-refined"
  function_description           = "This Lambda function will ingest data from the clean DynamoDB table to the refined S3 bucket."
  reserved_concurrent_executions = -1
  timeout                        = 60
  memory                         = 640

  publish = true

  deploy_package_info = {
    type      = "docker"
    image_uri = "${module.refined_ecr.repository_url}:latest"
  }

  allowed_actions = [
    "lambda:GetFunction",
    "lambda:InvokeFunction",
    "lambda:ListVersionsByFunction",
  ]
  lambda_policy_arns = {
    "clean_table_consumer"    = module.clean_table.consumer_policy_arn
    "refined_bucket_consumer" = module.refined_bucket.consumer_policy_arn
  }

  environment_variables = {
    "DYNAMODB_TABLE_NAME" = module.clean_table.table_name
    "S3_BUCKET_NAME"      = module.refined_bucket.bucket_name
    "REGION_NAME"         = data.aws_region.active.name
    "QUERY_HOURS"         = "12"
  }

  secrets = {}

  vpc_config = {
    vpc_subnet_ids         = []
    vpc_security_group_ids = []
  }

  tags = local.tags
}

module "refined_bucket" {
  source = "../terraform-components/aws-s3bucket"

  bucket_name                   = "bucket-refined"
  append_random_suffix          = true
  force_s3_destroy              = true
  versioning_enabled            = true
  server_access_logging_enabled = false

  apply_bucket_policy                    = true
  enable_kms_encryption                  = false
  bucket_kms_allow_additional_principals = []

  folder_names = []

  allowed_actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]

  enable_static_website_hosting = true

  tags = local.tags
}
