output "firehose_role" {
  description = "Firehose Role"
  value       = module.firehose.kinesis_firehose_role_arn
}

output "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_arn
}

output "kinesis_firehose_destination_id" {
  description = "The Destination id of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_destination_id
}

output "kinesis_firehose_version_id" {
  description = "The Version id of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_version_id
}
