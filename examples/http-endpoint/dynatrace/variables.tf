variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-dynatrace"
}

variable "dynatrace_api_token" {
  description = "Dynatrace Api Token"
  type        = string
  sensitive   = true
}

variable "dynatrace_api_url" {
  description = "Dynatrace Api url"
  type        = string
}
