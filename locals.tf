locals {
  firehose_role_arn           = var.create && var.create_role ? aws_iam_role.firehose[0].arn : var.firehose_role
  cw_log_group_name           = "/aws/kinesisfirehose/${var.name}"
  cw_log_delivery_stream_name = "DestinationDelivery"
  cw_log_backup_stream_name   = "BackupDelivery"
  destinations = {
    s3 : "extended_s3",
    extended_s3 : "extended_s3",
    redshift : "redshift",
    elasticsearch : "elasticsearch",
    opensearch : "elasticsearch",
    splunk : "splunk",
    http_endpoint : "http_endpoint"
  }
  destination    = local.destinations[var.destination]
  s3_destination = local.destination == "extended_s3" ? true : false

  # Data Transformation
  enable_processing = var.enable_lambda_transform || var.enable_dynamic_partitioning
  lambda_processor = var.enable_lambda_transform ? {
    type = "Lambda"
    parameters = [
      {
        name  = "LambdaArn"
        value = var.transform_lambda_arn
      },
      {
        name  = "BufferSizeInMBs"
        value = var.transform_lambda_buffer_size
      },
      {
        name  = "BufferIntervalInSeconds"
        value = var.transform_lambda_buffer_interval
      },
      {
        name  = "NumberOfRetries"
        value = var.transform_lambda_number_retries
      },
      {
        name  = "RoleArn"
        value = var.transform_lambda_role_arn != null ? var.transform_lambda_role_arn : local.firehose_role_arn
      },
    ]
  } : null
  metadata_extractor_processor = var.enable_dynamic_partitioning && var.dynamic_partition_metadata_extractor_query != null ? {
    type = "MetadataExtraction"
    parameters = [
      {
        name  = "JsonParsingEngine"
        value = "JQ-1.6"
      },
      {
        name  = "MetadataExtractionQuery"
        value = var.dynamic_partition_metadata_extractor_query
      },
    ]
  } : null
  append_delimiter_processor = var.enable_dynamic_partitioning && var.dynamic_partition_append_delimiter_to_record ? {
    type       = "AppendDelimiterToRecord"
    parameters = []
  } : null
  record_deaggregation_processor_json = {
    type = "RecordDeAggregation"
    parameters = [
      {
        name  = "SubRecordType"
        value = var.dynamic_partition_record_deaggregation_type
      },
    ]
  }
  record_deaggregation_processor_delimiter = {
    type = "RecordDeAggregation"
    parameters = [
      {
        name  = "SubRecordType"
        value = var.dynamic_partition_record_deaggregation_type
      },
      {
        name  = "Delimiter"
        value = var.dynamic_partition_record_deaggregation_delimiter
      },
    ]
  }
  record_deaggregation_processor = (var.enable_dynamic_partitioning && var.dynamic_partition_enable_record_deaggregation ?
    (var.dynamic_partition_record_deaggregation_type == "JSON" ? local.record_deaggregation_processor_json : local.record_deaggregation_processor_delimiter)
  : null)
  processors = [for each in [
    local.lambda_processor,
    local.metadata_extractor_processor,
    local.append_delimiter_processor,
    local.record_deaggregation_processor
  ] : each if local.enable_processing && each != null]

  # Data Format conversion
  data_format_conversion_glue_catalog_id = (var.enable_data_format_conversion ?
    (var.data_format_conversion_glue_catalog_id != null ? var.data_format_conversion_glue_catalog_id : data.aws_caller_identity.current.account_id)
  : null)

  data_format_conversion_glue_region = (var.enable_data_format_conversion ?
    (var.data_format_conversion_glue_region != null ? var.data_format_conversion_glue_region : data.aws_region.current.name)
  : null)

  data_format_conversion_glue_role = (var.enable_data_format_conversion ? (
    var.data_format_conversion_glue_use_existing_role ? local.firehose_role_arn : var.data_format_conversion_glue_role_arn
  ) : null)

  # S3 Backup
  use_backup_vars_in_s3_configuration = contains(["elasticsearch", "splunk", "http_endpoint"], local.destination) ? true : false
  s3_backup                           = var.enable_s3_backup ? "Enabled" : "Disabled"
  enable_s3_backup                    = var.enable_s3_backup || local.use_backup_vars_in_s3_configuration
  s3_backup_role_arn = (local.enable_s3_backup ? (
    var.s3_backup_use_existing_role ? local.firehose_role_arn : var.s3_backup_role_arn
  ) : null)
  s3_backup_cw_log_group_name  = var.create_destination_cw_log_group ? local.cw_log_group_name : var.s3_backup_log_group_name
  s3_backup_cw_log_stream_name = var.create_destination_cw_log_group ? local.cw_log_backup_stream_name : var.s3_backup_log_stream_name
  backup_modes = {
    elasticsearch : {
      FailedOnly : "FailedDocumentsOnly",
      All : "AllDocuments"
    }
    splunk : {
      FailedOnly : "FailedEventsOnly",
      All : "AllEvents"
    }
    http_endpoint : {
      FailedOnly : "FailedDataOnly",
      All : "AllData"
    }
  }
  s3_backup_mode = local.use_backup_vars_in_s3_configuration ? local.backup_modes[local.destination][var.s3_backup_mode] : null

  # Kinesis source Stream
  kinesis_source_stream_role = (var.enable_kinesis_source ? (
    var.kinesis_source_use_existing_role ? local.firehose_role_arn : var.kinesis_source_role_arn
  ) : null)

  # Destination Log
  destination_cw_log_group_name  = var.create_destination_cw_log_group ? local.cw_log_group_name : var.destination_log_group_name
  destination_cw_log_stream_name = var.create_destination_cw_log_group ? local.cw_log_delivery_stream_name : var.destination_log_stream_name

  # Cloudwatch
  create_destination_logs = var.create && var.enable_destination_log && var.create_destination_cw_log_group
  create_backup_logs      = var.create && var.enable_s3_backup && var.s3_backup_enable_log && var.s3_backup_create_cw_log_group

  # VPC Config
  elasticsearch_vpc_role_arn = (var.elasticsearch_enable_vpc ? (
    var.elasticsearch_vpc_use_existing_role ? local.firehose_role_arn : var.elasticsearch_vpc_role_arn
  ) : null)

  elasticsearch_vpc_create_firehose_sg                    = local.destination == "elasticsearch" && var.vpc_create_security_group
  elasticsearch_vpc_sgs                                   = local.elasticsearch_vpc_create_firehose_sg ? [aws_security_group.firehose[0].id] : var.vpc_security_group_firehose_ids
  elasticsearch_vpc_configure_existing_firehose_sg        = local.destination == "elasticsearch" && var.elasticsearch_enable_vpc && var.vpc_security_group_firehose_configure_existing && !local.elasticsearch_vpc_create_firehose_sg
  elasticsearch_vpc_create_destination_group              = local.destination == "elasticsearch" && var.vpc_create_destination_security_group && !var.elasticsearch_vpc_security_group_same_as_destination
  elasticsearch_vpc_firehose_sgs                          = local.elasticsearch_vpc_create_firehose_sg ? [aws_security_group.firehose[0].id] : var.vpc_security_group_firehose_ids
  elasticsearch_vpc_destination_sgs                       = local.elasticsearch_vpc_create_destination_group ? [aws_security_group.destination[0].id] : var.vpc_security_group_destination_ids
  not_elasticsearch_vpc_create_destination_group          = contains(["splunk", "redshift"], local.destination) && var.vpc_create_destination_security_group
  vpc_create_destination_group                            = local.elasticsearch_vpc_create_destination_group || local.not_elasticsearch_vpc_create_destination_group
  elasticsearch_vpc_configure_existing_destination_sg     = local.destination == "elasticsearch" && var.elasticsearch_enable_vpc && var.vpc_security_group_destination_configure_existing && !local.elasticsearch_vpc_create_destination_group && !var.elasticsearch_vpc_security_group_same_as_destination
  not_elasticsearch_vpc_configure_existing_destination_sg = contains(["splunk", "redshift"], local.destination) && var.vpc_security_group_destination_configure_existing
  vpc_configure_destination_group                         = local.elasticsearch_vpc_configure_existing_destination_sg || local.not_elasticsearch_vpc_configure_existing_destination_sg

  # Networking
  firehose_cidr_blocks = {
    redshift : {
      us-east-2 : ["13.58.135.96/27"],
      us-east-1 : ["52.70.63.192/27"],
      us-west-1 : ["13.57.135.192/27"],
      us-west-2 : ["52.89.255.224/27"],
      us-gov-east-1 : ["18.253.138.96/27"],
      us-gov-west-1 : ["52.61.204.160/27"],
      ap-east-1 : ["18.162.221.32/27"],
      ap-south-1 : ["13.232.67.32/27"],
      ap-northeast-2 : ["13.209.1.64/27"],
      ap-southeast-1 : ["13.228.64.192/27"],
      ap-southeast-2 : ["13.210.67.224/27"],
      ap-northeast-1 : ["13.113.196.224/27"],
      ca-central-1 : ["35.183.92.128/27"],
      af-south-1 : ["13.244.121.224/27"],
      ap-southeast-3 : ["108.136.221.64/27"],
      ap-northeast-3 : ["13.208.177.192/27"],
      eu-central-1 : ["35.158.127.160/27"],
      eu-west-1 : ["52.19.239.192/27"],
      eu-west-2 : ["18.130.1.96/27"],
      eu-south-1 : ["15.161.135.128/27"],
      eu-west-3 : ["35.180.1.96/27"],
      eu-north-1 : ["13.53.63.224/27"],
      me-south-1 : ["15.185.91.0/27"],
      sa-east-1 : ["18.228.1.128/27"],
      cn-north-1 : ["52.81.151.32/27"],
      cn-northwest-1 : ["161.189.23.64/27"],
    },
    splunk : {
      us-east-2 : ["18.216.68.160/27", "18.216.170.64/27", "18.216.170.96/27"],
      us-east-1 : ["34.238.188.128/26", "34.238.188.192/26", "34.238.195.0/26"],
      us-west-1 : ["13.57.180.0/26"],
      us-west-2 : ["34.216.24.32/27", "34.216.24.192/27", "34.216.24.224/27"],
      us-gov-east-1 : ["18.253.138.192/26"],
      us-gov-west-1 : ["52.61.204.192/26"],
      ap-east-1 : ["18.162.221.64/26"],
      ap-south-1 : ["13.232.67.64/26"],
      ap-northeast-2 : ["13.209.71.0/26"],
      ap-southeast-1 : ["13.229.187.128/26"],
      ap-southeast-2 : ["13.211.12.0/26"],
      ap-northeast-1 : ["13.230.21.0/27", "13.230.21.32/27"],
      ca-central-1 : ["35.183.92.64/26"],
      af-south-1 : ["13.244.165.128/26"],
      ap-southeast-3 : ["108.136.221.128/26"],
      ap-northeast-3 : ["13.208.217.0/26"],
      eu-central-1 : ["18.194.95.192/27", "18.194.95.224/27", "18.195.48.0/27"],
      eu-west-1 : ["34.241.197.32/27", "34.241.197.64/27", "34.241.197.96/27"],
      eu-west-2 : ["18.130.91.0/26"],
      eu-south-1 : ["15.161.135.192/26"],
      eu-west-3 : ["35.180.112.0/26"],
      eu-north-1 : ["13.53.191.0/26"],
      me-south-1 : ["15.185.91.64/26"],
      sa-east-1 : ["18.228.1.192/26"],
      cn-north-1 : ["52.81.151.64/26"],
      cn-northwest-1 : ["161.189.23.128/26"],
    }
  }
}
