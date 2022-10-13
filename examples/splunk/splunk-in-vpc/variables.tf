variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "firehose-to-splunk"
}

variable "splunk_hec_endpoint" {
  description = "Splunk Hec Endpoint"
  type        = string
}

variable "splunk_hec_endpoint_type" {
  description = "Splunk Hec Endpoint Type"
  type        = string
}

variable "splunk_hec_token" {
  description = "Splunk Hec Token"
  type        = string
  sensitive   = true
}


variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Redshift AZs"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "vpc_private_subnets" {
  description = "VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  description = "VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
