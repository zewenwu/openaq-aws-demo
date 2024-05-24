resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_count" {
  count = lower(var.image_expiry_rule.expire_type) == "count" ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep until ${var.image_expiry_rule.count} images",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "imageCountMoreThan",
            "countNumber" : var.image_expiry_rule.count
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
  })
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_age" {
  count = lower(var.image_expiry_rule.expire_type) == "age" ? 1 : 0
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep until ${var.image_expiry_rule.count} days",
          "selection" : {
            "tagStatus" : "any",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : var.image_expiry_rule.count
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
  })
}