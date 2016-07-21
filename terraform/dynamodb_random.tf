resource "aws_dynamodb_table" "s-random" {
  attribute {
    name = "id"
    type = "S"
  }
  hash_key = "id"
  name = "s-random"
  read_capacity = 1
  write_capacity = 1
}

resource "aws_dynamodb_table" "random" {
  attribute {
    name = "id"
    type = "S"
  }
  hash_key = "id"
  name = "random"
  read_capacity = 1
  write_capacity = 1
}
