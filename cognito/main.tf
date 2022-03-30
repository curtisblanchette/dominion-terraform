#resource "aws_cognito_user_pool" "main" {
#  name                     = "dominion-${var.environment}"
#  auto_verified_attributes = ["email"]
#}
#
#resource "aws_cognito_identity_provider" "example_provider" {
#  user_pool_id  = aws_cognito_user_pool.main.id
#  provider_name = "Google"
#  provider_type = "Google"
#
#  provider_details = {
#    authorize_scopes = "email"
#    client_id        = "your client_id"
#    client_secret    = "your client_secret"
#  }
#
#  attribute_mapping = {
#    email    = "email"
#    username = "sub"
#  }
#}
#
#resource "aws_cognito_user" "cognito_administrator_user" {
#  user_pool_id = aws_cognito_user_pool.main.id
#  username     = "4iiz.administrator"
#  groups       = []
#
#  attributes = {
#    terraform             = true
#    phone_number          = "+12507183166"
#    phone_number_verified = true
#    email                 = "4iiz.admin@4iiz.com"
#    email_verified        = true
#  }
#}
