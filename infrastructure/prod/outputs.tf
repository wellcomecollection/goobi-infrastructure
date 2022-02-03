output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_subnets" {
  value = module.network.private_subnets
}

output "num_private_subnets" {
  value = length(module.network.private_subnets)
}

output "service_egress_security_group_id" {
  value = aws_security_group.service_egress.id
}

output "interservice_security_group_id" {
  value = aws_security_group.interservice.id
}

output "efs_security_group_id" {
  value = aws_security_group.efs.id
}

output "service_lb_security_group_id" {
  value = aws_security_group.service_lb.id
}

output "load_balancer_https_listener_arn" {
  value = module.load_balancer.https_listener_arn
}

output "public_ip_ssh" {
  value = aws_instance.access_host.public_ip
}

# workflow upload users

output "production_iha_id" {
  value = module.production_iam.in_house_archives_id
}

output "production_iha_secret" {
  value = module.production_iam.in_house_archives_secret
  sensitive = true
}

output "production_ihp_id" {
  value = module.production_iam.in_house_photography_id
}

output "production_ihp_secret" {
  value = module.production_iam.in_house_photography_secret
  sensitive = true
}

output "production_dis_id" {
  value = module.production_iam.digitisation_services_id
}

output "production_dis_secret" {
  value = module.production_iam.digitisation_services_secret
  sensitive = true
}
