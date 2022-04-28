variable "name" {
  type = string
}

# variable "prefix" {
#   type = string
# }

variable "worker_node_container_image" {
  type = string
}

variable "goobi_hostname" {
  type = string
}

variable "goobi_external_job_queue" {
  type    = string
  default = "goobi_external"
}

variable "goobi_external_command_queue" {
  type    = string
  default = "goobi_command"
}

variable "working_storage_path" {
  type = string
}

variable "working_storage_fast_path" {
  type    = string
  default = "/var/scratch/"
}


variable "data_bucket_name" {
  type = string
}

variable "configuration_bucket_name" {
  type = string
}

variable "cpu" {
  type    = number
  default = 2048
}

variable "memory" {
  type    = number
  default = 4096
}

variable "efs_id" {
  type = string
}

variable "working_storage_efs_id" {
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

variable "ia_username_key" {
  type = string
}

variable "ia_password_key" {
  type = string
}

variable "launch_type" {
  type    = string
  default = "FARGATE"
}
variable "capacity_provider_strategies" {
  type = list(object({
    capacity_provider = string
    weight            = number
  }))
  default = []
}

variable "ordered_placement_strategies" {
  type = list(object({
    type  = string
    field = string
  }))
  default = []
}

variable "placement_constraints" {
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "default_region" {
  type    = string
  default = "eu-west-1"
}

variable "volumes" {
  type = list(object({
    name      = string
    host_path = string
  }))
  default = []
}