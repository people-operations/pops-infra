resource "aws_lb" "alb_pops" {
  name               = "alb-pops"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = var.security_groups_id_alb
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "alb-pops"
  }
}

resource "aws_lb_target_group" "tg_management_80" {
  name        = "tg-management-80"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
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
    Name = "tg-management-80"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach_management" {
  count = length(var.ec2_ids_management)

  target_group_arn = aws_lb_target_group.tg_management_80.arn
  target_id        = var.ec2_ids_management[count.index]
  port             = 80
}

resource "aws_lb_listener" "listener_8080" {
  load_balancer_arn = aws_lb.alb_pops.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_management_80.arn
  }
}

resource "aws_lb_target_group" "tg_analysis_3000" {
  name        = "tg-analysis-3000"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  # ... health check
}

resource "aws_lb_target_group_attachment" "tg_attach_analysis_3000" {
  count = length(var.ec2_ids_analysis)

  target_group_arn = aws_lb_target_group.tg_analysis_3000.arn
  target_id        = var.ec2_ids_analysis[count.index]
  port             = 3000
}

resource "aws_lb_listener" "listener_3000" {
  load_balancer_arn = aws_lb.alb_pops.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_analysis_3000.arn
  }
}

resource "aws_lb_target_group" "tg_analysis_8888" {
  name        = "tg-analysis-8888"
  port        = 8888
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  # ... health check
}

resource "aws_lb_target_group_attachment" "tg_attach_analysis_8888" {
  count = length(var.ec2_ids_analysis)

  target_group_arn = aws_lb_target_group.tg_analysis_8888.arn
  target_id        = var.ec2_ids_analysis[count.index]
  port             = 8888
}

resource "aws_lb_listener" "listener_8888" {
  load_balancer_arn = aws_lb.alb_pops.arn
  port              = 8888
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_analysis_8888.arn
  }
}