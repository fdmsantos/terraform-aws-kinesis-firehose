locals {
  firehose_role_name  = "${var.name_prefix}-role"
  table_name          = "kinesis_table"
  namespace           = "kinesis_namespace"
  s3Tables_catalog_id = "${data.aws_caller_identity.current.account_id}:s3tablescatalog/${aws_s3tables_table_bucket.this.name}"
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "backup" {
  bucket        = "${var.name_prefix}-backup-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_s3tables_table" "this" {
  name             = local.table_name
  namespace        = aws_s3tables_namespace.this.namespace
  table_bucket_arn = aws_s3tables_namespace.this.table_bucket_arn
  format           = "ICEBERG"
  metadata {
    iceberg {
      schema {
        field {
          name     = "id"
          type     = "int"
          required = true
        }
        field {
          name     = "name"
          type     = "string"
          required = true
        }
        field {
          name     = "value"
          type     = "int"
        }
      }
    }
  }

}

resource "aws_s3tables_namespace" "this" {
  namespace        = local.namespace
  table_bucket_arn = aws_s3tables_table_bucket.this.arn
}

resource "aws_s3tables_table_bucket" "this" {
  name = "${var.name_prefix}-bucket-${random_pet.this.id}"
}

# # Remove when Issue is solved: https://github.com/hashicorp/terraform-provider-aws/issues/40724
resource "null_resource" "create_glue_database" {
  provisioner "local-exec" {
    command = <<EOT
      aws glue create-database \
        --catalog-id ${data.aws_caller_identity.current.account_id} \
        --database-input '{"Name":"s3tables_resource_link","TargetDatabase":{ "CatalogId": "${data.aws_caller_identity.current.account_id}:s3tablescatalog/${aws_s3tables_table_bucket.this.name}", "DatabaseName": "${local.namespace}", "Region": "${data.aws_region.current.name}" }}'
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws glue delete-database --name s3tables_resource_link"
  }

  depends_on = [aws_s3tables_table.this]
}

# Remove when Issue is solved: https://github.com/hashicorp/terraform-provider-aws/issues/40724
# resource "null_resource" "lakeformation_permissions" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws lakeformation grant-permissions \
#         --principal DataLakePrincipalIdentifier="arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.firehose_role_name}" \
#         --permissions ALL \
#         --resource '{
#             "Table": {
#               "CatalogId": "${local.s3Tables_catalog_id}",
#               "DatabaseName": "${local.namespace}",
#               "Name": "${local.table_name}"
#             }
#         }'
#     EOT
#   }

  # provisioner "local-exec" {
  #   when    = destroy
  #   command = <<EOT
  #     aws lakeformation revoke-permissions \
  #       --principal DataLakePrincipalIdentifier="arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.firehose_role_name}" \
  #       --permissions ALL \
  #       --resource '{
  #           "Table": {
  #             "CatalogId": "${local.s3Tables_catalog_id}",
  #             "DatabaseName": "${local.namespace}",
  #             "Name": "${local.table_name}"
  #           }
  #       }'
  #   EOT
  # }

#   depends_on = [aws_s3tables_table.this, aws_iam_role.firehose]
# }

module "firehose" {
  source                   = "../../../"
  name                     = "${var.name_prefix}-delivery-stream"
  destination              = "s3tables"
  create_role              = false
  source_use_existing_role = true
  firehose_role            = aws_iam_role.firehose.arn
  s3_bucket_arn            = aws_s3_bucket.backup.arn
  enable_destination_log   = false
  buffering_interval       = 30
  buffering_size           = 10
  s3_tables_catalog_arn   = "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog"
  s3_tables_database_name = "s3tables_resource_link"
  s3_tables_table_name    = local.table_name
  depends_on = [
    null_resource.create_glue_database,
    aws_iam_role_policy_attachment.all,
    aws_iam_role_policy_attachment.s3
    # null_resource.lakeformation_permissions
  ]
}

##############
# Uncomment when Issue is solved: https://github.com/hashicorp/terraform-provider-aws/issues/40724
##############

# resource "aws_glue_catalog_database" "this" {
#   name = "s3tables_resource_link"
#   catalog_id = data.aws_caller_identity.current.account_id
#   target_database {
#     catalog_id    = "${data.aws_caller_identity.current.account_id}:s3tablescatalog/${aws_s3tables_table_bucket.this.name}"
#     database_name = local.namespace
#   }
# }

# resource "aws_lakeformation_permissions" "this" {
#   permissions = ["ALL"]
#   principal   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.firehose_role_name}"
#
#   table {
#     catalog_id = "${data.aws_caller_identity.current.account_id}:s3tablescatalog/${aws_s3tables_table_bucket.this.name}"
#     database_name = local.namespace
#     name          = local.table_name
#   }
# }

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-integrating-firehose.html#firehose-role-s3tables