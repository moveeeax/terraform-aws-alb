resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = var.target_port
  protocol    = var.target_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  health_check {
    path     = var.health_check_path
    protocol = var.target_protocol
  }

  tags = var.tags
}
