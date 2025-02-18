variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "msk-to-s3-basic"
}

variable "tags" {
  description = "Default Tags to be added to all resources."
  type        = map(string)
  default     = {}
}
