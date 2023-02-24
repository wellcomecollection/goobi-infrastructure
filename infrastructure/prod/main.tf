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

  db_server       = module.goobi_rds_cluster_aurora3.host
  db_port         = module.goobi_rds_cluster_aurora3.port
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

  db_server       = module.goobi_rds_cluster_aurora3.host
  db_port         = module.goobi_rds_cluster_aurora3.port
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

  db_server       = module.goobi_rds_cluster_aurora3.host
  db_port         = module.goobi_rds_cluster_aurora3.port
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
  db_server                    = module.goobi_rds_cluster_aurora3.host
  db_port                      = module.goobi_rds_cluster_aurora3.port
  db_name                      = "workernode"
  db_user_key                  = local.db_user_key
  db_password_key              = local.db_password_key

  volumes = [{
    name      = "scratch"
    host_path = null
  }]

  cluster_arn  = aws_ecs_cluster.cluster.arn
  cluster_name = aws_ecs_cluster.cluster.name

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
  queue_job_name              = module.queues.queue_job_name

  autoscaling_min_capacity    = 1
  autoscaling_max_capacity    = 10
  scale_up_evaluation_periods = 5
  scale_up_threshold          = 0
}

# ECS Cluster based on EC2 instances, used for bagit generation via worker node
resource "aws_ecs_cluster" "cluster-ec2" {
  name               = "${local.environment_name}_ec2"
  capacity_providers = [module.ec2_cluster_capacity_provider.name]
}

# Capacity provider to get autoscaling EC2 instances
module "ec2_cluster_capacity_provider" {
  source = "../modules/ec2_capacity_provider"

  name = "${local.environment_name}_ec2_cluster"

  // Setting this variable from aws_ecs_cluster.cluster.name creates a cycle
  // The cluster name is required for the instance user data script
  // This is a known issue https://github.com/terraform-providers/terraform-provider-aws/issues/12739
  cluster_name = "${local.environment_name}_ec2"

  instance_type           = "t3.medium"
  max_instances           = 2
  use_spot_purchasing     = false
  scaling_action_cooldown = 240
  ebs_size_gb             = 400

  subnets = module.network.private_subnets
  security_group_ids = [
    aws_security_group.service_egress.id,
  ]
}

# worker node to be used for bagit creation
module "worker_node_bagit" {
  source = "../modules/stack/worker_node"

  name = "${local.environment_name}-workernode_bagit"

  cpu    = null
  memory = "1900"

  working_storage_path         = "/var/scratch/"
  data_bucket_name             = aws_s3_bucket.workflow-data.bucket
  configuration_bucket_name    = aws_s3_bucket.workflow-configuration.bucket
  goobi_external_job_queue     = module.queues.queue_bagit_job_name
  goobi_external_command_queue = module.queues.queue_command_name
  goobi_hostname               = "${module.goobi.name}.${aws_service_discovery_private_dns_namespace.namespace.name}"
  db_server                    = module.goobi_rds_cluster_aurora3.host
  db_port                      = module.goobi_rds_cluster_aurora3.port
  db_name                      = "workernode"
  db_user_key                  = local.db_user_key
  db_password_key              = local.db_password_key

  cluster_arn  = aws_ecs_cluster.cluster-ec2.arn
  cluster_name = aws_ecs_cluster.cluster-ec2.name

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
    type  = "binpack"
    field = "memory"
  }]
  volumes = [{
    name      = "scratch"
    host_path = "/ebs"
  }]

  autoscaling_min_capacity          = 0
  autoscaling_max_capacity          = 4
  autoscaling_scale_up_adjustment   = 1
  autoscaling_scale_down_adjustment = -1
  scale_up_threshold                = 0
  scale_down_threshold              = 0

  queue_job_name = module.queues.queue_bagit_job_name
}

# cloudwatch log group as needed for above bagit worker node (not automatically created)
resource "aws_cloudwatch_log_group" "cloudwatch_log_group_workernode_bagit_stage" {
  name = "ecs/${local.environment_name}-workernode_bagit"

  retention_in_days = "14"
}
