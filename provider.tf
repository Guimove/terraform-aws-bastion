
# provider.tf

# Specify the provider and access details
provider "aws" {
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "default"
  region                  = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "lcdp-terraform-remote-store"
    key = "bastion.tfstate"
    region = "eu-west-3"
  }
}