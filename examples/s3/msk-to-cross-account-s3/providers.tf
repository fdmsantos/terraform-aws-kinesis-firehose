provider "aws" {
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  assume_role {
    role_arn = var.aws_role_arn
  }
}

provider "aws" {
  alias                       = "account2"
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  assume_role {
    role_arn = var.msk_aws_account_role_arn
  }
}
