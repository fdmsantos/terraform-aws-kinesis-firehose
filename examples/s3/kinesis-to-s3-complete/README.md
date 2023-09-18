# Kinesis Firehose: Kinesis Data Source To S3

Configuration in this directory creates kinesis firehose stream with Kinesis Data Stream as source and S3 bucket as destination with a basic configuration.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

Can use the following command to send records to Kinesis Data Stream.

```shell
aws kinesis put-record \
  --stream-name $(terraform output -json | jq -r .kinesis_data_stream_name.value) \
  --cli-binary-format raw-in-base64-out \
  --data '{"user_id":"user1", "score": 100}' \
  --partition-key 1
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_firehose"></a> [firehose](#module\_firehose) | ../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kinesis_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_kms_key.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.s3_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_glue_database_name"></a> [glue\_database\_name](#input\_glue\_database\_name) | GLUE Database name to Data Format Conversion | `string` | n/a | yes |
| <a name="input_glue_table_name"></a> [glue\_table\_name](#input\_glue\_table\_name) | GLUE Table name to Data Format Conversion | `string` | n/a | yes |
| <a name="input_lambda_arn"></a> [lambda\_arn](#input\_lambda\_arn) | ARN of AWS Lambda to use in data transformation | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"kinesis-to-s3-complete"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kinesis_data_stream_name"></a> [kinesis\_data\_stream\_name](#output\_kinesis\_data\_stream\_name) | The name of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_destination_id"></a> [kinesis\_firehose\_destination\_id](#output\_kinesis\_firehose\_destination\_id) | The Destination id of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_role_arn"></a> [kinesis\_firehose\_role\_arn](#output\_kinesis\_firehose\_role\_arn) | The ARN of the IAM role created for Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_version_id"></a> [kinesis\_firehose\_version\_id](#output\_kinesis\_firehose\_version\_id) | The Version id of the Kinesis Firehose Stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
