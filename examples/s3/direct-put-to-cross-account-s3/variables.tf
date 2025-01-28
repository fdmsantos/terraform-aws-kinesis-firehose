variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "direct-put-to-s3"
}

variable "aws_role_arn" {
  description = "AWS Account 1 ARN Role"
  type        = string
}

variable "aws_account_2_role_arn" {
  description = "AWS Account 2 ARN Role"
  type        = string
}
