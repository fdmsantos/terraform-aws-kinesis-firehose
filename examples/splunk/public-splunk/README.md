# Public Splunk

Configuration in this directory creates kinesis firehose stream with Direct Put as source and Splunk as destination.

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
splunk_hec_endpoint      = "https://http-inputs-mydomain.splunkcloud.com:443"
splunk_hec_endpoint_type = "<Raw|Event>"
splunk_hec_token         = "<splunk_hec_token>"
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
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"firehose-to-splunk"` | no |
| <a name="input_splunk_hec_endpoint"></a> [splunk\_hec\_endpoint](#input\_splunk\_hec\_endpoint) | Splunk Hec Endpoint | `string` | n/a | yes |
| <a name="input_splunk_hec_endpoint_type"></a> [splunk\_hec\_endpoint\_type](#input\_splunk\_hec\_endpoint\_type) | Splunk Hec Endpoint Type | `string` | n/a | yes |
| <a name="input_splunk_hec_token"></a> [splunk\_hec\_token](#input\_splunk\_hec\_token) | Splunk Hec Token | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_role"></a> [firehose\_role](#output\_firehose\_role) | Firehose Role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
