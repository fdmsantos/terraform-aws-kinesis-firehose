data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "this" {
  bucket        = "${var.name_prefix}-dest-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

resource "aws_glue_catalog_database" "this" {
  name = "demo"
}

resource "aws_glue_catalog_table" "this" {
  name          = "demo"
  database_name = aws_glue_catalog_database.this.name
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    format = "parquet"
  }
  open_table_format_input {
    iceberg_input {
      metadata_operation = "CREATE"
      version            = 2
    }
  }
  storage_descriptor {
    location = "s3://${aws_s3_bucket.this.id}"

    columns {
      name = "my_column_1"
      type = "int"
    }
  }
}

module "firehose" {
  source                       = "../../../"
  name                         = "${var.name_prefix}-delivery-stream"
  destination                  = "iceberg"
  s3_bucket_arn                = aws_s3_bucket.this.arn
  buffering_interval           = 30
  buffering_size               = 10
  iceberg_catalog_arn          = "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:catalog"
  iceberg_database_name        = aws_glue_catalog_database.this.name
  iceberg_table_name           = aws_glue_catalog_table.this.name
  s3_backup_mode               = "FailedOnly"
  s3_backup_prefix             = "backup/"
  s3_backup_bucket_arn         = aws_s3_bucket.this.arn
  s3_backup_buffering_interval = 100
  s3_backup_buffering_size     = 100
  s3_backup_compression        = "GZIP"
  s3_backup_enable_encryption  = true
  s3_backup_kms_key_arn        = aws_kms_key.this.arn
}
