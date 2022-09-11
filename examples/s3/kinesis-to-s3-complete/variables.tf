variable "name_prefix" {
  description = "Name prefix to use in resources"
  type        = string
  default     = "kinesis-to-s3-complete"
}

variable "lambda_arn" {
  description = "ARN of AWS Lambda to use in data transformation"
  type        = string
}

variable "glue_database_name" {
  description = "GLUE Database name to Data Format Conversion"
  type        = string
}

variable "glue_table_name" {
  description = "GLUE Table name to Data Format Conversion"
  type        = string
}
