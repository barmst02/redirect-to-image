# IAM role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

# # IAM policy for Lambda to access S3
# resource "aws_iam_role_policy" "lambda_s3" {
#   name = "${var.project_name}-lambda-s3-policy"
#   role = aws_iam_role.lambda.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:HeadObject"
#         ]
#         Resource = "${aws_s3_bucket.images.arn}/*"
#       }
#     ]
#   })
# }

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Attach AWS managed policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

