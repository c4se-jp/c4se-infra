variable "aws_access_key" {}

variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  region = "ap-northeast-1"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_route53_zone" "primary" {
  name = "c4se.jp"
}

resource "aws_route53_record" "root_a_record" {
  name = "c4se.jp"
  records = ["219.94.162.102"]
  ttl = "300"
  type = "A"
  zone_id = "${aws_route53_zone.primary.zone_id}"
}

resource "aws_iam_role" "lambda_heartbeat_ok_exec_role" {
  assume_role_policy = "${file("files/lambda_heartbeat_ok_exec_role_policy.json")}"
  name = "lambda_heartbeat_ok_exec_role"
}

resource "aws_iam_policy_attachment" "lambda_heartbeat_ok_exec_role_AWSLambdaExecute_attachment" {
  name = "lambda_heartbeat_ok_exec_role_AWSLambdaExecute_attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
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

resource "aws_lambda_permission" "heartbeat_ok_apigateway_permission" {
  statement_id = "heartbeat_ok_apigateway_permission"
  action = "lambda:InvokeFunction"
  function_name = "heartbeat-ok"
  principal = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "heartbeat_api" {
  description = "Dummy heartbeat endpoint."
  name = "heartbeat_api"
}

resource "aws_api_gateway_resource" "heartbeat_api_heartbeat_resource" {
  parent_id = "${aws_api_gateway_rest_api.heartbeat_api.root_resource_id}"
  path_part = "heartbeat"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
}

resource "aws_api_gateway_resource" "heartbeat_api_heartbeat_ok_resource" {
  parent_id = "${aws_api_gateway_resource.heartbeat_api_heartbeat_resource.id}"
  path_part = "ok"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
}

resource "aws_api_gateway_method" "heartbeat_api_heartbeat_ok_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = "${aws_api_gateway_resource.heartbeat_api_heartbeat_ok_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
}

resource "aws_api_gateway_integration" "heartbeat_api_heartbeat_ok_get_integration" {
  http_method = "${aws_api_gateway_method.heartbeat_api_heartbeat_ok_get.http_method}"
  integration_http_method = "POST"
  resource_id = "${aws_api_gateway_resource.heartbeat_api_heartbeat_ok_resource.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-1:547071375521:function:heartbeat-ok/invocations"
}

resource "aws_api_gateway_method_response" "heartbeat_api_heartbeat_ok_get_200" {
  http_method = "${aws_api_gateway_method.heartbeat_api_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_api_heartbeat_ok_resource.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": true
}
EOF
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "heartbeat_api_heartbeat_ok_get_integration_response" {
  http_method = "${aws_api_gateway_method.heartbeat_api_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_api_heartbeat_ok_resource.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": "'text/plain'"
}
EOF
  response_templates = {
    "application/json" = "$input.path('$')"
  }
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
  status_code = "${aws_api_gateway_method_response.heartbeat_api_heartbeat_ok_get_200.status_code}"
}

resource "aws_api_gateway_deployment" "heartbeat_api_prod_deployment" {
  depends_on = ["aws_api_gateway_integration.heartbeat_api_heartbeat_ok_get_integration"]
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_api.id}"
  stage_description = "production"
  stage_name = "prod"
}
