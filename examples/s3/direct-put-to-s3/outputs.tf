output "kinesis_firehose_arn" {
  value = module.firehose.kinesis_firehose_arn
}

output "kinesis_firehose_destination_id" {
  value = module.firehose.kinesis_firehose_destination_id
}

output "kinesis_firehose_version_id" {
  value = module.firehose.kinesis_firehose_version_id
}

output "kinesis_firehose_role_arn" {
  value = module.firehose.kinesis_firehose_role_arn
}
