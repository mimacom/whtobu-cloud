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
    Name = "${var.environment}-${var.name}-amazon-product-api"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.amazon_product_api.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.amazon_product_api.execution_arn}/*/*"
}