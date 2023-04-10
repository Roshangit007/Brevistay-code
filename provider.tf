# provider.tf

# Specify the provider and access details
provider "aws" {
  shared_credentials_file = "/home/neosoft/.aws/credentials"
  profile                 = "test"
  region                  = var.aws_region
}