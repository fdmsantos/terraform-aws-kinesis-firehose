resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_opensearch_domain" "this" {
  domain_name    = "firehose-es-cluster"
  engine_version = "Elasticsearch_7.10"
  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.es_username
      master_user_password = var.es_password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name = aws_opensearch_domain.this.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
              "AWS": "*"
            },
            "Effect": "Allow",
            "Resource": "${aws_opensearch_domain.this.arn}/*"
        }
    ]
}
POLICIES
}

module "firehose" {
  source                      = "../../../"
  name                        = "${var.name_prefix}-delivery-stream"
  destination                 = "opensearch"
  buffer_interval             = 60
  elasticsearch_domain_arn    = aws_opensearch_domain.this.arn
  elasticsearch_index_name    = "test"
  s3_backup_mode              = "All"
  s3_backup_prefix            = "backup/"
  s3_backup_bucket_arn        = aws_s3_bucket.s3.arn
  s3_backup_buffer_interval   = 100
  s3_backup_buffer_size       = 100
  s3_backup_compression       = "GZIP"
  s3_backup_enable_encryption = true
  s3_backup_kms_key_arn       = aws_kms_key.this.arn
}
