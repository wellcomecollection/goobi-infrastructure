resource "aws_alb_listener_rule" "https" {
  for_each     = nonsensitive(var.source_ips)
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.itm.arn
  }

  condition {
    host_header {
      values = [var.host_name]
    }
  }

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }

  condition {
    source_ip {
      values = [each.key]
    }
  }
}

