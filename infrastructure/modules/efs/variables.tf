variable "name" {
  description = "Name of the EFS mount"
}

variable "subnets" {
  type        = list(string)
  description = "subnets where to create the EFS mount"
}

variable "vpc_id" {
  description = "ID of VPC to to create EFS mount in"
}

variable "efs_access_security_group_ids" {
  type        = list(string)
  description = "IDs of the security groups of the EC2 instances that need to access the EFS"
}

variable "performance_mode" {
  description = "EFS Performance mode (generalPurpose or maxIO)"
  default     = "generalPurpose"
}

variable "num_subnets" {
  description = "Number of subnets"
}

variable "throughput_mode" {
  description = "EFS throughput mode (bursting or provisioned)"
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "EFS provisioned througput in MiB/s, if using provisioned throughput mode"
  default     = null
}