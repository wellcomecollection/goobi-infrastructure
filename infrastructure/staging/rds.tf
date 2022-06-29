module "goobi_rds_cluster" {
  source                  = "../modules/rds"
  cluster_identifier      = "goobi-stage"
  database_name           = "goobi"
  username                = local.rds_username
  password                = local.rds_password
  vpc_id                  = module.network.vpc_id
  vpc_subnet_ids          = module.network.private_subnets
  instance_class          = "db.t3.medium"
  backup_retention_period = "14"
  deletion_protection     = "true"

  # The database is in a private subnet, so this CIDR only gives access to
  # other instances in the private subnet (in order to reach via bastion host)
  admin_cidr_ingress = "0.0.0.0/0"

  engine                   = "aurora"

  db_access_security_group = [aws_security_group.interservice.id]
  vpc_security_group_ids   = [aws_security_group.interservice.id]
  sg_name                  = "goobi_sg"
}

module "goobi_rds_cluster_aurora3" {
  source                  = "../modules/rds"
  cluster_identifier      = "goobi-stage-aurora3"
  database_name           = "goobi"
  username                = local.rds_username
  password                = local.rds_password
  vpc_id                  = module.network.vpc_id
  vpc_subnet_ids          = module.network.private_subnets
  instance_class          = "db.t3.medium"
  backup_retention_period = "14"
  deletion_protection     = "true"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.0"

  # The database is in a private subnet, so this CIDR only gives access to
  # other instances in the private subnet (in order to reach via bastion host)
  admin_cidr_ingress = "0.0.0.0/0"

  db_access_security_group = [aws_security_group.interservice.id]
  vpc_security_group_ids   = [aws_security_group.interservice.id]
  sg_name                  = "goobi-stage-aurora3_sg"
}