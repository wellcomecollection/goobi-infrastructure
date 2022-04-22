resource "aws_ecs_cluster" "cluster" {
  name = "workflow-stage"
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name = "workflow-stage"

  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets

  certificate_domain = "workflow.wellcomecollection.org"

  service_lb_security_group_ids = [
    aws_security_group.service_lb.id,
    aws_security_group.interservice.id
  ]

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

# module "production_iam" {
#   source = "../modules/production"
# }

module "harvester" {
  source = "../modules/stack/harvester"

  name = "${local.environment_name}-harvester"

  configuration_bucket_name = aws_s3_bucket.workflow-stage-configuration.bucket
  result_bucket_name        = aws_s3_bucket.workflow-stage-harvesting-results.bucket

  cluster_arn = aws_ecs_cluster.cluster.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id,
    aws_security_group.service_lb.id
  ]

  efs_id = module.efs.efs_id

  harvester_container_image = local.harvester_container_image
  proxy_container_image     = local.proxy_container_image

  db_server       = module.goobi_rds_cluster.host
  db_port         = module.goobi_rds_cluster.port
  db_name         = "harvester"
  db_user_key     = local.db_user_key
  db_password_key = local.db_password_key

  ia_username_key = local.ia_username_key
  ia_password_key = local.ia_password_key

  host_name    = var.domain_name
  path_pattern = "/harvester/*"
  source_ips   = local.harvester_source_ips

  vpc_id = module.network.vpc_id

  alb_listener_arn = module.load_balancer.https_listener_arn

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
}

module "itm" {
  source = "../modules/stack/itm"

  name = "${local.environment_name}-itm"

  data_bucket_name          = aws_s3_bucket.workflow-stage-data.bucket
  configuration_bucket_name = aws_s3_bucket.workflow-stage-configuration.bucket

  cluster_arn = aws_ecs_cluster.cluster.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id,
    aws_security_group.service_lb.id
  ]

  efs_id = module.efs.efs_id

  itm_container_image   = local.itm_container_image
  proxy_container_image = local.proxy_container_image

  db_server       = module.goobi_rds_cluster.host
  db_port         = module.goobi_rds_cluster.port
  db_name         = "itm"
  db_user_key     = local.db_user_key
  db_password_key = local.db_password_key

  host_name    = var.domain_name
  path_pattern = "/itm/*"
  source_ips   = local.itm_source_ips

  vpc_id = module.network.vpc_id

  alb_listener_arn = module.load_balancer.https_listener_arn

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
}

module "goobi" {
  source = "../modules/stack/goobi"

  name = "${local.environment_name}-goobi"

  cpu    = "2048"
  memory = "8192"

  data_bucket_name               = aws_s3_bucket.workflow-stage-data.bucket
  configuration_bucket_name      = aws_s3_bucket.workflow-stage-configuration.bucket
  goobi_external_job_queue       = module.queues.queue_job_name
  goobi_external_command_queue   = module.queues.queue_command_name
  goobi_external_job_dlq         = module.queues.dlq_job_name
  goobi_external_bagit_job_queue = module.queues.queue_bagit_job_name

  cluster_arn = aws_ecs_cluster.cluster.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id,
    aws_security_group.service_lb.id
  ]

  efs_id = module.efs.efs_id

  goobi_container_image = local.goobi_container_image
  proxy_container_image = local.proxy_container_image

  db_server       = module.goobi_rds_cluster.host
  db_port         = module.goobi_rds_cluster.port
  db_name         = "goobi"
  db_user_key     = local.db_user_key
  db_password_key = local.db_password_key

  host_name    = var.domain_name
  path_pattern = "/goobi/*"

  vpc_id = module.network.vpc_id

  alb_listener_arn = module.load_balancer.https_listener_arn

  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.namespace.id
}

# SQS Queues
module "queues" {
  source = "../modules/stack/queues"

  name = local.environment_name
}


module "worker_node_1" {
  source = "../modules/stack/worker_node"

  name = "${local.environment_name}-workernode_1"

  cpu    = "2048"
  memory = "6144"

  working_storage_path         = "/workingstorage/tmp_workernode1"
  data_bucket_name             = aws_s3_bucket.workflow-stage-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-stage-configuration.bucket
  goobi_external_job_queue     = module.queues.queue_job_name
  goobi_external_command_queue = module.queues.queue_command_name
  goobi_hostname               = "${module.goobi.name}.${aws_service_discovery_private_dns_namespace.namespace.name}"

  cluster_arn = aws_ecs_cluster.cluster.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id
  ]

  efs_id                 = module.efs.efs_id
  working_storage_efs_id = module.efs-workernode.efs_id

  ia_username_key = local.ia_username_key
  ia_password_key = local.ia_password_key

  worker_node_container_image = local.worker_node_container_image
}

module "worker_node_1_autoscaling" {
  source = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/autoscaling?ref=v3.5.2"

