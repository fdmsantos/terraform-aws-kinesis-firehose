output "es_domain" {
  description = "Opensearch Domain"
  value       = aws_opensearch_domain.this.domain_name
}

output "es_endpoint" {
  description = "Opensearch Endpoint"
  value       = aws_opensearch_domain.this.endpoint
}

output "firehose_role" {
  description = "Firehose Role"
  value       = module.firehose.kinesis_firehose_role_arn
}

output "dashboard_endpoint" {
  description = "Kibana Endpoint"
  value       = aws_opensearch_domain.this.dashboard_endpoint
}
