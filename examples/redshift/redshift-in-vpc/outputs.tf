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

output "kinesis_firehose_role_arn" {
  description = "The ARN of the IAM role created for Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_role_arn
}

output "security_group_id" {
  description = "Security Group ID created for Destination"
  value       = module.security_groups.destination_security_group_id
}

output "firehose_cidr_blocks" {
  description = "CIDR Blocks used by Firehose Delivery Stream"
  value       = module.security_groups.firehose_cidr_blocks
}
