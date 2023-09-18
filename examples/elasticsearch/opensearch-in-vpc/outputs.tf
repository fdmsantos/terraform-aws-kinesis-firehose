output "firehose_role" {
  description = "Firehose Role"
  value       = module.firehose.kinesis_firehose_role_arn
}

output "firehose_security_group" {
  description = "Firehose Security Group"
  value       = module.security_groups.firehose_security_group_id
}

output "destination_security_group" {
  description = "Destination Security Group"
  value       = module.security_groups.destination_security_group_id
}

output "es_domain" {
  description = "Opensearch Domain"
  value       = aws_opensearch_domain.this.domain_name
}

output "es_endpoint" {
  description = "Opensearch Endpoint"
  value       = aws_opensearch_domain.this.endpoint
}

output "dashboard_endpoint" {
  description = "Kibana Endpoint"
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "opensearch_iam_service_linked_role_arn" {
  description = "AWS Opensearch iam Service Linked Role"
  value       = module.firehose.opensearch_iam_service_linked_role_arn
}
