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

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "${var.name_prefix}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
}

module "security_groups" {
  source                                 = "../../../"
  name                                   = "${var.name_prefix}-delivery-stream"
  destination                            = "opensearchserverless"
  create                                 = false
  vpc_create_security_group              = true
  vpc_create_destination_security_group  = true
  vpc_security_group_same_as_destination = false
  vpc_security_group_destination_vpc_id  = module.vpc.vpc_id
}

module "opensearch_serverless" {
  source                  = "fdmsantos/opensearch-serverless/aws"
  version                 = "1.0.0"
  name                    = local.collection_name
  network_policy_type     = "PrivateCollectionPublicDashboard"
  vpce_vpc_id             = module.vpc.vpc_id
  vpce_subnet_ids         = [module.vpc.private_subnets[0]]
  vpce_security_group_ids = [module.security_groups.destination_security_group_id]
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
  enable_vpc                                = true
  vpc_subnet_ids                            = module.vpc.private_subnets
  vpc_security_group_firehose_ids           = [module.security_groups.firehose_security_group_id]
  s3_backup_mode                            = "All"
  s3_backup_prefix                          = "backup/"
  s3_backup_bucket_arn                      = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval              = 100
  s3_backup_buffering_size                  = 100
  s3_backup_compression                     = "GZIP"
  s3_backup_enable_encryption               = true
  s3_backup_kms_key_arn                     = aws_kms_key.this.arn
}
