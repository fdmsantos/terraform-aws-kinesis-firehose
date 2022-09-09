variable "name" {
  description = "A name to identify the stream. This is unique to the AWS account and region the Stream is created in"
  type        = string
}

variable "destination" {
  description = "This is the destination to where the data is delivered"
  type        = string

  validation {
    error_message = "Please use a valid destination"
    condition     = contains(["extended_s3"], var.destination)
  }
}

variable "create_role" {
  description = "Controls whether IAM role for Kinesis Firehose Stream should be created"
  type        = bool
  default     = true
}

######
# All Destinations
######
variable "buffer_size" {
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination."
  type        = number
  default     = 5
  validation {
    error_message = "Valid values: minimum: 1 MiB, maximum: 128 MiB"
    condition     = var.buffer_size >= 1 && var.buffer_size <= 128
  }
}

variable "buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination."
  type        = number
  default     = 300
  validation {
    error_message = "Valid Values: Minimum: 60 seconds, maximum: 900 seconds."
    condition     = var.buffer_interval >= 60 && var.buffer_interval <= 900
  }
}

variable "transform_lambda_arn" {
  description = "Lambda ARN to Transform source records."
  type        = string
  default     = null
}

variable "transform_lambda_buffer_size" {
  description = "The AWS Lambda function has a 6 MB invocation payload quota. Your data can expand in size after it's processed by the AWS Lambda function. A smaller buffer size allows for more room should the data expand after processing."
  type        = number
  default     = 3
  validation {
    error_message = "Valid Values: minimum: 1 MB, maximum: 3 MB"
    condition     = var.transform_lambda_buffer_size >= 1 && var.transform_lambda_buffer_size <= 3
  }
}

variable "transform_lambda_buffer_interval" {
  description = "The period of time during which Kinesis Data Firehose buffers incoming data before invoking the AWS Lambda function. The AWS Lambda function is invoked once the value of the buffer size or the buffer interval is reached."
  type        = number
  default     = 60
  validation {
    error_message = "Valid Values: minimum: 60 seconds, maximum: 900 seconds."
    condition     = var.transform_lambda_buffer_interval >= 60 && var.transform_lambda_buffer_interval <= 900
  }
}

variable "transform_lambda_number_retries" {
  description = "Number of retries for AWS Transformation lambda"
  type        = number
  default     = 3
  validation {
    error_message = "Number of retries for lambda must be between 0 and 300."
    condition     = var.transform_lambda_number_retries >= 0 && var.transform_lambda_number_retries <= 300
  }
}

variable "enable_data_format_conversion" {
  description = "Set it to true if you want to disable format conversion."
  type        = bool
  default     = false
}

variable "data_format_conversion_glue_database" {
  description = "Name of the AWS Glue database that contains the schema for the output data."
  type        = string
  default     = null
}

variable "data_format_conversion_glue_use_existing_role" {
  description = "Indicates if want use the kinesis firehose role to glue access."
  type        = bool
  default     = true
}

variable "data_format_conversion_glue_role_arn" {
  description = "The role that Kinesis Data Firehose can use to access AWS Glue. This role must be in the same account you use for Kinesis Data Firehose. Cross-account roles aren't allowed."
  type        = string
  default     = null
}

variable "data_format_conversion_glue_table_name" {
  description = "Specifies the AWS Glue table that contains the column information that constitutes your data schema"
  type        = string
  default     = null
}

variable "data_format_conversion_glue_catalog_id" {
  description = "The ID of the AWS Glue Data Catalog. If you don't supply this, the AWS account ID is used by default."
  type        = string
  default     = null
}

variable "data_format_conversion_glue_region" {
  description = "If you don't specify an AWS Region, the default is the current region."
  type        = string
  default     = null
}

variable "data_format_conversion_glue_version_id" {
  description = "Specifies the table version for the output data schema."
  type        = string
  default     = "LATEST"
}

variable "data_format_conversion_deserializer" {
  description = "Specifies which deserializer to use. You can choose either the Apache Hive JSON SerDe or the OpenX JSON SerDe"
  type        = string
  default     = "OpenX"
  validation {
    error_message = "Valid values are HIVE and OPENX"
    condition     = contains(["HIVE", "OpenX"], var.data_format_conversion_deserializer)
  }
}

variable "data_format_conversion_openX_case_insensitive" {
  description = "When set to true, Kinesis Data Firehose converts JSON keys to lowercase before deserializing them."
  type        = bool
  default     = true
}

