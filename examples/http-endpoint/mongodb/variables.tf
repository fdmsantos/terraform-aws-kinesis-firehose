variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-mongodb"
}

variable "mongodb_realm_webhook_url" {
  description = "MongoDB Realm Webhook URL"
  type        = string
}

variable "mongodb_api_key" {
  description = "MongoDB Api Key"
  type        = string
  sensitive   = true
}
