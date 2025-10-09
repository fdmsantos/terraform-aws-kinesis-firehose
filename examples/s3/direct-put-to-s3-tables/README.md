# Kinesis Firehose: Direct Put To S3 Tables

Configuration in this directory creates kinesis firehose stream with Direct Put as source and S3 Tabçes bucket as destination.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Current Module Limitations

* Firehose Role needs to be created outside of module

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
#
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