variable "data_format_conversion_openX_convert_dots_to_underscores" {
  description = "Specifies that the names of the keys include dots and that you want Kinesis Data Firehose to replace them with underscores. This is useful because Apache Hive does not allow dots in column names."
  type        = bool
  default     = false
}

variable "data_format_conversion_openX_column_to_json_key_mappings" {
  description = "A map of column names to JSON keys that aren't identical to the column names. This is useful when the JSON contains keys that are Hive keywords."
  type        = map(string)
  default     = null
}

variable "data_format_conversion_hive_timestamps" {
  description = "A list of how you want Kinesis Data Firehose to parse the date and time stamps that may be present in your input data JSON. To specify these format strings, follow the pattern syntax of JodaTime's DateTimeFormat format strings."
  type        = list(string)
  default     = []
}

variable "data_format_conversion_serializer" {
  description = "Specifies which serializer to use. You can choose either the ORC SerDe or the Parquet SerDe"
  type        = string
  default     = "PARQUET"
  validation {
    error_message = "Valid values are ORC and PARQUET"
    condition     = contains(["ORC", "PARQUET"], var.data_format_conversion_serializer)
  }
}

variable "data_format_conversion_block_size" {
  description = "The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The Value is in Bytes."
  type        = number
  default     = 268435456
  validation {
    error_message = "Minimum Value is 64 MiB"
    condition     = var.data_format_conversion_block_size >= 67108864
  }
}

variable "data_format_conversion_parquet_compression" {
  description = "The compression code to use over data blocks."
  type        = string
  default     = "SNAPPY"
  validation {
    error_message = "Valid values are UNCOMPRESSED, SNAPPY and GZIP"
    condition     = contains(["UNCOMPRESSED", "SNAPPY", "GZIP"], var.data_format_conversion_parquet_compression)
  }
}

variable "data_format_conversion_parquet_dict_compression" {
  description = "Indicates whether to enable dictionary compression."
  type        = bool
  default     = false
}

variable "data_format_conversion_parquet_max_padding" {
  description = "The maximum amount of padding to apply. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The value is in bytes"
  type        = number
  default     = 0
}

variable "data_format_conversion_parquet_page_size" {
  description = "Column chunks are divided into pages. A page is conceptually an indivisible unit (in terms of compression and encoding). The value is in bytes"
  type        = number
  default     = 1048576
  validation {
    error_message = "Minimum Value is 64 KiB"
    condition     = var.data_format_conversion_parquet_page_size >= 65536
  }
}

variable "data_format_conversion_parquet_writer_version" {
  description = "Indicates the version of row format to output."
  type        = string
  default     = "V1"
  validation {
    error_message = "Valid values are V1 and V2"
    condition     = contains(["V1", "V2"], var.data_format_conversion_parquet_writer_version)
  }
}

variable "data_format_conversion_orc_compression" {
  description = "The compression code to use over data blocks."
  type        = string
  default     = "SNAPPY"
  validation {
    error_message = "Valid values are NONE, ZLIB and SNAPPY"
    condition     = contains(["NONE", "ZLIB", "SNAPPY"], var.data_format_conversion_orc_compression)
  }
}

variable "data_format_conversion_orc_format_version" {
  description = "The version of the file to write."
  type        = string
  default     = "V0_12"
  validation {
    error_message = "Valid values are V0_11 and V0_12"
    condition     = contains(["V0_11", "V0_12"], var.data_format_conversion_orc_format_version)
  }
}

variable "data_format_conversion_orc_enable_padding" {
  description = "Set this to true to indicate that you want stripes to be padded to the HDFS block boundaries. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying."
  type        = bool
  default     = false
}

variable "data_format_conversion_orc_padding_tolerance" {
  description = "A float between 0 and 1 that defines the tolerance for block padding as a decimal fraction of stripe size."
  type        = number
  default     = 0.05
  validation {
    error_message = "Valid values are V0_11 and V0_12"
    condition     = var.data_format_conversion_orc_padding_tolerance >= 0 && var.data_format_conversion_orc_padding_tolerance <= 1
  }
}

variable "data_format_conversion_orc_dict_key_threshold" {
  description = "A float that represents the fraction of the total number of non-null rows. To turn off dictionary encoding, set this fraction to a number that is less than the number of distinct keys in a dictionary. To always use dictionary encoding, set this threshold to 1."
  type        = number
  default     = 0.0
  validation {
    error_message = "Valid values are between 0 and 1"
    condition     = var.data_format_conversion_orc_dict_key_threshold >= 0 && var.data_format_conversion_orc_dict_key_threshold <= 1
  }
}

