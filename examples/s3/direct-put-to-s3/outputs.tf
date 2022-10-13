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

output "application_role_arn" {
  description = "The ARN of the IAM application role created for Kinesis Firehose Stream Source"
  value       = module.firehose.application_role_arn
}

output "application_role_name" {
  description = "The Name of the IAM application role created for Kinesis Firehose Stream Source"
  value       = module.firehose.application_role_name
}

output "application_role_policy_arn" {
  description = "The ARN of the IAM application role created for Kinesis Firehose Stream Source"
  value       = module.firehose.application_role_policy_arn
}

output "application_role_policy_name" {
  description = "The Name of the IAM application role created for Kinesis Firehose Stream Source"
  value       = module.firehose.application_role_policy_name
}
