output "firehose_role" {
  description = "Firehose Role"
  value       = module.firehose.kinesis_firehose_role_arn
}

output "destination_security_group_rule_ids" {
  description = "Security Group Rules ID created in Destination Security group"
  value       = module.firehose.destination_security_group_rule_ids
}

output "firehose_cidr_blocks" {
  description = "Firehose stream cidr blocks to unblock on destination security group"
  value       = module.firehose.firehose_cidr_blocks
}
