variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-coralogix"
}

variable "coralogix_private_key" {
  description = "Coralogix Access Key"
  type        = string
  sensitive   = true
}
