# outputs.tf
output "s3_bucket_name" {
  description = "Name of the S3 bucket for images"
  value       = aws_s3_bucket.images.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.images.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.image_service.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.image_service.arn
}

# output "lambda_function_url" {
#   description = "URL endpoint for the Lambda function"
#   value       = aws_lambda_function_url.image_service.function_url
# }

# output "lambda_invoke_example" {
#   description = "Example of how to invoke the Lambda"
#   value       = "${aws_lambda_function_url.image_service.function_url}images/your-image.jpg"
# }


output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.image_service.api_endpoint
}
