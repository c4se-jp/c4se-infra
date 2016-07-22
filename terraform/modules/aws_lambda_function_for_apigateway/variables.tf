variable "description" {}

variable "filename" {}

variable "function_name" {}

variable "handler" {}

variable "memory_size" {}

variable "prod_function_version" {
  default = "$LATEST"
}

variable "role" {}

variable "runtime" {}

variable "timeout" {}
