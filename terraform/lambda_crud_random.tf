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

module "aws_lambda_function_for_apigateway_get_random" {
  source = "./modules/aws_lambda_function_for_apigateway"
  description = "Get the code."
  filename = "../aws_lambda/crud_random.zip"
  function_name = "get_random"
  handler = "get_random.main"
  memory_size = 128
  prod_function_version = "3"
  role = "${aws_iam_role.lambda_crud_random_exec.arn}"
  runtime = "python2.7"
  timeout = 3
}

module "aws_lambda_function_for_apigateway_put_random" {
  source = "./modules/aws_lambda_function_for_apigateway"
  description = "Get the code."
  filename = "../aws_lambda/crud_random.zip"
  function_name = "put_random"
  handler = "put_random.main"
  memory_size = 128
  prod_function_version = "3"
  role = "${aws_iam_role.lambda_crud_random_exec.arn}"
  runtime = "python2.7"
  timeout = 3
}
