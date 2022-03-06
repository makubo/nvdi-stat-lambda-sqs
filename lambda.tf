# IAM Role for Lambda Function
resource "aws_iam_role" "app_role" {
  name               = var.app_name
  description        = "IAM Role for ${var.app_name}"
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  )
}

# IAM Policy for Lambda Function
resource "aws_iam_policy" "app_policy" {
  name        = var.app_name
  description = "IAM Policy for ${var.app_name}"
  policy      = jsonencode(
    {
      "Version": "2012-10-17",
#      "Id": "sqspolicy",
      "Id": "${var.app_name}_policy",
      "Statement": [
        {
          "Sid": "First",
          "Effect": "Allow",
          "Action": [
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:ReceiveMessage",
            "sqs:SendMessage"
          ]
          "Resource": ["${aws_sqs_queue.input.arn}", "${aws_sqs_queue.result.arn}"]
        },
        {
          "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
          "Resource": "arn:aws:logs:*:*:*",
          "Effect": "Allow"
        }  
      ]
    }
  )
}

# Policy and Role binding
resource "aws_iam_role_policy_attachment" "app_role_policy_attachment" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# Log group
resource "aws_cloudwatch_log_group" "app_log_group" {
 name              = "/aws/lambda/${var.app_name}"
 retention_in_days = 7
}

# Lambda function
resource "aws_lambda_function" "app_lambda" {
  filename         = var.output_path
  function_name    = var.app_name
  role             = aws_iam_role.app_role.arn
  handler          = "logic.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.9"
  timeout          = 300
  environment {
    variables = {
      #SQS variables
      RESULT_QUEUE_URL = aws_sqs_queue.result.id

      #Sentinel hub variables
      SH_INSTANCE_ID = var.SH_INSTANCE_ID
      SH_CLIENT_ID = var.SH_CLIENT_ID
      SH_CLIENT_SECRET = var.SH_CLIENT_SECRET
    }
  }
}
