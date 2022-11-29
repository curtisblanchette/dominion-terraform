variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "user_groups" {
  description = "the cognito user pool groups"
}

variable "account" {
  description = "the aws account number"
}

variable "app_url" {
  description = "the dominion-ui app URL of this environment"
}

variable "region" {
  description = "aws region"
}
