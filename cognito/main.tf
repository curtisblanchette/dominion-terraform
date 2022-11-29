resource "aws_cognito_user_pool" "main" {
  name                     = "dominion-${var.environment}"
  auto_verified_attributes = ["email"]

  mfa_configuration = "OPTIONAL"
  sms_authentication_message = "Your one-time passcode is {####}"

  sms_configuration {
    external_id = "cognito_sms"
    sns_caller_arn = aws_iam_role.cognito_sns_role.arn
  }

  email_configuration {
    reply_to_email_address = "contact@4iiz.com"
  }

  username_attributes = ["email"]

  username_configuration {
    case_sensitive = false
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

  schema {
    name                     = "userId"
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
  name                = "app"
  user_pool_id        = aws_cognito_user_pool.main.id
  allowed_oauth_flows = [
    "code", "implicit"
  ]
  callback_urls = [
    var.app_url
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
  username                 = "4iiz.system@4iiz.com"
  desired_delivery_mediums = ["EMAIL"]
  password                 = "$BeBetter911"

  attributes = {
    phone_number          = "+12507183166"
    phone_number_verified = true
    email                 = "4iiz.system@4iiz.com"
    email_verified        = true
  }
}

resource "aws_iam_role" "cognito_sns_role" {
  name = "${var.name}-cognito-sns-role-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "cognito-idp.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name        = "${var.name}-cognito-sns-role-policy-${var.environment}"
  description = "Policy that allows access to SNS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cognito-sns-role-policy-attachment" {
  role       = aws_iam_role.cognito_sns_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}

resource "aws_cognito_user_in_group" "cognito_system_user_in_group" {
  user_pool_id = aws_cognito_user_pool.main.id
  group_name   = aws_cognito_user_group.main[0].name
  username     = aws_cognito_user.cognito_system_user.username
}
