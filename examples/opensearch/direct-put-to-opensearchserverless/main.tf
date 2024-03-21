locals {
  collection_name = "firehose-es-serverless"
  index_name      = "test"
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-dest-bucket-${random_pet.this.id}"
  force_destroy = true
}

module "opensearch_serverless" {
  source  = "fdmsantos/opensearch-serverless/aws"
  version = "1.0.0"
  name    = local.collection_name
  access_policy_rules = [
    {
      type        = "collection"
      permissions = ["All"]
      principals  = [module.firehose.kinesis_firehose_role_arn]
    },
    {
      type        = "index"
      permissions = ["All"]
      indexes     = ["*"]
      principals  = [module.firehose.kinesis_firehose_role_arn]
    }
  ]
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

module "firehose" {
  source                                    = "../../../"
  name                                      = "${var.name_prefix}-delivery-stream"
  destination                               = "opensearchserverless"
  buffering_interval                        = 60
  opensearchserverless_collection_endpoint  = module.opensearch_serverless.collection_endpoint
  opensearchserverless_collection_arn       = module.opensearch_serverless.collection_arn
  opensearch_vpc_create_service_linked_role = true
  opensearch_index_name                     = local.index_name
  s3_backup_mode                            = "All"
  s3_backup_prefix                          = "backup/"
  s3_backup_bucket_arn                      = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval              = 100
  s3_backup_buffering_size                  = 100
  s3_backup_compression                     = "GZIP"
  s3_backup_enable_encryption               = true
  s3_backup_kms_key_arn                     = aws_kms_key.this.arn
}
