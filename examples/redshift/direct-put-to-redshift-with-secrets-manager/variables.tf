variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "direct-put-to-redshift"
}

variable "redshift_username" {
  description = "The username that the firehose delivery stream will assume. It is strongly recommended that the username and password provided is used exclusively for Amazon Kinesis Firehose purposes, and that the permissions for the account are restricted for Amazon Redshift INSERT permissions"
  type        = string
  sensitive   = true
}

variable "redshift_password" {
  description = "The password for the redshift username above"
  type        = string
  sensitive   = true
}
