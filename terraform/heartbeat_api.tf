variable "heartbeat_ok_prod_function_version" {
  default = "2"
}

resource "aws_iam_role" "lambda_heartbeat_ok_exec" {
  assume_role_policy = "${file("../files/lambda_heartbeat_ok_exec_role_policy.json")}"
  name = "lambda_heartbeat_ok_exec"
}

resource "aws_iam_policy_attachment" "lambda_heartbeat_ok_exec_AWSLambdaExecute" {
  name = "lambda_heartbeat_ok_exec_AWSLambdaExecute"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
  roles = ["${aws_iam_role.lambda_heartbeat_ok_exec.name}"]
}

resource "aws_lambda_function" "heartbeat_ok" {
  description = "Dummy heartbeat endpoint."
  filename = "../aws-lambda/heartbeat_ok.zip"
  function_name = "heartbeat_ok"
  handler = "main.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_heartbeat_ok_exec.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("../aws-lambda/heartbeat_ok.zip"))}"
  timeout = 3
}

resource "aws_lambda_alias" "heartbeat_ok_staging" {
  name = "staging"
  description = "staging"
  function_name = "${aws_lambda_function.heartbeat_ok.arn}"
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "heartbeat_ok_prod" {
  name = "prod"
  description = "production"
  function_name = "${aws_lambda_function.heartbeat_ok.arn}"
  function_version = "${var.heartbeat_ok_prod_function_version}"
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

resource "aws_api_gateway_rest_api" "heartbeat_ok" {
  description = "Dummy heartbeat endpoint."
  name = "heartbeat_ok"
}

resource "aws_api_gateway_resource" "heartbeat_ok_heartbeat" {
  parent_id = "${aws_api_gateway_rest_api.heartbeat_ok.root_resource_id}"
  path_part = "heartbeat"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
}

resource "aws_api_gateway_resource" "heartbeat_ok_heartbeat_ok" {
  parent_id = "${aws_api_gateway_resource.heartbeat_ok_heartbeat.id}"
  path_part = "ok"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
}

resource "aws_api_gateway_method" "heartbeat_ok_heartbeat_ok_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = "${aws_api_gateway_resource.heartbeat_ok_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
}

resource "aws_api_gateway_integration" "heartbeat_ok_heartbeat_ok_get" {
  http_method = "${aws_api_gateway_method.heartbeat_ok_heartbeat_ok_get.http_method}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
{
  "stage": "$stageVariables.stage"
}
EOF
  }
  resource_id = "${aws_api_gateway_resource.heartbeat_ok_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${aws_lambda_function.heartbeat_ok.function_name}:$${stageVariables.stage}/invocations"
}

resource "aws_api_gateway_method_response" "heartbeat_ok_heartbeat_ok_get_200" {
  http_method = "${aws_api_gateway_method.heartbeat_ok_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_ok_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": true
}
EOF
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "heartbeat_ok_heartbeat_ok_get_200" {
  depends_on = ["aws_api_gateway_integration.heartbeat_ok_heartbeat_ok_get"]
  http_method = "${aws_api_gateway_method.heartbeat_ok_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_ok_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": "'text/plain'"
}
EOF
  response_templates = {
    "application/json" = "$input.path('$')"
  }
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
  status_code = "${aws_api_gateway_method_response.heartbeat_ok_heartbeat_ok_get_200.status_code}"
}

resource "aws_api_gateway_deployment" "heartbeat_ok_staging" {
  depends_on = ["aws_api_gateway_integration.heartbeat_ok_heartbeat_ok_get"]
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
  stage_description = "staging"
  stage_name = "staging"
  variables = {
    stage = "staging"
  }
}

resource "aws_api_gateway_deployment" "heartbeat_ok_prod" {
  depends_on = ["aws_api_gateway_integration.heartbeat_ok_heartbeat_ok_get"]
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat_ok.id}"
  stage_description = "production"
  stage_name = "prod"
  variables = {
    stage = "prod"
  }
}

# vim: set fdm=marker:
