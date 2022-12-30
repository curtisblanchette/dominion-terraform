resource "aws_route53domains_registered_domain" "main" {
  domain_name = "curtisblanchette.com"
}

data "aws_route53_zone" "main" {
  name = "curtisblanchette.com"
}

resource "aws_route53_record" "alb_subdomain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "dominion-alb-${var.environment}.curtisblanchette.com"
  type    = "A"

  alias {
    name                   = var.aws_alb_dns_name
    zone_id                = var.aws_alb_zone_id
    evaluate_target_health = true
  }
}

#resource "aws_route53_record" "gateway_alias" {
#  count = terraform.workspace == "default" ? 1 : 0
#  zone_id = aws_route53_zone.main.zone_id
#  name    = "dominion-api.curtisblanchette.com"
#  type    = "A"
#
#  alias {
#    name                   = var.deployment_invoke_url
#    zone_id                = "Z1UJRXOUMOOFQ8" # https://docs.aws.amazon.com/general/latest/gr/apigateway.html
#    evaluate_target_health = true
#  }
#}

resource "aws_route53_record" "ui_subdomain" {
  zone_id = "Z0521237I3C05XVWU5AR"
  name    = "app-${var.environment}.curtisblanchette.com"
  type    = "A"

  alias {
    name = var.cloudfront_domain_name
    zone_id = "Z2FDTNDATAQYW2" # This is always the CloudFront ZoneID (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-route53-aliastarget.html)
    evaluate_target_health = false
  }
}


output "route53_alb_record_uri" {
  value = aws_route53_record.alb_subdomain.records
}

output "route53_ui_record_uri" {
  value = aws_route53_record.ui_subdomain.records
}

output "route53_hosted_zone_id" {
  value = data.aws_route53_zone.main.zone_id
}
