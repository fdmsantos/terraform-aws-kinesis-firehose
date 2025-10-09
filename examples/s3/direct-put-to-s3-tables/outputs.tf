output "s3_bucket_arn" {
  value = aws_s3_bucket.backup.arn
}

output "s3_tables_table_name" {
  value = aws_s3tables_table.this.name
}

output "s3_tables_namespace" {
  value = aws_s3tables_namespace.this.namespace
}

output "s3_tables_bucket" {
  value = aws_s3tables_table_bucket.this.name
}