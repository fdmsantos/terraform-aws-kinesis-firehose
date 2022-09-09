variable "name_prefix" {
  type    = string
  default = "kinesis-to-s3-complete"
}

variable "lambda_arn" {
  type = string
}

variable "glue_database_name" {
  type = string
}

variable "glue_table_name" {
  type = string
}
