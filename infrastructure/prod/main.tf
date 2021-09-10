resource "aws_ecs_cluster" "cluster" {
  name = "workflow"
}

module "load_balancer" {
  source = "../modules/load_balancer"

  name = "workflow"

  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets

  certificate_domain = "workflow.wellcomecollection.org"

  service_lb_security_group_ids = [
    aws_security_group.service_lb.id,
    aws_security_group.interservice.id
  ]

  lb_controlled_ingress_cidrs = ["0.0.0.0/0"]
}

module "production_iam" {
  source = "../modules/production"
}

module "harvester" {
  source = "../modules/stack/harvester"

  name = "${local.environment_name}-harvester"

  configuration_bucket_name = aws_s3_bucket.workflow-configuration.bucket
  result_bucket_name        = aws_s3_bucket.workflow-harvesting-results.bucket

  cpu    = "1024"
  memory = "2048"

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

  data_bucket_name          = aws_s3_bucket.workflow-data.bucket
  configuration_bucket_name = aws_s3_bucket.workflow-configuration.bucket

  cpu    = "1024"
  memory = "4096"

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

  cpu    = "4096"
  memory = "8192"

  data_bucket_name             = aws_s3_bucket.workflow-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-configuration.bucket
  goobi_external_job_queue     = module.queues.queue_job_name
  goobi_external_command_queue = module.queues.queue_command_name
  goobi_external_job_dlq       = module.queues.dlq_job_name

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
  data_bucket_name             = aws_s3_bucket.workflow-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-configuration.bucket
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
  max_capacity = 10

  cluster_name = aws_ecs_cluster.cluster.name
  service_name = module.worker_node_1.name

  scale_down_adjustment = -4
  scale_up_adjustment   = 1
}

resource "aws_cloudwatch_metric_alarm" "high" {
  count = 1

  alarm_name          = "${local.environment_name}-workernode-scaling-alarm-high"
  alarm_description   = "Alarm monitors high utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 5
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
