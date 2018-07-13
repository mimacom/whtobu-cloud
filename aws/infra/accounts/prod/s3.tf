resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "com.mimacom.rety.terraform-state"
  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "Terraform State Bucket"
    Environment = "production"
  }
}
