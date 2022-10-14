variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose"
}

variable "http_endpoint_name" {
  description = "Http Endpoint Name"
  type        = string
}

variable "http_endpoint_url" {
  description = "Http Endpoint URL"
  type        = string
}

variable "http_endpoint_access_key" {
  description = "Http Endpoint Access Key"
  type        = string
  sensitive   = true
}
