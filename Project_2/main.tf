# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_CIDR      = var.vpc_CIDR
  private_CIDR  = var.private_CIDR
  public_CIDR   = var.public_CIDR
  public_2_CIDR = var.public_2_CIDR
  route_CIDR    = var.route_CIDR
}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Allow traffic to the ALB and back from listener"
  vpc_id      = module.vpc.vpc-id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ec2_from_alb" {
  security_group_id            = aws_security_group.allow_traffic.id
  referenced_security_group_id = aws_security_group.allow_alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_to_nat" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = var.route_CIDR
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_security_group" "allow_alb" {
  name        = "allow_alb"
  description = "Allow alb inbound and outbound traffic"
  vpc_id      = module.vpc.vpc-id

  tags = {
    Name = "allow_alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_https" {
  security_group_id = aws_security_group.allow_alb.id
  cidr_ipv4         = var.route_CIDR
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_http" {
  security_group_id = aws_security_group.allow_alb.id
  cidr_ipv4         = var.route_CIDR
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_alb_traffic" {
  security_group_id = aws_security_group.allow_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_alb.id]
  subnets            = [module.vpc.public-id, module.vpc.public-id_2]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc-id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_launch_template" "launch_temp" {
  name          = "project-launch-template"
  image_id      = "ami-0236922087fa98b6e"
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.allow_traffic.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }
}


resource "aws_autoscaling_group" "scale" {
  vpc_zone_identifier = [module.vpc.private-id]
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.target_group.arn]

  launch_template {
    id      = aws_launch_template.launch_temp.id
    version = "$Latest"
  }
}