module "raw_schedule_lambda" {
  source = "../terraform-components/aws-eventbridge-schedule"

  schedule_info = {
    name        = "lambda-raw-schedule"
    state       = "ENABLED"
    description = "This Schedule will trigger the Raw Lambda function."
    start_date  = null
    end_date    = null
  }
  schedule_group_name          = "default"
  schedule_expression          = "rate(5 minutes)"
  schedule_expression_timezone = "UTC"

  schedule_policy_arns = {
    "raw_lambda_policy" = module.raw_lambda.lambda_consumer_policy_arn
  }

  target_info = {
    arn      = module.raw_lambda.lambda_info.arn
    role_arn = module.raw_lambda.lambda_consumer_policy_arn
    input    = {}
  }

  tags = local.tags
}

module "raw_ecr" {
  source = "../terraform-components/aws-ecr"

  repository_name = "lambda-raw"
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

module "raw_lambda" {
  source = "../terraform-components/aws-lambda"

  function_name                  = "lambda-raw"
  function_description           = "This Lambda function will ingest from OpenAQ API data into S3 in the raw zone."
  reserved_concurrent_executions = -1
  timeout                        = 30
  memory                         = 128

  publish = true

  deploy_package_info = {
    type      = "docker"
    image_uri = "${module.raw_ecr.repository_url}:latest"
  }

  allowed_actions = [
    "lambda:GetFunction",
    "lambda:InvokeFunction",
    "lambda:ListVersionsByFunction",
  ]
  lambda_policy_arns = {
    "raw_bucket_consumer" = module.raw_bucket.consumer_policy_arn
  }

  environment_variables = {
    "COUNTRY"              = "BE"
    "S3_BUCKET_NAME"       = module.raw_bucket.bucket_name
    "REGION_NAME"          = data.aws_region.active.name
    API_TOKEN_API_KEY_NAME = "OPENAQ_API_KEY"
  }

  secrets = {
    "OPENAQ_API_KEY" = file(local.openaq_api_key_file_path)
  }

  vpc_config = {
    vpc_subnet_ids         = []
    vpc_security_group_ids = []
  }

  tags = local.tags
}

module "raw_bucket" {
  source = "../terraform-components/aws-s3bucket"

  bucket_name                   = "bucket-raw"
  append_random_suffix          = true
  force_s3_destroy              = true
  versioning_enabled            = false
  server_access_logging_enabled = false

  apply_bucket_policy                    = false
  enable_kms_encryption                  = false
  bucket_kms_allow_additional_principals = []

  folder_names = []

  allowed_actions = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ]

  enable_bucket_notification = true
  bucket_notification_info = {
    events               = ["s3:ObjectCreated:*"]
    filter_prefix        = ""
    filter_suffix        = ""
    lambda_function_arns = [module.clean_lambda.lambda_info.arn]
    sqs_queue_arns       = []
    sns_topic_arns       = []
  }

  tags = local.tags
}
