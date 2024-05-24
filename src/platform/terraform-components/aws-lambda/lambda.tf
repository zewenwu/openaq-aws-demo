resource "aws_lambda_function" "function" {
  description                    = var.function_description
  function_name                  = var.function_name
  role                           = aws_iam_role.lambda_exec.arn
  runtime                        = (var.deploy_package_info.type == "file" || var.deploy_package_info.type == "s3") ? var.deploy_package_info.runtime : null
  reserved_concurrent_executions = var.reserved_concurrent_executions
  handler                        = (var.deploy_package_info.type == "file" || var.deploy_package_info.type == "s3") ? var.deploy_package_info.handler : null
  publish                        = var.publish
  timeout                        = var.timeout
  memory_size                    = var.memory

  package_type = (var.deploy_package_info.type == "file" || var.deploy_package_info.type == "s3") ? "Zip" : "Image"
  filename     = var.deploy_package_info.type == "file" ? var.deploy_package_info.file_path : null
  image_uri    = var.deploy_package_info.type == "docker" ? var.deploy_package_info.image_uri : null
  s3_bucket    = var.deploy_package_info.type == "s3" ? var.deploy_package_info.s3_bucket : null
  s3_key       = var.deploy_package_info.type == "s3" ? var.deploy_package_info.s3_key : null

  dynamic "environment" {
    for_each = length(keys(local.environment_variables)) == 0 ? [] : [true]
    content {
      variables = local.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_config.vpc_subnet_ids) == 0 ? [] : [true]
    content {
      security_group_ids = var.vpc_config.vpc_security_group_ids
      subnet_ids         = var.vpc_config.vpc_subnet_ids
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode == null ? [] : [true]
    content {
      mode = var.tracing_mode
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config_arn == "" ? [] : [true]
    content {
      target_arn = var.dead_letter_config_arn
    }
  }

  tags = merge({
    Name = var.function_name
  }, var.tags)
}
