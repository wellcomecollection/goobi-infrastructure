variable "cluster_identifier" {
}

variable "instance_class" {
  type    = string
  default = "db.t2.small"
}

variable "backup_retention_period" {
  default = "14"
}

variable "deletion_protection" {
}

variable "database_name" {
}

variable "username" {
}

variable "password" {
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "vpc_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
}

variable "admin_cidr_ingress" {
}

variable "db_access_security_group" {
  type = list(string)
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "engine" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "cluster_parameter_group" {
  type    = string
  default = ""
}

variable "db_parameter_group" {
  type    = string
  default = ""
}
