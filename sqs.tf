# SQS input queue
resource "aws_sqs_queue" "input" {
  name                        = "${var.app_name}_input.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 360
}

# SQS Lambda trigger
resource "aws_lambda_event_source_mapping" "input" {
  event_source_arn = aws_sqs_queue.input.arn
  function_name    = aws_lambda_function.app_lambda.arn
}

# SQS result queue
resource "aws_sqs_queue" "result" {
  name = "${var.app_name}_result" #.fifo"
}
