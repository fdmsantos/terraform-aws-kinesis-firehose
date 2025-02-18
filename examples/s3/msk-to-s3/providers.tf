provider "aws" {
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  default_tags {
    tags = var.tags
  }
}
