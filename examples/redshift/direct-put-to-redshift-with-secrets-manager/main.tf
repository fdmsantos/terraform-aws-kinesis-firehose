data "aws_caller_identity" "current" {}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier  = "${var.name_prefix}-redshift-cluster"
  database_name       = "test"
  master_username     = var.redshift_username
  master_password     = var.redshift_password
  node_type           = "dc2.large"
  cluster_type        = "single-node"
  skip_final_snapshot = true
  #   provisioner "local-exec" {
  #     command = "psql \"postgresql://${self.master_username}:${self.master_password}@${self.endpoint}/${self.database_name}\" -f ./redshift_table.sql"
  #   }
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

module "firehose" {
  source                       = "../../../"
  name                         = "${var.name_prefix}-delivery-stream"
  destination                  = "redshift"
  s3_bucket_arn                = aws_s3_bucket.s3.arn
  buffering_interval           = 60
  redshift_cluster_identifier  = aws_redshift_cluster.this.cluster_identifier
  redshift_cluster_endpoint    = aws_redshift_cluster.this.endpoint
  redshift_database_name       = aws_redshift_cluster.this.database_name
  enable_secrets_manager       = true
  secret_arn                   = module.secrets_manager.secret_arn
  secret_kms_key_arn           = module.secrets_manager.secret_arn
  redshift_table_name          = "firehose_test_table"
  redshift_copy_options        = "json 'auto ignorecase'"
  enable_s3_backup             = true
  s3_backup_prefix             = "backup/"
  s3_backup_bucket_arn         = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval = 100
  s3_backup_buffering_size     = 100
  s3_backup_compression        = "GZIP"
  s3_backup_enable_encryption  = true
  s3_backup_kms_key_arn        = aws_kms_key.this.arn
}


module "secrets_manager" {
  source     = "terraform-aws-modules/secrets-manager/aws"
  version    = "1.1.2"
  kms_key_id = aws_kms_key.this.id

  # Secret
  name_prefix             = "${var.name_prefix}-redshift-secret"
  description             = "Example Secrets Manager secret"
  recovery_window_in_days = 0
  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  secret_string = jsonencode({
    username = var.redshift_username,
    password = var.redshift_password
  })
}
