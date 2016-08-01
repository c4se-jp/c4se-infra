resource "aws_api_gateway_method" "method" {
  authorization = "${var.authorization}"
  http_method = "${var.http_method}"
  request_parameters_in_json = "${var.method_request_parameters_in_json}"
  resource_id = "${var.resource_id}"
  rest_api_id = "${var.rest_api_id}"
}

resource "aws_api_gateway_integration" "integration" {
  depends_on = ["aws_api_gateway_method.method"]
  http_method = "${var.http_method}"
  integration_http_method = "POST"
  request_parameters_in_json = "${var.integration_request_parameters_in_json}"
  request_templates = {
    "application/json" = "${var.integration_request_templates}"
  }
  resource_id = "${var.resource_id}"
  rest_api_id = "${var.rest_api_id}"
  type = "AWS"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.function_name}:$${stageVariables.stage}/invocations"
}

resource "aws_api_gateway_method_response" "method_response_200" {
  depends_on = ["aws_api_gateway_method.method"]
  http_method = "${var.http_method}"
  resource_id = "${var.resource_id}"
  response_parameters_in_json = "${var.method_response_parameters_in_json}"
  rest_api_id = "${var.rest_api_id}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  depends_on = [
    "aws_api_gateway_integration.integration",
    "aws_api_gateway_method_response.method_response_200"
  ]
  http_method = "${var.http_method}"
  resource_id = "${var.resource_id}"
  response_parameters_in_json = "${var.integration_response_parameters_in_json}"
  response_templates = {
    "application/json" = "${var.integration_response_templates}"
  }
  rest_api_id = "${var.rest_api_id}"
  status_code = "200"
}

resource "aws_api_gateway_method_response" "method_response_error" {
  count = "${length(split(",", var.error_status_codes))}"
  depends_on = ["aws_api_gateway_method.method"]
  http_method = "${var.http_method}"
  resource_id = "${var.resource_id}"
  rest_api_id = "${var.rest_api_id}"
  status_code = "${element(split(",", var.error_status_codes), count.index)}"
}

resource "aws_api_gateway_integration_response" "integration_response_error" {
  count = "${length(split(",", var.error_status_codes))}"
  depends_on = ["aws_api_gateway_integration.integration"]
  http_method = "${var.http_method}"
  resource_id = "${var.resource_id}"
  response_templates = {
    "application/json" = <<EOF
{ "error": "$input.path('$.errorMessage').substring(5)" }
EOF
  }
  rest_api_id = "${var.rest_api_id}"
  selection_pattern = "${element(split(",", var.error_status_codes), count.index)}: .+"
  status_code = "${element(split(",", var.error_status_codes), count.index)}"
}
