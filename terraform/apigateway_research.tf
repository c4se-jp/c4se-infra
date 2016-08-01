resource "aws_api_gateway_rest_api" "research" {
  description = "Dummy endpoint for research."
  name = "research"
}

resource "aws_api_gateway_deployment" "research_staging" {
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  stage_description = "staging"
  stage_name = "staging"
  variables = {
    stage = "staging"
  }
}

resource "aws_api_gateway_deployment" "research_prod" {
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  stage_description = "production"
  stage_name = "prod"
  variables = {
    stage = "prod"
  }
}

# /hertbeat
resource "aws_api_gateway_resource" "research_heartbeat" {
  parent_id = "${aws_api_gateway_rest_api.research.root_resource_id}"
  path_part = "heartbeat"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# /hertbeat/ok
resource "aws_api_gateway_resource" "research_heartbeat_ok" {
  parent_id = "${aws_api_gateway_resource.research_heartbeat.id}"
  path_part = "ok"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# /random
resource "aws_api_gateway_resource" "research_random" {
  parent_id = "${aws_api_gateway_rest_api.research.root_resource_id}"
  path_part = "random"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# /random/{id}
resource "aws_api_gateway_resource" "research_random_id" {
  parent_id = "${aws_api_gateway_resource.research_random.id}"
  path_part = "{id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# GET /heartbeat/ok
module "aws_api_gateway_method_research_heartbeat_ok_get" {
  source = "./modules/aws_api_gateway_method_for_lambda_function"
  aws_region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"
  error_status_codes = "500"
  function_name = "${module.aws_lambda_function_for_apigateway_heartbeat_ok.function_name}"
  http_method = "GET"
  integration_response_parameters_in_json = <<EOF
{ "method.response.header.Content-Type": "'text/plain'" }
EOF
  integration_response_templates = "$input.path('$')"
  method_response_parameters_in_json = <<EOF
{ "method.response.header.Content-Type": true }
EOF
  resource_id = "${aws_api_gateway_resource.research_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# GET /random/{id}
module "aws_api_gateway_method_research_random_id_get" {
  source = "./modules/aws_api_gateway_method_for_lambda_function"
  aws_region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"
  error_status_codes = "400,500"
  function_name = "${module.aws_lambda_function_for_apigateway_get_random.function_name}"
  http_method = "GET"
  integration_request_parameters_in_json = <<EOF
{
  "integration.request.path.id": "method.request.path.id",
  "integration.request.querystring.dummy1": "method.request.querystring.dummy1",
  "integration.request.querystring.dummy2": "method.request.querystring.dummy2"
}
EOF
  integration_request_templates = <<EOF
{
  "dummy1": "$input.params('dummy1')",
  "dummy2": "$input.params('dummy2')",
  "id": "$input.params('id')",
  "stage": "$stageVariables.stage"
}
EOF
  method_request_parameters_in_json = <<EOF
{
  "method.request.path.id": true,
  "method.request.querystring.dummy1": true,
  "method.request.querystring.dummy2": true
}
EOF
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# PUT /random/{id}
module "aws_api_gateway_method_research_random_id_put" {
  source = "./modules/aws_api_gateway_method_for_lambda_function"
  aws_region = "${var.aws_region}"
  aws_account_id = "${var.aws_account_id}"
  error_status_codes = "400,500"
  function_name = "${module.aws_lambda_function_for_apigateway_put_random.function_name}"
  http_method = "PUT"
  integration_request_templates = <<EOF
{
  "dummy1": "$input.path('$.dummy1')",
  "dummy2": "$input.path('$.dummy2')",
  "id": "$input.params('id')",
  "stage": "$stageVariables.stage"
}
EOF
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

# vim: set fdm=marker:
