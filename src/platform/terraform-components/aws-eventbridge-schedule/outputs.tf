output "schedule_info" {
  description = "The name and ARN of the schedule."
  value = {
    name = aws_scheduler_schedule.schedule.name
    arn  = aws_scheduler_schedule.schedule.arn
  }
}

output "schedule_execution_role_arn" {
  description = "The ARN of the Lambda Consumer Policy."
  value = aws_iam_role.schedule_role.arn
}
