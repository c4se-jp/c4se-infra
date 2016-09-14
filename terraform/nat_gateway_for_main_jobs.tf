resource "aws_eip" "main_jobs_ap-northeast-1a" { }

resource "aws_eip" "main_jobs_ap-northeast-1c" { }

resource "aws_security_group" "main_jobs" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    self = true
    to_port = 0
  }
  ingress {
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    from_port = 0
    protocol = "-1"
    self = true
    to_port = 0
  }
  name = "main_job"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_jobs_ap-northeast-1a" {
  availability_zone = "${var.aws_region}a"
  cidr_block = "172.31.128.0/28"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_jobs_ap-northeast-1c" {
  availability_zone = "${var.aws_region}c"
  cidr_block = "172.31.128.16/28"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_network_acl" "main_jobs" {
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
    cidr_block = "${aws_vpc.main.cidr_block}"
    from_port = 22
    protocol = "tcp"
    rule_no = 1
    to_port = 22
  }
  subnet_ids = [
    "${aws_subnet.main_jobs_ap-northeast-1a.id}",
    "${aws_subnet.main_jobs_ap-northeast-1c.id}"
  ]
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_nat_gateway" "main_jobs_ap-northeast-1a" {
  allocation_id = "${aws_eip.main_jobs_ap-northeast-1a.id}"
  depends_on = ["aws_internet_gateway.main"]
  subnet_id = "${aws_subnet.main_jobs_ap-northeast-1a.id}"
}

resource "aws_nat_gateway" "main_jobs_ap-northeast-1c" {
  allocation_id = "${aws_eip.main_jobs_ap-northeast-1c.id}"
  depends_on = ["aws_internet_gateway.main"]
  subnet_id = "${aws_subnet.main_jobs_ap-northeast-1c.id}"
}

resource "aws_route_table" "main_jobs_ap-northeast-1a" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.main_jobs_ap-northeast-1a.id}"
  }
}

resource "aws_route_table" "main_jobs_ap-northeast-1c" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.main_jobs_ap-northeast-1c.id}"
  }
}

resource "aws_route_table_association" "main_jobs_ap-northeast-1a" {
  route_table_id = "${aws_route_table.main_jobs_ap-northeast-1c.id}"
  subnet_id = "${aws_subnet.main_jobs_ap-northeast-1a.id}"
}

resource "aws_route_table_association" "main_jobs_ap-northeast-1c" {
  route_table_id = "${aws_route_table.main_jobs_ap-northeast-1c.id}"
  subnet_id = "${aws_subnet.main_jobs_ap-northeast-1c.id}"
}
