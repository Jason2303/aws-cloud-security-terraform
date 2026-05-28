resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_CIDR

  tags = {
    Name = "project-vpc"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "default-restricted"
  }
}

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = aws_vpc.my_vpc.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 365
  kms_key_id        = var.kms_key_arn
}

resource "aws_iam_role" "flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "flow_log_policy" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "arn:aws:logs:*:*:log-group:/aws/vpc/flow-logs:*"
    }]
  })
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_CIDR

  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_CIDR
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_2_CIDR
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "public_2"
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

resource "aws_route_table_association" "route-ass_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.routes.id
}

resource "aws_eip" "nat_gw_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }

  # the NAT GW depends on the IGW to be deployed first
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "route_nat" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = var.route_CIDR
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "router_NAT"
  }
}

resource "aws_route_table_association" "route-nat" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_nat.id
}

