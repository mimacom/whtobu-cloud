resource "aws_lambda_function" "amazon_product_api" {
  filename = "${path.module}/amazon-product-api.zip"
  function_name = "${var.environment}-${var.name}"
  role = "${aws_iam_role.amazon_product_api_role.arn}"
  handler = "index.handler"
  source_code_hash = "${base64sha256(file("${path.module}/amazon-product-api.zip"))}"
  runtime = "nodejs8.10"
  memory_size = "256"
  timeout = "30"

  kms_key_arn = "${data.aws_kms_alias.default.target_key_arn}"

  tags {
    Name = "${var.environment}-bulktrade-v1-sms-consumer"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}