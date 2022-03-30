output "queue_job_id" {
  value = aws_sqs_queue.goobi_job.id
}

output "queue_command_id" {
  value = aws_sqs_queue.goobi_command.id
}

output "dlq_job_id" {
  value = aws_sqs_queue.goobi_job_dlq.id
}

output "queue_command_name" {
  value = aws_sqs_queue.goobi_command.name
}

output "queue_job_name" {
  value = aws_sqs_queue.goobi_job.name
}

output "dlq_job_name" {
  value = aws_sqs_queue.goobi_job_dlq.name
}

output "queue_bagit_job_name" {
  value = aws_sqs_queue.goobi_bagit_job.name
}

output "read_write_policy" {
  description = "Policy that allows reading from and writing the created SQS queues"
  value       = data.aws_iam_policy_document.read_write_queue.json
}
