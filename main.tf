provider "aws" {
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region     = var.region
}

provider "aws" {
  alias = "virginia" # secondary provider must be aliased to support multi-region resources
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
  region = "us-east-1"
}

data "aws_acm_certificate" "main" {
  domain = "*.curtisblanchette.com"
  statuses = ["ISSUED"]
}

# WARNING: Cloudfront is only available in the 'us-east-1' region
# a certificate resource can be imported from AWS in any region
# we use the us-east-1 provider to perform any dependant requests
data "aws_acm_certificate" "cloudfront" {
  domain = "*.curtisblanchette.com"
  statuses = ["ISSUED"]
  provider = aws.virginia
}

#data "aws_secretsmanager_secret" "secrets" {
#  arn = var.secrets_manager_arn
#}
#data "aws_secretsmanager_secret_version" "current" {
#  secret_id = data.aws_secretsmanager_secret.secrets.id
#}

# Learn our public IP Address
data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

# Extract public rsa from pem as a data variable
data "external" "bastion_rsa_public_key" {
  program = ["bash", "-c", "jq --null-input --arg key \"$(ssh-keygen -y -f ~/.ssh/bastion_rsa.pem)\" '{\"key\": $key}'"]
}

#terraform {
#  backend "s3" {
#    bucket  = "terraform-backend-store"
#    encrypt = true
#    key     = "terraform.tfstate"
#    region  = "us-west-2"
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

module "secrets_manager" {
  source      = "./secrets_manager"
  environment = var.environment
  region      = var.region
}

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
  my_public_ip   = data.external.myipaddr.result.ip
}

module "rds" {
  depends_on        = [module.secrets_manager]
  source            = "./rds"
  name              = var.name
  vpc_id            = module.vpc.id
  environment       = var.environment
  container_port    = var.container_port
  db_security_group = module.security_groups.rds
  availability_zones = var.availability_zones
  db_subnet_group   = module.vpc.db_subnet_group
  master_password   = jsondecode(module.secrets_manager.secret_string)["services.postgres.password"]
}

module "alb" {
  depends_on = [data.aws_acm_certificate.main]
  source              = "./alb"
  name                = var.name
  vpc_id              = module.vpc.id
  subnets             = module.vpc.public_subnets
  environment         = var.environment
  alb_security_groups = [module.security_groups.alb]
  alb_tls_cert_arn    = data.aws_acm_certificate.main.arn
  health_check_path   = var.health_check_path
}

# ECR Repository
# repository for API service docker container images
module "ecr" {
  source      = "./ecr"
  name        = var.name
  environment = var.environment
}

# Elastic Container Service
module "ecs" {
  source                      = "./ecs"
  name                        = var.name
  environment                 = var.environment
  region                      = var.region
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

#module "apigw" {
#  source           = "./apigw"
#  name             = var.name
#  environment      = var.environment
#  aws_alb_dns_name = module.alb.aws_alb_dns_name
#}

module "route53" {
  source                 = "./route53"
  name                   = var.name
  environment            = var.environment
  aws_alb_dns_name       = module.alb.aws_alb_dns_name
  aws_alb_zone_id        = module.alb.aws_alb_zone_id
#  deployment_invoke_url  = module.apigw.invoke_url
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
  certificate_arn    = data.aws_acm_certificate.cloudfront.arn
  s3_bucket_dns_name = module.s3.s3_bucket_dns_name
}

module "cognito" {
  depends_on      = [module.secrets_manager]

  source          = "./cognito"
  name            = var.name
  account         = var.account
  region          = var.region
  app_url         = var.app_url
  environment     = var.environment
  user_groups     = var.user_groups
  system_password = jsondecode(module.secrets_manager.secret_string)["credentials.system.password"]
}

module "ec2" {
  source        = "./ec2"
  vpc_id        = module.vpc.id
  name          = var.name
  cidr          = var.cidr
  subnets       = module.vpc.public_subnets
  region        = var.region
  environment   = var.environment
  my_public_ip  = data.external.myipaddr.result.ip
  public_key    = data.external.bastion_rsa_public_key.result.key
  bastion_sg_id = module.security_groups.bastion
  internet_gateway = module.vpc.internet_gateway
}

