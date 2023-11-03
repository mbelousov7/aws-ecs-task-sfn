provider "aws" {
  region = var.region

  # fake config for terraform plan check without aws access
  # must be deleted or overwritten in real environment
  # start fake config
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "fake_mock_access_key"
  secret_key                  = "fake_mock_secret_key"
  # enf fake config
}

