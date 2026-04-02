provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["/home/kuba/.aws/credentials"]
}

provider "random" {}

provider "null" {}