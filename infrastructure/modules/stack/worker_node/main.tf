module "container_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v3.11.1"

  name  = var.name
  image = var.worker_node_container_image

  mount_points = [
    {
      containerPath = "/efs/"
      sourceVolume  = "efs"
    },
    {
      containerPath = "/workingstorage/"
      sourceVolume  = "workingstorage-efs"
    },
    {
      containerPath = "/var/scratch"
      sourceVolume  = "scratch"
    }
  ]

  log_configuration = {
    logDriver = "awslogs"

    options = {
      "awslogs-group"         = "ecs/${var.name}",
      "awslogs-region"        = "eu-west-1",
      "awslogs-create-group"  = "true",
      "awslogs-stream-prefix" = var.name
    }

    secretOptions = null
  }

  environment = {
    CONFIGSOURCE                 = "s3"
    AWS_S3_BUCKET                = var.configuration_bucket_name
    GOOBI_EXTERNAL_JOB_QUEUE     = var.goobi_external_job_queue
    GOOBI_EXTERNAL_COMMAND_QUEUE = var.goobi_external_command_queue
    GOOBI_HOST                   = var.goobi_hostname
    WORKING_STORAGE              = var.working_storage_path
    WORKING_STORAGE_FAST         = var.working_storage_fast_path
    S3_DATA_BUCKET               = var.data_bucket_name
    TZ                           = "Europe/London"
    AWS_DEFAULT_REGION           = var.default_region
  }

  secrets = local.secrets

}

module "task_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/task_definition?ref=v3.11.1"

  cpu    = var.cpu
  memory = var.memory

  container_definitions = [
    module.container_definition.container_definition
  ]

  efs_volumes = [{
    name           = "efs"
    file_system_id = var.efs_id
    root_directory = "/"
    },
    {
      name           = "workingstorage-efs"
      file_system_id = var.working_storage_efs_id
      root_directory = "/"
    }
  ]

  volumes = var.volumes

  launch_types          = [var.launch_type]
  task_name             = var.name
  placement_constraints = var.placement_constraints
}


module "service" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/service?ref=v3.11.1"

  cluster_arn  = var.cluster_arn
  service_name = var.name

  task_definition_arn = module.task_definition.arn

  container_name = module.container_definition.name
  subnets        = var.subnets

  security_group_ids = var.security_group_ids

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  launch_type                  = var.launch_type
  ordered_placement_strategies = var.ordered_placement_strategies
  placement_constraints        = var.placement_constraints
  capacity_provider_strategies = var.capacity_provider_strategies
}

module "credentials_permissions" {
  source    = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v3.11.1"
  secrets   = local.secrets
  role_name = module.task_definition.task_execution_role_name
}

module "autoscaling" {
  source = "../../autoscaling"

  name = var.name

  min_capacity = var.autoscaling_min_capacity
  max_capacity = var.autoscaling_max_capacity

  cluster_name = var.cluster_name
  service_name = module.service.name

  scale_down_adjustment = var.autoscaling_scale_down_adjustment
  scale_up_adjustment   = var.autoscaling_scale_up_adjustment
}

resource "aws_cloudwatch_metric_alarm" "high" {
  count = 1

  alarm_name          = "${var.name}-scaling-alarm-high"
  alarm_description   = "Alarm monitors high utilization for scaling up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.scale_up_evaluation_periods
  threshold           = var.scale_up_threshold
  alarm_actions       = [module.autoscaling.scale_up_arn]

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  period      = "60"
  statistic   = "Maximum"
  dimensions = {
    QueueName = var.queue_job_name
  }
}

resource "aws_cloudwatch_metric_alarm" "low" {
  count = 1

  alarm_name          = "${var.name}-scaling-alarm-low"
  alarm_description   = "Alarm monitors low utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scale_down_evaluation_periods
  threshold           = var.scale_down_threshold
  alarm_actions       = [module.autoscaling.scale_down_arn]

  metric_query {
    id          = "${var.name}_scale_down"
    expression  = "visible+invisible"
    label       = "Visible plus invisible messages"
    return_data = "true"
  }

  metric_query {
    id = "visible"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesVisible"
      period      = "60"
      stat        = "Maximum"
      dimensions = {
        QueueName = var.queue_job_name
      }
    }
  }
  metric_query {
    id = "invisible"
    metric {
      namespace   = "AWS/SQS"
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      period      = "60"
      stat        = "Maximum"
      dimensions = {
        QueueName = var.queue_job_name
      }
    }
  }
}
