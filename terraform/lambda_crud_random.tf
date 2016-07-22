variable "get_random_prod_function_version" {
  default = "2"
}

variable "put_random_prod_function_version" {
  default = "2"
}

resource "aws_iam_role" "lambda_crud_random_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      }
    }
  ]
}
EOF
  name = "lambda_crud_random_exec"
}

resource "aws_iam_role_policy" "lambda_crud_random_exec" {
  name = "lambda_crud_random_exec"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.s-random.arn}",
        "${aws_dynamodb_table.random.arn}"
      ]
    }
  ]
}
EOF
  role = "${aws_iam_role.lambda_crud_random_exec.id}"
}

# {{{ get_random

resource "aws_lambda_function" "get_random" {
  description = "Get the code."
  filename = "../aws_lambda/crud_random.zip"
  function_name = "get_random"
  handler = "get_random.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_crud_random_exec.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("../aws_lambda/crud_random.zip"))}"
  timeout = 3
}

resource "aws_lambda_alias" "get_random_staging" {
  description = "staging"
  function_name = "${aws_lambda_function.get_random.arn}"
  function_version = "$LATEST"
  name = "staging"
}

resource "aws_lambda_alias" "get_random_prod" {
  description = "production"
  function_name = "${aws_lambda_function.get_random.arn}"
  function_version = "${var.get_random_prod_function_version}"
  name = "prod"
}

resource "aws_lambda_permission" "get_random_staging_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_random.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.get_random_staging.name}"
  statement_id = "get_random_staging_apigateway"
}

resource "aws_lambda_permission" "get_random_prod_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.get_random.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.get_random_prod.name}"
  statement_id = "get_random_prod_apigateway"
}

# }}} get_random

# {{{ put_random

resource "aws_lambda_function" "put_random" {
  description = "Get the code."
  filename = "../aws_lambda/crud_random.zip"
  function_name = "put_random"
  handler = "put_random.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_crud_random_exec.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("../aws_lambda/crud_random.zip"))}"
  timeout = 3
}

resource "aws_lambda_alias" "put_random_staging" {
  description = "staging"
  function_name = "${aws_lambda_function.put_random.arn}"
  function_version = "$LATEST"
  name = "staging"
}

resource "aws_lambda_alias" "put_random_prod" {
  description = "production"
  function_name = "${aws_lambda_function.put_random.arn}"
  function_version = "${var.put_random_prod_function_version}"
  name = "prod"
}

resource "aws_lambda_permission" "put_random_staging_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.put_random.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.put_random_staging.name}"
  statement_id = "put_random_staging_apigateway"
}

resource "aws_lambda_permission" "put_random_prod_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.put_random.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.put_random_prod.name}"
  statement_id = "put_random_prod_apigateway"
}

# }}} put_random

# vim: set fdm=marker:
