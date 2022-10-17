variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-honeycomb"
}

variable "honeycomb_dataset_name" {
  description = "Honeycomb Api Key"
  type        = string
}

variable "honeycomb_api_key" {
  description = "Honeycomb Api Key"
  type        = string
  sensitive   = true
}
