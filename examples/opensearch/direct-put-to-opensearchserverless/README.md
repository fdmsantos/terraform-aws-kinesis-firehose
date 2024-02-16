# Public Opensearch Serverless

Configuration in this directory creates kinesis firehose stream with Direct Put as source and Opensearch Serverless as destination.

This example can be tested with Demo Data in Kinesis Firehose Console.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

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
| [aws_opensearchserverless_access_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_collection.os](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | resource |
| [aws_opensearchserverless_security_policy.networking](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.security_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"firehose-to-public-opensearch"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_os_domain"></a> [os\_domain](#output\_os\_domain) | Opensearch Serverless Collection Endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
