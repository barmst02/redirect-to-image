# Lambda function
resource "aws_lambda_function" "image_service" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${var.project_name}-${var.environment}"
  role            = aws_iam_role.lambda.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 512

  environment {
    variables = {
      S3_BUCKET_NAME    = aws_s3_bucket.images.id
      PRESIGNED_URL_TTL = "900"  # 15 minutes
      ALLOWED_ORIGINS   = join(",", var.allowed_origins)
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic,
  ]

  tags = {
    Name        = "${var.project_name}-lambda"
    Environment = var.environment
  }
}

# # Lambda Function URL
# resource "aws_lambda_function_url" "image_service" {
#   function_name      = aws_lambda_function.image_service.function_name
#   authorization_type = "NONE"  # Change to "AWS_IAM" if you want IAM auth

#   cors {
#     allow_credentials = false
#     allow_origins     = var.allowed_origins
#     allow_methods     = ["POST", "HEAD"]
#     allow_headers     = ["authorization", "content-type", "x-api-key"]
#     expose_headers    = ["location"]
#     max_age          = 3600
#   }
# }

