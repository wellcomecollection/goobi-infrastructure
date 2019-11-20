module "iam_roles" {
  source = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//task_definition/modules/iam_role?ref=v1.0.2"

  task_name = "${var.name}"
}

locals {
  ebs_volume_name = "ebs"
  efs_volume_name = "efs"

  mount_points = [
    {
      sourceVolume  = "${local.ebs_volume_name}"
      containerPath = "${var.ebs_container_path}"
    },
    {
      sourceVolume  = "${local.efs_volume_name}"
      containerPath = "${var.efs_container_path}"
    },
  ]
}

resource "aws_ecs_task_definition" "task" {
  family                = "${var.name}"
  container_definitions = "${data.template_file.container_definition.rendered}"

  task_role_arn      = "${module.iam_roles.task_role_arn}"
  execution_role_arn = "${module.iam_roles.task_execution_role_arn}"

  network_mode = "awsvpc"

  # For now, using EBS/EFS means we need to be on EC2 instance.
  requires_compatibilities = ["EC2"]

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ebs.volume exists"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:efs.volume exists"
  }

  volume {
    name      = "${local.ebs_volume_name}"
    host_path = "${var.ebs_host_path}"
  }

  volume {
    name      = "${local.efs_volume_name}"
    host_path = "${var.efs_host_path}"
  }

  cpu    = "${var.app_cpu + var.sidecar_cpu}"
  memory = "${var.app_memory + var.sidecar_memory}"
}
