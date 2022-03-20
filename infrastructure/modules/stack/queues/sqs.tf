resource "aws_sqs_queue" "goobi_job" {
  name = "${var.name}_goobi_job.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 300
  delay_seconds               = 5
  redrive_policy = jsonencode(
    {
      deadLetterTargetArn = aws_sqs_queue.goobi_job_dlq.arn,
      maxReceiveCount     = 5
    }
  )
}
resource "aws_sqs_queue" "goobi_job_dlq" {
  name = "${var.name}_goobi_job_dlq.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 60
}
resource "aws_sqs_queue" "goobi_command" {
  name = "${var.name}_goobi_command.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 60
}
resource "aws_sqs_queue" "goobi_bagit_job" {
  name = "${var.name}_goobi_bagit_job.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  visibility_timeout_seconds  = 300
  delay_seconds               = 5
  redrive_policy = jsonencode(
    {
      deadLetterTargetArn = aws_sqs_queue.goobi_job_dlq.arn,
      maxReceiveCount     = 5
    }
  )
}
