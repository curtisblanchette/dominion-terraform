variable "account" {
  description = "the id of the aws account"
}

variable "name" {
  description = "the name of your stack, e.g. \"demo\""
  default     = "dominion"
}

variable "environment" {
  description = "the name of your environment, e.g. \"dev\""
  default     = "dev"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-west-2"
}

variable "app_url" {
  description = "the dominion-ui url for this environment"
  default     = "https://app-dev.curtisblanchette.com"
}

variable "aws-access-key" {
  type = string
}

variable "aws-secret-key" {
  type = string
}

variable "hosted_zone_id" {
  description = "the hosted zone id for dns records"
  default     = ""
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
  default     = ""
}

variable "container_port" {
  description = "The port where the Docker is exposed"
  default     = 80
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
}

variable "user_groups" {
  description = "the cognito user pool groups"
  default     = ["system", "admin", "owner", "consultant", "agent"]
}

variable "secrets_manager_arn" {
  description = "The ARN for the secrets manager secret"
}
