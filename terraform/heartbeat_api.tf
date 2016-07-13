resource "aws_iam_role" "lambda_heartbeat-ok_exec" {
  assume_role_policy = "${file("../files/lambda_heartbeat_ok_exec_role_policy.json")}"
  name = "lambda_heartbeat-ok_exec"
}

resource "aws_iam_policy_attachment" "lambda_heartbeat-ok_exec_AWSLambdaExecute" {
  name = "lambda_heartbeat-ok_exec_AWSLambdaExecute"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
  roles = ["${aws_iam_role.lambda_heartbeat-ok_exec.name}"]
}

resource "aws_lambda_function" "heartbeat-ok" {
  description = "Dummy heartbeat endpoint."
  filename = "../aws-lambda/heartbeat-ok.zip"
  function_name = "heartbeat-ok"
  handler = "main.main"
  memory_size = 128
  role = "${aws_iam_role.lambda_heartbeat-ok_exec.arn}"
  runtime = "python2.7"
  source_code_hash = "${base64sha256(file("../aws-lambda/heartbeat-ok.zip"))}"
  timeout = 3
}

resource "aws_lambda_permission" "heartbeat-ok_apigateway" {
  statement_id = "heartbeat-ok_apigateway"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.heartbeat-ok.function_name}"
  principal = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "heartbeat" {
  description = "Dummy heartbeat endpoint."
  name = "heartbeat"
}

resource "aws_api_gateway_resource" "heartbeat_heartbeat" {
  parent_id = "${aws_api_gateway_rest_api.heartbeat.root_resource_id}"
  path_part = "heartbeat"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
}

resource "aws_api_gateway_resource" "heartbeat_heartbeat_ok" {
  parent_id = "${aws_api_gateway_resource.heartbeat_heartbeat.id}"
  path_part = "ok"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
}

resource "aws_api_gateway_method" "heartbeat_heartbeat_ok_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = "${aws_api_gateway_resource.heartbeat_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
}

resource "aws_api_gateway_integration" "heartbeat_heartbeat_ok_get" {
  http_method = "${aws_api_gateway_method.heartbeat_heartbeat_ok_get.http_method}"
  integration_http_method = "POST"
  resource_id = "${aws_api_gateway_resource.heartbeat_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-northeast-1:547071375521:function:${aws_lambda_function.heartbeat-ok.function_name}/invocations"
}

resource "aws_api_gateway_method_response" "heartbeat_heartbeat_ok_get_200" {
  http_method = "${aws_api_gateway_method.heartbeat_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": true
}
EOF
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "heartbeat_heartbeat_ok_get" {
  depends_on = ["aws_api_gateway_integration.heartbeat_heartbeat_ok_get"]
  http_method = "${aws_api_gateway_method.heartbeat_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.heartbeat_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": "'text/plain'"
}
EOF
  response_templates = {
    "application/json" = "$input.path('$')"
  }
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
  status_code = "${aws_api_gateway_method_response.heartbeat_heartbeat_ok_get_200.status_code}"
}

resource "aws_api_gateway_deployment" "heartbeat_prod" {
  depends_on = ["aws_api_gateway_integration.heartbeat_heartbeat_ok_get"]
  rest_api_id = "${aws_api_gateway_rest_api.heartbeat.id}"
  stage_description = "production"
  stage_name = "prod"
}
