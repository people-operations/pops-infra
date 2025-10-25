resource "aws_lb" "alb_pops" {
  name               = "alb-pops"
  internal           = false # internet-facing
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = var.security_groups_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "alb-pops"
  }
}

resource "aws_lb_target_group" "tg_pops" {
  name     = "tg-pops"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tg-pops"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_pops.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_pops.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_a" {
  target_group_arn = aws_lb_target_group.tg_pops.arn
  target_id        = var.ec2_ids[0]
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_b" {
  target_group_arn = aws_lb_target_group.tg_pops.arn
  target_id        = var.ec2_ids[1]
  port             = 80
}
