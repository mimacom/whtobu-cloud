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
                "kms:*"
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


resource "aws_iam_policy" "secretsmanager_policy" {
  name = "${var.environment}-${var.name}-role-secretsmanager-policy"
  description = "Secrets Manager policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:::secret:lambda/${var.name}",
                "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:lambda/${var.name}",
                "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:lambda/${var.name}-*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "secretsmanager_policy_attachment" {
  role = "${aws_iam_role.amazon_product_api_role.name}"
  policy_arn = "${aws_iam_policy.secretsmanager_policy.arn}"
}

resource "aws_iam_policy" "log_policy" {
  name = "${var.environment}-${var.name}-role-log-policy"
  description = "Log policy"
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
         ],
         "Resource":[
            "arn:aws:logs:*"
         ]
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "log_policy_attachment" {
  role = "${aws_iam_role.amazon_product_api_role.name}"
  policy_arn = "${aws_iam_policy.log_policy.arn}"
}