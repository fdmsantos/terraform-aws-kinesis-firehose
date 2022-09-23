variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-public-es"
}

variable "es_username" {
  description = "ES Username"
  type        = string
  default     = null
  sensitive   = true
}

variable "es_password" {
  description = "ES Password"
  type        = string
  default     = null
  sensitive   = true
}
