variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-logicmonitor"
}

variable "logicmonitor_account" {
  description = "Logic Monitor Api Account"
  type        = string
}

variable "logicmonitor_api_key" {
  description = "Logic Monitor Api key"
  type        = string
  sensitive   = true
}
