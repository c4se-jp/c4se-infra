variable "heartbeat_ok_prod_function_version" {
  default = "2"
}

resource "aws_iam_role" "lambda_heartbeat_ok_exec" {
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
  name = "lambda_heartbeat_ok_exec"
}

resource "aws_lambda_function" "heartbeat_ok" {
  description = "Dummy heartbeat endpoint."
  filename = "../aws_lambda/heartbeat_ok.zip"
  function_name = "heartbeat_ok"
  handler = "main.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_heartbeat_ok_exec.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("../aws_lambda/heartbeat_ok.zip"))}"
  timeout = 3
}

resource "aws_lambda_alias" "heartbeat_ok_staging" {
  description = "staging"
  function_name = "${aws_lambda_function.heartbeat_ok.arn}"
  function_version = "$LATEST"
  name = "staging"
}

resource "aws_lambda_alias" "heartbeat_ok_prod" {
  description = "production"
  function_name = "${aws_lambda_function.heartbeat_ok.arn}"
  function_version = "${var.heartbeat_ok_prod_function_version}"
  name = "prod"
}

resource "aws_lambda_permission" "heartbeat_ok_staging_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.heartbeat_ok.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.heartbeat_ok_staging.name}"
  statement_id = "heartbeat_ok_staging_apigateway"
}

resource "aws_lambda_permission" "heartbeat_ok_prod_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.heartbeat_ok.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "${aws_lambda_alias.heartbeat_ok_prod.name}"
  statement_id = "heartbeat_ok_prod_apigateway"
}
