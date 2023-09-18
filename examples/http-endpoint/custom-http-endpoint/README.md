# Http Endpoint

Configuration in this directory creates kinesis firehose stream with Direct Put as source and custom http endpoint as destination.

This example can be tested with Demo Data in Kinesis Firehose Console.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

It's necessary configure the following variables:

```hcl
http_endpoint_name       = "<http_endpoint_name>"
http_endpoint_url        = "<http_endpoint_url>"
http_endpoint_access_key = "<http_endpoint_access_key>"
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
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_http_endpoint_access_key"></a> [http\_endpoint\_access\_key](#input\_http\_endpoint\_access\_key) | Http Endpoint Access Key | `string` | n/a | yes |
| <a name="input_http_endpoint_name"></a> [http\_endpoint\_name](#input\_http\_endpoint\_name) | Http Endpoint Name | `string` | n/a | yes |
| <a name="input_http_endpoint_url"></a> [http\_endpoint\_url](#input\_http\_endpoint\_url) | Http Endpoint URL | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"firehose"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_role"></a> [firehose\_role](#output\_firehose\_role) | Firehose Role |
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_destination_id"></a> [kinesis\_firehose\_destination\_id](#output\_kinesis\_firehose\_destination\_id) | The Destination id of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_version_id"></a> [kinesis\_firehose\_version\_id](#output\_kinesis\_firehose\_version\_id) | The Version id of the Kinesis Firehose Stream |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