variable "data_format_conversion_orc_bloom_filter_columns" {
  description = "A list of column names for which you want Kinesis Data Firehose to create bloom filters."
  type        = list(string)
  default     = []
}

variable "data_format_conversion_orc_bloom_filter_false_positive_probability" {
  description = "The Bloom filter false positive probability (FPP). The lower the FPP, the bigger the Bloom filter."
  type        = number
  default     = 0.05
  validation {
    error_message = "Valid values are between 0 and 1"
    condition     = var.data_format_conversion_orc_bloom_filter_false_positive_probability >= 0 && var.data_format_conversion_orc_bloom_filter_false_positive_probability <= 1
  }
}

variable "data_format_conversion_orc_row_index_stripe" {
  description = "The number of rows between index entries."
  type        = number
  default     = 10000
  validation {
    error_message = "Minimum value is 1000"
    condition     = var.data_format_conversion_orc_row_index_stripe >= 1000
  }
}

variable "data_format_conversion_orc_stripe_size" {
  description = "he number of bytes in each strip."
  type        = number
  default     = 67108864
  validation {
    error_message = "Minimum Value is 8 MiB"
    condition     = var.data_format_conversion_orc_stripe_size >= 8388608
  }
}

variable "enable_s3_backup" {
  description = "The Amazon S3 backup mode"
  type        = bool
  default     = false
}

variable "s3_backup_bucket_arn" {
  description = "The ARN of the S3 backup bucket"
  type        = string
  default     = null
}

variable "s3_backup_prefix" {
  description = "The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
  default     = null
}

variable "s3_backup_buffer_size" { // Add validation, default value is wrong
  description = "Buffer incoming data to the specified size, in MBs, before delivering it to the destination."
  type        = number
  default     = 5
}

variable "s3_backup_buffer_interval" {
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination."
  type        = number
  default     = 300
  validation {
    error_message = "Valid Values: Minimum: 60 seconds, maximum: 900 seconds."
    condition     = var.s3_backup_buffer_interval >= 60 && var.s3_backup_buffer_interval <= 900
  }
}

variable "s3_backup_compression" {
  description = "The compression format"
  type        = string
  default     = "UNCOMPRESSED"
  validation {
    error_message = "Valid values are UNCOMPRESSED, GZIP, ZIP, Snappy and HADOOP_SNAPPY."
    condition     = contains(["UNCOMPRESSED", "GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY"], var.s3_backup_compression)
  }
}

variable "s3_backup_error_output_prefix" {
  description = "Prefix added to failed records before writing them to S3"
  type        = string
  default     = null
}

variable "s3_backup_enable_encryption" {
  description = "Indicates if want enable KMS Encryption in S3 Backup Bucket"
  type        = bool
  default     = false
}

variable "s3_backup_kms_key_arn" {
  description = "Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used"
  type        = string
  default     = null
}

variable "s3_backup_use_existing_role" {
  description = "Indicates if want use the kinesis firehose role to s3 backup bucket access."
  type        = bool
  default     = true
}

variable "s3_backup_role_arn" {
  description = "The role that Kinesis Data Firehose can use to access S3 Backup."
  type        = string
  default     = null
}

variable "s3_backup_enable_log" {
  description = "Enables or disables the logging"
  type        = bool
  default     = false
}

variable "s3_backup_create_cw_log_group" {
  description = "Enables or disables the cloudwatch log group creation"
  type        = bool
  default     = true
}

variable "s3_backup_log_group_name" {
  description = "he CloudWatch group name for logging"
  type        = string
  default     = null
}

variable "s3_backup_log_stream_name" {
  description = "The CloudWatch log stream name for logging"
  type        = string
  default     = null
}

variable "enable_destination_log" {
  description = "The CloudWatch Logging Options for the delivery stream"
  type        = bool
  default     = false
}

variable "create_destination_cw_log_group" {
  description = "Enables or disables the cloudwatch log group creation to destination"
  type        = bool
  default     = true
}

variable "destination_log_group_name" {
  description = "The CloudWatch group name for destination logs"
  type        = string
  default     = null
}

variable "destination_log_stream_name" {
  description = "The CloudWatch log stream name for destination logs"
  type        = string
  default     = null
}

variable "cw_log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = null
}

variable "cw_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "destination_s3_bucket_arn" {
  description = "The ARN of the S3 destination bucket"
  type        = string
  default     = null
}

