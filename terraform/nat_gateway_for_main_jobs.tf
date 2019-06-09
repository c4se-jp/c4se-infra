resource "aws_eip" "main_jobs_az0" {}

resource "aws_eip" "main_jobs_az1" {}

resource "aws_security_group" "main_jobs" {
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = -1
    self = true
    to_port = 0
  }
  ingress {
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    from_port = 0
    protocol = "icmp"
    to_port = 0
  }
  ingress {
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  name = "main_job"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_jobs_az0" {
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "172.31.128.0/28"
  map_public_ip_on_launch = false
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_subnet" "main_jobs_az1" {
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "172.31.128.16/28"
  map_public_ip_on_launch = false
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_network_acl" "main_jobs" {
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
  subnet_ids = [
    "${aws_subnet.main_jobs_az0.id}",
    "${aws_subnet.main_jobs_az1.id}"
  ]
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_nat_gateway" "main_jobs_az0" {
  allocation_id = "${aws_eip.main_jobs_az0.id}"
  depends_on = ["aws_internet_gateway.main"]
  subnet_id = "${aws_subnet.main_jobs_az0.id}"
}

resource "aws_nat_gateway" "main_jobs_az1" {
  allocation_id = "${aws_eip.main_jobs_az1.id}"
  depends_on = ["aws_internet_gateway.main"]
  subnet_id = "${aws_subnet.main_jobs_az1.id}"
}

resource "aws_route_table" "main_jobs_az0" {
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main_jobs_az0.id}"
  }
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main_jobs_az1" {
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.main_jobs_az1.id}"
  }
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table_association" "main_jobs_az0" {
  route_table_id = "${aws_route_table.main_jobs_az0.id}"
  subnet_id = "${aws_subnet.main_jobs_az0.id}"
}

resource "aws_route_table_association" "main_jobs_az1" {
  route_table_id = "${aws_route_table.main_jobs_az1.id}"
  subnet_id = "${aws_subnet.main_jobs_az1.id}"
}

# resource "aws_launch_configuration" "main_jobs" {
# }
#
# resource "aws_autoscaling_group" "main_jobs" {
# }
