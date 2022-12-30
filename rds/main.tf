# Note
# changes wont take effect updating `instance_class` if `apply_immediately` is not true

resource "aws_rds_cluster_instance" "main" {
  count                = 2
  apply_immediately    = false
  identifier           = "${var.name}-${var.environment}-${count.index}"
  cluster_identifier   = aws_rds_cluster.main.id
  availability_zone    = var.availability_zones[0]
  instance_class       = "db.serverless"
  publicly_accessible  = true # this could likely be changed to false
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = var.db_subnet_group.name
}

resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.name}-${var.environment}"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
# availability_zones      = var.availability_zones # https://github.com/hashicorp/terraform-provider-aws/issues/7307#issuecomment-457441633
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

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}