variable "enable_s3_encryption" {
  description = "Indicates if want use encryption in S3 bucket."
  type        = bool
  default     = false
}

variable "s3_kms_key_arn" {
  description = "Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used."
  type        = string
  default     = null
}

variable "compression_format" {
  description = "The compression format."
  type        = string
  default     = "UNCOMPRESSED"
  validation {
    error_message = "Valid values are UNCOMPRESSED, GZIP, ZIP, Snappy and HADOOP_SNAPPY."
    condition     = contains(["UNCOMPRESSED", "GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY"], var.compression_format)
  }
}

variable "sse_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = false
}

variable "sse_kms_key_type" {
  description = "Type of encryption key."
  type        = string
  default     = "AWS_OWNED_CMK"
  validation {
    error_message = "Valid values are AWS_OWNED_CMK and CUSTOMER_MANAGED_CMK"
    condition     = contains(["AWS_OWNED_CMK", "CUSTOMER_MANAGED_CMK"], var.sse_kms_key_type)
  }
}

variable "sse_kms_key_arn" {
  description = "Amazon Resource Name (ARN) of the encryption key"
  type        = string
  default     = null
}

variable "enable_kinesis_source" {
  description = "Set it to true to use kinesis data stream as source"
  type        = bool
  default     = false
}

variable "kinesis_source_stream_arn" {
  description = "The kinesis stream used as the source of the firehose delivery stream"
  type        = string
  default     = null
}

variable "kinesis_source_role_arn" {
  description = "The ARN of the role that provides access to the source Kinesis stream"
  type        = string
  default     = null
}

variable "kinesis_source_use_existing_role" {
  description = "Indicates if want use the kinesis firehose role to kinesis data stream access."
  type        = bool
  default     = true
}

variable "kinesis_source_is_encrypted" {
  description = "Indicates if Kinesis data stream source is encrypted"
  type        = bool
  default     = false
}

variable "kinesis_source_kms_arn" {
  description = "Kinesis Source KMS Key to add Firehose role to decrypt the records"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

######
# S3 Destination Configurations
######
variable "s3_prefix" {
  description = "The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket"
  type        = string
  default     = null
}

variable "s3_error_output_prefix" {
  description = "Prefix added to failed records before writing them to S3. This prefix appears immediately following the bucket name."
  type        = string
  default     = null
}

variable "enable_dynamic_partitioning" {
  description = "Enables or disables dynamic partitioning"
  type        = bool
  default     = false
}

variable "dynamic_partitioning_retry_duration" {
  description = "Total amount of seconds Firehose spends on retries"
  type        = number
  default     = 300
  validation {
    error_message = "Valid values between 0 and 7200"
    condition     = var.dynamic_partitioning_retry_duration >= 0 && var.dynamic_partitioning_retry_duration <= 7200
  }
}

variable "dynamic_partition_append_delimiter_to_record" {
  description = "To configure your delivery stream to add a new line delimiter between records in objects that are delivered to Amazon S3."
  type        = bool
  default     = false
}

variable "dynamic_partition_metadata_extractor_query" {
  type    = string
  default = null
}

variable "dynamic_partition_enable_record_deaggregation" {
  description = "Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter"
  type        = bool
  default     = false
}

variable "dynamic_partition_record_deaggregation_type" {
  description = "Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter"
  type        = string
  default     = "JSON"
  validation {
    error_message = "Valid values are JSON and DELIMITED"
    condition     = contains(["JSON", "DELIMITED"], var.dynamic_partition_record_deaggregation_type)
  }
}

variable "dynamic_partition_record_deaggregation_delimiter" {
  description = "Specifies the delimiter to be used for parsing through the records in the delivery stream and deaggregating them."
  type        = string
  default     = null
}

######
# IAM
######
variable "firehose_role" {
  description = "IAM role ARN attached to the Kinesis Firehose Stream."
  type        = string
  default     = null
}

variable "role_name" {
  description = "Name of IAM role to use for Kinesis Firehose Stream"
  type        = string
  default     = null
}

variable "role_description" {
  description = "Description of IAM role to use for Kinesis Firehose Stream"
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role to use for Kinesis Firehose Stream"
  type        = string
  default     = null
}

variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by Kinesis Firehose Stream"
  type        = string
  default     = null
}

variable "role_tags" {
  description = "A map of tags to assign to IAM role"
  type        = map(string)
  default     = {}
}

variable "policy_path" {
  description = "Path of policies to that should be added to IAM role for Kinesis Firehose Stream"
  type        = string
  default     = null
}
