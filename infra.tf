variable "aws_access_key" {}

variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  region = "ap-northeast-1"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_iam_role" "lambda_heartbeat_ok_exec_role" {
  assume_role_policy = "${file("files/lambda_heartbeat_ok_exec_role_policy.json")}"
  name = "lambda_heartbeat_ok_exec_role"
}

resource "aws_iam_policy_attachment" "lambda_heartbeat_ok_exec_role_AWSLambdaBasicExecutionRole_attachment" {
  name = "lambda_heartbeat_ok_exec_role_AWSLambdaBasicExecutionRole_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles = ["${aws_iam_role.lambda_heartbeat_ok_exec_role.name}"]
}

resource "aws_lambda_function" "heartbeat-ok" {
  description = "Dummy heartbeat endpoint."
  filename = "aws-lambda/heartbeat-ok.zip"
  function_name = "heartbeat-ok"
  handler = "main.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_heartbeat_ok_exec_role.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("aws-lambda/heartbeat-ok.zip"))}"
  timeout = 3
}
