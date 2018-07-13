resource "aws_iam_role" "amazon_product_api_role" {
  name = "${var.environment}-${var.name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "kms_policy" {
  name = "${var.environment}-${var.name}-role-kms-policy"
  description = "KMS policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "${data.aws_kms_alias.default.target_key_arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role = "${aws_iam_role.amazon_product_api_role.name}"
  policy_arn = "${aws_iam_policy.kms_policy.arn}"
}