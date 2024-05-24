# Terraform resource to pull a public Docker image and push it to the ECR repository.
resource "null_resource" "docker_pull_push" {
  count = var.public_docker_image != "" ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
      # Pull the public Docker image
      docker pull ${var.public_docker_image}

      # Authenticate to the ECR repository
      aws ecr get-login-password --region ${data.aws_region.active.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.main.repository_url}

      # Tag the Docker image with the ECR repository URL
      docker tag ${var.public_docker_image} ${aws_ecr_repository.main.repository_url}:latest

      # Push the Docker image to the ECR repository
      docker push ${aws_ecr_repository.main.repository_url}:latest
    EOT
  }

  # Trigger the provisioner when the public Docker image variable changes.
  triggers = {
    docker_image = var.public_docker_image
  }
}