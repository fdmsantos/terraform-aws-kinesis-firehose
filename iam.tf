locals {
  role_name                 = var.create_role ? coalesce(var.role_name, var.name, "*") : null
  add_backup_policies       = var.enable_s3_backup && var.s3_backup_use_existing_role
  add_kinesis_source_policy = var.create_role && var.enable_kinesis_source && var.kinesis_source_use_existing_role
  add_lambda_policy         = var.create_role && var.enable_lambda_transform
  add_s3_kms_policy         = var.create_role && ((local.add_backup_policies && var.s3_backup_enable_encryption) || var.enable_s3_encryption)
  add_glue_policy           = var.create_role && var.enable_data_format_conversion && var.data_format_conversion_glue_use_existing_role
  add_s3_policy             = var.create_role
  add_cw_policy             = var.create_role && ((local.add_backup_policies && var.s3_backup_enable_log) || var.enable_destination_log)
  #  add_sse_kms_policy        = var.create_role && var.enable_sse && var.sse_kms_key_type == "CUSTOMER_MANAGED_CMK"
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = compact([
        "firehose.amazonaws.com",
        var.destination == "redshift" ? "redshift.amazonaws.com" : "",
      ])
    }
  }
}

resource "aws_iam_role" "firehose" {
  count                 = var.create_role ? 1 : 0
  name                  = local.role_name
  description           = var.role_description
  path                  = var.role_path
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  tags                  = merge(var.tags, var.role_tags)
}

##################
# Kinesis Source
##################
data "aws_iam_policy_document" "kinesis" {
  count = local.add_kinesis_source_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [var.kinesis_source_stream_arn]
  }

  dynamic "statement" {
    for_each = var.kinesis_source_is_encrypted ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kinesis:Decrypt"
      ]
      resources = [var.kinesis_source_kms_arn]
      condition {
        test     = "StringEquals"
        values   = ["kinesis.${data.aws_region.current.name}.amazonaws.com"]
        variable = "kms:ViaService"
      }
      condition {
        test     = "StringLike"
        values   = [var.kinesis_source_stream_arn]
        variable = "kms:EncryptionContext:aws:kinesis:arn"
      }
    }
  }
}

resource "aws_iam_policy" "kinesis" {
  count = local.add_kinesis_source_policy ? 1 : 0

  name   = "${local.role_name}-kinesis"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.kinesis[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  count = local.add_kinesis_source_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.kinesis[0].arn
}

##################
# Lambda
##################
data "aws_iam_policy_document" "lambda" {
  count = local.add_lambda_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration"
    ]
    resources = [var.transform_lambda_arn]
  }
}

resource "aws_iam_policy" "lambda" {
  count = local.add_lambda_policy ? 1 : 0

  name   = "${local.role_name}-lambda"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.lambda[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = local.add_lambda_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.lambda[0].arn
}

##################
# KMS
##################
data "aws_iam_policy_document" "s3_kms" {
  count = local.add_s3_kms_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = distinct(compact([
      var.enable_s3_encryption ? var.s3_kms_key_arn : "",
      var.s3_backup_enable_encryption ? var.s3_backup_kms_key_arn : ""
    ]))
    condition {
      test     = "StringEquals"
      values   = ["s3.${data.aws_region.current.name}.amazonaws.com"]
      variable = "kms:ViaService"
    }
    condition {
      test = "StringLike"
      values = distinct(compact([
        var.enable_s3_backup ? "${var.s3_backup_bucket_arn}/*" : "",
        var.enable_s3_encryption ? "${var.s3_bucket_arn}/*" : ""
      ]))
      variable = "kms:EncryptionContext:aws:s3:arn"
    }
  }
}

resource "aws_iam_policy" "s3_kms" {
  count = local.add_s3_kms_policy ? 1 : 0

  name   = "${local.role_name}-s3-kms"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.s3_kms[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_kms" {
  count = local.add_s3_kms_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.s3_kms[0].arn
}

#data "aws_iam_policy_document" "sse-kms" {
#  count = local.add_sse_kms_policy ? 1 : 0
#  statement {
#    effect = "Allow"
#    actions = [
#      "kms:Encrypt",
#      "kms:Decrypt",
#      "kms:ReEncrypt*",
#      "kms:GenerateDataKey*",
#      "kms:DescribeKey"
#    ]
#    resources = [var.sse_kms_key_arn]
#    condition {
#      test     = "StringEquals"
#      values   = ["firehose.${data.aws_region.current.name}.amazonaws.com"]
#      variable = "kms:ViaService"
#    }
#    condition {
#      test     = "StringLike"
#      values   = ["arn:aws:firehose:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deliverystream/${var.name}"]
#      variable = "kms:EncryptionContext:aws:firehose:arn"
#    }
#  }
#}
#
#resource "aws_iam_policy" "sse-kms" {
#  count = local.add_sse_kms_policy ? 1 : 0
#
#  name   = "${local.role_name}-sse-kms"
#  path   = var.policy_path
#  policy = data.aws_iam_policy_document.sse-kms[0].json
#  tags   = var.tags
#}
#
#resource "aws_iam_role_policy_attachment" "sse-kms" {
#  count = local.add_sse_kms_policy ? 1 : 0
#
#  role       = aws_iam_role.firehose[0].name
#  policy_arn = aws_iam_policy.sse-kms[0].arn
#}

##################
# Glue
##################
data "aws_iam_policy_document" "glue" {
  count = local.add_glue_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = [
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current.account_id}:database/${var.data_format_conversion_glue_database}",
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current.account_id}:table/${var.data_format_conversion_glue_database}/${var.data_format_conversion_glue_table_name}"
    ]
  }
}

resource "aws_iam_policy" "glue" {
  count = local.add_glue_policy ? 1 : 0

  name   = "${local.role_name}-glue"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.glue[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "glue" {
  count = local.add_glue_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.glue[0].arn
}

##################
# S3
##################
data "aws_iam_policy_document" "s3" {
  count = local.add_s3_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = distinct(compact([
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
      var.enable_s3_backup ? var.s3_backup_bucket_arn : "",
      var.enable_s3_backup ? "${var.s3_backup_bucket_arn}/*" : ""
    ]))
  }
}

resource "aws_iam_policy" "s3" {
  count = local.add_s3_policy ? 1 : 0

  name   = "${local.role_name}-s3"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.s3[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "s3" {
  count = local.add_s3_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.s3[0].arn
}

##################
# Cloudwatch
##################
data "aws_iam_policy_document" "cw" {
  count = local.add_cw_policy ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = distinct(compact([
      var.enable_destination_log ? "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.destination_cw_log_group_name}:log-stream:${local.destination_cw_log_stream_name}" : "",
      var.s3_backup_enable_log ? "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.s3_backup_cw_log_group_name}:log-stream:${local.s3_backup_cw_log_stream_name}" : ""
    ]))
  }
}

resource "aws_iam_policy" "cw" {
  count = local.add_cw_policy ? 1 : 0

  name   = "${local.role_name}-cw"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.cw[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "cw" {
  count = local.add_cw_policy ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.cw[0].arn
}

##################
# Redshift
##################
resource "aws_redshift_cluster_iam_roles" "this" {
  count              = var.create_role && var.destination == "redshift" && var.associate_role_to_redshift_cluster ? 1 : 0
  cluster_identifier = var.redshift_cluster_identifier
  iam_role_arns      = [aws_iam_role.firehose[0].arn]
}
