data "aws_availability_zones" "available" {}

locals {
  vpc_cidr  = "10.0.0.0/16"
  azs       = slice(data.aws_availability_zones.available.names, 0, 2)
  topic     = "demo-topic"
  topic_arn = "arn:aws:kafka:${data.aws_region.current.name}:${var.msk_aws_account_id}:topic/${var.name_prefix}-msk/${module.msk_cluster.cluster_uuid}/*"
  group_arn = "arn:aws:kafka:${data.aws_region.current.name}:${var.msk_aws_account_id}:group/${var.name_prefix}-msk/${module.msk_cluster.cluster_uuid}/*"
}

resource "random_pet" "this" {
  length = 2
}

data "aws_region" "current" {}

### S3 Bucket ###
resource "aws_s3_bucket" "s3" {
  provider      = aws.account2
  bucket        = "${var.name_prefix}-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "this" {
  provider = aws.account2
  bucket   = aws_s3_bucket.s3.id
  policy   = data.aws_iam_policy_document.cross_account_s3.json
}

data "aws_iam_policy_document" "cross_account_s3" {
  version = "2012-10-17"
  statement {
    sid    = "Cross Account Access"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose.arn]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.s3.arn,
      "${aws_s3_bucket.s3.arn}/*"
    ]
  }
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
  providers = {
    aws = aws.account2
  }
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
  providers = {
    aws = aws.account2
  }
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
  providers = {
    aws = aws.account2
  }
}

module "msk_cluster" {
  source                      = "terraform-aws-modules/msk-kafka-cluster/aws"
  version                     = "2.11.0"
  name                        = "${var.name_prefix}-msk"
  kafka_version               = "3.4.0"
  number_of_broker_nodes      = 2
  broker_node_client_subnets  = module.vpc.public_subnets
  broker_node_instance_type   = "kafka.m5.large"
  broker_node_security_groups = [module.security_group.security_group_id]
  broker_node_connectivity_info = {
    public_access = {
      #type = "SERVICE_PROVIDED_EIPS"
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
  providers = {
    aws = aws.account2
  }
}

resource "aws_msk_cluster_policy" "this" {
  provider    = aws.account2
  cluster_arn = module.msk_cluster.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow"
      Principal = {
        "AWS" = aws_iam_role.firehose.arn
      }
      Action = [
        "kafka:GetBootstrapBrokers",
        "kafka:DescribeCluster",
        "kafka:DescribeClusterV2",
        "kafka-cluster:Connect"
      ]
      Resource = module.msk_cluster.arn
      },
      {
        Effect = "Allow"
        Principal = {
          "AWS" = aws_iam_role.firehose.arn
        }
        Action = [
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:DescribeTopicDynamicConfiguration",
          "kafka-cluster:ReadData"
        ]
        Resource = [
          local.topic_arn
        ]
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::233450236687:role/mskaasTestDeliveryRole"
        },
        "Action" : "kafka-cluster:DescribeGroup",
        Resource = [
          local.group_arn
        ]
      }
    ]
  })
}

### Firehose ###
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com"
      ]
    }
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "${var.name_prefix}-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "msk" {
  statement {
    effect = "Allow"
    actions = [
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka-cluster:Connect"
    ]
    resources = [module.msk_cluster.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:DescribeTopicDynamicConfiguration",
      "kafka-cluster:ReadData"
    ]
    resources = [
      local.topic_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka-cluster:DescribeGroup"
    ]
    resources = [
      local.group_arn
    ]
  }
}

resource "aws_iam_policy" "msk" {
  name   = "${var.name_prefix}-msk"
  policy = data.aws_iam_policy_document.msk.json
}

resource "aws_iam_role_policy_attachment" "msk" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.msk.arn
}

module "firehose" {
  source                   = "../../../"
  name                     = "${var.name_prefix}-delivery-stream"
  input_source             = "msk"
  create_role              = false
  source_use_existing_role = true
  firehose_role            = aws_iam_role.firehose.arn
  msk_source_cluster_arn   = module.msk_cluster.arn
  msk_source_topic_name    = local.topic
  destination              = "s3"
  s3_bucket_arn            = aws_s3_bucket.s3.arn
  s3_cross_account         = true
  buffering_interval       = 100
  depends_on = [
    aws_msk_cluster_policy.this,
    aws_iam_role_policy_attachment.msk
  ]
}
