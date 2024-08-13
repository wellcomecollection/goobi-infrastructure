moved {
  from = aws_alb_target_group.itm
  to = aws_alb_target_group.goobi
}

resource "aws_alb_target_group" "goobi" {
  # We use snake case in a lot of places, but ALB Target Group names can
  # only contain alphanumerics and hyphens.
  name = replace(var.name, "_", "-")

  target_type = "ip"

  protocol = "HTTP"
  port     = var.container_port
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = var.healthcheck_path
    matcher  = "200-399"
  }
}
