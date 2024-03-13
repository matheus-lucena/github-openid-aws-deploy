provider "aws" {
  region = "us-east-1" # Substitua pela região desejada
}

resource "aws_api_gateway_rest_api" "main" {
  name = var.name
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.main.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.stage
}

resource "aws_api_gateway_resource" "ping_resource" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "ping"
}

resource "aws_api_gateway_method" "ping_method" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.ping_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ping_integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.ping_resource.id
  http_method = aws_api_gateway_method.ping_method.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_integration_response" "ping_integration_response" {
  depends_on  = [aws_api_gateway_integration.ping_integration]
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.ping_resource.id
  http_method = aws_api_gateway_method.ping_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = jsonencode({
      message = "pong"
    })
  }
}

resource "aws_api_gateway_method_response" "ping_method_response" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.ping_resource.id
  http_method = aws_api_gateway_method.ping_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}
