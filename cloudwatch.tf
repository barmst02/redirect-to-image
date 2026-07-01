# CloudWatch metric alarm for Lambda errors (optional)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "Errors"
  namespace          = "AWS/Lambda"
  period             = 300
  statistic          = "Sum"
  threshold          = 5
  alarm_description  = "This metric monitors lambda errors"
  treat_missing_data = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.image_service.function_name
  }

  tags = {
    Name        = "${var.project_name}-error-alarm"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  }
}
