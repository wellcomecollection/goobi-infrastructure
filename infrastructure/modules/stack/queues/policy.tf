data "aws_iam_policy_document" "read_write_queue" {

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:ChangeMessageVisibility"
    ]

    resources = [
      aws_sqs_queue.goobi_job.arn,
      aws_sqs_queue.goobi_command.arn,
      aws_sqs_queue.goobi_job_dlq.arn,
      aws_sqs_queue.goobi_bagit_job.arn
    ]
  }

}
