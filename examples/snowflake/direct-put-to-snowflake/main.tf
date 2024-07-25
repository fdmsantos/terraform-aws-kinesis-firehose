resource "random_pet" "this" {
  length = 2
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name_prefix}-dest-bucket-${random_pet.this.id}"
  force_destroy = true
}

resource "aws_kms_key" "this" {
  description             = "${var.name_prefix}-kms-key"
  deletion_window_in_days = 7
}

module "firehose" {
  source                               = "../../../"
  name                                 = "${var.name_prefix}-delivery-stream"
  destination                          = "snowflake"
  snowflake_account_identifier         = "demo"
  snowflake_private_key                = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDIQEU9NvCE4EyK0QZtFBLYWX6KAnNmel4zHsNJ4WEjNzY/YEASrJ9YtHjxItVig4kQqumn8FWkbPoKLUYUqIq9UBIvtjzlsTgMJ7GznShsm0M/n1Bszqmxwm1AwFAPfH21h2MNIzXkHitg/2BN3bkTGctmySFOwNRRervo5HIUtr4qqYZwVYDQtT8+NVL1Tchvgkv4kOuQmDXpmc7iRPx0WQZU1dyPzJ9Vg5sN2nJPZwfRTL0dJfoOVOjJQTZSAEvNw3d05ez0aKBMWYM97ZFc6IJzaSEx19RYjPnluYWlpkUp309cIUlGQHGmVSxPpaoOrI5cfHTdudCzYmQiRxebAgMBAAECggEAA+/5zIx/8Pav2plXqyu50SI1WSHlwm4iFM/LbRsu30WrJQFPwvx10kyFPrOoXBxbNoYvkPQqagmiShYozhn1nGenehyTfEqztV15xi0rnyTXgNRcC2pRhGrCbGcCvcM2DAHewlRQoTsh9uM7ByQIbp798QYqnTbbTsPw+kLt34jpz3eJjFMqB+uVtLuFDA4PZi1Nq/EJhWyuwi3taW2dKn3gx0DD69yxq5lS8USV/XQ0BrF4bbcmQoEJuKnt16hMGl9PMDkqX9DPnrxBR6a9BDMaOw/r4kyOXQBgPIRr59UfN13E1Lj35rXnK6C0TcA98pichFFYjiUvR5ss+Ob7KQKBgQD9ZHqGlI+s826ov4XTbnhcxUGBFX1NHoU9zE28w6bs2++0Bim+jMgwIdJmG7ziOsV9PpvP5Zq3N2tPnkSEA+q8N+BtfBOf60kjpe4eoaYOZiGFpqGPmAW9p+b+gWsOxyUQ2HA9FdUCwEnnWx1gIdJ5BFo4YIEdJWx3Uybw1fxtswKBgQDKT8yizQ0y0dzaCyxNeIIzYpg8Cx77tvV0EFBhDQIt/fEZOIBruBZUaZYaZReEv7VHd6bIGKASDFOx7XtdhlVbfa2p5o/7rPYlAhgsCwfW94ESYJw0X3KTlS9ulSseF+bmPBHIIXPfjARcJIDi4TKv60vbW1Wdxcv08uvFTvjKeQKBgDDeEt8ngXnqTJoQrZ9z+5Rwmkxpt4uK6klbwFY6KVQeqmC+m4hbIDRgIXJ9wPSkPvgDfgsfDbJt5q0pKa+IDdoUsJyMxEAgIS/VzVFs/Vhji+15kEjgGaNU4TCOBvaHo3dXNnYhYr4wFVCf+s9SVoPuOfQLcHsNf5iXmbfynMcPAoGBAKeZPBmSbWCwYplvsB/tuU8AWsVDIUO96dFgwnXj5O5c9SLDn/+c3ULIxcTQAo/CkVbHVK9nVxQciilYZ16vLn9AumGJ07XXL4KxHX0/FhuLpq2mw0DP4YdJi6W8hZ/EhVAuazy0Gd4TjHkY9Hz/upHqB0mNfHvbpH8jzxYBujFhAoGBAMn0LHHuaajivswiK9QpM95qv2tk1wC7spZQXh2Ky4TYcTo3S83datye7Uk85NKYt4790anaGjegA6cTbuky8FgnGm1+iqVhyGxfUMPwREgWOZ3km0DeQGHxApYHiVx2xD6oZzTVpgxM7S6pCX2YxxWQolq7mIfOg5h6U6b5GmiT"
  snowflake_user                       = "user"
  snowflake_database                   = "database"
  snowflake_schema                     = "schema"
  snowflake_table                      = "table"
  snowflake_data_loading_option        = "VARIANT_CONTENT_AND_METADATA_MAPPING"
  snowflake_metadata_column_name       = "test"
  snowflake_content_column_name        = "test"
  snowflake_role_configuration_enabled = true
  snowflake_role_configuration_role    = "snowflake_role"
  s3_backup_mode                       = "FailedOnly"
  s3_backup_prefix                     = "backup/"
  s3_backup_bucket_arn                 = aws_s3_bucket.s3.arn
  s3_backup_buffering_interval         = 100
  s3_backup_buffering_size             = 100
  s3_backup_compression                = "GZIP"
  s3_backup_enable_encryption          = true
  s3_backup_kms_key_arn                = aws_kms_key.this.arn
}
