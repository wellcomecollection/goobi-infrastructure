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

# the staging environment needs only one shellserver - it handles all jobtypes
module "shell_server_1" {
  source = "../modules/stack/shell_server"

  name = "${local.environment_name}-shellserver_1"

  cpu    = "2048"
  memory = "4096"

  configuration_bucket_name = aws_s3_bucket.workflow-stage-configuration.bucket
  working_storage_path      = "/efs/tmp_shellserver1"
  data_bucket_name          = aws_s3_bucket.workflow-stage-data.bucket
  configuration_file_path   = "/opt/digiverso/shellserver/conf/shellserver_1_config.properties"

  cluster_arn = aws_ecs_cluster.cluster.arn

  subnets = module.network.private_subnets

  security_group_ids = [
    aws_security_group.service_egress.id,
    aws_security_group.interservice.id,
    aws_security_group.efs.id
  ]

  efs_id = module.efs.efs_id

  shell_server_container_image = local.shell_server_container_image
}

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

  data_bucket_name             = aws_s3_bucket.workflow-stage-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-stage-configuration.bucket
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

  working_storage_path         = "/efs/tmp_workernode1"
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

  efs_id = module.efs.efs_id

  worker_node_container_image = local.worker_node_container_image
}

module "worker_node_1_autoscaling_cloudwatch" {
  source  = "umotif-public/ecs-service-autoscaling-cloudwatch/aws"
  version = "~> 2.0.0"

  enabled = true

  name_prefix = "worker_node_scaling"

  min_capacity = 1
  max_capacity = 5

  cluster_name = aws_ecs_cluster.cluster.name
  service_name = module.worker_node_1.name

  high_threshold = 1.0001 #this is exact until we decide to have more than 10,000 instances
  low_threshold  = 0.9999 #this is exact until we decide to have more than 10,000 instances

  scale_up_step_adjustment = [
    {
      scaling_adjustment          = 1
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = "" # indicates inifinity
    }
  ]

  scale_down_step_adjustment = [
    {
      scaling_adjustment          = -1
      metric_interval_upper_bound = 0
      metric_interval_lower_bound = ""
    }
  ]

  metric_query = [
    {
      id          = "workerNodeScaleMetric"
      expression  = "(notVisible/numWorkerNodes)+visible"
      label       = "worker node scaling indicator"
      return_data = true
    },
    {
      id = "visible"
      metric = [
        {
          namespace   = "AWS/SQS"
          metric_name = "ApproximateNumberOfMessagesVisible"
          period      = 60
          stat        = "Maximum"

          dimensions = {
            QueueName = module.queues.queue_job_name
          }
        }
      ]
    },
    {
      id = "notVisible"
      metric = [
        {
          namespace   = "AWS/SQS"
          metric_name = "ApproximateNumberOfMessagesNotVisible"
          period      = 60
          stat        = "Maximum"

          dimensions = {
            QueueName = module.queues.queue_job_name
          }
        }
      ]
    },
    {
      id = "numWorkerNodes"
      metric = [
        {
          namespace   = "AWS/ECS"
          metric_name = "CPUUtilization"
          period      = 60
          stat        = "SampleCount"
          dimensions = {
            ClusterName = aws_ecs_cluster.cluster.name
            ServiceName = module.worker_node_1.name
          }
        }
      ]
    }
  ]
}
