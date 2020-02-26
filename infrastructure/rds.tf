module "goobi_rds_cluster" {
  source             = "git::https://github.com/wellcometrust/terraform.git//rds?ref=v6.4.1"
  cluster_identifier = "goobi"
  database_name      = "goobi"
  username           = "${var.rds_username}"
  password           = "${var.rds_password}"
  vpc_id             = "${module.network.vpc_id}"
  vpc_subnet_ids     = ["${module.network.private_subnets}"]

  # The database is in a private subnet, so this CIDR only gives access to
  # other instances in the private subnet (in order to reach via bastion host)
  admin_cidr_ingress = "0.0.0.0/0"

  db_access_security_group = ["${aws_security_group.interservice.id}"]
  vpc_security_group_ids   = "${aws_security_group.interservice.id}"
}