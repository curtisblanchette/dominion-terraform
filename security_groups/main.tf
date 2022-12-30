resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-sg-alb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-sg-task-${var.environment}"
    Environment = var.environment
  }
}

###################################################
# EC2 Bastion Host - Security Group
###################################################
resource "aws_security_group" "ec2_bastion_host" {
  name        = "${var.name}-sg-bastion-host-${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Curts Home IP"
    protocol         = "tcp"
    from_port        = 0
    to_port          = 65535
    cidr_blocks      = ["${var.my_public_ip}/32"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name}-sg-bastion-host-${var.environment}"
    Environment = var.environment
  }
}


##########################################################
# RDS Aurora - Security Group
##########################################################
resource "aws_security_group" "rds" {
  name        = "${var.name}-sg-rds-${var.environment}"
  description = "RDS Allowed Ports"
  vpc_id      = var.vpc_id

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.name}-sg-rds-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "dominion_rds_sg_inbound_ecs" {
    type = "ingress"
    description = "Inbound From ECS"
    protocol = "TCP"
    from_port = 5432
    to_port = 5432
    security_group_id = aws_security_group.rds.id
    source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_security_group_rule" "dominion_rds_sg_inbound_bastion" {
  type = "ingress"
  description = "Inbound From Bastion"
  protocol = "TCP"
  from_port = 5432
  to_port = 5432
  security_group_id = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ec2_bastion_host.id
}

output "alb" {
  value = aws_security_group.alb.id
}

output "ecs_tasks" {
  value = aws_security_group.ecs_tasks.id
}

output "rds" {
  value = aws_security_group.rds.id
}

output "bastion" {
  value = aws_security_group.ec2_bastion_host.id
}
