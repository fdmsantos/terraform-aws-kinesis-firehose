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

resource "aws_opensearchserverless_vpc_endpoint" "vpc_endpoint" {
  name               = "example-vpc-endpoint"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.vpc.private_subnets[0]]
  security_group_ids = [module.security_groups.destination_security_group_id]
}

resource "aws_opensearchserverless_security_policy" "security_policy" {
  name = "os-security-policy"
  type = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource" = [
          "collection/${local.collection_name}"
        ],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = true
  })
}

resource "aws_opensearchserverless_security_policy" "networking" {
  name        = "networking-policy"
  type        = "network"
  description = "Public access"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.collection_name}"
          ]
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [
        aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
      ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${local.collection_name}"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "policy" {
  name        = "data-access-policy"
  type        = "data"
  description = "read and write permissions"
  policy = jsonencode([{
    Rules = [
      {
        ResourceType = "collection",
        Resource = [
          "collection/${local.collection_name}"
        ],
        Permission = [
          "aoss:CreateCollectionItems",
          "aoss:DeleteCollectionItems",
          "aoss:UpdateCollectionItems",
          "aoss:DescribeCollectionItems"
        ]
      },
      {
        ResourceType = "index",
        Resource = [
          "index/${local.collection_name}/${local.index_name}"
        ],
        Permission = [
          "aoss:CreateIndex",
          "aoss:DeleteIndex",
          "aoss:UpdateIndex",
          "aoss:DescribeIndex",
          "aoss:ReadDocument",
          "aoss:WriteDocument"
        ]
      }
    ],
    Principal = [
      module.firehose.kinesis_firehose_role_arn
    ],
    Description = "Data Access Policy"
  }])
}

resource "aws_opensearchserverless_collection" "os" {
  name       = local.collection_name
  depends_on = [aws_opensearchserverless_security_policy.security_policy, aws_opensearchserverless_security_policy.networking]
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
  opensearchserverless_collection_endpoint  = aws_opensearchserverless_collection.os.collection_endpoint
  opensearchserverless_collection_arn       = aws_opensearchserverless_collection.os.arn
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
