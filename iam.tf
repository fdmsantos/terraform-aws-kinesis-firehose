locals {
  role_name = var.create_role ? coalesce(var.role_name, var.name, "*") : null
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
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
  count = var.create_role && local.enable_kinesis_source && var.kinesis_source_use_existing_role ? 1 : 0
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
        values   = ["kinesis.${data.aws_region.current[0].name}.amazonaws.com"]
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
  count = var.create_role && local.enable_kinesis_source && var.kinesis_source_use_existing_role ? 1 : 0

  name   = "${local.role_name}-kinesis"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.kinesis[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kinesis" {
  count = var.create_role && local.enable_kinesis_source && var.kinesis_source_use_existing_role ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.kinesis[0].arn
}

##################
# Lambda
##################
data "aws_iam_policy_document" "lambda" {
  count = var.create_role && local.enable_transformation ? 1 : 0
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
  count = var.create_role && local.enable_transformation ? 1 : 0

  name   = "${local.role_name}-lambda"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.lambda[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  count = var.create_role && local.enable_transformation ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.lambda[0].arn
}

##################
# KMS
##################
data "aws_iam_policy_document" "kms" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_kms_key_arn != null) || var.sse_enabled) ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = distinct([
      var.sse_key_arn,
      var.s3_backup_kms_key_arn
    ])
    condition {
      test     = "StringEquals"
      values   = ["s3.${data.aws_region.current[0].name}.amazonaws.com"]
      variable = "kms:ViaService"
    }
    condition {
      test     = "StringLike"
      values   = distinct(["${var.s3_backup_bucket_arn}/*", "${var.s3_bucket_arn}/*"])
      variable = "kms:EncryptionContext:aws:s3:arn"
    }
  }
}

resource "aws_iam_policy" "kms" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_kms_key_arn != null) || var.sse_enabled) ? 1 : 0

  name   = "${local.role_name}-kms"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.kms[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "kms" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_kms_key_arn != null) || var.sse_enabled) ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.kms[0].arn
}

##################
# Glue
##################
data "aws_iam_policy_document" "glue" {
  count = var.create_role && var.enable_data_format_conversion && var.data_format_conversion_glue_use_existing_role ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = [
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current[0].account_id}:catalog",
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current[0].account_id}:database/${var.data_format_conversion_glue_database}",
      "arn:aws:glue:${local.data_format_conversion_glue_region}:${data.aws_caller_identity.current[0].account_id}:table/${var.data_format_conversion_glue_database}/${var.data_format_conversion_glue_table_name}"
    ]
  }
}

resource "aws_iam_policy" "glue" {
  count = var.create_role && var.enable_data_format_conversion && var.data_format_conversion_glue_use_existing_role ? 1 : 0

  name   = "${local.role_name}-glue"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.glue[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "glue" {
  count = var.create_role && var.enable_data_format_conversion && var.data_format_conversion_glue_use_existing_role ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.glue[0].arn
}

##################
# S3
##################
data "aws_iam_policy_document" "s3" {
  count = var.create_role && (local.s3_destination || (var.enable_s3_backup && var.s3_backup_use_existing_role)) ? 1 : 0
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
    resources = distinct([
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
      var.s3_backup_bucket_arn,
      "${var.s3_backup_bucket_arn}/*"
    ])
  }
}

resource "aws_iam_policy" "s3" {
  count = var.create_role && var.enable_s3_backup && var.s3_backup_use_existing_role ? 1 : 0

  name   = "${local.role_name}-s3"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.s3[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "s3" {
  count = var.create_role && var.enable_s3_backup && var.s3_backup_use_existing_role ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.s3[0].arn
}

##################
# Cloudwatch
##################
data "aws_iam_policy_document" "cw" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_enable_log) || var.enable_destination_log) ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents"
    ]
    resources = distinct([
      "arn:aws:logs:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:log-group:${local.destination_cw_log_group_name}:log-stream:${local.destination_cw_log_stream_name}",
      "arn:aws:logs:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:log-group:${local.s3_backup_cw_log_group_name}:log-stream:${local.s3_backup_cw_log_stream_name}"
    ])
  }
}

resource "aws_iam_policy" "cw" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_enable_log) || var.enable_destination_log) ? 1 : 0

  name   = "${local.role_name}-cw"
  path   = var.policy_path
  policy = data.aws_iam_policy_document.cw[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "cw" {
  count = var.create_role && ((var.enable_s3_backup && var.s3_backup_use_existing_role && var.s3_backup_enable_log) || var.enable_destination_log) ? 1 : 0

  role       = aws_iam_role.firehose[0].name
  policy_arn = aws_iam_policy.cw[0].arn
}
