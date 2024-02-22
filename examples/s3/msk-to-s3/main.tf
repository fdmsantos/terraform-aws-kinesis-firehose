data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "~> 5.0"
  name                         = "${var.name_prefix}-vpc"
  cidr                         = local.vpc_cidr
  azs                          = local.azs
  public_subnets               = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets              = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets             = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name_prefix}-sg"
  description = "Security group for ${var.name_prefix}-sg"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  ingress_rules = [
    "kafka-broker-tcp",
    "kafka-broker-tls-tcp"
  ]
}

module "msk_cluster" {
  source                      = "terraform-aws-modules/msk-kafka-cluster/aws"
  version                     = "2.3.0"
  name                        = "${var.name_prefix}-msk"
  kafka_version               = "3.4.0"
  number_of_broker_nodes      = 2
  broker_node_client_subnets  = module.vpc.public_subnets
  broker_node_instance_type   = "kafka.m5.large"
  broker_node_security_groups = [module.security_group.security_group_id]
  broker_node_connectivity_info = {
    public_access = {
      #      type = "SERVICE_PROVIDED_EIPS"
      type = "DISABLED"
    }
    vpc_connectivity = {
      client_authentication = {
        tls = false
        sasl = {
          iam   = true
          scram = false
        }
      }
    }
  }
  client_authentication = {
    sasl = { iam = true }
  }
  enable_storage_autoscaling  = false
  create_cloudwatch_log_group = false
  cloudwatch_logs_enabled     = false
  s3_logs_enabled             = false
  configuration_name          = "${var.name_prefix}-msk-configuration"
  configuration_description   = "${var.name_prefix} MSK configuration"
  configuration_server_properties = {
    "allow.everyone.if.no.acl.found" = false
  }
}

resource "aws_msk_cluster_policy" "this" {
  cluster_arn = module.msk_cluster.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "FirehoseMskClusterPolicy"
      Effect = "Allow"
      Principal = {
        "Service" = "firehose.amazonaws.com"
      }
      Action = [
        "kafka:Describe*",
        "kafka:Get*",
        "kafka:CreateVpcConnection",
        "kafka:GetBootstrapBrokers",
      ]
      Resource = module.msk_cluster.arn
    }]
  })
}

module "firehose" {
  source                 = "../../../"
  name                   = "${var.name_prefix}-delivery-stream"
  input_source           = "msk"
  msk_source_cluster_arn = module.msk_cluster.arn
  msk_source_topic_name  = "test"
  destination            = "s3"
  s3_bucket_arn          = aws_s3_bucket.s3.arn
}
