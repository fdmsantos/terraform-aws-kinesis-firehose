# Kinesis Firehose: Kinesis Data Source To S3 

Basic Configuration in this directory creates kinesis firehose stream with Kinesis Data Stream as source and S3 bucket as destination with a basic configuration.

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
