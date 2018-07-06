resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name = "${var.name}"
  vpc  = "${module.network.vpc_id}"
}

