module "app_container_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v3.11.1"

  name  = var.name
  image = var.goobi_container_image

  mount_points = [{
    containerPath = "/efs/"
    sourceVolume  = "efs"
    },
    {
      containerPath = "/var/scratch"
      sourceVolume  = "scratch"
  }]

  log_configuration = module.log_router_container.container_log_configuration

  environment = {
    CONFIGSOURCE                 = "s3"
    AWS_S3_BUCKET                = var.configuration_bucket_name
    TZ                           = "Europe/London"
    DB_SERVER                    = var.db_server
    DB_PORT                      = var.db_port
    DB_NAME                      = var.db_name
    DB_HA                        = "aurora:"
    WORKING_STORAGE              = "/efs/tmp_goobi"
    SERVERNAME                   = var.host_name
    HTTPS_DOMAIN                 = var.host_name
    APP_PATH                     = "goobi"
    APP_CONTAINER                = "localhost"
    S3_DATA_BUCKET               = var.data_bucket_name
    GOOBI_EXTERNAL_JOB_QUEUE     = var.goobi_external_job_queue
    GOOBI_EXTERNAL_COMMAND_QUEUE = var.goobi_external_command_queue
    GOOBI_EXTERNAL_JOB_DLQ       = var.goobi_external_job_dlq
    bagitqueue                   = var.goobi_external_bagit_job_queue
    AWS_SNS_TOPICARN             = var.sns_topic_output_notification
  }

  secrets = local.secrets
}

module "log_router_container" {
  source    = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/firelens?ref=v3.15.3"
  namespace = var.name
}

module "log_router_container_secrets_permissions" {
  source    = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v3.15.3"
  secrets   = module.log_router_container.shared_secrets_logging
  role_name = module.task_definition.task_execution_role_name
}

module "proxy_container_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/container_definition?ref=v3.11.1"

  name  = "${var.name}_proxy"
  image = var.proxy_container_image

  port_mappings = [
    {
      containerPort = var.container_port,
      hostPort      = var.container_port,
      protocol      = "tcp"
    }
  ]

  log_configuration = module.log_router_container.container_log_configuration

  environment = {
    SERVERNAME    = var.host_name
    HTTPS_DOMAIN  = var.host_name
    APP_PATH      = "goobi"
    APP_CONTAINER = "localhost"
    TZ            = "Europe/London"
  }
}

module "task_definition" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/task_definition?ref=v3.11.1"

  cpu    = var.cpu
  memory = var.memory

  container_definitions = [
    module.app_container_definition.container_definition,
    module.proxy_container_definition.container_definition,
    module.log_router_container.container_definition
  ]

  efs_volumes = [{
    name           = "efs"
    file_system_id = var.efs_id
    root_directory = "/"
  }]

  volumes = [{
    name      = "scratch"
    host_path = ""
  }]

  launch_types = ["FARGATE"]
  task_name    = var.name
}

module "service" {
  source = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/service?ref=v3.11.1"

  cluster_arn  = var.cluster_arn
  service_name = var.name

  task_definition_arn = module.task_definition.arn

  container_name = module.proxy_container_definition.name
  subnets        = var.subnets

  service_discovery_namespace_id = var.service_discovery_namespace_id

  security_group_ids = var.security_group_ids

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  target_group_arn = aws_alb_target_group.goobi.arn

  container_port = var.container_port

}

module "credentials_permissions" {
  source    = "git::https://github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v3.11.1"
  secrets   = local.secrets
  role_name = module.task_definition.task_execution_role_name
}
