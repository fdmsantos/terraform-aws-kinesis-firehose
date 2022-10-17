# Datadog

Configuration in this directory creates kinesis firehose stream with Direct Put as source and new relic as destination to Europe Metrics URL.

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
newrelic_api_key = "<newrelic_api_key>"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
