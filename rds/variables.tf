variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "availability_zones" {
  description = "Availability Zones for this region"
}

variable "container_port" {
  description = "Ingres and egress port of the container"
}

variable "db_subnet_group" {
  description = "The DB subnet group"
}

variable "master_password" {
  description = "The db master password"
}

variable "db_security_group" {
  description = "The dn security group"
}
