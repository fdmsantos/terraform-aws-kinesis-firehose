# AWS Kinesis Firehose Terraform module

Dynamic Terraform module, which creates a Kinesis Firehose Stream and others resources like Cloudwatch and IAM Roles that integrate with Kinesis Firehose.
Supports all destinations and all Kinesis Firehose Features.

## Table of Contents

* [Features](#features)
* [RoadMap](#roadmap)
* [How to Use](#how-to-use)
  * [Kinesis Data Stream as Source](#kinesis-data-stream-as-source)
    * [Kinesis Data Stream Encrypted](#kinesis-data-stream-encrypted)
  * [Direct Put as Source](#direct-put-as-source)
  * [S3 destination](#s3-destination)
  * [Redshift Destination](#redshift-destination)
  * [Elasticsearch / Opensearch Destination](#elasticsearch--opensearch-destination)
  * [Splunk Destination](#splunk-destination)
  * [HTTP Endpoint Destination](#http-endpoint-destination)
  * [Server Side Encryption](#server-side-encryption)
  * [Data Transformation with Lambda](#data-transformation-with-lambda)
  * [Data Format Conversion](#data-format-conversion)
  * [Dynamic Partition](#dynamic-partition)
  * [S3 Backup Data](#s3-backup-data)
  * [Destination Delivery Logging](#destination-delivery-logging)
* [Examples](#examples)
* [Requirements](#requirements)
* [Providers](#providers)
* [Modules](#modules)
* [Resources](#resources)
* [Inputs](#inputs)
* [Outputs](#outputs)
* [License](#license)

## Features

- Sources 
  - Kinesis Data Stream
  - Direct Put
- Destinations
  - S3
    - Data Format Conversion
    - Dynamic Partition
  - Redshift
  - ElasticSearch / Opensearch
  - Splunk
  - Http Endpoint
- Data Transformation With Lambda
- Original Data Backup in S3
- Logging and Encryption

## RoadMap

- VPC Support (ElasticSearch, Redshift, Splunk) (Expected in Version 1.5.0)

## How to Use

### Kinesis Data Stream as Source

**To Enabled it:** `enable_kinesis_source = true`

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  enable_kinesis_source     = true
  kinesis_source_stream_arn = "<kinesis_stream_arn>"
  destination               = "extended_s3"
  s3_bucket_arn             = "<bucket_arn>"
}
```

#### Kinesis Data Stream Encrypted

If Kinesis Data Stream is encrypted, it's necessary pass this info to module .

**To Enabled It:**  `kinesis_source_is_encrypted = true`

**KMS Key:** use `kinesis_source_kms_arn` variable to indicate the KMS Key to module add permissions to policy to decrypt the Kinesis Data Stream.

### Direct Put as Source

```hcl
module "firehose" {
  source           = "fdmsantos/kinesis-firehose/aws"
  version          = "x.x.x"
  name             = "firehose-delivery-stream"
  destination      = "extended_s3"
  s3_bucket_arn    = "<bucket_arn>"
}
```

### S3 destination

**To Enabled It:** `destination = "extended_s3"`

**Variables Prefix:** `s3_`

**To Enable Encryption:** `enable_s3_encryption = true`

**Note:** For other destinations, the `s3_` variables are used to configure the required intermediary bucket before delivery data to destination. Not Supported to Elasticsearch and Splunk destinations

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  destination               = "extended_s3"
  s3_bucket_arn             = "<bucket_arn>"
}
```

### Redshift Destination

**To Enabled It:** `destination = "redshift"`

**Variables Prefix:** `redshift_`

```hcl
module "firehose" {
  source                        = "fdmsantos/kinesis-firehose/aws"
  version                       = "x.x.x"
  name                          = "firehose-delivery-stream"
  destination                   = "redshift"
  s3_bucket_arn                 = "<bucket_arn>"
  redshift_cluster_identifier   = "<redshift_cluster_identifier>"
  redshift_cluster_endpoint     = "<redshift_cluster_endpoint>"
  redshift_database_name        = "<redshift_cluster_database>"
  redshift_username             = "<redshift_cluster_username>"
  redshift_password             = "<redshift_cluster_password>"
  redshift_table_name           = "<redshift_cluster_table>"
  redshift_copy_options         = "json 'auto ignorecase'"
}
```

### Elasticsearch / Opensearch Destination

**To Enabled It:** `destination = "elasticsearch"`

**Variables Prefix:** `elasticsearch_`

```hcl
module "firehose" {
  source                   = "fdmsantos/kinesis-firehose/aws"
  version                  = "x.x.x"
  name                     = "firehose-delivery-stream"
  destination              = "elasticsearch"
  elasticsearch_domain_arn = "<elasticsearch_domain_arn>"
  elasticsearch_index_name = "<elasticsearch_index_name"
}
```

### Splunk Destination

**To Enabled It:** `destination = "splunk"`

**Variables Prefix:** `splunk_`

```hcl
module "firehose" {
  source                            = "fdmsantos/kinesis-firehose/aws"
  version                           = "x.x.x"
  name                              = "firehose-delivery-stream"
  destination                       = "splunk"
  splunk_hec_endpoint               = "<splunk_hec_endpoint>"
  splunk_hec_endpoint_type          = "<splunk_hec_endpoint_type>"
  splunk_hec_token                  = "<splunk_hec_token>"
  splunk_hec_acknowledgment_timeout = 450
  splunk_retry_duration             = 450
}
```

### HTTP Endpoint Destination

**To Enabled It:** `destination = "http_endpoint"`

**Variables Prefix:** `http_endpoint_`

**To enable Request Configuration:** `http_endpoint_enable_request_configuration = true`

**Request Configuration Variables Prefix:** `http_endpoint_request_configuration_`

```hcl
module "firehose" {
  source                                                = "fdmsantos/kinesis-firehose/aws"
  version                                               = "x.x.x"
  name                                                  = "firehose-delivery-stream"
  destination                                           = "http_endpoint"
  buffer_interval                                       = 60
  http_endpoint_name                                    = "<http_endpoint_name>"
  http_endpoint_url                                     = "<http_endpoint_url>"
  http_endpoint_access_key                              = "<http_endpoint_access_key>"
  http_endpoint_retry_duration                          = 400
  http_endpoint_enable_request_configuration            = true
  http_endpoint_request_configuration_content_encoding  = "GZIP"
  http_endpoint_request_configuration_common_attributes = [
    {
      name  = "testname"
      value = "testvalue"
    },
    {
      name  = "testname2"
      value = "testvalue2"
    }
  ]
}
```


### Server Side Encryption

**Supported By:** Only Direct Put source

**To Enabled It:** `enable_sse = true`

**Variables Prefix:** `sse_`

```hcl
module "firehose" {
  source           = "fdmsantos/kinesis-firehose/aws"
  version          = "x.x.x"
  name             = "firehose-delivery-stream"
  destination      = "extended_s3"
  s3_bucket_arn    = "<bucket_arn>"
  enable_sse       = true
  sse_kms_key_type = "CUSTOMER_MANAGED_CMK"
  sse_kms_key_arn  = aws_kms_key.this.arn
}
```

### Data Transformation with Lambda

**Supported By:** All destinations and Sources

**To Enabled It:** `enable_lambda_transform = true`

**Variables Prefix:** `transform_lambda_`

```hcl
module "firehose" {
  source                           = "fdmsantos/kinesis-firehose/aws"
  version                          = "x.x.x"
  name                             = "firehose-delivery-stream"
  enable_kinesis_source            = true
  kinesis_source_stream_arn        = "<kinesis_stream_arn>"
  destination                      = "extended_s3"
  s3_bucket_arn                    = "<bucket_arn>"
  enable_lambda_transform          = true
  transform_lambda_arn             = "<lambda_arn>"
  transform_lambda_buffer_size     = 3
  transform_lambda_buffer_interval = 60
  transform_lambda_number_retries  = 3
}
```

### Data Format Conversion

**Supported By:** Only S3 Destination

**To Enabled It:** `enable_data_format_conversion = true`

**Variables Prefix:** `data_format_conversion_`

```hcl
module "firehose" {
  source                                 = "fdmsantos/kinesis-firehose/aws"
  version                                = "x.x.x"
  name                                   = "firehose-delivery-stream"
  enable_kinesis_source                  = true
  kinesis_source_stream_arn              = "<kinesis_stream_arn>"
  destination                            = "extended_s3"
  s3_bucket_arn                          = "<bucket_arn>"
  enable_data_format_conversion          = true
  data_format_conversion_glue_database   = "<glue_database_name>"
  data_format_conversion_glue_table_name = "<glue_table_name>"
  data_format_conversion_input_format    = "HIVE"
  data_format_conversion_output_format   = "ORC"
}

```

### Dynamic Partition

**Supported By:** Only S3 Destination

**To Enabled It:** `enable_dynamic_partitioning = true`

**Variables Prefix:** `dynamic_partitioning_`

```hcl
module "firehose" {
  source                                        = "fdmsantos/kinesis-firehose/aws"
  version                                       = "x.x.x"
  name                                          = "firehose-delivery-stream"
  enable_kinesis_source                         = true
  kinesis_source_stream_arn                     = "<kinesis_stream_arn>"
  destination                                   = "extended_s3"
  s3_bucket_arn                                 = "<bucket_arn>"
  s3_prefix                                     = "prod/user_id=!{partitionKeyFromQuery:user_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  enable_dynamic_partitioning                   = true
  dynamic_partitioning_retry_duration           = 350
  dynamic_partition_metadata_extractor_query    = "{user_id:.user_id}"
  dynamic_partition_append_delimiter_to_record  = true
  dynamic_partition_enable_record_deaggregation = true
}

```

### S3 Backup Data

**Supported By:** All Destinations

**To Enabled It:** `enable_s3_backup = true`. It's always enable to Elasticsearch and splunk destinations.

**To Enable Backup Encruption:** `s3_backup_enable_encryption = true`

**To Enable Backup Logging** `s3_backup_enable_log = true`. Not supported to Elasticsearch and splunk destinations. It's possible add existing cloudwatch group or create new

**Variables Prefix:** `s3_backup_`

```hcl
module "firehose" {
  source                        = "fdmsantos/kinesis-firehose/aws"
  version                       = "x.x.x"
  name                          = "${var.name_prefix}-delivery-stream"
  destination                   = "extended_s3"
  s3_bucket_arn                 = aws_s3_bucket.s3.arn
  enable_s3_backup              = true
  s3_backup_bucket_arn          = aws_s3_bucket.s3.arn
  s3_backup_prefix              = "backup/"
  s3_backup_error_output_prefix = "error/"
  s3_backup_buffer_interval     = 100
  s3_backup_buffer_size         = 100
  s3_backup_compression         = "GZIP"
  s3_backup_use_existing_role   = false
  s3_backup_role_arn            = aws_iam_role.this.arn
  s3_backup_enable_encryption   = true
  s3_backup_kms_key_arn         = aws_kms_key.this.arn
  s3_backup_enable_log          = true
}
```

### Destination Delivery Logging

**Supported By:** All Destinations

**To Enabled It:** `enable_destination_log = true`. It's enabled by default. It's possible add existing cloudwatch group or create new

**Variables Prefix:** `destination_cw_log_`

```hcl
module "firehose" {
  source                      = "fdmsantos/kinesis-firehose/aws"
  version                     = "x.x.x"
  name                        = "firehose-delivery-stream"
  destination                 = "extended_s3"
  s3_bucket_arn               = "<bucket_arn>"
  enable_destination_log      = true
  destination_log_group_name  = "<cw_log_group_arn>"
  destination_log_stream_name = "<cw_log_stream_name>"
}
```

## Examples

- [Direct Put](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/direct-put-to-s3) - Creates an encrypted Kinesis firehose stream with Direct Put as source and S3 as destination.
- [Kinesis Data Stream Source](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/kinesis-to-s3-basic) - Creates a basic Kinesis Firehose stream with Kinesis data stream as source and s3 as destination .
- [S3 Destination Complete](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/kinesis-to-s3-complete) - Creates a Kinesis Firehose Stream with all features enabled.
- [Redshift](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/redshift/direct-put-to-redshift) - Creates a Kinesis Firehose Stream with redshift as destination.
- [Public Opensearch](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/elasticsearch/public-opensearch) - Creates a Kinesis Firehose Stream with public opensearch as destination.
- [Public Splunk](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/splunk/public-splunk) - Creates a Kinesis Firehose Stream with public splunk as destination.
- [Custom Http Endpoint](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/custom-http-endpoint) - Creates a Kinesis Firehose Stream with custom http endpoint as destination.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_policy.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_redshift_cluster_iam_roles.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster_iam_roles) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_role_to_redshift_cluster"></a> [associate\_role\_to\_redshift\_cluster](#input\_associate\_role\_to\_redshift\_cluster) | Set it to false if don't want the module associate the role to redshift cluster | `bool` | `true` | no |
| <a name="input_buffer_interval"></a> [buffer\_interval](#input\_buffer\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | `number` | `300` | no |
| <a name="input_buffer_size"></a> [buffer\_size](#input\_buffer\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. | `number` | `5` | no |
| <a name="input_create_destination_cw_log_group"></a> [create\_destination\_cw\_log\_group](#input\_create\_destination\_cw\_log\_group) | Enables or disables the cloudwatch log group creation to destination | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Controls whether IAM role for Kinesis Firehose Stream should be created | `bool` | `true` | no |
| <a name="input_cw_log_retention_in_days"></a> [cw\_log\_retention\_in\_days](#input\_cw\_log\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `null` | no |
| <a name="input_cw_tags"></a> [cw\_tags](#input\_cw\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_data_format_conversion_block_size"></a> [data\_format\_conversion\_block\_size](#input\_data\_format\_conversion\_block\_size) | The Hadoop Distributed File System (HDFS) block size. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The Value is in Bytes. | `number` | `268435456` | no |
| <a name="input_data_format_conversion_glue_catalog_id"></a> [data\_format\_conversion\_glue\_catalog\_id](#input\_data\_format\_conversion\_glue\_catalog\_id) | The ID of the AWS Glue Data Catalog. If you don't supply this, the AWS account ID is used by default. | `string` | `null` | no |
| <a name="input_data_format_conversion_glue_database"></a> [data\_format\_conversion\_glue\_database](#input\_data\_format\_conversion\_glue\_database) | Name of the AWS Glue database that contains the schema for the output data. | `string` | `null` | no |
| <a name="input_data_format_conversion_glue_region"></a> [data\_format\_conversion\_glue\_region](#input\_data\_format\_conversion\_glue\_region) | If you don't specify an AWS Region, the default is the current region. | `string` | `null` | no |
| <a name="input_data_format_conversion_glue_role_arn"></a> [data\_format\_conversion\_glue\_role\_arn](#input\_data\_format\_conversion\_glue\_role\_arn) | The role that Kinesis Data Firehose can use to access AWS Glue. This role must be in the same account you use for Kinesis Data Firehose. Cross-account roles aren't allowed. | `string` | `null` | no |
| <a name="input_data_format_conversion_glue_table_name"></a> [data\_format\_conversion\_glue\_table\_name](#input\_data\_format\_conversion\_glue\_table\_name) | Specifies the AWS Glue table that contains the column information that constitutes your data schema | `string` | `null` | no |
| <a name="input_data_format_conversion_glue_use_existing_role"></a> [data\_format\_conversion\_glue\_use\_existing\_role](#input\_data\_format\_conversion\_glue\_use\_existing\_role) | Indicates if want use the kinesis firehose role to glue access. | `bool` | `true` | no |
| <a name="input_data_format_conversion_glue_version_id"></a> [data\_format\_conversion\_glue\_version\_id](#input\_data\_format\_conversion\_glue\_version\_id) | Specifies the table version for the output data schema. | `string` | `"LATEST"` | no |
| <a name="input_data_format_conversion_hive_timestamps"></a> [data\_format\_conversion\_hive\_timestamps](#input\_data\_format\_conversion\_hive\_timestamps) | A list of how you want Kinesis Data Firehose to parse the date and time stamps that may be present in your input data JSON. To specify these format strings, follow the pattern syntax of JodaTime's DateTimeFormat format strings. | `list(string)` | `[]` | no |
| <a name="input_data_format_conversion_input_format"></a> [data\_format\_conversion\_input\_format](#input\_data\_format\_conversion\_input\_format) | Specifies which deserializer to use. You can choose either the Apache Hive JSON SerDe or the OpenX JSON SerDe | `string` | `"OpenX"` | no |
| <a name="input_data_format_conversion_openx_case_insensitive"></a> [data\_format\_conversion\_openx\_case\_insensitive](#input\_data\_format\_conversion\_openx\_case\_insensitive) | When set to true, Kinesis Data Firehose converts JSON keys to lowercase before deserializing them. | `bool` | `true` | no |
| <a name="input_data_format_conversion_openx_column_to_json_key_mappings"></a> [data\_format\_conversion\_openx\_column\_to\_json\_key\_mappings](#input\_data\_format\_conversion\_openx\_column\_to\_json\_key\_mappings) | A map of column names to JSON keys that aren't identical to the column names. This is useful when the JSON contains keys that are Hive keywords. | `map(string)` | `null` | no |
| <a name="input_data_format_conversion_openx_convert_dots_to_underscores"></a> [data\_format\_conversion\_openx\_convert\_dots\_to\_underscores](#input\_data\_format\_conversion\_openx\_convert\_dots\_to\_underscores) | Specifies that the names of the keys include dots and that you want Kinesis Data Firehose to replace them with underscores. This is useful because Apache Hive does not allow dots in column names. | `bool` | `false` | no |
| <a name="input_data_format_conversion_orc_bloom_filter_columns"></a> [data\_format\_conversion\_orc\_bloom\_filter\_columns](#input\_data\_format\_conversion\_orc\_bloom\_filter\_columns) | A list of column names for which you want Kinesis Data Firehose to create bloom filters. | `list(string)` | `[]` | no |
| <a name="input_data_format_conversion_orc_bloom_filter_false_positive_probability"></a> [data\_format\_conversion\_orc\_bloom\_filter\_false\_positive\_probability](#input\_data\_format\_conversion\_orc\_bloom\_filter\_false\_positive\_probability) | The Bloom filter false positive probability (FPP). The lower the FPP, the bigger the Bloom filter. | `number` | `0.05` | no |
| <a name="input_data_format_conversion_orc_compression"></a> [data\_format\_conversion\_orc\_compression](#input\_data\_format\_conversion\_orc\_compression) | The compression code to use over data blocks. | `string` | `"SNAPPY"` | no |
| <a name="input_data_format_conversion_orc_dict_key_threshold"></a> [data\_format\_conversion\_orc\_dict\_key\_threshold](#input\_data\_format\_conversion\_orc\_dict\_key\_threshold) | A float that represents the fraction of the total number of non-null rows. To turn off dictionary encoding, set this fraction to a number that is less than the number of distinct keys in a dictionary. To always use dictionary encoding, set this threshold to 1. | `number` | `0` | no |
| <a name="input_data_format_conversion_orc_enable_padding"></a> [data\_format\_conversion\_orc\_enable\_padding](#input\_data\_format\_conversion\_orc\_enable\_padding) | Set this to true to indicate that you want stripes to be padded to the HDFS block boundaries. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. | `bool` | `false` | no |
| <a name="input_data_format_conversion_orc_format_version"></a> [data\_format\_conversion\_orc\_format\_version](#input\_data\_format\_conversion\_orc\_format\_version) | The version of the file to write. | `string` | `"V0_12"` | no |
| <a name="input_data_format_conversion_orc_padding_tolerance"></a> [data\_format\_conversion\_orc\_padding\_tolerance](#input\_data\_format\_conversion\_orc\_padding\_tolerance) | A float between 0 and 1 that defines the tolerance for block padding as a decimal fraction of stripe size. | `number` | `0.05` | no |
| <a name="input_data_format_conversion_orc_row_index_stripe"></a> [data\_format\_conversion\_orc\_row\_index\_stripe](#input\_data\_format\_conversion\_orc\_row\_index\_stripe) | The number of rows between index entries. | `number` | `10000` | no |
| <a name="input_data_format_conversion_orc_stripe_size"></a> [data\_format\_conversion\_orc\_stripe\_size](#input\_data\_format\_conversion\_orc\_stripe\_size) | he number of bytes in each strip. | `number` | `67108864` | no |
| <a name="input_data_format_conversion_output_format"></a> [data\_format\_conversion\_output\_format](#input\_data\_format\_conversion\_output\_format) | Specifies which serializer to use. You can choose either the ORC SerDe or the Parquet SerDe | `string` | `"PARQUET"` | no |
| <a name="input_data_format_conversion_parquet_compression"></a> [data\_format\_conversion\_parquet\_compression](#input\_data\_format\_conversion\_parquet\_compression) | The compression code to use over data blocks. | `string` | `"SNAPPY"` | no |
| <a name="input_data_format_conversion_parquet_dict_compression"></a> [data\_format\_conversion\_parquet\_dict\_compression](#input\_data\_format\_conversion\_parquet\_dict\_compression) | Indicates whether to enable dictionary compression. | `bool` | `false` | no |
| <a name="input_data_format_conversion_parquet_max_padding"></a> [data\_format\_conversion\_parquet\_max\_padding](#input\_data\_format\_conversion\_parquet\_max\_padding) | The maximum amount of padding to apply. This is useful if you intend to copy the data from Amazon S3 to HDFS before querying. The value is in bytes | `number` | `0` | no |
| <a name="input_data_format_conversion_parquet_page_size"></a> [data\_format\_conversion\_parquet\_page\_size](#input\_data\_format\_conversion\_parquet\_page\_size) | Column chunks are divided into pages. A page is conceptually an indivisible unit (in terms of compression and encoding). The value is in bytes | `number` | `1048576` | no |
| <a name="input_data_format_conversion_parquet_writer_version"></a> [data\_format\_conversion\_parquet\_writer\_version](#input\_data\_format\_conversion\_parquet\_writer\_version) | Indicates the version of row format to output. | `string` | `"V1"` | no |
| <a name="input_destination"></a> [destination](#input\_destination) | This is the destination to where the data is delivered | `string` | n/a | yes |
| <a name="input_destination_log_group_name"></a> [destination\_log\_group\_name](#input\_destination\_log\_group\_name) | The CloudWatch group name for destination logs | `string` | `null` | no |
| <a name="input_destination_log_stream_name"></a> [destination\_log\_stream\_name](#input\_destination\_log\_stream\_name) | The CloudWatch log stream name for destination logs | `string` | `null` | no |
| <a name="input_dynamic_partition_append_delimiter_to_record"></a> [dynamic\_partition\_append\_delimiter\_to\_record](#input\_dynamic\_partition\_append\_delimiter\_to\_record) | To configure your delivery stream to add a new line delimiter between records in objects that are delivered to Amazon S3. | `bool` | `false` | no |
| <a name="input_dynamic_partition_enable_record_deaggregation"></a> [dynamic\_partition\_enable\_record\_deaggregation](#input\_dynamic\_partition\_enable\_record\_deaggregation) | Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter | `bool` | `false` | no |
| <a name="input_dynamic_partition_metadata_extractor_query"></a> [dynamic\_partition\_metadata\_extractor\_query](#input\_dynamic\_partition\_metadata\_extractor\_query) | Dynamic Partition JQ query. | `string` | `null` | no |
| <a name="input_dynamic_partition_record_deaggregation_delimiter"></a> [dynamic\_partition\_record\_deaggregation\_delimiter](#input\_dynamic\_partition\_record\_deaggregation\_delimiter) | Specifies the delimiter to be used for parsing through the records in the delivery stream and deaggregating them | `string` | `null` | no |
| <a name="input_dynamic_partition_record_deaggregation_type"></a> [dynamic\_partition\_record\_deaggregation\_type](#input\_dynamic\_partition\_record\_deaggregation\_type) | Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter | `string` | `"JSON"` | no |
| <a name="input_dynamic_partitioning_retry_duration"></a> [dynamic\_partitioning\_retry\_duration](#input\_dynamic\_partitioning\_retry\_duration) | Total amount of seconds Firehose spends on retries | `number` | `300` | no |
| <a name="input_elasticsearch_domain_arn"></a> [elasticsearch\_domain\_arn](#input\_elasticsearch\_domain\_arn) | The ARN of the Amazon ES domain. The pattern needs to be arn:.* | `string` | `null` | no |
| <a name="input_elasticsearch_index_name"></a> [elasticsearch\_index\_name](#input\_elasticsearch\_index\_name) | The Elasticsearch index name | `string` | `null` | no |
| <a name="input_elasticsearch_index_rotation_period"></a> [elasticsearch\_index\_rotation\_period](#input\_elasticsearch\_index\_rotation\_period) | The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data | `string` | `"OneDay"` | no |
| <a name="input_elasticsearch_retry_duration"></a> [elasticsearch\_retry\_duration](#input\_elasticsearch\_retry\_duration) | The length of time during which Firehose retries delivery after a failure, starting from the initial request and including the first attempt | `string` | `3600` | no |
| <a name="input_elasticsearch_type_name"></a> [elasticsearch\_type\_name](#input\_elasticsearch\_type\_name) | The Elasticsearch type name with maximum length of 100 characters | `string` | `null` | no |
| <a name="input_enable_data_format_conversion"></a> [enable\_data\_format\_conversion](#input\_enable\_data\_format\_conversion) | Set it to true if you want to disable format conversion. | `bool` | `false` | no |
| <a name="input_enable_destination_log"></a> [enable\_destination\_log](#input\_enable\_destination\_log) | The CloudWatch Logging Options for the delivery stream | `bool` | `true` | no |
| <a name="input_enable_dynamic_partitioning"></a> [enable\_dynamic\_partitioning](#input\_enable\_dynamic\_partitioning) | Enables or disables dynamic partitioning | `bool` | `false` | no |
| <a name="input_enable_kinesis_source"></a> [enable\_kinesis\_source](#input\_enable\_kinesis\_source) | Set it to true to use kinesis data stream as source | `bool` | `false` | no |
| <a name="input_enable_lambda_transform"></a> [enable\_lambda\_transform](#input\_enable\_lambda\_transform) | Set it to true to enable data transformation with lambda | `bool` | `false` | no |
| <a name="input_enable_s3_backup"></a> [enable\_s3\_backup](#input\_enable\_s3\_backup) | The Amazon S3 backup mode | `bool` | `false` | no |
| <a name="input_enable_s3_encryption"></a> [enable\_s3\_encryption](#input\_enable\_s3\_encryption) | Indicates if want use encryption in S3 bucket. | `bool` | `false` | no |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Whether to enable encryption at rest. Only makes sense when source is Direct Put | `bool` | `false` | no |
| <a name="input_firehose_role"></a> [firehose\_role](#input\_firehose\_role) | IAM role ARN attached to the Kinesis Firehose Stream. | `string` | `null` | no |
| <a name="input_kinesis_source_is_encrypted"></a> [kinesis\_source\_is\_encrypted](#input\_kinesis\_source\_is\_encrypted) | Indicates if Kinesis data stream source is encrypted | `bool` | `false` | no |
| <a name="input_kinesis_source_kms_arn"></a> [kinesis\_source\_kms\_arn](#input\_kinesis\_source\_kms\_arn) | Kinesis Source KMS Key to add Firehose role to decrypt the records | `string` | `null` | no |
| <a name="input_kinesis_source_role_arn"></a> [kinesis\_source\_role\_arn](#input\_kinesis\_source\_role\_arn) | The ARN of the role that provides access to the source Kinesis stream | `string` | `null` | no |
| <a name="input_kinesis_source_stream_arn"></a> [kinesis\_source\_stream\_arn](#input\_kinesis\_source\_stream\_arn) | The kinesis stream used as the source of the firehose delivery stream | `string` | `null` | no |
| <a name="input_kinesis_source_use_existing_role"></a> [kinesis\_source\_use\_existing\_role](#input\_kinesis\_source\_use\_existing\_role) | Indicates if want use the kinesis firehose role to kinesis data stream access. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | A name to identify the stream. This is unique to the AWS account and region the Stream is created in | `string` | n/a | yes |
| <a name="input_policy_path"></a> [policy\_path](#input\_policy\_path) | Path of policies to that should be added to IAM role for Kinesis Firehose Stream | `string` | `null` | no |
| <a name="input_redshift_cluster_endpoint"></a> [redshift\_cluster\_endpoint](#input\_redshift\_cluster\_endpoint) | The redshift endpoint | `string` | `null` | no |
| <a name="input_redshift_cluster_identifier"></a> [redshift\_cluster\_identifier](#input\_redshift\_cluster\_identifier) | Redshift Cluster identifier. Necessary to associate the iam role to cluster | `string` | `null` | no |
| <a name="input_redshift_copy_options"></a> [redshift\_copy\_options](#input\_redshift\_copy\_options) | Copy options for copying the data from the s3 intermediate bucket into redshift, for example to change the default delimiter | `string` | `null` | no |
| <a name="input_redshift_data_table_columns"></a> [redshift\_data\_table\_columns](#input\_redshift\_data\_table\_columns) | The data table columns that will be targeted by the copy command | `string` | `null` | no |
| <a name="input_redshift_database_name"></a> [redshift\_database\_name](#input\_redshift\_database\_name) | The redshift database name | `string` | `null` | no |
| <a name="input_redshift_password"></a> [redshift\_password](#input\_redshift\_password) | The password for the redshift username above | `string` | `null` | no |
| <a name="input_redshift_retry_duration"></a> [redshift\_retry\_duration](#input\_redshift\_retry\_duration) | The length of time during which Firehose retries delivery after a failure, starting from the initial request and including the first attempt | `string` | `3600` | no |
| <a name="input_redshift_table_name"></a> [redshift\_table\_name](#input\_redshift\_table\_name) | The name of the table in the redshift cluster that the s3 bucket will copy to | `string` | `null` | no |
| <a name="input_redshift_username"></a> [redshift\_username](#input\_redshift\_username) | The username that the firehose delivery stream will assume. It is strongly recommended that the username and password provided is used exclusively for Amazon Kinesis Firehose purposes, and that the permissions for the account are restricted for Amazon Redshift INSERT permissions | `string` | `null` | no |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Description of IAM role to use for Kinesis Firehose Stream | `string` | `null` | no |
| <a name="input_role_force_detach_policies"></a> [role\_force\_detach\_policies](#input\_role\_force\_detach\_policies) | Specifies to force detaching any policies the IAM role has before destroying it | `bool` | `true` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of IAM role to use for Kinesis Firehose Stream | `string` | `null` | no |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | Path of IAM role to use for Kinesis Firehose Stream | `string` | `null` | no |
| <a name="input_role_permissions_boundary"></a> [role\_permissions\_boundary](#input\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the IAM role used by Kinesis Firehose Stream | `string` | `null` | no |
| <a name="input_role_tags"></a> [role\_tags](#input\_role\_tags) | A map of tags to assign to IAM role | `map(string)` | `{}` | no |
| <a name="input_s3_backup_bucket_arn"></a> [s3\_backup\_bucket\_arn](#input\_s3\_backup\_bucket\_arn) | The ARN of the S3 backup bucket | `string` | `null` | no |
| <a name="input_s3_backup_buffer_interval"></a> [s3\_backup\_buffer\_interval](#input\_s3\_backup\_buffer\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. | `number` | `300` | no |
| <a name="input_s3_backup_buffer_size"></a> [s3\_backup\_buffer\_size](#input\_s3\_backup\_buffer\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. | `number` | `5` | no |
| <a name="input_s3_backup_compression"></a> [s3\_backup\_compression](#input\_s3\_backup\_compression) | The compression format | `string` | `"UNCOMPRESSED"` | no |
| <a name="input_s3_backup_create_cw_log_group"></a> [s3\_backup\_create\_cw\_log\_group](#input\_s3\_backup\_create\_cw\_log\_group) | Enables or disables the cloudwatch log group creation | `bool` | `true` | no |
| <a name="input_s3_backup_enable_encryption"></a> [s3\_backup\_enable\_encryption](#input\_s3\_backup\_enable\_encryption) | Indicates if want enable KMS Encryption in S3 Backup Bucket. | `bool` | `false` | no |
| <a name="input_s3_backup_enable_log"></a> [s3\_backup\_enable\_log](#input\_s3\_backup\_enable\_log) | Enables or disables the logging | `bool` | `true` | no |
| <a name="input_s3_backup_error_output_prefix"></a> [s3\_backup\_error\_output\_prefix](#input\_s3\_backup\_error\_output\_prefix) | Prefix added to failed records before writing them to S3 | `string` | `null` | no |
| <a name="input_s3_backup_kms_key_arn"></a> [s3\_backup\_kms\_key\_arn](#input\_s3\_backup\_kms\_key\_arn) | Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used. | `string` | `null` | no |
| <a name="input_s3_backup_log_group_name"></a> [s3\_backup\_log\_group\_name](#input\_s3\_backup\_log\_group\_name) | he CloudWatch group name for logging | `string` | `null` | no |
| <a name="input_s3_backup_log_stream_name"></a> [s3\_backup\_log\_stream\_name](#input\_s3\_backup\_log\_stream\_name) | The CloudWatch log stream name for logging | `string` | `null` | no |
| <a name="input_s3_backup_mode"></a> [s3\_backup\_mode](#input\_s3\_backup\_mode) | Defines how documents should be delivered to Amazon S3. Used to elasticsearch, splunk, http configurations. For S3 and Redshift use enable\_s3\_backup | `string` | `"FailedOnly"` | no |
| <a name="input_s3_backup_prefix"></a> [s3\_backup\_prefix](#input\_s3\_backup\_prefix) | The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `null` | no |
| <a name="input_s3_backup_role_arn"></a> [s3\_backup\_role\_arn](#input\_s3\_backup\_role\_arn) | The role that Kinesis Data Firehose can use to access S3 Backup. | `string` | `null` | no |
| <a name="input_s3_backup_use_existing_role"></a> [s3\_backup\_use\_existing\_role](#input\_s3\_backup\_use\_existing\_role) | Indicates if want use the kinesis firehose role to s3 backup bucket access. | `bool` | `true` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the S3 destination bucket | `string` | `null` | no |
| <a name="input_s3_compression_format"></a> [s3\_compression\_format](#input\_s3\_compression\_format) | The compression format | `string` | `"UNCOMPRESSED"` | no |
| <a name="input_s3_error_output_prefix"></a> [s3\_error\_output\_prefix](#input\_s3\_error\_output\_prefix) | Prefix added to failed records before writing them to S3. This prefix appears immediately following the bucket name. | `string` | `null` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used | `string` | `null` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `null` | no |
| <a name="input_splunk_hec_acknowledgment_timeout"></a> [splunk\_hec\_acknowledgment\_timeout](#input\_splunk\_hec\_acknowledgment\_timeout) | The amount of time, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data | `number` | `600` | no |
| <a name="input_splunk_hec_endpoint"></a> [splunk\_hec\_endpoint](#input\_splunk\_hec\_endpoint) | The HTTP Event Collector (HEC) endpoint to which Kinesis Firehose sends your data | `string` | `null` | no |
| <a name="input_splunk_hec_endpoint_type"></a> [splunk\_hec\_endpoint\_type](#input\_splunk\_hec\_endpoint\_type) | The HEC endpoint type | `string` | `"Raw"` | no |
| <a name="input_splunk_hec_token"></a> [splunk\_hec\_token](#input\_splunk\_hec\_token) | The GUID that you obtain from your Splunk cluster when you create a new HEC endpoint | `string` | `null` | no |
| <a name="input_splunk_retry_duration"></a> [splunk\_retry\_duration](#input\_splunk\_retry\_duration) | After an initial failure to deliver to Splunk, the total amount of time, in seconds between 0 to 7200, during which Firehose re-attempts delivery (including the first attempt) | `number` | `300` | no |
| <a name="input_sse_kms_key_arn"></a> [sse\_kms\_key\_arn](#input\_sse\_kms\_key\_arn) | Amazon Resource Name (ARN) of the encryption key | `string` | `null` | no |
| <a name="input_sse_kms_key_type"></a> [sse\_kms\_key\_type](#input\_sse\_kms\_key\_type) | Type of encryption key. | `string` | `"AWS_OWNED_CMK"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_transform_lambda_arn"></a> [transform\_lambda\_arn](#input\_transform\_lambda\_arn) | Lambda ARN to Transform source records. | `string` | `null` | no |
| <a name="input_transform_lambda_buffer_interval"></a> [transform\_lambda\_buffer\_interval](#input\_transform\_lambda\_buffer\_interval) | The period of time during which Kinesis Data Firehose buffers incoming data before invoking the AWS Lambda function. The AWS Lambda function is invoked once the value of the buffer size or the buffer interval is reached. | `number` | `60` | no |
| <a name="input_transform_lambda_buffer_size"></a> [transform\_lambda\_buffer\_size](#input\_transform\_lambda\_buffer\_size) | The AWS Lambda function has a 6 MB invocation payload quota. Your data can expand in size after it's processed by the AWS Lambda function. A smaller buffer size allows for more room should the data expand after processing. | `number` | `3` | no |
| <a name="input_transform_lambda_number_retries"></a> [transform\_lambda\_number\_retries](#input\_transform\_lambda\_number\_retries) | Number of retries for AWS Transformation lambda | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_cloudwatch_log_backup_stream_arn"></a> [kinesis\_firehose\_cloudwatch\_log\_backup\_stream\_arn](#output\_kinesis\_firehose\_cloudwatch\_log\_backup\_stream\_arn) | The ARN of the created Cloudwatch Log Group Stream to backup |
| <a name="output_kinesis_firehose_cloudwatch_log_backup_stream_name"></a> [kinesis\_firehose\_cloudwatch\_log\_backup\_stream\_name](#output\_kinesis\_firehose\_cloudwatch\_log\_backup\_stream\_name) | The name of the created Cloudwatch Log Group Stream to backup |
| <a name="output_kinesis_firehose_cloudwatch_log_delivery_stream_arn"></a> [kinesis\_firehose\_cloudwatch\_log\_delivery\_stream\_arn](#output\_kinesis\_firehose\_cloudwatch\_log\_delivery\_stream\_arn) | The ARN of the created Cloudwatch Log Group Stream to delivery |
| <a name="output_kinesis_firehose_cloudwatch_log_delivery_stream_name"></a> [kinesis\_firehose\_cloudwatch\_log\_delivery\_stream\_name](#output\_kinesis\_firehose\_cloudwatch\_log\_delivery\_stream\_name) | The name of the created Cloudwatch Log Group Stream to delivery |
| <a name="output_kinesis_firehose_cloudwatch_log_group_arn"></a> [kinesis\_firehose\_cloudwatch\_log\_group\_arn](#output\_kinesis\_firehose\_cloudwatch\_log\_group\_arn) | The ARN of the created Cloudwatch Log Group |
| <a name="output_kinesis_firehose_cloudwatch_log_group_name"></a> [kinesis\_firehose\_cloudwatch\_log\_group\_name](#output\_kinesis\_firehose\_cloudwatch\_log\_group\_name) | The name of the created Cloudwatch Log Group |
| <a name="output_kinesis_firehose_destination_id"></a> [kinesis\_firehose\_destination\_id](#output\_kinesis\_firehose\_destination\_id) | The Destination id of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_name"></a> [kinesis\_firehose\_name](#output\_kinesis\_firehose\_name) | The name of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_role_arn"></a> [kinesis\_firehose\_role\_arn](#output\_kinesis\_firehose\_role\_arn) | The ARN of the IAM role created for Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_version_id"></a> [kinesis\_firehose\_version\_id](#output\_kinesis\_firehose\_version\_id) | The Version id of the Kinesis Firehose Stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/LICENSE) for full details.