# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_CIDR

  tags = {
    Name = "project-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_CIDR

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_CIDR
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "routes" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_CIDR
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "router"
  }
}

resource "aws_route_table_association" "route-ass" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.routes.id
}

resource "aws_instance" "project_instance" {
  ami           = "ami-0236922087fa98b6e"
  instance_type = var.instance_type
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]

  tags = {
    Name = "instance_1"
  }
}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow traffic within VPC"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = aws_vpc.my_vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = var.vpc_CIDR
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_eip" "nat_gw_eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_CIDR
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "router_NAT"
  }
}

resource "aws_route_table_association" "route-nat" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_nat.id
}