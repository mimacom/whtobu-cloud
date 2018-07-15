resource "aws_api_gateway_rest_api" "amazon_product_api" {
  name = "${var.environment}-${var.name}-amazon-product-api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.amazon_product_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  resource_id             = "${aws_api_gateway_method.proxy.resource_id}"
  http_method             = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.amazon_product_api.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.amazon_product_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id             = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  resource_id             = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method             = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.amazon_product_api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "amazon_product_api" {
  depends_on  = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  //  stage_description = "Deployed at: ${timestamp()}"

  rest_api_id = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  stage_name  = "${var.environment}"
}

resource "aws_api_gateway_domain_name" "amazon_product_api_rety_io" {
  domain_name     = "amazon-product-api.rety.io"
  certificate_arn = "${aws_acm_certificate.certificate.arn}"
}

resource "aws_api_gateway_base_path_mapping" "base_path_mapping" {
  api_id      = "${aws_api_gateway_rest_api.amazon_product_api.id}"
  stage_name  = "${aws_api_gateway_deployment.amazon_product_api.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.amazon_product_api_rety_io.domain_name}"
}

data "aws_route53_zone" amazon_product_api_rety_io {
  name = "rety.io"
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "amazon_product_api_rety_io" {
  zone_id = "${data.aws_route53_zone.amazon_product_api_rety_io.id}"
  # See aws_route53_zone for how to create this

  name    = "amazon-product-api.rety.io"
  type    = "A"

  alias {
    name                   = "${aws_api_gateway_domain_name.amazon_product_api_rety_io.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.amazon_product_api_rety_io.cloudfront_zone_id}"
    evaluate_target_health = true
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "US_EAST_1"
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = "amazon-product-api.rety.io"
  validation_method = "DNS"

  tags {
    Environment = "${var.environment}"
  }

  provider          = "aws.US_EAST_1"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.amazon_product_api_rety_io.zone_id}"
  records = [
    "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = "${aws_acm_certificate.certificate.arn}"
  validation_record_fqdns = [
    "${aws_route53_record.cert_validation.fqdn}"]

  provider                = "aws.US_EAST_1"
}
