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
  name               = local.firehose_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = compact([
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ])
    resources = distinct(compact([
      aws_s3_bucket.backup.arn,
      "${aws_s3_bucket.backup.arn}/*"
    ]))
  }
}


data "aws_iam_policy_document" "all" {
  statement {
    effect = "Allow"
    actions = compact([
      "*",
    ])
    resources = ["*"]
  }
}



resource "aws_iam_policy" "s3" {
  name   = "${local.firehose_role_name}-s3"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_policy" "all" {
  name   = "${local.firehose_role_name}-all"
  policy = data.aws_iam_policy_document.all.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_role_policy_attachment" "all" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.all.arn
}
