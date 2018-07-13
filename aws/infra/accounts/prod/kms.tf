resource "aws_kms_key" "default" {
  description = "Rety KMS Key"
  deletion_window_in_days = 10

  tags {
    Name = "Rety"
    Project = "Rety"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "a" {
  name = "alias/rety"
  target_key_id = "${aws_kms_key.default.key_id}"
}