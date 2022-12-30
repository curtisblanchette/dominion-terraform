variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "my_public_ip" {
  description = "Your public ipv4"
}

variable "container_port" {
  description = "Ingres and egress port of the container"
}
