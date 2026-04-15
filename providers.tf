provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = var.credentials_files
}

provider "random" {}

provider "null" {}