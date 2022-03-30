resource "aws_cognito_user_pool" "main" {
  name                     = "dominion-${var.environment}"
  auto_verified_attributes = ["email"]

  email_configuration {
    reply_to_email_address = "contact@4iiz.com"
  }

  password_policy {
    minimum_length                   = 12
    temporary_password_validity_days = 30
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
  }
  schema {
    name                     = "workspaceId"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false

    string_attribute_constraints {
      min_length = 0
      max_length = 36 # 36 for "UUID"
    }
  }

}

resource "aws_cognito_user_pool_client" "client" {
  name                = "api"
  user_pool_id        = aws_cognito_user_pool.main.id
  allowed_oauth_flows = [
    "code", "implicit"
  ]
  callback_urls = [
    "https://app2-dev.4iiz.io"
  ]
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30
}

resource "aws_cognito_user_group" "main" {
  count        = length(var.user_groups)
  name         = element(var.user_groups, count.index)
  user_pool_id = aws_cognito_user_pool.main.id
  description  = "Managed by Terraform"
  precedence   = count.index
}

resource "aws_cognito_user" "cognito_system_user" {
  user_pool_id             = aws_cognito_user_pool.main.id
  username                 = "4iiz.system"
  desired_delivery_mediums = ["EMAIL"]
  password                 = "$BeBetter911"

  attributes = {
    phone_number          = "+12507183166"
    phone_number_verified = true
    email                 = "4iiz.system@4iiz.com"
    email_verified        = true
  }
}

resource "aws_cognito_user_in_group" "cognito_system_user_in_group" {
  user_pool_id = aws_cognito_user_pool.main.id
  group_name   = aws_cognito_user_group.main[0].name
  username     = aws_cognito_user.cognito_system_user.username
}
