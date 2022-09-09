resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_kinesis_stream" "this" {
  name             = "${var.name_prefix}-data-stream"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

module "firehose" {
  source                    = "../../../"
  name                      = "${var.name_prefix}-delivery-stream"
  enable_kinesis_source     = true
  kinesis_source_stream_arn = aws_kinesis_stream.this.arn
  destination               = "extended_s3"
  destination_s3_bucket_arn = aws_s3_bucket.s3.arn
}
