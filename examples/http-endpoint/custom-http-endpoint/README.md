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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
