resource "aws_scheduler_schedule" "schedule" {
  name = var.schedule_info.name
  description = var.schedule_info.description
  state = var.schedule_info.state

  start_date = var.schedule_info.start_date
  end_date = var.schedule_info.end_date

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = var.target_info.arn
    role_arn = aws_iam_role.schedule_role.arn
    input = jsonencode(var.target_info.input)
  }
}
