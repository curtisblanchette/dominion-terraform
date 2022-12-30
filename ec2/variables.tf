variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created"
}

variable "subnets" {
  description = "List of subnet IDs"
}

variable "my_public_ip" {
  description = "The public IP address of your local machine connected to internet."
}

variable "public_key" {
  description = "The public key used to access the ec2 instance"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "internet_gateway" {
  description = "The IGW connected to this instance"
}

variable "bastion_sg_id" {
  description = "Security Group id for ec2 Bastion host"
}
