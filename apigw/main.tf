resource "aws_api_gateway_rest_api" "dominion_api_gateway_rest_api" {
  name = "${var.name}-gateway"
}

resource "aws_api_gateway_resource" "dominion_api_gateway" {
  rest_api_id = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
  parent_id   = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "dominion_api_gateway_proxy_method" {
  rest_api_id        = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.dominion_api_gateway.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

#resource "aws_api_gateway_method" "dominion_api_gateway_options_method" {
#  rest_api_id        = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
#  resource_id        = aws_api_gateway_resource.dominion_api_gateway.id
#  http_method        = "OPTIONS"
#  authorization      = "NONE"
#  request_parameters = {
#    "method.request.path.proxy" = true
#  }
#}

resource "aws_api_gateway_integration" "dominion_api_gateway_proxy_integration" {
  rest_api_id        = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.dominion_api_gateway.id
  http_method        = aws_api_gateway_method.dominion_api_gateway_proxy_method.http_method
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
  type                    = "HTTP_PROXY"
  uri                     = "https://${var.aws_alb_dns_name}/{proxy}"
  integration_http_method = "ANY"

  connection_type         = "INTERNET"
}
#
#resource "aws_api_gateway_integration" "dominion_api_gateway_options_integration" {
#  rest_api_id        = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
#  resource_id        = aws_api_gateway_resource.dominion_api_gateway.id
#  http_method        = aws_api_gateway_method.dominion_api_gateway_options_method.http_method
#  request_parameters = {
#    "integration.request.path.proxy" = "method.request.path.proxy"
#  }
#  type                    = "HTTP_PROXY"
#  uri                     = "https://${var.aws_alb_dns_name}:443/{proxy}"
#  integration_http_method = "OPTIONS"
#
#  connection_type         = "INTERNET"
#}

resource "aws_api_gateway_deployment" "dominion_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.dominion_api_gateway_rest_api.id
  stage_name  = var.environment
  depends_on  = [
    aws_api_gateway_method.dominion_api_gateway_proxy_method,
#    aws_api_gateway_method.dominion_api_gateway_options_method,
    aws_api_gateway_integration.dominion_api_gateway_proxy_integration,
#    aws_api_gateway_integration.dominion_api_gateway_options_integration
  ]
  variables   = {
    # just to trigger redeploy on resource changes
    resources = join(", ", [aws_api_gateway_resource.dominion_api_gateway.id])
    # note: redeployment might be required with other gateway changes.
    # when necessary run `terraform taint <this resource's address>`
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "invoke_url" {
  value = "d-jrvm9gwaz5.execute-api.us-east-1.amazonaws.com"
}
