# Splunk In VPC

Configuration in this directory creates kinesis firehose stream with Direct Put as source and Splunk within VPC as destination.

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
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"firehose-to-splunk"` | no |
| <a name="input_splunk_hec_endpoint"></a> [splunk\_hec\_endpoint](#input\_splunk\_hec\_endpoint) | Splunk Hec Endpoint | `string` | n/a | yes |
| <a name="input_splunk_hec_endpoint_type"></a> [splunk\_hec\_endpoint\_type](#input\_splunk\_hec\_endpoint\_type) | Splunk Hec Endpoint Type | `string` | n/a | yes |
| <a name="input_splunk_hec_token"></a> [splunk\_hec\_token](#input\_splunk\_hec\_token) | Splunk Hec Token | `string` | n/a | yes |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | Redshift AZs | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | VPC Private Subnets | `list(string)` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC Public Subnets | `list(string)` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24",<br>  "10.0.103.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_security_group_rule_ids"></a> [destination\_security\_group\_rule\_ids](#output\_destination\_security\_group\_rule\_ids) | Security Group Rules ID created in Destination Security group |
| <a name="output_firehose_cidr_blocks"></a> [firehose\_cidr\_blocks](#output\_firehose\_cidr\_blocks) | Firehose stream cidr blocks to unblock on destination security group |
| <a name="output_firehose_role"></a> [firehose\_role](#output\_firehose\_role) | Firehose Role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
