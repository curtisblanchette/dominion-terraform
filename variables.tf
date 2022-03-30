variable "account" {
  description = "the id of the aws account"
}

variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default = "dominion"
}

variable "environment" {
  description = "the name of your environment, e.g. \"dev\""
  default     = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "aws-region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws-access-key" {
  type = string
}

variable "aws-secret-key" {
  type = string
}

variable "hosted_zone_id" {
  description = "the hosted zone id for dns records"
  default = "Z1U9E1P8BYPT7O"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both private_subnets and public_subnets have to be defined as well"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.1.0/24"]
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.0.0.0/24"]
}

variable "service_desired_count" {
  description = "Number of tasks running in parallel"
  default     = 1
}

variable "container_image" {
  description = "The name of the Docker image"
  default = ""
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  default     = 443
}

variable "container_cpu" {
  description = "The number of cpu units used by the task"
  default     = 256
}

variable "container_memory" {
  description = "The amount (in MiB) of memory used by the task"
  default     = 512
}

variable "health_check_path" {
  description = "Http path for task health check"
  default     = "/api/v1/healthcheck"
}

variable "certificate_arn" {
  description = "The ARN of the certificate that the ALB uses for https"
  default = "arn:aws:acm:us-east-1:229693131931:certificate/e312a218-750b-41fb-830c-07125a0a2f1f"
}

variable "master_password" {
  description = "The postgres instance master password"
}

variable "user_groups" {
  description = "the cognito user pool groups"
}
