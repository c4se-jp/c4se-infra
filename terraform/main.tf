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

data "aws_availability_zones" "available" {}

data "aws_ami" "default" {
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners = ["amazon"]
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
  enable_dns_hostnames = true
  tags {
    Name = "main"
  }
}

resource "aws_security_group" "main" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = -1
    to_port = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "icmp"
    to_port = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 433
    protocol = "tcp"
    to_port = 433
  }
  name = "main"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_az0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "172.31.0.0/20"
  map_public_ip_on_launch = true
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_az1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "172.31.16.0/20"
  map_public_ip_on_launch = true
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_network_acl" "default" {
  egress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    protocol = -1
    rule_no = 1
    to_port = 0
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    protocol = "icmp"
    rule_no = 1
    to_port = 0
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 32768
    protocol = "tcp"
    rule_no = 2
    to_port = 65535
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 32768
    protocol = "udp"
    rule_no = 3
    to_port = 65535
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 22
    protocol = "tcp"
    rule_no = 4
    to_port = 22
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    protocol = "tcp"
    rule_no = 5
    to_port = 80
  }
  ingress {
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 433
    protocol = "tcp"
    rule_no = 6
    to_port = 433
  }
  subnet_ids = [
    "${aws_subnet.main_az0.id}",
    "${aws_subnet.main_az1.id}"
  ]
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "main" {
  tags {
    Name = "main"
  }
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

resource "aws_route_table_association" "main_az0" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.main_az0.id}"
}

resource "aws_route_table_association" "main_az1" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.main_az1.id}"
}

resource "aws_instance" "jump_server" {
  ami = "${data.aws_ami.default.id}"
  associate_public_ip_address = true
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t2.nano"
  key_name = "c4se"
  subnet_id = "${aws_subnet.main_az0.id}"
  tags {
    Name = "jump_server"
  }
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
}
