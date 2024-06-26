output "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_arn
}

output "kinesis_firehose_destination_id" {
  description = "The Destination id of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_destination_id
}

output "kinesis_firehose_role_arn" {
  description = "The ARN of the IAM role created for Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_role_arn
}
