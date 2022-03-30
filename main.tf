provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region     = var.aws-region
}

#terraform {
#  backend "s3" {
#    bucket  = "terraform-backend-store"
#    encrypt = true
#    key     = "terraform.tfstate"
#    region  = "us-east-1"
#    # dynamodb_table = "terraform-state-lock-dynamo" - uncomment this line once the terraform-state-lock-dynamo has been terraformed
#  }
#}

#resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#  name           = "terraform-state-lock-dynamo"
#  hash_key       = "LockID"
#  read_capacity  = 20
#  write_capacity = 20
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
#  tags = {
#    Name = "DynamoDB Terraform State Lock Table"
#  }
#}

module "vpc" {
  source             = "./vpc"
  name               = var.name
  cidr               = var.cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "security_groups" {
  source         = "./security_groups"
  name           = var.name
  vpc_id         = module.vpc.id
  environment    = var.environment
  container_port = var.container_port
}

module "rds" {
  source            = "./rds"
  name              = var.name
  vpc_id            = module.vpc.id
  environment       = var.environment
  container_port    = var.container_port
  db_security_group = module.security_groups.rds
  db_subnet_group   = module.vpc.db_subnet_group
  master_password   = var.master_password
}

module "alb" {
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [module.security_groups.alb]
  alb_tls_cert_arn    = var.certificate_arn
  health_check_path   = var.health_check_path
}

module "ecr" {
  source      = "./ecr"
  name        = var.name
  environment = var.environment
}

module "ecs" {
  source                      = "./ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.aws-region
  subnets                     = module.vpc.private_subnets
  aws_alb_target_group_arn    = module.alb.aws_alb_target_group_arn
  ecs_service_security_groups = [module.security_groups.ecs_tasks]
  container_port              = var.container_port
  container_cpu               = var.container_cpu
  container_memory            = var.container_memory
  service_desired_count       = var.service_desired_count
  container_environment       = [
    {
      name  = "NODE_ENV",
      value = var.environment
    },
    {
      name  = "LOG_LEVEL",
      value = "DEBUG"
    },
    {
      name  = "PORT",
      value = var.container_port
    }
  ]
  #  aws_ecr_repository_url = module.ecr.aws_ecr_repository_url
}

module "apigw" {
  source           = "./apigw"
  name             = var.name
  environment      = var.environment
  aws_alb_dns_name = module.alb.aws_alb_dns_name
}

module "route53" {
  source                 = "./route53"
  name                   = var.name
  environment            = var.environment
  aws_alb_dns_name       = module.alb.aws_alb_dns_name
  route53_alb_record_uri = module.route53.route53_alb_record_uri
  route53_ui_record_uri  = module.route53.route53_ui_record_uri
  hosted_zone_id         = var.hosted_zone_id
  aws_alb_zone_id        = module.alb.aws_alb_zone_id
  deployment_invoke_url  = module.apigw.invoke_url
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
}

module "s3" {
  source      = "./s3"
  name        = var.name
  environment = var.environment
  vpc_id      = module.vpc.id
  account     = var.account
}

module "cloudfront" {
  source             = "./cloudfront"
  name               = var.name
  environment        = var.environment
  certificate_arn    = var.certificate_arn
  s3_bucket_dns_name = module.s3.s3_bucket_dns_name
}

module "cognito" {
  source = "./cognito"
  name = var.name
  environment = var.environment
  user_groups = var.user_groups
}

# TODO Add the ec2 t2.micro instance (used as a bastion host) to access postgres (in the private subnet)
