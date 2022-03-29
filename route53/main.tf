resource "aws_route53_record" "subdomain" {
  zone_id = var.hosted_zone_id
  name    = "dominion-alb-${var.environment}.4iiz.io"
  type    = "A"

  alias {
    name                   = var.aws_alb_dns_name
    zone_id                = var.aws_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gateway_alias" {
  zone_id = var.hosted_zone_id
  name    = "dominion-api.4iiz.io"
  type    = "A"

  alias {
    name                   = var.deployment_invoke_url
    zone_id                = "Z1UJRXOUMOOFQ8" # https://docs.aws.amazon.com/general/latest/gr/apigateway.html
    evaluate_target_health = true
  }
}

output "aws_route53_record_uri" {
  value = aws_route53_record.subdomain.records
}
