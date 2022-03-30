variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "certificate_arn" {
  description = "the arn of our 4iiz.io certificate"
}

variable "s3_bucket_dns_name" {
  description = "the dns name of the s3 bucket"
}



data "aws_region" "current" {}
