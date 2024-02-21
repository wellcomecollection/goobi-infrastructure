data "aws_ssm_parameter" "admin_cidr_ingress" {
  name = "/workflow/config/stage/admin_cidr_ingress"
}

data "aws_ssm_parameter" "harvester_source_ips" {
  name = "/workflow/config/stage/harvester_source_ips"
}

data "aws_ssm_parameter" "worker_node_container_image" {
  name = "/workflow/images/stage/workernode"
}

data "aws_ssm_parameter" "goobi_container_image" {
  name = "/workflow/images/stage/goobi"
}

data "aws_ssm_parameter" "harvester_container_image" {
  name = "/workflow/images/stage/harvester"
}

data "aws_ssm_parameter" "proxy_container_image" {
  name = "/workflow/images/stage/proxy"
}

data "aws_ssm_parameter" "lambda_api_endpoint_ep" {
  name = "/workflow/config/stage/lambda_api_endpoint_ep"
}

data "aws_ssm_parameter" "lambda_templateid_ep" {
  name = "/workflow/config/stage/lambda_templateid_ep"
}

data "aws_ssm_parameter" "lambda_updatetemplateid_ep" {
  name = "/workflow/config/stage/lambda_updatetemplateid_ep"
}

data "aws_ssm_parameter" "lambda_token_ep" {
  name = "/workflow/config/stage/lambda_token_ep"
}

data "aws_ssm_parameter" "lambda_api_endpoint_digitised" {
  name = "/workflow/config/stage/lambda_api_endpoint_digitised"
}

data "aws_ssm_parameter" "lambda_templateid_digitised" {
  name = "/workflow/config/stage/lambda_templateid_digitised"
}

data "aws_ssm_parameter" "lambda_updatetemplateid_digitised" {
  name = "/workflow/config/stage/lambda_updatetemplateid_digitised"
}

data "aws_ssm_parameter" "lambda_token_digitised" {
  name = "/workflow/config/stage/lambda_token_digitised"
}

data "aws_ssm_parameter" "lambda_api_endpoint_video" {
  name = "/workflow/config/stage/lambda_api_endpoint_video"
}

data "aws_ssm_parameter" "lambda_templateid_video" {
  name = "/workflow/config/stage/lambda_templateid_video"
}

data "aws_ssm_parameter" "lambda_updatetemplateid_video" {
  name = "/workflow/config/stage/lambda_updatetemplateid_video"
}

data "aws_ssm_parameter" "lambda_token_video" {
  name = "/workflow/config/stage/lambda_token_video"
}

data "aws_ssm_parameter" "lambda_api_endpoint_audio" {
  name = "/workflow/config/stage/lambda_api_endpoint_audio"
}

data "aws_ssm_parameter" "lambda_templateid_audio" {
  name = "/workflow/config/stage/lambda_templateid_audio"
}

data "aws_ssm_parameter" "lambda_updatetemplateid_audio" {
  name = "/workflow/config/stage/lambda_updatetemplateid_audio"
}

data "aws_ssm_parameter" "lambda_token_audio" {
  name = "/workflow/config/stage/lambda_token_audio"
}

data "aws_ssm_parameter" "rds_username" {
  name = "/aws/reference/secretsmanager/workflow/stage/rds_username"
}

data "aws_ssm_parameter" "rds_password" {
  name = "/aws/reference/secretsmanager/workflow/stage/rds_password"
}

locals {
  admin_cidr_ingress                = split(",", data.aws_ssm_parameter.admin_cidr_ingress.value)
  harvester_source_ips              = split(",", data.aws_ssm_parameter.harvester_source_ips.value)
  worker_node_container_image       = data.aws_ssm_parameter.worker_node_container_image.value
  goobi_container_image             = data.aws_ssm_parameter.goobi_container_image.value
  harvester_container_image         = data.aws_ssm_parameter.harvester_container_image.value
  proxy_container_image             = data.aws_ssm_parameter.proxy_container_image.value
  lambda_api_endpoint_ep            = data.aws_ssm_parameter.lambda_api_endpoint_ep.value
  lambda_templateid_ep              = data.aws_ssm_parameter.lambda_templateid_ep.value
  lambda_updatetemplateid_ep        = data.aws_ssm_parameter.lambda_updatetemplateid_ep.value
  lambda_token_ep                   = data.aws_ssm_parameter.lambda_token_ep.value
  lambda_api_endpoint_digitised     = data.aws_ssm_parameter.lambda_api_endpoint_digitised.value
  lambda_templateid_digitised       = data.aws_ssm_parameter.lambda_templateid_digitised.value
  lambda_updatetemplateid_digitised = data.aws_ssm_parameter.lambda_updatetemplateid_digitised.value
  lambda_token_digitised            = data.aws_ssm_parameter.lambda_token_digitised.value
  lambda_api_endpoint_video         = data.aws_ssm_parameter.lambda_api_endpoint_video.value
  lambda_templateid_video           = data.aws_ssm_parameter.lambda_templateid_video.value
  lambda_updatetemplateid_video     = data.aws_ssm_parameter.lambda_updatetemplateid_video.value
  lambda_token_video                = data.aws_ssm_parameter.lambda_token_video.value
  lambda_api_endpoint_audio         = data.aws_ssm_parameter.lambda_api_endpoint_audio.value
  lambda_templateid_audio           = data.aws_ssm_parameter.lambda_templateid_audio.value
  lambda_updatetemplateid_audio     = data.aws_ssm_parameter.lambda_updatetemplateid_audio.value
  lambda_token_audio                = data.aws_ssm_parameter.lambda_token_audio.value
  rds_username                      = data.aws_ssm_parameter.rds_username.value
  rds_password                      = data.aws_ssm_parameter.rds_password.value
}
