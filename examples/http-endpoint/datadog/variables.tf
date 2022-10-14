variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-datadog"
}

variable "http_endpoint_access_key" {
  description = "Datadog Access Key"
  type        = string
  sensitive   = true
}
