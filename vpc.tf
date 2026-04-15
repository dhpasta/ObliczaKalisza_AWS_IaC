resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.app_name}_vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.app_name}_gateway"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}_private_subnet_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}_private_subnet_b"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}_public_subnet_a"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.app_name}_private_route_table"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.app_name}_public_route_table"
  }
}

resource "aws_route_table_association" "private_route_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "private_route_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "public_route_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_security_group" "default" {
  name       = "${var.app_name}_default_security_group"
  vpc_id     = aws_vpc.this.id
  depends_on = [aws_vpc.this]
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.default.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.default.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_out" {
  security_group_id = aws_security_group.default.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
