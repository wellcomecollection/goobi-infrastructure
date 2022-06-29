module "goobi_rds_cluster" {
  source                  = "../modules/rds"
  cluster_identifier      = "goobi"
  database_name           = "goobi"
  username                = local.rds_username
  password                = local.rds_password
  vpc_id                  = module.network.vpc_id
  vpc_subnet_ids          = module.network.private_subnets
  instance_class          = "db.r5.large"
  backup_retention_period = "14"
  deletion_protection     = "true"

  # The database is in a private subnet, so this CIDR only gives access to
  # other instances in the private subnet (in order to reach via bastion host)
  admin_cidr_ingress = "0.0.0.0/0"

  engine = "aurora"

  db_access_security_group = [aws_security_group.interservice.id]
  vpc_security_group_ids   = [aws_security_group.interservice.id]
  sg_name                  = "goobi_sg"
}

