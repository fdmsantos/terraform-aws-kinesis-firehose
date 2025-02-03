variable "aws_role_arn" {
  description = "AWS Account 1 ARN Role"
  type        = string
}

variable "msk_aws_account_role_arn" {
  description = "AWS Account 2 ARN Role"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "msk-to-cross-account-s3-basic"
}

variable "msk_aws_account_id" {
  description = "MSK AWS Account ID"
  type        = string
}
