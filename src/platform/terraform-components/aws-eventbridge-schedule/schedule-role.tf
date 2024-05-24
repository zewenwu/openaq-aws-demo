
### Schedule role
resource "aws_iam_role" "schedule_role" {
  name               = local.schedule_role_name
  assume_role_policy = data.aws_iam_policy_document.schedule_role.json

  tags = merge({
    Name = local.schedule_role_name
  }, var.tags)
}

data "aws_iam_policy_document" "schedule_role" {
  version = "2012-10-17"

  statement {
    sid = "EventBridgeScheduleRole"

    actions = ["sts:AssumeRole"]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

### Additional policies
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = var.schedule_policy_arns
  role       = aws_iam_role.schedule_role.name
  policy_arn = each.value
}
