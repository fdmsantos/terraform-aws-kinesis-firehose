# Kinesis Firehose: Kinesis Data Source To S3 

Basic Configuration in this directory creates kinesis firehose stream with MSK Cluster as source and S3 bucket as destination with a basic configuration.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

* Send Message to Kafka

[Documentation](https://docs.aws.amazon.com/msk/latest/developerguide/create-serverless-cluster-client.html)

```sh
# Create Client Machine
sudo su -
sudo yum -y install java-11
wget https://archive.apache.org/dist/kafka/2.8.1/kafka_2.12-2.8.1.tgz
tar -xzf kafka_2.12-2.8.1.tgz
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar
mv aws-msk-iam-auth-1.1.1-all.jar kafka_2.12-2.8.1/libs/
vi kafka_2.12-2.8.1/bin/client.properties
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler

# Create Topic
export BS=my-endpoint
./kafka_2.12-2.8.1/bin/kafka-topics.sh --bootstrap-server $BS --command-config kafka_2.12-2.8.1/bin/client.properties --create --topic demo-topic --partitions 6

# Produce data
./kafka_2.12-2.8.1/bin/kafka-console-producer.sh --broker-list $BS --producer.config kafka_2.12-2.8.1/bin/client.properties --topic demo-topic

# Consume Data
./kafka_2.12-2.8.1/bin/kafka-console-consumer.sh --bootstrap-server $BS --consumer.config kafka_2.12-2.8.1/bin/client.properties --topic demo-topic --from-beginning
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | n/a |
| <a name="module_firehose"></a> [firehose](#module\_firehose) | ../../../ | n/a |
| <a name="module_msk_cluster"></a> [msk\_cluster](#module\_msk\_cluster) | terraform-aws-modules/msk-kafka-cluster/aws | 2.3.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | ~> 5.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_msk_cluster_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster_policy) | resource |
| [aws_s3_bucket.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use in resources | `string` | `"msk-to-s3-basic"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default Tags to be added to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kinesis_data_stream_name"></a> [kinesis\_data\_stream\_name](#output\_kinesis\_data\_stream\_name) | The name of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_arn"></a> [kinesis\_firehose\_arn](#output\_kinesis\_firehose\_arn) | The ARN of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_destination_id"></a> [kinesis\_firehose\_destination\_id](#output\_kinesis\_firehose\_destination\_id) | The Destination id of the Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_role_arn"></a> [kinesis\_firehose\_role\_arn](#output\_kinesis\_firehose\_role\_arn) | The ARN of the IAM role created for Kinesis Firehose Stream |
| <a name="output_kinesis_firehose_version_id"></a> [kinesis\_firehose\_version\_id](#output\_kinesis\_firehose\_version\_id) | The Version id of the Kinesis Firehose Stream |
| <a name="output_msk_arn"></a> [msk\_arn](#output\_msk\_arn) | MSK Topic Endpoint |
| <a name="output_msk_brokers_endpoint"></a> [msk\_brokers\_endpoint](#output\_msk\_brokers\_endpoint) | Brokers endpoints |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | S3 Bucket ARN |
| <a name="output_topic_name"></a> [topic\_name](#output\_topic\_name) | MSK Topic Name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
