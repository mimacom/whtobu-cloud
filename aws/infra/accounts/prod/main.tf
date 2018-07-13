provider "aws" {
  region = "eu-central-1"
  allowed_account_ids = [
    "152842245101"
  ]
}

terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket = "com.mimacom.rety.terraform-state"
    key = "accounts/production.tfstate"
    region = "eu-central-1"
    dynamodb_table = "terraform_state_lock"
  }
}
