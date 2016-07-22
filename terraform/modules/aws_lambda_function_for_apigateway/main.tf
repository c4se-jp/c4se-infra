resource "aws_lambda_function" "function" {
  description = "Get the code."
  filename = "${var.filename}"
  function_name = "${var.function_name}"
  handler = "${var.handler}"
  memory_size = "${var.memory_size}"
  role = "${var.role}"
  runtime = "${var.runtime}"
  source_code_hash = "${base64sha256(file(var.filename))}"
  timeout = "${var.timeout}"
}

resource "aws_lambda_alias" "staging" {
  depends_on = ["aws_lambda_function.function"]
  description = "staging"
  function_name = "${var.function_name}"
  function_version = "$LATEST"
  name = "staging"
}

resource "aws_lambda_alias" "prod" {
  depends_on = ["aws_lambda_function.function"]
  description = "production"
  function_name = "${var.function_name}"
  function_version = "${var.prod_function_version}"
  name = "prod"
}

resource "aws_lambda_permission" "staging_apigateway" {
  action = "lambda:InvokeFunction"
  depends_on = ["aws_lambda_function.function"]
  function_name = "${var.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "staging"
  statement_id = "${var.function_name}_staging_apigateway"
}

resource "aws_lambda_permission" "prod_apigateway" {
  action = "lambda:InvokeFunction"
  depends_on = ["aws_lambda_function.function"]
  function_name = "${var.function_name}"
  principal = "apigateway.amazonaws.com"
  qualifier = "prod"
  statement_id = "${var.function_name}_prod_apigateway"
}
