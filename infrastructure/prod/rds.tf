module "goobi_rds_cluster_aurora3" {
  source                  = "../modules/rds"
  cluster_identifier      = "goobi-aurora3"
  database_name           = "goobi"
  username                = local.rds_username
  password                = local.rds_password
  vpc_id                  = module.network.vpc_id
  vpc_subnet_ids          = module.network.private_subnets
  instance_class          = "db.r5.large"
  backup_retention_period = "14"
  deletion_protection     = "true"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"

  # The database is in a private subnet, so this CIDR only gives access to
  # other instances in the private subnet (in order to reach via bastion host)
  admin_cidr_ingress = "0.0.0.0/0"

  db_access_security_group = [aws_security_group.interservice.id]
  vpc_security_group_ids   = [aws_security_group.interservice.id]
  sg_name                  = "goobi-aurora3_sg"
  cluster_parameter_group  = aws_rds_cluster_parameter_group.goobi-aurora3.name
  db_parameter_group       = aws_db_parameter_group.goobi-aurora3.name
}

resource "aws_rds_cluster_parameter_group" "goobi-aurora3" {
  name        = "goobi-aurora3"
  family      = "aurora-mysql8.0"
  description = "RDS cluster parameter group for workflow production"
}

resource "aws_db_parameter_group" "goobi-aurora3" {
  name        = "goobi-aurora3"
  family      = "aurora-mysql8.0"
  description = "RDS cluster parameter group for workflow production"
}
