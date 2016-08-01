variable "authorization" {
  default = "NONE"
}

variable "aws_region" {}

variable "aws_account_id" {}

variable "error_status_codes" {}

variable "function_name" {}

variable "http_method" {}

variable "integration_request_parameters_in_json" {
  default = "{}"
}

variable "integration_request_templates" {
  default = <<EOF
{ "stage": "$stageVariables.stage" }
EOF
}

variable "integration_response_parameters_in_json" {
  default = "{}"
}

variable "integration_response_templates" {
  default = "$input.json('$')"
}

variable "method_request_parameters_in_json" {
  default = "{}"
}

variable "method_response_parameters_in_json" {
  default = "{}"
}

variable "resource_id" {}

variable "rest_api_id" {}
