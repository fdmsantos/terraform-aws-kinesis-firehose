resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-destination-bucket-${random_pet.this.id}"
  force_destroy = true
}

module "lambda_function" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "lambda"
  description   = "My awesome lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  source_path   = "lambda"

}

module "firehose" {
  source                  = "../../../"
  name                    = "${var.name_prefix}-delivery-stream"
  input_source            = "direct-put"
  destination             = "s3"
  s3_bucket_arn           = aws_s3_bucket.s3.arn
  enable_lambda_transform = true
  transform_lambda_arn    = module.lambda_function.lambda_function_arn
}
