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
    key = "environments/p-fra.tfstate"
    region = "eu-central-1"
    encrypt = "true"
    dynamodb_table = "terraform_state_lock"
  }
}

module "amazon_product_api" {
  source = "../../modules/lambda/amazon-product-api"
  name   = "amazon-product-api"
  environment = "p-fra"
}