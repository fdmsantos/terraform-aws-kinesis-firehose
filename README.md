# AWS Kinesis Firehose Terraform module

[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

Dynamic Terraform module, which creates a Kinesis Firehose Stream and others resources like Cloudwatch, IAM Roles and Security Groups that integrate with Kinesis Firehose.
Supports all destinations and all Kinesis Firehose Features.

## Table of Contents

* [Table of Contents](#table-of-contents)
* [Module versioning rule](#module-versioning-rule)
* [Features](#features)
* [How to Use](#how-to-use)
  * [Sources](#sources)
    * [Kinesis Data Stream](#kinesis-data-stream)
      * [Kinesis Data Stream Encrypted](#kinesis-data-stream-encrypted)
    * [Direct Put](#direct-put)
    * [WAF](#waf)
    * [MSK](#msk)
  * [Destinations](#destinations)
    * [S3](#s3)
    * [Redshift](#redshift)
    * [Elasticsearch](#elasticsearch)
    * [Opensearch](#opensearch)
    * [Opensearch Serverless](#opensearch-serverless)
    * [Splunk](#splunk)
    * [HTTP Endpoint](#http-endpoint)
    * [Datadog](#datadog)
    * [New Relic](#new-relic)
    * [Coralogix](#coralogix)
    * [Dynatrace](#dynatrace)
    * [Honeycomb](#honeycomb)
    * [Logic Monitor](#logic-monitor)
    * [MongoDB](#mongodb)
    * [SumoLogic](#sumologic)
  * [Server Side Encryption](#server-side-encryption)
  * [Data Transformation with Lambda](#data-transformation-with-lambda)
  * [Data Format Conversion](#data-format-conversion)
  * [Dynamic Partition](#dynamic-partition)
  * [S3 Backup Data](#s3-backup-data)
  * [Destination Delivery Logging](#destination-delivery-logging)
  * [VPC Support](#vpc-support)
    * [ElasticSearch / Opensearch / Opensearch Serverless](#elasticsearch--opensearch--opensearch-serverless)
    * [Redshift / Splunk](#redshift--splunk)
  * [Application Role](#application-role)
* [Destinations Mapping](#destinations-mapping)
* [Examples](#examples)
* [Requirements](#requirements)
* [Providers](#providers)
* [Modules](#modules)
* [Resources](#resources)
* [Inputs](#inputs)
* [Outputs](#outputs)
* [Upgrade](#upgrade)
* [Deprecations](#deprecations)
  * [Version 3.1.0](#version-310)
  * [Version 3.3.0](#version-330)
* [License](#license)

## Module versioning rule

| Module version | AWS Provider version |
|----------------|----------------------|
| >= 1.x.x       | ~> 4.4               |
| >= 2.x.x       | ~> 5.0               |
| >= 3.x.x       | >= 5.33              | 

## Features

- Sources 
  - Kinesis Data Stream
  - Direct Put
  - WAF
  - MSK
- Destinations
  - S3
    - Data Format Conversion
    - Dynamic Partition
  - Redshift
    - VPC Support. Security Groups creation supported
  - ElasticSearch / Opensearch / Opensearch Serverless
    - VPC Support. Security Groups creation supported
  - Splunk
    - VPC Support. Security Groups creation supported
  - Custom Http Endpoint
  - DataDog
  - Coralogix
  - New Relic
  - Dynatrace
  - Honeycomb
  - Logic Monitor
  - MongoDB Cloud
  - Sumo Logic
- Data Transformation With Lambda
- Original Data Backup in S3
- Logging and Encryption
- Application Role to Direct Put Sources
- Turn on/off cloudwatch logs decompressing and data message extraction
- Permissions
  - IAM Roles
  - Opensearch / Opensearch Serverless Service Role
  - Associate Role to Redshift Cluster Iam Roles
  - Cross Account S3 Bucket Policy
  - Cross Account Elasticsearch / OpenSearch / Opensearch Serverless Service policy

## How to Use

### Sources

#### Kinesis Data Stream

**To Enabled it:** `input_source = "kinesis"`.

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  input_source              =  "kinesis"
  kinesis_source_stream_arn = "<kinesis_stream_arn>"
  destination               = "s3" # or destination = "extended_s3"
  s3_bucket_arn             = "<bucket_arn>"
}
```

##### Kinesis Data Stream Encrypted

If Kinesis Data Stream is encrypted, it's necessary pass this info to module .

**To Enabled It:** `input_source = "kinesis"`.

**KMS Key:** use `kinesis_source_kms_arn` variable to indicate the KMS Key to module add permissions to policy to decrypt the Kinesis Data Stream.

#### Direct Put

**To Enabled it:** `input_source = "direct-put"`.

```hcl
module "firehose" {
  source           = "fdmsantos/kinesis-firehose/aws"
  version          = "x.x.x"
  name             = "firehose-delivery-stream"
  input_source     = "direct-put"
  destination      = "s3" # or destination = "extended_s3"
  s3_bucket_arn    = "<bucket_arn>"
}
```

#### WAF

**To Enabled it:** `input_source = "waf"`.

```hcl
module "firehose" {
  source           = "fdmsantos/kinesis-firehose/aws"
  version          = "x.x.x"
  name             = "firehose-delivery-stream"
  input_source     = "waf"
  destination      = "s3" # or destination = "extended_s3"
  s3_bucket_arn    = "<bucket_arn>"
}
```

#### MSK

**To Enabled it:** `input_source = "msk"`.

```hcl
module "firehose" {
  source                 = "fdmsantos/kinesis-firehose/aws"
  version                = "x.x.x"
  name                   = "firehose-delivery-stream"
  input_source           = "msk"
  msk_source_cluster_arn = "<msk_cluster_arn>"
  msk_source_topic_name  = "test"
  destination            = "s3"
  s3_bucket_arn          = "<bucket_arn>"
}
```

### Destinations

#### S3

**To Enabled It:** `destination = "s3" or destination = "extended_s3"`

**Variables Prefix:** `s3_`

**To Enable Encryption:** `enable_s3_encryption = true`

**Note:** For other destinations, the `s3_` variables are used to configure the required intermediary bucket before delivery data to destination. Not Supported to Elasticsearch, Splunk and http destinations

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  destination               = "s3" # or destination = "extended_s3"
  s3_bucket_arn             = "<bucket_arn>"
}
```

#### Redshift

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

#### Elasticsearch

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

####  Opensearch

**To Enabled It:** `destination = "opensearch"`

**Variables Prefix:** `opensearch_` 

```hcl
module "firehose" {
  source                = "fdmsantos/kinesis-firehose/aws"
  version               = "x.x.x"
  name                  = "firehose-delivery-stream"
  destination           = "opensearch"
  opensearch_domain_arn = "<opensearch_domain_arn>"
  opensearch_index_name = "<opensearch_index_name"
}
```

####  Opensearch Serverless

**To Enabled It:** `destination = "opensearchserverless"`

**Variables Prefix:** `opensearchserverless_`

```hcl
module "firehose" {
  source                                   = "fdmsantos/kinesis-firehose/aws"
  version                                  = "x.x.x"
  name                                     = "firehose-delivery-stream"
  destination                              = "opensearch"
  opensearchserverless_collection_endpoint = "<opensearchserverless_collection_endpoint>"
  opensearchserverless_collection_arn      = "<opensearchserverless_collection_arn>"
  opensearch_index_name                    = "<opensearchserverless_index_name"
}
```

#### Splunk

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

#### HTTP Endpoint

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

#### Datadog

**To Enabled It:** `destination = "datadog"`

**Variables Prefix:** `http_endpoint_` and `datadog_endpoint_type`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and datadog destinations**

```hcl
module "firehose" {
  source                   = "fdmsantos/kinesis-firehose/aws"
  version                  = "x.x.x"
  name                     = "firehose-delivery-stream"
  destination              = "datadog"
  datadog_endpoint_type    = "metrics_eu"
  http_endpoint_access_key = "<datadog_api_key>"
}
```

#### New Relic

**To Enabled It:** `destination = "newrelic"`

**Variables Prefix:** `http_endpoint_` and `newrelic_endpoint_type`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and newrelic destinations**

```hcl
module "firehose" {
  source                   = "fdmsantos/kinesis-firehose/aws"
  version                  = "x.x.x"
  name                     = "firehose-delivery-stream"
  destination              = "newrelic"
  newrelic_endpoint_type   = "metrics_eu"
  http_endpoint_access_key = "<newrelic_api_key>"
}
```

#### Coralogix

**To Enabled It:** `destination = "coralogix"`

**Variables Prefix:** `http_endpoint_` and `coralogix_`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and coralogix destinations**

**Check [Firehose-to-Coralogix](https://coralogix.com/docs/aws-firehose/#data-source-configuration) to more details.

```hcl
module "firehose" {
  source                       = "fdmsantos/kinesis-firehose/aws"
  version                      = "x.x.x"
  name                         = "firehose-delivery-stream"
  destination                  = "coralogix"
  coralogix_endpoint_location  = "ireland"
  http_endpoint_access_key     = "<coralogix_private_key>"
}
```

#### Dynatrace

**To Enabled It:** `destination = "dynatrace"`

**Variables Prefix:** `http_endpoint_`, `dynatrace_endpoint_location` and `dynatrace_api_url`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and dynatrace destinations**

```hcl
module "firehose" {
  source                      = "fdmsantos/kinesis-firehose/aws"
  version                     = "x.x.x"
  name                        = "firehose-delivery-stream"
  destination                 = "dynatrace"
  dynatrace_endpoint_location = "eu"
  dynatrace_api_url           = "https://xyazb123456.live.dynatrace.com"
  http_endpoint_access_key    = "<dynatrace_api_token>"
}
```

#### Honeycomb

**To Enabled It:** `destination = "honeycomb"`

**Variables Prefix:** `http_endpoint_`, `honeycomb_api_host (Default: https://api.honeycomb.io)` and `honeycomb_dataset_name`. 

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and honeycomb destinations**

```hcl
module "firehose" {
  source                   = "fdmsantos/kinesis-firehose/aws"
  version                  = "x.x.x"
  name                     = "firehose-delivery-stream"
  destination              = "honeycomb"
  honeycomb_api_host       = "https://api.honeycomb.io"
  honeycomb_dataset_name   = "<honeycomb_dataset_name>"
  http_endpoint_access_key = "<honeycomb_api_key>"
}
```

#### Logic Monitor

**To Enabled It:** `destination = "logicmonitor"`

**Variables Prefix:** `http_endpoint_` and `logicmonitor_account`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and logicmonitor destinations**

```hcl
module "firehose" {
  source                   = "fdmsantos/kinesis-firehose/aws"
  version                  = "x.x.x"
  name                     = "firehose-delivery-stream"
  destination              = "logicmonitor"
  logicmonitor_account     = "<logicmonitor_account>"
  http_endpoint_access_key = "<logicmonitor_api_key>"
}
```

#### MongoDB

**To Enabled It:** `destination = "mongodb"`

**Variables Prefix:** `http_endpoint_` and `mongodb_realm_webhook_url`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and mongodb destinations**

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  destination               = "mongodb"
  mongodb_realm_webhook_url = "<mongodb_realm_webhook_url>"
  http_endpoint_access_key  = "<mongodb_api_key>"
}
```

#### SumoLogic

**To Enabled It:** `destination = "sumologic"`

**Variables Prefix:** `http_endpoint_`, `sumologic_deployment_name` and `sumologic_data_type`

**Check [HTTP Endpoint](#http-endpoint) to more details and [Destinations Mapping](#destinations-mapping) to see the difference between http_endpoint and Sumo Logic destinations**

```hcl
module "firehose" {
  source                    = "fdmsantos/kinesis-firehose/aws"
  version                   = "x.x.x"
  name                      = "firehose-delivery-stream"
  destination               = "sumologic"
  sumologic_deployment_name = "<sumologic_deployment_name>"
  sumologic_data_type       = "<sumologic_data_type>"
  http_endpoint_access_key  = "<sumologic_access_token>"
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
  destination      = "s3" # or destination = "extended_s3"
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
  input_source                     = "kinesis"
  kinesis_source_stream_arn        = "<kinesis_stream_arn>"
  destination                      = "s3" # or destination = "extended_s3"
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
  input_source                           = "kinesis"
  kinesis_source_stream_arn              = "<kinesis_stream_arn>"
  destination                            = "s3" # or destination = "extended_s3"
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
  input_source                                  = "kinesis"
  kinesis_source_stream_arn                     = "<kinesis_stream_arn>"
  destination                                   = "s3" # or destination = "extended_s3"
  s3_bucket_arn                                 = "<bucket_arn>"
  s3_prefix                                     = "prod/user_id=!{partitionKeyFromQuery:user_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
  enable_dynamic_partitioning                   = true
  dynamic_partitioning_retry_duration           = 350
  dynamic_partition_metadata_extractor_query    = "{user_id:.user_id}"
  dynamic_partition_enable_record_deaggregation = true
}

```

### S3 Backup Data

**Supported By:** All Destinations

**To Enabled It:** `enable_s3_backup = true`. It's always enable to Elasticsearch, splunk and http destinations

**To Enable Backup Encryption:** `s3_backup_enable_encryption = true`

**To Enable Backup Logging** `s3_backup_enable_log = true`. Not supported to Elasticsearch, splunk and http destinations. It's possible add existing cloudwatch group or create new

**Variables Prefix:** `s3_backup_`

```hcl
module "firehose" {
  source                        = "fdmsantos/kinesis-firehose/aws"
  version                       = "x.x.x"
  name                          = "${var.name_prefix}-delivery-stream"
  destination                   = "s3" # or destination = "extended_s3"
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
  destination                 = "s3" # or destination = "extended_s3"
  s3_bucket_arn               = "<bucket_arn>"
  enable_destination_log      = true
  destination_log_group_name  = "<cw_log_group_arn>"
  destination_log_stream_name = "<cw_log_stream_name>"
}
```

### VPC Support

It's possible use module only to create security groups.

Use variable `create = false` for this feature.

#### ElasticSearch / Opensearch / Opensearch Serverless

**Supported By:** ElasticSearch / Opensearch destination

**To Enabled It:** `enable_vpc = true`

**To Create Opensearch IAM Service Linked Role:** `vpc_create_service_linked_role = true` 

**If you want to have separate security groups for firehose and destination:** `vpc_security_group_same_as_destination = false`

**Examples**

```hcl
# Creates the Security Groups (For firehose and Destination)
module "firehose" {
  source                                               = "fdmsantos/kinesis-firehose/aws"
  version                                              = "x.x.x"
  name                                                 = "firehose-delivery-stream"
  destination                                          = "opensearch"
  opensearch_domain_arn                                = "<opensearch_domain_arn>"
  opensearch_index_name                                = "<opensearch_index_name>"
  enable_vpc                                           = true
  vpc_subnet_ids                                       = "<list(subnets_ids)>"
  vpc_create_security_group                            = true
  vpc_create_destination_security_group                = true
  elasticsearch_vpc_security_group_same_as_destination = false
}
```

```hcl
# Use Existing Security Group
module "firehose" {
  source                          = "fdmsantos/kinesis-firehose/aws"
  version                         = "x.x.x"
  name                            = "firehose-delivery-stream"
  destination                     = "opensearch"
  opensearch_domain_arn           = "<opensearch_domain_arn>"
  opensearch_index_name           = "<opensearch_index_name>"
  enable_vpc                      = true
  vpc_subnet_ids                  = "<list(subnets_ids)>"
  vpc_security_group_firehose_ids = "<list(security_group_ids)>"
}
```

```hcl
# Configure Existing Security Groups
module "firehose" {
  source                                            = "fdmsantos/kinesis-firehose/aws"
  version                                           = "x.x.x"
  name                                              = "firehose-delivery-stream"
  destination                                       = "opensearch"
  opensearch_domain_arn                             = "<opensearch_domain_arn>"
  opensearch_index_name                             = "<opensearch_index_name>"
  enable_vpc                                        = true
  vpc_subnet_ids                                    = "<list(subnets_ids)>"
  vpc_security_group_firehose_configure_existing    = true
  vpc_security_group_firehose_ids                   = "<list(security_group_ids)>"
  vpc_security_group_destination_configure_existing = true
  vpc_security_group_destination_ids                = "<list(security_group_ids)>"
}
```

#### Redshift / Splunk

**Supported By:** Redshift and Splunk destination

To Get Firehose CIDR Blocks to allow in destination security groups, use the following output: `firehose_cidr_blocks`

```hcl
# Create the Security Group (For Destination)
module "firehose" {
  source                                = "fdmsantos/kinesis-firehose/aws"
  version                               = "x.x.x"
  name                                  = "firehose-delivery-stream"
  destination                           = "<redshift|splunk>"
  vpc_create_destination_security_group = true
}
```

```hcl
# Configure Existing Security Groups
module "firehose" {
  source                                            = "fdmsantos/kinesis-firehose/aws"
  version                                           = "x.x.x"
  name                                              = "firehose-delivery-stream"
  destination                                       = "<redshift|splunk>"
  vpc_security_group_destination_configure_existing = true
  vpc_security_group_destination_ids                = "<list(security_group_ids)>"
}
```

### Application Role

**Supported By:** Direct Put Source

**To Create:** `create_application_role = true`

**To Create Policy:** `create_application_role_policy = true`

**Variables Prefix:** `application_role_`

```hcl
# Create Application Role to an application that runs in EC2 Instance
module "firehose" {
  source                             = "fdmsantos/kinesis-firehose/aws"
  version                            = "x.x.x"
  name                               = "firehose-delivery-stream"
  destination                        = "s3" # or destination = "extended_s3"
  create_application_role            = true
  create_application_role_policy     = true
  application_role_service_principal = "ec2.amazonaws.com"
}
```

```hcl
# Configure existing Application Role to an application that runs in EC2 Instance with a policy with provided actions
module "firehose" {
  source                              = "fdmsantos/kinesis-firehose/aws"
  version                             = "x.x.x"
  name                                = "firehose-delivery-stream"
  destination                         = "s3" # or destination = "extended_s3"
  configure_existing_application_role = true
  application_role_name               = "application-role"
  create_application_role_policy      = true
  application_role_policy_actions     = [
    "firehose:PutRecord",
    "firehose:PutRecordBatch",
    "firehose:CreateDeliveryStream",
    "firehose:UpdateDestination"
  ]
}
```

## Destinations Mapping

The destination variable configured in module is mapped to firehose valid destination.

| Module Destination   | Firehose Destination | Differences                                                                                                                                                                                               |
|----------------------|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s3 and extended_s3   | extended_s3          | There is no difference between s3 or extended_s3 destinations                                                                                                                                             |
| redshift             | redshift             |                                                                                                                                                                                                           |
| splunk               | splunk               |                                                                                                                                                                                                           |
| opensearch           | elasticsearch        |                                                                                                                                                                                                           |
| opensearch           | opensearch           |                                                                                                                                                                                                           |
| opensearchserverless | opensearchserverless |                                                                                                                                                                                                           |
| http_endpoint        | http_endpoint        |                                                                                                                                                                                                           |
| datadog              | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure datadog_endpoint_type variable                              |
| newrelic             | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure newrelic_endpoint_type variable                             |
| coralogix            | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure coralogix_endpoint_location variable                        |
| dynatrace            | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure dynatrace_endpoint_location and dynatrace_api_url variable  |
| honeycomb            | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure honeycomb_dataset_name variable                             |
| logicmonitor         | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure logicmonitor_account variable                               |
| mongodb              | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure mongodb_realm_webhook_url variable                          |
| sumologic            | http_endpoint        | The difference regarding http_endpoint is the http_endpoint_url and http_endpoint_name variables aren't support, and it's necessary configure sumologic_deployment_name and sumologic_data_type variables |

## Examples

- [Direct Put](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/direct-put-to-s3) - Creates an encrypted Kinesis firehose stream with Direct Put as source and S3 as destination.
- [Kinesis Data Stream Source](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/kinesis-to-s3-basic) - Creates a basic Kinesis Firehose stream with Kinesis data stream as source and s3 as destination.
- [WAF Source](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/waf-to-s3) - Creates a Kinesis Firehose Stream with AWS Web WAF as source and S3 as destination.
- [MSK Source](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/msk-to-s3) - Creates a Kinesis Firehose Stream with MSK Cluster as source and S3 as destination.
- [S3 Destination Complete](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/s3/kinesis-to-s3-complete) - Creates a Kinesis Firehose Stream with all features enabled.
- [Redshift](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/redshift/direct-put-to-redshift) - Creates a Kinesis Firehose Stream with redshift as destination.
- [Redshift In VPC](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/redshift/redshift-in-vpc) - Creates a Kinesis Firehose Stream with redshift in VPC as destination.
- [Public Opensearch](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/opensearch/direct-put-to-opensearch) - Creates a Kinesis Firehose Stream with public opensearch as destination.
- [Public Opensearch Serverless](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/opensearch/direct-put-to-opensearchserverless) - Creates a Kinesis Firehose Stream with public serverless opensearch as destination.
- [Opensearch Serverless In Vpc](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/opensearch/direct-put-to-opensearchserverless-in-vpc) - Creates a Kinesis Firehose Stream with serverless opensearch in VPC as destination.
- [Public Splunk](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/splunk/public-splunk) - Creates a Kinesis Firehose Stream with public splunk as destination.
- [Splunk In VPC](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/splunk/splunk-in-vpc) - Creates a Kinesis Firehose Stream with splunk in VPC as destination.
- [Custom Http Endpoint](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/custom-http-endpoint) - Creates a Kinesis Firehose Stream with custom http endpoint as destination.
- [Datadog](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/datadog) - Creates a Kinesis Firehose Stream with datadog europe metrics as destination.
- [New Relic](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/newrelic) - Creates a Kinesis Firehose Stream with New Relic europe metrics as destination.
- [Coralogix](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/coralogix) - Creates a Kinesis Firehose Stream with coralogix ireland as destination.
- [Dynatrace](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/dynatrace) - Creates a Kinesis Firehose Stream with dynatrace europe as destination.
- [Honeycomb](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/honeycomb) - Creates a Kinesis Firehose Stream with honeycomb as destination.
- [LogicMonitor](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/logicmonitor) - Creates a Kinesis Firehose Stream with Logic Monitor as destination.
- [MongoDB](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/mongodb) - Creates a Kinesis Firehose Stream with MongoDB as destination.
- [SumoLogic](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/examples/http-endpoint/sumologic) - Creates a Kinesis Firehose Stream with Sumo Logic as destination.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.33 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.33 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_iam_policy.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.opensearchserverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.opensearchserverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_iam_service_linked_role.opensearchserverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_kinesis_firehose_delivery_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_redshift_cluster_iam_roles.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster_iam_roles) | resource |
| [aws_security_group.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.firehose_egress_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.application_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_opensearchserverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cross_account_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.glue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kinesis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.opensearchserverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_append_delimiter_to_record"></a> [append\_delimiter\_to\_record](#input\_append\_delimiter\_to\_record) | To configure your delivery stream to add a new line delimiter between records in objects that are delivered to Amazon S3. | `bool` | `false` | no |
| <a name="input_application_role_description"></a> [application\_role\_description](#input\_application\_role\_description) | Description of IAM Application role to use for Kinesis Firehose Stream Source | `string` | `null` | no |
| <a name="input_application_role_force_detach_policies"></a> [application\_role\_force\_detach\_policies](#input\_application\_role\_force\_detach\_policies) | Specifies to force detaching any policies the IAM Application role has before destroying it | `bool` | `true` | no |
| <a name="input_application_role_name"></a> [application\_role\_name](#input\_application\_role\_name) | Name of IAM Application role to use for Kinesis Firehose Stream Source | `string` | `null` | no |
| <a name="input_application_role_path"></a> [application\_role\_path](#input\_application\_role\_path) | Path of IAM Application role to use for Kinesis Firehose Stream Source | `string` | `null` | no |
| <a name="input_application_role_permissions_boundary"></a> [application\_role\_permissions\_boundary](#input\_application\_role\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the IAM Application role used by Kinesis Firehose Stream Source | `string` | `null` | no |
| <a name="input_application_role_policy_actions"></a> [application\_role\_policy\_actions](#input\_application\_role\_policy\_actions) | List of Actions to Application Role Policy | `list(string)` | <pre>[<br>  "firehose:PutRecord",<br>  "firehose:PutRecordBatch"<br>]</pre> | no |
| <a name="input_application_role_service_principal"></a> [application\_role\_service\_principal](#input\_application\_role\_service\_principal) | AWS Service Principal to assume application role | `string` | `null` | no |
| <a name="input_application_role_tags"></a> [application\_role\_tags](#input\_application\_role\_tags) | A map of tags to assign to IAM Application role | `map(string)` | `{}` | no |
| <a name="input_associate_role_to_redshift_cluster"></a> [associate\_role\_to\_redshift\_cluster](#input\_associate\_role\_to\_redshift\_cluster) | Set it to false if don't want the module associate the role to redshift cluster | `bool` | `true` | no |
| <a name="input_buffering_interval"></a> [buffering\_interval](#input\_buffering\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination | `number` | `300` | no |
| <a name="input_buffering_size"></a> [buffering\_size](#input\_buffering\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. | `number` | `5` | no |
| <a name="input_configure_existing_application_role"></a> [configure\_existing\_application\_role](#input\_configure\_existing\_application\_role) | Set it to True if want use existing application role to add the firehose Policy | `bool` | `false` | no |
| <a name="input_coralogix_endpoint_location"></a> [coralogix\_endpoint\_location](#input\_coralogix\_endpoint\_location) | Endpoint Location to coralogix destination | `string` | `"ireland"` | no |
| <a name="input_coralogix_parameter_application_name"></a> [coralogix\_parameter\_application\_name](#input\_coralogix\_parameter\_application\_name) | By default, your delivery stream arn will be used as applicationName | `string` | `null` | no |
| <a name="input_coralogix_parameter_subsystem_name"></a> [coralogix\_parameter\_subsystem\_name](#input\_coralogix\_parameter\_subsystem\_name) | By default, your delivery stream name will be used as subsystemName | `string` | `null` | no |
| <a name="input_coralogix_parameter_use_dynamic_values"></a> [coralogix\_parameter\_use\_dynamic\_values](#input\_coralogix\_parameter\_use\_dynamic\_values) | To use dynamic values for applicationName and subsystemName | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if kinesis firehose should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_create_application_role"></a> [create\_application\_role](#input\_create\_application\_role) | Set it to true to create role to be used by the source | `bool` | `false` | no |
| <a name="input_create_application_role_policy"></a> [create\_application\_role\_policy](#input\_create\_application\_role\_policy) | Set it to true to create policy to the role used by the source | `bool` | `false` | no |
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
| <a name="input_datadog_endpoint_type"></a> [datadog\_endpoint\_type](#input\_datadog\_endpoint\_type) | Endpoint type to datadog destination | `string` | `"logs_eu"` | no |
| <a name="input_destination"></a> [destination](#input\_destination) | This is the destination to where the data is delivered | `string` | n/a | yes |
| <a name="input_destination_cross_account"></a> [destination\_cross\_account](#input\_destination\_cross\_account) | Indicates if destination is in a different account. Only supported to Elasticsearch and OpenSearch | `bool` | `false` | no |
| <a name="input_destination_log_group_name"></a> [destination\_log\_group\_name](#input\_destination\_log\_group\_name) | The CloudWatch group name for destination logs | `string` | `null` | no |
| <a name="input_destination_log_stream_name"></a> [destination\_log\_stream\_name](#input\_destination\_log\_stream\_name) | The CloudWatch log stream name for destination logs | `string` | `null` | no |
| <a name="input_dynamic_partition_append_delimiter_to_record"></a> [dynamic\_partition\_append\_delimiter\_to\_record](#input\_dynamic\_partition\_append\_delimiter\_to\_record) | DEPRECATED!! Use var append\_delimiter\_to\_record instead!! Use To configure your delivery stream to add a new line delimiter between records in objects that are delivered to Amazon S3. | `bool` | `false` | no |
| <a name="input_dynamic_partition_enable_record_deaggregation"></a> [dynamic\_partition\_enable\_record\_deaggregation](#input\_dynamic\_partition\_enable\_record\_deaggregation) | Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter | `bool` | `false` | no |
| <a name="input_dynamic_partition_metadata_extractor_query"></a> [dynamic\_partition\_metadata\_extractor\_query](#input\_dynamic\_partition\_metadata\_extractor\_query) | Dynamic Partition JQ query. | `string` | `null` | no |
| <a name="input_dynamic_partition_record_deaggregation_delimiter"></a> [dynamic\_partition\_record\_deaggregation\_delimiter](#input\_dynamic\_partition\_record\_deaggregation\_delimiter) | Specifies the delimiter to be used for parsing through the records in the delivery stream and deaggregating them | `string` | `null` | no |
| <a name="input_dynamic_partition_record_deaggregation_type"></a> [dynamic\_partition\_record\_deaggregation\_type](#input\_dynamic\_partition\_record\_deaggregation\_type) | Data deaggregation is the process of parsing through the records in a delivery stream and separating the records based either on valid JSON or on the specified delimiter | `string` | `"JSON"` | no |
| <a name="input_dynamic_partitioning_retry_duration"></a> [dynamic\_partitioning\_retry\_duration](#input\_dynamic\_partitioning\_retry\_duration) | Total amount of seconds Firehose spends on retries | `number` | `300` | no |
| <a name="input_dynatrace_api_url"></a> [dynatrace\_api\_url](#input\_dynatrace\_api\_url) | API URL to Dynatrace destination | `string` | `null` | no |
| <a name="input_dynatrace_endpoint_location"></a> [dynatrace\_endpoint\_location](#input\_dynatrace\_endpoint\_location) | Endpoint Location to Dynatrace destination | `string` | `"eu"` | no |
| <a name="input_elasticsearch_domain_arn"></a> [elasticsearch\_domain\_arn](#input\_elasticsearch\_domain\_arn) | The ARN of the Amazon ES domain. The pattern needs to be arn:.* | `string` | `null` | no |
| <a name="input_elasticsearch_index_name"></a> [elasticsearch\_index\_name](#input\_elasticsearch\_index\_name) | The Elasticsearch index name | `string` | `null` | no |
| <a name="input_elasticsearch_index_rotation_period"></a> [elasticsearch\_index\_rotation\_period](#input\_elasticsearch\_index\_rotation\_period) | The Elasticsearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data | `string` | `"OneDay"` | no |
| <a name="input_elasticsearch_retry_duration"></a> [elasticsearch\_retry\_duration](#input\_elasticsearch\_retry\_duration) | The length of time during which Firehose retries delivery after a failure, starting from the initial request and including the first attempt | `string` | `300` | no |
| <a name="input_elasticsearch_type_name"></a> [elasticsearch\_type\_name](#input\_elasticsearch\_type\_name) | The Elasticsearch type name with maximum length of 100 characters | `string` | `null` | no |
| <a name="input_enable_cloudwatch_logs_data_message_extraction"></a> [enable\_cloudwatch\_logs\_data\_message\_extraction](#input\_enable\_cloudwatch\_logs\_data\_message\_extraction) | Cloudwatch Logs data message extraction | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_logs_decompression"></a> [enable\_cloudwatch\_logs\_decompression](#input\_enable\_cloudwatch\_logs\_decompression) | Enables or disables Cloudwatch Logs decompression | `bool` | `false` | no |
| <a name="input_enable_data_format_conversion"></a> [enable\_data\_format\_conversion](#input\_enable\_data\_format\_conversion) | Set it to true if you want to disable format conversion. | `bool` | `false` | no |
| <a name="input_enable_destination_log"></a> [enable\_destination\_log](#input\_enable\_destination\_log) | The CloudWatch Logging Options for the delivery stream | `bool` | `true` | no |
| <a name="input_enable_dynamic_partitioning"></a> [enable\_dynamic\_partitioning](#input\_enable\_dynamic\_partitioning) | Enables or disables dynamic partitioning | `bool` | `false` | no |
| <a name="input_enable_lambda_transform"></a> [enable\_lambda\_transform](#input\_enable\_lambda\_transform) | Set it to true to enable data transformation with lambda | `bool` | `false` | no |
| <a name="input_enable_s3_backup"></a> [enable\_s3\_backup](#input\_enable\_s3\_backup) | The Amazon S3 backup mode | `bool` | `false` | no |
| <a name="input_enable_s3_encryption"></a> [enable\_s3\_encryption](#input\_enable\_s3\_encryption) | Indicates if want use encryption in S3 bucket. | `bool` | `false` | no |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Whether to enable encryption at rest. Only makes sense when source is Direct Put | `bool` | `false` | no |
| <a name="input_enable_vpc"></a> [enable\_vpc](#input\_enable\_vpc) | Indicates if destination is configured in VPC. Supports Elasticsearch and Opensearch destinations. | `bool` | `false` | no |
| <a name="input_firehose_role"></a> [firehose\_role](#input\_firehose\_role) | IAM role ARN attached to the Kinesis Firehose Stream. | `string` | `null` | no |
| <a name="input_honeycomb_api_host"></a> [honeycomb\_api\_host](#input\_honeycomb\_api\_host) | If you use a Secure Tenancy or other proxy, put its schema://host[:port] here | `string` | `"https://api.honeycomb.io"` | no |
| <a name="input_honeycomb_dataset_name"></a> [honeycomb\_dataset\_name](#input\_honeycomb\_dataset\_name) | Your Honeycomb dataset name to Honeycomb destination | `string` | `null` | no |
| <a name="input_http_endpoint_access_key"></a> [http\_endpoint\_access\_key](#input\_http\_endpoint\_access\_key) | The access key required for Kinesis Firehose to authenticate with the HTTP endpoint selected as the destination | `string` | `null` | no |
| <a name="input_http_endpoint_enable_request_configuration"></a> [http\_endpoint\_enable\_request\_configuration](#input\_http\_endpoint\_enable\_request\_configuration) | The request configuration | `bool` | `false` | no |
| <a name="input_http_endpoint_name"></a> [http\_endpoint\_name](#input\_http\_endpoint\_name) | The HTTP endpoint name | `string` | `null` | no |
| <a name="input_http_endpoint_request_configuration_common_attributes"></a> [http\_endpoint\_request\_configuration\_common\_attributes](#input\_http\_endpoint\_request\_configuration\_common\_attributes) | Describes the metadata sent to the HTTP endpoint destination. The variable is list. Each element is map with two keys , name and value, that corresponds to common attribute name and value | `list(map(string))` | `[]` | no |
| <a name="input_http_endpoint_request_configuration_content_encoding"></a> [http\_endpoint\_request\_configuration\_content\_encoding](#input\_http\_endpoint\_request\_configuration\_content\_encoding) | Kinesis Data Firehose uses the content encoding to compress the body of a request before sending the request to the destination | `string` | `"GZIP"` | no |
| <a name="input_http_endpoint_retry_duration"></a> [http\_endpoint\_retry\_duration](#input\_http\_endpoint\_retry\_duration) | Total amount of seconds Firehose spends on retries. This duration starts after the initial attempt fails, It does not include the time periods during which Firehose waits for acknowledgment from the specified destination after each attempt | `number` | `300` | no |
| <a name="input_http_endpoint_url"></a> [http\_endpoint\_url](#input\_http\_endpoint\_url) | The HTTP endpoint URL to which Kinesis Firehose sends your data | `string` | `null` | no |
| <a name="input_input_source"></a> [input\_source](#input\_input\_source) | This is the kinesis firehose source | `string` | `"direct-put"` | no |
| <a name="input_kinesis_source_is_encrypted"></a> [kinesis\_source\_is\_encrypted](#input\_kinesis\_source\_is\_encrypted) | Indicates if Kinesis data stream source is encrypted | `bool` | `false` | no |
| <a name="input_kinesis_source_kms_arn"></a> [kinesis\_source\_kms\_arn](#input\_kinesis\_source\_kms\_arn) | Kinesis Source KMS Key to add Firehose role to decrypt the records. | `string` | `null` | no |
| <a name="input_kinesis_source_role_arn"></a> [kinesis\_source\_role\_arn](#input\_kinesis\_source\_role\_arn) | DEPRECATED!! Use variable instead source\_role\_arn! The ARN of the role that provides access to the source Kinesis stream | `string` | `null` | no |
| <a name="input_kinesis_source_stream_arn"></a> [kinesis\_source\_stream\_arn](#input\_kinesis\_source\_stream\_arn) | The kinesis stream used as the source of the firehose delivery stream | `string` | `null` | no |
| <a name="input_kinesis_source_use_existing_role"></a> [kinesis\_source\_use\_existing\_role](#input\_kinesis\_source\_use\_existing\_role) | DEPRECATED!! Use variable source\_use\_existing\_role instead! Indicates if want use the kinesis firehose role to kinesis data stream access. | `bool` | `true` | no |
| <a name="input_logicmonitor_account"></a> [logicmonitor\_account](#input\_logicmonitor\_account) | Account to use in Logic Monitor destination | `string` | `null` | no |
| <a name="input_mongodb_realm_webhook_url"></a> [mongodb\_realm\_webhook\_url](#input\_mongodb\_realm\_webhook\_url) | Realm Webhook URL to use in MongoDB destination | `string` | `null` | no |
| <a name="input_msk_source_cluster_arn"></a> [msk\_source\_cluster\_arn](#input\_msk\_source\_cluster\_arn) | The ARN of the Amazon MSK cluster. | `string` | `null` | no |
| <a name="input_msk_source_connectivity_type"></a> [msk\_source\_connectivity\_type](#input\_msk\_source\_connectivity\_type) | The type of connectivity used to access the Amazon MSK cluster. Valid values: PUBLIC, PRIVATE. | `string` | `"PUBLIC"` | no |
| <a name="input_msk_source_topic_name"></a> [msk\_source\_topic\_name](#input\_msk\_source\_topic\_name) | The topic name within the Amazon MSK cluster. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | A name to identify the stream. This is unique to the AWS account and region the Stream is created in | `string` | n/a | yes |
| <a name="input_newrelic_endpoint_type"></a> [newrelic\_endpoint\_type](#input\_newrelic\_endpoint\_type) | Endpoint type to New Relic destination | `string` | `"logs_eu"` | no |
| <a name="input_opensearch_document_id_options"></a> [opensearch\_document\_id\_options](#input\_opensearch\_document\_id\_options) | The method for setting up document ID. | `string` | `"FIREHOSE_DEFAULT"` | no |
| <a name="input_opensearch_domain_arn"></a> [opensearch\_domain\_arn](#input\_opensearch\_domain\_arn) | The ARN of the Amazon Opensearch domain. The pattern needs to be arn:.*. Conflicts with cluster\_endpoint. | `string` | `null` | no |
| <a name="input_opensearch_index_name"></a> [opensearch\_index\_name](#input\_opensearch\_index\_name) | The Opensearch (And OpenSearch Serverless) index name. | `string` | `null` | no |
| <a name="input_opensearch_index_rotation_period"></a> [opensearch\_index\_rotation\_period](#input\_opensearch\_index\_rotation\_period) | The Opensearch index rotation period. Index rotation appends a timestamp to the IndexName to facilitate expiration of old data | `string` | `"OneDay"` | no |
| <a name="input_opensearch_retry_duration"></a> [opensearch\_retry\_duration](#input\_opensearch\_retry\_duration) | After an initial failure to deliver to Amazon OpenSearch, the total amount of time, in seconds between 0 to 7200, during which Firehose re-attempts delivery (including the first attempt). After this time has elapsed, the failed documents are written to Amazon S3. The default value is 300s. There will be no retry if the value is 0. | `string` | `300` | no |
| <a name="input_opensearch_type_name"></a> [opensearch\_type\_name](#input\_opensearch\_type\_name) | The opensearch type name with maximum length of 100 characters. Types are deprecated in OpenSearch\_1.1. TypeName must be empty. | `string` | `null` | no |
| <a name="input_opensearch_vpc_create_service_linked_role"></a> [opensearch\_vpc\_create\_service\_linked\_role](#input\_opensearch\_vpc\_create\_service\_linked\_role) | Set it to True if want create Opensearch Service Linked Role to Access VPC. | `bool` | `false` | no |
| <a name="input_opensearchserverless_collection_arn"></a> [opensearchserverless\_collection\_arn](#input\_opensearchserverless\_collection\_arn) | The ARN of the Amazon Opensearch Serverless Collection. The pattern needs to be arn:.*. | `string` | `null` | no |
| <a name="input_opensearchserverless_collection_endpoint"></a> [opensearchserverless\_collection\_endpoint](#input\_opensearchserverless\_collection\_endpoint) | The endpoint to use when communicating with the collection in the Serverless offering for Amazon OpenSearch Service. | `string` | `null` | no |
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
| <a name="input_s3_backup_buffering_interval"></a> [s3\_backup\_buffering\_interval](#input\_s3\_backup\_buffering\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. | `number` | `300` | no |
| <a name="input_s3_backup_buffering_size"></a> [s3\_backup\_buffering\_size](#input\_s3\_backup\_buffering\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. | `number` | `5` | no |
| <a name="input_s3_backup_compression"></a> [s3\_backup\_compression](#input\_s3\_backup\_compression) | The compression format | `string` | `"UNCOMPRESSED"` | no |
| <a name="input_s3_backup_create_cw_log_group"></a> [s3\_backup\_create\_cw\_log\_group](#input\_s3\_backup\_create\_cw\_log\_group) | Enables or disables the cloudwatch log group creation | `bool` | `true` | no |
| <a name="input_s3_backup_enable_encryption"></a> [s3\_backup\_enable\_encryption](#input\_s3\_backup\_enable\_encryption) | Indicates if want enable KMS Encryption in S3 Backup Bucket. | `bool` | `false` | no |
| <a name="input_s3_backup_enable_log"></a> [s3\_backup\_enable\_log](#input\_s3\_backup\_enable\_log) | Enables or disables the logging | `bool` | `true` | no |
| <a name="input_s3_backup_error_output_prefix"></a> [s3\_backup\_error\_output\_prefix](#input\_s3\_backup\_error\_output\_prefix) | Prefix added to failed records before writing them to S3 | `string` | `null` | no |
| <a name="input_s3_backup_kms_key_arn"></a> [s3\_backup\_kms\_key\_arn](#input\_s3\_backup\_kms\_key\_arn) | Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used. | `string` | `null` | no |
| <a name="input_s3_backup_log_group_name"></a> [s3\_backup\_log\_group\_name](#input\_s3\_backup\_log\_group\_name) | he CloudWatch group name for logging | `string` | `null` | no |
| <a name="input_s3_backup_log_stream_name"></a> [s3\_backup\_log\_stream\_name](#input\_s3\_backup\_log\_stream\_name) | The CloudWatch log stream name for logging | `string` | `null` | no |
| <a name="input_s3_backup_mode"></a> [s3\_backup\_mode](#input\_s3\_backup\_mode) | Defines how documents should be delivered to Amazon S3. Used to elasticsearch, opensearch, splunk, http configurations. For S3 and Redshift use enable\_s3\_backup | `string` | `"FailedOnly"` | no |
| <a name="input_s3_backup_prefix"></a> [s3\_backup\_prefix](#input\_s3\_backup\_prefix) | The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `null` | no |
| <a name="input_s3_backup_role_arn"></a> [s3\_backup\_role\_arn](#input\_s3\_backup\_role\_arn) | The role that Kinesis Data Firehose can use to access S3 Backup. | `string` | `null` | no |
| <a name="input_s3_backup_use_existing_role"></a> [s3\_backup\_use\_existing\_role](#input\_s3\_backup\_use\_existing\_role) | Indicates if want use the kinesis firehose role to s3 backup bucket access. | `bool` | `true` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the S3 destination bucket | `string` | `null` | no |
| <a name="input_s3_compression_format"></a> [s3\_compression\_format](#input\_s3\_compression\_format) | The compression format | `string` | `"UNCOMPRESSED"` | no |
| <a name="input_s3_configuration_buffering_interval"></a> [s3\_configuration\_buffering\_interval](#input\_s3\_configuration\_buffering\_interval) | Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination. | `number` | `300` | no |
| <a name="input_s3_configuration_buffering_size"></a> [s3\_configuration\_buffering\_size](#input\_s3\_configuration\_buffering\_size) | Buffer incoming data to the specified size, in MBs, before delivering it to the destination. The default value is 5. We recommend setting SizeInMBs to a value greater than the amount of data you typically ingest into the delivery stream in 10 seconds. For example, if you typically ingest data at 1 MB/sec set SizeInMBs to be 10 MB or higher. | `number` | `5` | no |
| <a name="input_s3_cross_account"></a> [s3\_cross\_account](#input\_s3\_cross\_account) | Indicates if S3 bucket destination is in a different account | `bool` | `false` | no |
| <a name="input_s3_error_output_prefix"></a> [s3\_error\_output\_prefix](#input\_s3\_error\_output\_prefix) | Prefix added to failed records before writing them to S3. This prefix appears immediately following the bucket name. | `string` | `null` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | Specifies the KMS key ARN the stream will use to encrypt data. If not set, no encryption will be used | `string` | `null` | no |
| <a name="input_s3_own_bucket"></a> [s3\_own\_bucket](#input\_s3\_own\_bucket) | Indicates if you own the bucket. If not, will be configure permissions to grants the bucket owner full access to the objects delivered by Kinesis Data Firehose | `bool` | `true` | no |
| <a name="input_s3_prefix"></a> [s3\_prefix](#input\_s3\_prefix) | The YYYY/MM/DD/HH time format prefix is automatically used for delivered S3 files. You can specify an extra prefix to be added in front of the time format prefix. Note that if the prefix ends with a slash, it appears as a folder in the S3 bucket | `string` | `null` | no |
| <a name="input_source_role_arn"></a> [source\_role\_arn](#input\_source\_role\_arn) | The ARN of the role that provides access to the source. Only Supported on Kinesis and MSK Sources | `string` | `null` | no |
| <a name="input_source_use_existing_role"></a> [source\_use\_existing\_role](#input\_source\_use\_existing\_role) | Indicates if want use the kinesis firehose role for sources access. Only Supported on Kinesis and MSK Sources | `bool` | `true` | no |
| <a name="input_splunk_hec_acknowledgment_timeout"></a> [splunk\_hec\_acknowledgment\_timeout](#input\_splunk\_hec\_acknowledgment\_timeout) | The amount of time, that Kinesis Firehose waits to receive an acknowledgment from Splunk after it sends it data | `number` | `600` | no |
| <a name="input_splunk_hec_endpoint"></a> [splunk\_hec\_endpoint](#input\_splunk\_hec\_endpoint) | The HTTP Event Collector (HEC) endpoint to which Kinesis Firehose sends your data | `string` | `null` | no |
| <a name="input_splunk_hec_endpoint_type"></a> [splunk\_hec\_endpoint\_type](#input\_splunk\_hec\_endpoint\_type) | The HEC endpoint type | `string` | `"Raw"` | no |
| <a name="input_splunk_hec_token"></a> [splunk\_hec\_token](#input\_splunk\_hec\_token) | The GUID that you obtain from your Splunk cluster when you create a new HEC endpoint | `string` | `null` | no |
| <a name="input_splunk_retry_duration"></a> [splunk\_retry\_duration](#input\_splunk\_retry\_duration) | After an initial failure to deliver to Splunk, the total amount of time, in seconds between 0 to 7200, during which Firehose re-attempts delivery (including the first attempt) | `number` | `300` | no |
| <a name="input_sse_kms_key_arn"></a> [sse\_kms\_key\_arn](#input\_sse\_kms\_key\_arn) | Amazon Resource Name (ARN) of the encryption key | `string` | `null` | no |
| <a name="input_sse_kms_key_type"></a> [sse\_kms\_key\_type](#input\_sse\_kms\_key\_type) | Type of encryption key. | `string` | `"AWS_OWNED_CMK"` | no |
| <a name="input_sumologic_data_type"></a> [sumologic\_data\_type](#input\_sumologic\_data\_type) | Data Type to use in Sumo Logic destination | `string` | `"log"` | no |
| <a name="input_sumologic_deployment_name"></a> [sumologic\_deployment\_name](#input\_sumologic\_deployment\_name) | Deployment Name to use in Sumo Logic destination | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_transform_lambda_arn"></a> [transform\_lambda\_arn](#input\_transform\_lambda\_arn) | Lambda ARN to Transform source records | `string` | `null` | no |
| <a name="input_transform_lambda_buffer_interval"></a> [transform\_lambda\_buffer\_interval](#input\_transform\_lambda\_buffer\_interval) | The period of time during which Kinesis Data Firehose buffers incoming data before invoking the AWS Lambda function. The AWS Lambda function is invoked once the value of the buffer size or the buffer interval is reached. | `number` | `60` | no |
| <a name="input_transform_lambda_buffer_size"></a> [transform\_lambda\_buffer\_size](#input\_transform\_lambda\_buffer\_size) | The AWS Lambda function has a 6 MB invocation payload quota. Your data can expand in size after it's processed by the AWS Lambda function. A smaller buffer size allows for more room should the data expand after processing. | `number` | `3` | no |
| <a name="input_transform_lambda_number_retries"></a> [transform\_lambda\_number\_retries](#input\_transform\_lambda\_number\_retries) | Number of retries for AWS Transformation lambda | `number` | `3` | no |
| <a name="input_transform_lambda_role_arn"></a> [transform\_lambda\_role\_arn](#input\_transform\_lambda\_role\_arn) | The ARN of the role to execute the transform lambda. If null use the Firehose Stream role | `string` | `null` | no |
| <a name="input_vpc_create_destination_security_group"></a> [vpc\_create\_destination\_security\_group](#input\_vpc\_create\_destination\_security\_group) | Indicates if want create destination security group to associate to firehose destinations | `bool` | `false` | no |
| <a name="input_vpc_create_security_group"></a> [vpc\_create\_security\_group](#input\_vpc\_create\_security\_group) | Indicates if want create security group to associate to kinesis firehose | `bool` | `false` | no |
| <a name="input_vpc_role_arn"></a> [vpc\_role\_arn](#input\_vpc\_role\_arn) | The ARN of the IAM role to be assumed by Firehose for calling the Amazon EC2 configuration API and for creating network interfaces. Supports Elasticsearch and Opensearch destinations. | `string` | `null` | no |
| <a name="input_vpc_security_group_destination_configure_existing"></a> [vpc\_security\_group\_destination\_configure\_existing](#input\_vpc\_security\_group\_destination\_configure\_existing) | Indicates if want configure an existing destination security group with the necessary rules | `bool` | `false` | no |
| <a name="input_vpc_security_group_destination_ids"></a> [vpc\_security\_group\_destination\_ids](#input\_vpc\_security\_group\_destination\_ids) | A list of security group IDs associated to destinations to allow firehose traffic | `list(string)` | `null` | no |
| <a name="input_vpc_security_group_destination_vpc_id"></a> [vpc\_security\_group\_destination\_vpc\_id](#input\_vpc\_security\_group\_destination\_vpc\_id) | VPC ID to create the destination security group. Only supported to Redshift and splunk destinations | `string` | `null` | no |
| <a name="input_vpc_security_group_firehose_configure_existing"></a> [vpc\_security\_group\_firehose\_configure\_existing](#input\_vpc\_security\_group\_firehose\_configure\_existing) | Indicates if want configure an existing firehose security group with the necessary rules | `bool` | `false` | no |
| <a name="input_vpc_security_group_firehose_ids"></a> [vpc\_security\_group\_firehose\_ids](#input\_vpc\_security\_group\_firehose\_ids) | A list of security group IDs to associate with Kinesis Firehose. | `list(string)` | `null` | no |
| <a name="input_vpc_security_group_same_as_destination"></a> [vpc\_security\_group\_same\_as\_destination](#input\_vpc\_security\_group\_same\_as\_destination) | Indicates if the firehose security group is the same as destination. | `bool` | `true` | no |
| <a name="input_vpc_security_group_tags"></a> [vpc\_security\_group\_tags](#input\_vpc\_security\_group\_tags) | A map of tags to assign to security group | `map(string)` | `{}` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | A list of subnet IDs to associate with Kinesis Firehose. Supports Elasticsearch and Opensearch destinations. | `list(string)` | `null` | no |
| <a name="input_vpc_use_existing_role"></a> [vpc\_use\_existing\_role](#input\_vpc\_use\_existing\_role) | Indicates if want use the kinesis firehose role to VPC access. Supports Elasticsearch and Opensearch destinations. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_role_arn"></a> [application\_role\_arn](#output\_application\_role\_arn) | The ARN of the IAM role created for Kinesis Firehose Stream Source |
| <a name="output_application_role_name"></a> [application\_role\_name](#output\_application\_role\_name) | The Name of the IAM role created for Kinesis Firehose Stream Source Source |
| <a name="output_application_role_policy_arn"></a> [application\_role\_policy\_arn](#output\_application\_role\_policy\_arn) | The ARN of the IAM policy created for Kinesis Firehose Stream Source |
| <a name="output_application_role_policy_name"></a> [application\_role\_policy\_name](#output\_application\_role\_policy\_name) | The Name of the IAM policy created for Kinesis Firehose Stream Source Source |
| <a name="output_destination_security_group_id"></a> [destination\_security\_group\_id](#output\_destination\_security\_group\_id) | Security Group ID associated to destination |
| <a name="output_destination_security_group_name"></a> [destination\_security\_group\_name](#output\_destination\_security\_group\_name) | Security Group Name associated to destination |
| <a name="output_destination_security_group_rule_ids"></a> [destination\_security\_group\_rule\_ids](#output\_destination\_security\_group\_rule\_ids) | Security Group Rules ID created in Destination Security group |
| <a name="output_elasticsearch_cross_account_service_policy"></a> [elasticsearch\_cross\_account\_service\_policy](#output\_elasticsearch\_cross\_account\_service\_policy) | Elasticsearch Service policy when the opensearch domain belongs to another account |
| <a name="output_firehose_cidr_blocks"></a> [firehose\_cidr\_blocks](#output\_firehose\_cidr\_blocks) | Firehose stream cidr blocks to unblock on destination security group |
| <a name="output_firehose_security_group_id"></a> [firehose\_security\_group\_id](#output\_firehose\_security\_group\_id) | Security Group ID associated to Firehose Stream. Only Supported for elasticsearch destination |
| <a name="output_firehose_security_group_name"></a> [firehose\_security\_group\_name](#output\_firehose\_security\_group\_name) | Security Group Name associated to Firehose Stream. Only Supported for elasticsearch destination |
| <a name="output_firehose_security_group_rule_ids"></a> [firehose\_security\_group\_rule\_ids](#output\_firehose\_security\_group\_rule\_ids) | Security Group Rules ID created in Firehose Stream Security group. Only Supported for elasticsearch destination |
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
| <a name="output_opensearch_cross_account_service_policy"></a> [opensearch\_cross\_account\_service\_policy](#output\_opensearch\_cross\_account\_service\_policy) | Opensearch Service policy when the opensearch domain belongs to another account |
| <a name="output_opensearch_iam_service_linked_role_arn"></a> [opensearch\_iam\_service\_linked\_role\_arn](#output\_opensearch\_iam\_service\_linked\_role\_arn) | The ARN of the Opensearch IAM Service linked role |
| <a name="output_opensearchserverless_cross_account_service_policy"></a> [opensearchserverless\_cross\_account\_service\_policy](#output\_opensearchserverless\_cross\_account\_service\_policy) | Opensearch Serverless Service policy when the opensearch domain belongs to another account |
| <a name="output_opensearchserverless_iam_service_linked_role_arn"></a> [opensearchserverless\_iam\_service\_linked\_role\_arn](#output\_opensearchserverless\_iam\_service\_linked\_role\_arn) | The ARN of the Opensearch Serverless IAM Service linked role |
| <a name="output_s3_cross_account_bucket_policy"></a> [s3\_cross\_account\_bucket\_policy](#output\_s3\_cross\_account\_bucket\_policy) | Bucket Policy to S3 Bucket Destination when the bucket belongs to another account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Upgrade

- Version 1.x to 2.x Upgrade Guide [here](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/blob/main/UPGRADE-2.0.md)
- Version 2.x to 3.x Upgrade Guide [here](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/blob/main/UPGRADE-3.0.md)


## Deprecations

### Version 3.1.0

* Variable `kinesis_source_role_arn` is deprecated. Use `source_role_arn` instead.
* Variable `kinesis_source_use_existing_role` is deprecated. Use `source_use_existing_role` instead.

### Version 3.3.0

* Variable `dynamic_partition_append_delimiter_to_record` is deprecated. Use `append_delimiter_to_record` instead.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/fdmsantos/terraform-aws-kinesis-firehose/tree/main/LICENSE) for full details.
