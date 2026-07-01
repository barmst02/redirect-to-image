# api_gateway.tf (OPTIONAL - if you want API Gateway instead of Function URL)

# Uncomment this entire file if you prefer API Gateway over Lambda Function URL
# API Gateway gives you more features but is slightly more complex

resource "aws_apigatewayv2_api" "image_service" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = var.allowed_origins
    allow_methods = ["GET", "HEAD", "OPTIONS"]
    allow_headers = ["authorization", "content-type", "x-api-key"]
    expose_headers = ["location"]
    max_age       = 3600
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.image_service.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.image_service.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "images" {
  api_id    = aws_apigatewayv2_api.image_service.id
  route_key = "GET /images/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.image_service.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Name        = "${var.project_name}-api-stage"
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.image_service.execution_arn}/*/*"
}
