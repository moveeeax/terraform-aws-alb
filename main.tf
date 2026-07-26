resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = var.drop_invalid_header_fields

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]

    content {
      bucket  = access_logs.value.bucket
      prefix  = access_logs.value.prefix
      enabled = access_logs.value.enabled
    }
  }

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

  # name, port, protocol, target_type, and vpc_id all force replacement. A
  # target group can't be deleted while it's still attached to a listener
  # rule, so without create_before_destroy an in-place change to any of
  # those attributes fails apply once the calling configuration has wired
  # target_group_arn into an aws_lb_listener or aws_lb_listener_rule: the
  # old target group can't be destroyed until the listener is repointed,
  # but the listener can't be repointed until the new target group exists.
  # create_before_destroy makes the new target group first, so the
  # listener update and the old target group's destroy can both proceed.
  lifecycle {
    create_before_destroy = true
  }
}
