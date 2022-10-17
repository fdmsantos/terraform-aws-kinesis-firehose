variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-newrelic"
}

variable "newrelic_api_key" {
  description = "New Relic Api Key"
  type        = string
  sensitive   = true
}
