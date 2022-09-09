variable "lambda_arn" {
  type    = string
  default = null
}

variable "glue_database" {
  type    = string
  default = null
}

variable "glue_table" {
  type    = string
  default = null
}

variable "s3_backup_kms_key" {
  type = string
  default = null
}