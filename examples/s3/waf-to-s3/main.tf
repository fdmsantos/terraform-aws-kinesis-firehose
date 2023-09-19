resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

module "waf" {
  source  = "cloudposse/waf/aws"
  version = "1.2.0"

  log_destination_configs = [module.firehose.kinesis_firehose_arn]

  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "rules-example-metric"
    sampled_requests_enabled   = false
  }

  managed_rule_group_statement_rules = [
    {
      name     = "AWS-AWSManagedRulesAdminProtectionRuleSet"
      priority = 1

      statement = {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "AWS-AWSManagedRulesAdminProtectionRuleSet"
      }
    }
  ]

  context = {
    enabled             = true
    namespace           = "test"
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["unset"]
  }
}

module "firehose" {
  source        = "../../../"
  name          = "${var.name_prefix}-delivery-stream"
  input_source  = "waf"
  destination   = "s3"
  s3_bucket_arn = aws_s3_bucket.s3.arn
}
