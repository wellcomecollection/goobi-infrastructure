resource "aws_rds_cluster_instance" "cluster_instances" {
  count = 2

  identifier              = "${var.cluster_identifier}-${count.index}"
  cluster_identifier      = aws_rds_cluster.default.id
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.default.name
  publicly_accessible     = var.publicly_accessible
  engine_version          = var.engine_version
  engine                  = var.engine
  db_parameter_group_name = var.db_parameter_group
}

resource "aws_db_subnet_group" "default" {
  subnet_ids = var.vpc_subnet_ids
}

resource "aws_rds_cluster" "default" {
  db_subnet_group_name            = aws_db_subnet_group.default.name
  cluster_identifier              = var.cluster_identifier
  database_name                   = var.database_name
  master_username                 = var.username
  master_password                 = var.password
  vpc_security_group_ids          = [aws_security_group.database_sg.id]
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
  engine_version                  = var.engine_version
  engine                          = var.engine
  final_snapshot_identifier       = "${var.cluster_identifier}-final"
  skip_final_snapshot             = false
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  db_cluster_parameter_group_name = var.cluster_parameter_group
}

