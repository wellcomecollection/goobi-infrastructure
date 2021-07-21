variable "name" {
  type = string
}

# variable "prefix" {
#   type = string
# }

variable "harvester_container_image" {
  type = string
}

variable "proxy_container_image" {
  type = string
}

variable "configuration_bucket_name" {
  type = string
}

variable "db_server" {
  type = string
}

variable "db_name" {
  type    = string
  default = "harvester"
}

variable "db_port" {
  type = number
}

variable "db_user_key" {
  type = string
}

variable "db_password_key" {
  type = string
}

variable "result_bucket_name" {
  type = string
}

variable "cpu" {
  type    = number
  default = 1024
}

variable "memory" {
  type    = number
  default = 2048
}

variable "efs_id" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "service_discovery_namespace_id" {
  type    = string
  default = null
}

variable "container_port" {
  type    = string
  default = "80"
}

variable "source_ips" {
  type    = set(string)
  default = ["0.0.0.0/0"]
}

variable "path_pattern" {
  type    = string
  default = "/harvester/*"
}

variable "host_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "healthcheck_path" {
  type    = string
  default = "/harvester/index.xhtml"
}

variable "alb_listener_arn" {
  type = string
}

variable "ia_username_key" {
  type = string
}

variable "ia_password_key" {
  type = string
}
