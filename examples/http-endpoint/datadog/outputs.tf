output "firehose_role" {
  description = "Firehose Role"
  value       = module.firehose.kinesis_firehose_role_arn
}
