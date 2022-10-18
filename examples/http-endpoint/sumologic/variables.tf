variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-sumologic"
}

variable "sumologic_deployment_name" {
  description = "SumoLogic Deployment Name"
  type        = string
}

variable "sumologic_data_type" {
  description = "Sumo Logic Data Type"
  type        = string
  validation {
    error_message = "Please use a valid data type!"
    condition     = contains(["log", "metric"], var.sumologic_data_type)
  }
}

variable "sumologic_access_token" {
  description = "Sumo Logic Access Token"
  type        = string
  sensitive   = true
}
