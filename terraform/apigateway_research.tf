resource "aws_api_gateway_rest_api" "research" {
  description = "Dummy endpoint for research."
  name = "research"
}

resource "aws_api_gateway_deployment" "research_staging" {
  depends_on = ["aws_api_gateway_integration.research_heartbeat_ok_get"]
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  stage_description = "staging"
  stage_name = "staging"
  variables = {
    stage = "staging"
  }
}

resource "aws_api_gateway_deployment" "research_prod" {
  depends_on = ["aws_api_gateway_integration.research_heartbeat_ok_get"]
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

# {{{ GET /heartbeat/ok

resource "aws_api_gateway_method" "research_heartbeat_ok_get" {
  authorization = "NONE"
  http_method = "GET"
  resource_id = "${aws_api_gateway_resource.research_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

resource "aws_api_gateway_integration" "research_heartbeat_ok_get" {
  http_method = "${aws_api_gateway_method.research_heartbeat_ok_get.http_method}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
{
  "stage": "$stageVariables.stage"
}
EOF
  }
  resource_id = "${aws_api_gateway_resource.research_heartbeat_ok.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${module.aws_lambda_function_for_apigateway_heartbeat_ok.function_name}:$${stageVariables.stage}/invocations"
}

resource "aws_api_gateway_method_response" "research_heartbeat_ok_get_200" {
  http_method = "${aws_api_gateway_method.research_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": true
}
EOF
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "research_heartbeat_ok_get_200" {
  depends_on = ["aws_api_gateway_integration.research_heartbeat_ok_get"]
  http_method = "${aws_api_gateway_method.research_heartbeat_ok_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_heartbeat_ok.id}"
  response_parameters_in_json = <<EOF
{
  "method.response.header.Content-Type": "'text/plain'"
}
EOF
  response_templates = {
    "application/json" = "$input.path('$')"
  }
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "${aws_api_gateway_method_response.research_heartbeat_ok_get_200.status_code}"
}

# }}} GET /heartbeat/ok

# {{{ GET /random/{id}

resource "aws_api_gateway_method" "research_random_id_get" {
  authorization = "NONE"
  http_method = "GET"
  request_parameters_in_json = <<EOF
{
  "method.request.path.id": true,
  "method.request.querystring.dummy1": true,
  "method.request.querystring.dummy2": true
}
EOF
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

resource "aws_api_gateway_integration" "research_random_id_get" {
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  integration_http_method = "POST"
  request_parameters_in_json = <<EOF
{
  "integration.request.path.id": "method.request.path.id",
  "integration.request.querystring.dummy1": "method.request.querystring.dummy1",
  "integration.request.querystring.dummy2": "method.request.querystring.dummy2"
}
EOF
  request_templates = {
    "application/json" = <<EOF
{
  "dummy1": "$input.params('dummy1')",
  "dummy2": "$input.params('dummy2')",
  "id": "$input.params('id')",
  "stage": "$stageVariables.stage"
}
EOF
  }
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${module.aws_lambda_function_for_apigateway_get_random.function_name}:$${stageVariables.stage}/invocations"
}

resource "aws_api_gateway_method_response" "research_random_id_get_200" {
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "research_random_id_get_400" {
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "400"
}

resource "aws_api_gateway_method_response" "research_random_id_get_500" {
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "research_random_id_get_200" {
  depends_on = ["aws_api_gateway_integration.research_random_id_get"]
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "${aws_api_gateway_method_response.research_random_id_get_200.status_code}"
}

resource "aws_api_gateway_integration_response" "research_random_id_get_400" {
  depends_on = ["aws_api_gateway_integration.research_random_id_get"]
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  response_templates = {
    "application/json" = <<EOF
{
  "error": "$input.path('$.errorMessage').substring(5)"
}
EOF
  }
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  selection_pattern = "400:.+"
  status_code = "${aws_api_gateway_method_response.research_random_id_get_400.status_code}"
}

resource "aws_api_gateway_integration_response" "research_random_id_get_500" {
  depends_on = ["aws_api_gateway_integration.research_random_id_get"]
  http_method = "${aws_api_gateway_method.research_random_id_get.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  response_templates = {
    "application/json" = <<EOF
{
  "error": "$input.path('$.errorMessage')"
}
EOF
  }
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  selection_pattern = "(?<!\\d{3}: ).+"
  status_code = "${aws_api_gateway_method_response.research_random_id_get_500.status_code}"
}

# }}} GET /random/{id}

# {{{ PUT /random/{id}

resource "aws_api_gateway_method" "research_random_id_put" {
  authorization = "NONE"
  http_method = "PUT"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
}

resource "aws_api_gateway_integration" "research_random_id_put" {
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = <<EOF
{
  "dummy1": "$input.path('$.dummy1')",
  "dummy2": "$input.path('$.dummy2')",
  "id": "$input.params('id')",
  "stage": "$stageVariables.stage"
}
EOF
  }
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${module.aws_lambda_function_for_apigateway_put_random.function_name}:$${stageVariables.stage}/invocations"
}

resource "aws_api_gateway_method_response" "research_random_id_put_200" {
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "research_random_id_put_400" {
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "400"
}

resource "aws_api_gateway_method_response" "research_random_id_put_500" {
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "500"
}

resource "aws_api_gateway_integration_response" "research_random_id_put_200" {
  depends_on = ["aws_api_gateway_integration.research_random_id_put"]
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  status_code = "${aws_api_gateway_method_response.research_random_id_put_200.status_code}"
}
resource "aws_api_gateway_integration_response" "research_random_id_put_400" {
  depends_on = ["aws_api_gateway_integration.research_random_id_put"]
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  response_templates = {
    "application/json" = <<EOF
{
  "error": "$input.path('$.errorMessage').substring(5)"
}
EOF
  }
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  selection_pattern = "400:.+"
  status_code = "${aws_api_gateway_method_response.research_random_id_put_400.status_code}"
}

resource "aws_api_gateway_integration_response" "research_random_id_put_500" {
  depends_on = ["aws_api_gateway_integration.research_random_id_put"]
  http_method = "${aws_api_gateway_method.research_random_id_put.http_method}"
  resource_id = "${aws_api_gateway_resource.research_random_id.id}"
  response_templates = {
    "application/json" = <<EOF
{
  "error": "$input.path('$.errorMessage')"
}
EOF
  }
  rest_api_id = "${aws_api_gateway_rest_api.research.id}"
  selection_pattern = "(?<!\\d{3}: ).+"
  status_code = "${aws_api_gateway_method_response.research_random_id_put_500.status_code}"
}

# }}} PUT /random/{id}

# vim: set fdm=marker:
