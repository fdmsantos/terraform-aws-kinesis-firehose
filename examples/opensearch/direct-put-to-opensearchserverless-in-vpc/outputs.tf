output "os_domain" {
  description = "Opensearch Serverless Collection Endpoint"
  value       = aws_opensearchserverless_collection.os.collection_endpoint
}