  name = "${local.environment_name}-worker_node_scaling"

  min_capacity = 1
  max_capacity = 5

  cluster_name = aws_ecs_cluster.cluster.name
  service_name = module.worker_node_1.name

  scale_down_adjustment = -4
  scale_up_adjustment   = 1
}

resource "aws_cloudwatch_metric_alarm" "high" {
  count = 1

  alarm_name          = "${local.environment_name}-workernode-scaling-alarm-high"
  alarm_description   = "Alarm monitors high utilization for scaling up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_actions       = [module.worker_node_1_autoscaling.scale_up_arn]

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  period      = "60"
  statistic   = "Maximum"
  dimensions = {
    QueueName = module.queues.queue_job_name
  }
}

resource "aws_cloudwatch_metric_alarm" "low" {
  count = 1

  alarm_name          = "${local.environment_name}-workernode-scaling-alarm-low"
  alarm_description   = "Alarm monitors low utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 0
  alarm_actions       = [module.worker_node_1_autoscaling.scale_down_arn]

  metric_query {
    id          = "workernode_scale_down"
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
        QueueName = module.queues.queue_job_name
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
        QueueName = module.queues.queue_job_name
      }
    }
  }
}

resource "aws_ecs_cluster" "cluster-ec2" {
  name               = "${local.environment_name}_ec2"
  capacity_providers = [module.ec2_cluster_capacity_provider.name]
}

module "ec2_cluster_capacity_provider" {
  source = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/ec2_capacity_provider?ref=v3.12.0"

  name = "${local.environment_name}_ec2_cluster"

  // Setting this variable from aws_ecs_cluster.cluster.name creates a cycle
  // The cluster name is required for the instance user data script
  // This is a known issue https://github.com/terraform-providers/terraform-provider-aws/issues/12739
  cluster_name = "${local.environment_name}_ec2"

  instance_type           = "t3a.medium"
  max_instances           = 1
  use_spot_purchasing     = false
  scaling_action_cooldown = 240
  ebs_size_gb             = 500

  subnets = module.network.private_subnets
  security_group_ids = [
    aws_security_group.service_egress.id,
  ]
}

module "worker_node_bagit" {
  source = "../modules/stack/worker_node"

  name = "${local.environment_name}-workernode_bagit"

  cpu    = "2048"
  memory = "2048"

  working_storage_path         = "/var/scratch/"
  data_bucket_name             = aws_s3_bucket.workflow-stage-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-stage-configuration.bucket
  goobi_external_job_queue     = module.queues.queue_bagit_job_name
  goobi_external_command_queue = module.queues.queue_command_name
  goobi_hostname               = "${module.goobi.name}.${aws_service_discovery_private_dns_namespace.namespace.name}"

  cluster_arn = aws_ecs_cluster.cluster-ec2.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id
  ]

  efs_id                 = module.efs.efs_id
  working_storage_efs_id = module.efs-workernode.efs_id

  ia_username_key = local.ia_username_key
  ia_password_key = local.ia_password_key

  worker_node_container_image = local.worker_node_container_image

  launch_type = "EC2"
  capacity_provider_strategies = [{
    capacity_provider = module.ec2_cluster_capacity_provider.name
    weight            = 100
  }]
  ordered_placement_strategies = [{
    type  = "spread"
    field = "host"
  }]
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group_workernode_bagit_stage" {
  name = "ecs/${local.environment_name}-workernode_bagit"

  retention_in_days = "14"
}

module "worker_node_bagit_autoscaling" {
  source = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/autoscaling?ref=v3.5.2"

  name = "${local.environment_name}-worker_node_bagit_scaling"

  min_capacity = 0
  max_capacity = 2

  cluster_name = aws_ecs_cluster.cluster-ec2.name
  service_name = module.worker_node_bagit.name

  scale_down_adjustment = -1
  scale_up_adjustment   = 1
}
resource "aws_cloudwatch_metric_alarm" "high_bagit" {
  count = 1

  alarm_name          = "${local.environment_name}-workernode-scaling-alarm-bagit-high"
  alarm_description   = "Alarm monitors high utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  alarm_actions       = [module.worker_node_bagit_autoscaling.scale_up_arn]

  namespace   = "AWS/SQS"
  metric_name = "ApproximateNumberOfMessagesVisible"
  period      = "60"
  statistic   = "Maximum"
  dimensions = {
    QueueName = module.queues.queue_bagit_job_name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_bagit" {
  count = 1

  alarm_name          = "${local.environment_name}-workernode-scaling-alarm-bagit-low"
  alarm_description   = "Alarm monitors low utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 0
  alarm_actions       = [module.worker_node_bagit_autoscaling.scale_down_arn]

  metric_query {
    id          = "workernode_bagit_scale_down"
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
        QueueName = module.queues.queue_bagit_job_name
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
        QueueName = module.queues.queue_bagit_job_name
      }
    }
  }
}
