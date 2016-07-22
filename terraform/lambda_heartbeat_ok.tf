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

module "aws_lambda_function_for_apigateway_heartbeat_ok" {
  source = "./modules/aws_lambda_function_for_apigateway"
  description = "Get the code."
  filename = "../aws_lambda/heartbeat_ok.zip"
  function_name = "heartbeat_ok"
  handler = "main.main"
  memory_size = 128
  prod_function_version = "3"
  role = "${aws_iam_role.lambda_heartbeat_ok_exec.arn}"
  runtime = "python2.7"
  timeout = 3
}
