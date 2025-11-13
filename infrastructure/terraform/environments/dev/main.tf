terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "s3" {
    # Configure this with your S3 bucket name
    bucket         = "nexus-learn-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = "dev"
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
}

# ALB Module
module "alb" {
  source = "../../modules/alb"

  project_name         = var.project_name
  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_security_group_id
  certificate_arn      = var.certificate_arn
}

# RDS Module (Cost-optimized configuration)
module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  environment          = "dev"
  database_subnet_ids  = module.vpc.database_subnet_ids
  rds_security_group_id = module.vpc.rds_security_group_id
  database_name        = var.database_name
  database_username    = var.database_username
  instance_class       = var.rds_instance_class
  allocated_storage    = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  backup_retention_period = var.rds_backup_retention_period
  performance_insights_enabled = var.rds_performance_insights_enabled
  multi_az             = false
  deletion_protection  = false
  skip_final_snapshot  = true
}

# ECS Module (Cost-optimized configuration)
module "ecs" {
  source = "../../modules/ecs"

  project_name            = var.project_name
  environment             = "dev"
  aws_region              = var.aws_region
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_security_group_id   = module.vpc.ecs_security_group_id
  target_group_arn        = module.alb.target_group_arn
  backend_image           = var.backend_image
  backend_cpu             = var.backend_cpu
  backend_memory          = var.backend_memory
  backend_desired_count   = var.backend_desired_count
  backend_min_count       = var.backend_min_count
  backend_max_count       = var.backend_max_count
  enable_container_insights = var.enable_container_insights
  log_retention_days      = var.log_retention_days
  backend_environment_variables = [
    {
      name  = "DJANGO_SETTINGS_MODULE"
      value = "config.settings"
    },
    {
      name  = "POSTGRES_DB"
      value = module.rds.db_instance_name
    },
    {
      name  = "POSTGRES_USER"
      value = module.rds.db_instance_username
    },
    {
      name  = "POSTGRES_HOST"
      value = module.rds.db_instance_address
    },
    {
      name  = "POSTGRES_PORT"
      value = tostring(module.rds.db_instance_port)
    },
    {
      name  = "DJANGO_ALLOWED_HOSTS"
      value = "${module.alb.alb_dns_name},*"
    }
  ]
  backend_secrets = [
    {
      name      = "POSTGRES_PASSWORD"
      valueFrom = module.rds.db_password_secret_arn
    }
  ]
}

# CloudFront Module (optional for dev)
module "cloudfront" {
  count = var.enable_cloudfront ? 1 : 0
  source = "../../modules/cloudfront"

  project_name    = var.project_name
  environment     = "dev"
  alb_origin_id   = "alb-${module.alb.alb_id}"
  certificate_arn = var.cloudfront_certificate_arn
}

