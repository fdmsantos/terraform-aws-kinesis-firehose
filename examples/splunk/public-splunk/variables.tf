variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-splunk"
}

variable "splunk_hec_endpoint" {
  description = "Splunk Hec Endpoint"
  type        = string
}

variable "splunk_hec_endpoint_type" {
  description = "Splunk Hec Endpoint Type"
  type        = string
}

variable "splunk_hec_token" {
  description = "Splunk Hec Token"
  type        = string
  sensitive   = true
}
