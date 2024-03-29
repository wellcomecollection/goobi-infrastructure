locals {
  ebs_device_name = "/dev/xvdc"
}
resource "aws_autoscaling_group" "asg" {
  name                = "${var.name}_asg"
  max_size            = var.max_instances
  default_cooldown    = var.scaling_action_cooldown
  vpc_zone_identifier = var.subnets

  min_size                  = 0
  health_check_type         = "EC2"
  health_check_grace_period = 180

  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.name}_instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = ""
  }
}

resource "aws_launch_template" "launch_template" {
  name                   = "${var.name}_launch_template"
  instance_type          = var.instance_type
  image_id               = var.ami_id == null ? data.aws_ami.ecs_optimized.id : var.ami_id
  vpc_security_group_ids = var.security_group_ids
  user_data              = base64encode(local.user_data)
  update_default_version = true

  ebs_optimized = var.ebs_size_gb > 0

  dynamic "block_device_mappings" {
    for_each = var.ebs_size_gb > 0 ? [{}] : []

    content {
      device_name = local.ebs_device_name

      ebs {
        volume_size           = var.ebs_size_gb
        volume_type           = var.ebs_volume_type
        delete_on_termination = true
      }
    }
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot_purchasing ? [{}] : []

    content {
      market_type = "spot"
    }
  }

  dynamic "network_interfaces" {
    for_each = var.assign_public_ips ? [{}] : []

    content {
      associate_public_ip_address = true
      security_groups             = var.security_group_ids
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }
}

data "aws_ami" "ecs_optimized" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

locals {
  user_data = templatefile(
    "${path.module}/user_data.tpl",
    {
      cluster_name  = var.cluster_name
      ebs_volume_id = local.ebs_device_name
      ebs_host_path = "/ebs"
    }
  )
}
