output "msk_arn" {
  description = "MSK Topic Endpoint"
  value       = module.msk_cluster.arn
}

output "kinesis_firehose_arn" {
  description = "The ARN of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_arn
}

output "kinesis_data_stream_name" {
  description = "The name of the Kinesis Firehose Stream"
  value       = module.firehose.kinesis_firehose_name
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

output "msk_brokers_endpoint" {
  description = "Brokers endpoints"
  value       = module.msk_cluster.bootstrap_brokers
}

output "topic_name" {
  description = "MSK Topic Name"
  value       = local.topic
}

output "s3_bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.s3.arn
}
