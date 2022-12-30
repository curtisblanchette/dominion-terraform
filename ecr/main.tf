resource "aws_ecr_repository" "main" {
  count = terraform.workspace == "default" ? 1 : 0
  name                 = "${var.name}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  count = terraform.workspace == "default" ? 1 : 0
  repository = aws_ecr_repository.main[count.index].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action       = {
        type = "expire"
      }
      selection     = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

output "aws_ecr_repository_url" {
    value = length(aws_ecr_repository.main) > 0 ? aws_ecr_repository.main[*].repository_url : null
}

# TODO add ability to get latest docker container image from source (github build artifact maybe?)
# https://stackoverflow.com/questions/68658353/push-docker-image-to-ecr-using-terraform
