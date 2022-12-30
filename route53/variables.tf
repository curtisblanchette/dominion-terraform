variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}
#
#variable "hosted_zone_id" {
#  description = "the id of the hosted zone for dns."
#}

variable "aws_alb_dns_name" {
  description = "then dns name of your alb."
}

#variable "route53_alb_record_uri" {
#  description = "the cname of the alb"
#}
#
#variable "route53_ui_record_uri" {
#  description = "the cname of the ui"
#}

variable "aws_alb_zone_id" {
  description = "the hosted zone id for dns"
}

#variable "deployment_invoke_url" {
#  description = "the api gateway stage invoke url"
#}

variable "cloudfront_domain_name" {
  description = "the domain name of the cloudfront distribution"
}
