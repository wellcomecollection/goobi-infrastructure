variable "public_subnets" {
  type = list(string)
}

variable "vpc_id" {
}

variable "certificate_domain" {
}

variable "name" {
}

variable "service_lb_security_group_ids" {
  type = list(string)
}

variable "lb_controlled_ingress_cidrs" {
  type = list(string)
}

variable "idle_timeout" {
  type = number
  default = 120
}
