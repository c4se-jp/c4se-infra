variable "aws_access_key" {}

variable "aws_account_id" {}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  region = "${var.aws_region}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_route53_zone" "primary" {
  name = "c4se.jp"
}

resource "aws_route53_record" "primary_root_a_record" {
  name = "c4se.jp"
  records = ["219.94.162.102"]
  ttl = "300"
  type = "A"
  zone_id = "${aws_route53_zone.primary.zone_id}"
}

resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
  tags {
    Name = "main"
  }
}

resource "aws_security_group" "main" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    self = true
    to_port = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    self = true
    to_port = 0
  }
  name = "main"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_ap-northeast-1a" {
  availability_zone = "${var.aws_region}a"
  cidr_block = "172.31.0.0/20"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_ap-northeast-1c" {
  availability_zone = "${var.aws_region}c"
  cidr_block = "172.31.16.0/20"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_network_acl" "default" {
  egress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    protocol = "tcp"
    rule_no = 1
    to_port = 0
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    protocol = "tcp"
    rule_no = 1
    to_port = 80
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 433
    protocol = "tcp"
    rule_no = 2
    to_port = 433
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    protocol = "tcp"
    rule_no = 3
    to_port = 22
  }
  subnet_ids = [
    "${aws_subnet.main_ap-northeast-1a.id}",
    "${aws_subnet.main_ap-northeast-1c.id}"
  ]
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_main_route_table_association" "main" {
  route_table_id = "${aws_route_table.main.id}"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table_association" "main_ap-northeast-1a" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.main_ap-northeast-1a.id}"
}

resource "aws_route_table_association" "main_ap-northeast-1c" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.main_ap-northeast-1c.id}"
}
