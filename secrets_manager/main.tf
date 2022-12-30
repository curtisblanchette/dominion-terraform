resource "aws_secretsmanager_secret" "main" {
  name = var.environment
}

variable "secret" {
  default = {
    "credentials.system.password" = "I!7UJ$lPYB2$"
    "services.postgres.password" = "R!d30rd!3"
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "current" {
  depends_on = [aws_secretsmanager_secret.main]
  secret_id = aws_secretsmanager_secret.main.id

  secret_string = jsonencode(var.secret)
}

output "secret_string" {
  depends_on = [aws_secretsmanager_secret_version.current]
  value = aws_secretsmanager_secret_version.current.secret_string
}
