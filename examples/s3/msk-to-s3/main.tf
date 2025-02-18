data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  topic    = "demo-topic"
}

resource "random_pet" "this" {
  length = 2
}

### S3 Bucket ###
resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

### Networking ###
module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "~> 5.0"
  name                         = "${var.name_prefix}-vpc"
  cidr                         = local.vpc_cidr
  azs                          = local.azs
  public_subnets               = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  create_database_subnet_group = false
  enable_nat_gateway           = false
  single_nat_gateway           = false
}

module "security_group" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 5.0"
  name                = "${var.name_prefix}-sg"
  description         = "Security group for ${var.name_prefix}-sg"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "all-all"
  ]
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

### MSK ###
module "ec2" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = "test-instance"
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  create_iam_instance_profile = true
  create_eip                  = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AdministratorAccess          = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  depends_on = [
    module.msk_cluster
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
  create_cloudwatch_log_group = true
  cloudwatch_logs_enabled     = true
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
        "kafka:CreateVpcConnection",
        "kafka:GetBootstrapBrokers",
        "kafka:DescribeCluster",
        "kafka:DescribeClusterV2"
      ]
      Resource = module.msk_cluster.arn
    }]
  })
}

module "firehose" {
  source                       = "../../../"
  name                         = "${var.name_prefix}-delivery-stream"
  input_source                 = "msk"
  msk_source_cluster_arn       = module.msk_cluster.arn
  msk_source_connectivity_type = "PRIVATE"
  msk_source_topic_name        = local.topic
  destination                  = "s3"
  s3_bucket_arn                = aws_s3_bucket.s3.arn
  buffering_interval           = 10
  depends_on = [
    aws_msk_cluster_policy.this
  ]
}
