resource "aws_rds_cluster_instance" "main" {
  count                = 2
  identifier           = "${var.name}-${var.environment}-${count.index}"
  cluster_identifier   = aws_rds_cluster.main.id
  availability_zone    = "us-east-1a"
  instance_class       = "db.r5.large"
  publicly_accessible  = true
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = var.db_subnet_group.name
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.name}-${var.environment}"
  engine                  = "aurora-postgresql"
#  availability_zones      = ["us-east-1a", "us-east-1b"]
  db_subnet_group_name    = var.db_subnet_group.name
  database_name           = "postgres"
  master_username         = "postgres"
  master_password         = var.master_password
  backup_retention_period = 1
  apply_immediately       = false
  #  preferred_backup_window   = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [
    var.db_security_group
  ]
}
