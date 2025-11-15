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
    },
    {
      name  = "CELERY_BROKER_URL"
      value = module.elasticache.redis_url
    },
    {
      name  = "CELERY_RESULT_BACKEND"
      value = module.elasticache.redis_url
    },
    {
      name  = "REDIS_HOST"
      value = module.elasticache.redis_endpoint
    },
    {
      name  = "REDIS_PORT"
      value = tostring(module.elasticache.redis_port)
    },
    {
      name  = "NEO4J_URI"
      value = "bolt://neo4j.nexus-learn.local:7687"
    },
    {
      name  = "WEAVIATE_URL"
      value = "http://weaviate.nexus-learn.local:8080"
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

# Neo4j Module
module "neo4j" {
  source = "../../modules/neo4j"

  project_name                  = var.project_name
  environment                   = "dev"
  aws_region                    = var.aws_region
  private_subnet_ids            = module.vpc.private_subnet_ids
  neo4j_security_group_id       = module.vpc.neo4j_security_group_id
  ecs_cluster_id                = module.ecs.cluster_id
  ecs_execution_role_arn        = module.ecs.execution_role_arn
  service_discovery_namespace_id = module.vpc.service_discovery_namespace_id
  neo4j_image                   = var.neo4j_image
  neo4j_cpu                     = var.neo4j_cpu
  neo4j_memory                  = var.neo4j_memory
  neo4j_desired_count           = var.neo4j_desired_count
  neo4j_password_secret_arn     = var.neo4j_password_secret_arn
  enable_container_insights     = var.enable_container_insights
  log_retention_days            = var.log_retention_days
}

# Weaviate Module
module "weaviate" {
  source = "../../modules/weaviate"

  project_name                   = var.project_name
  environment                    = "dev"
  aws_region                     = var.aws_region
  private_subnet_ids             = module.vpc.private_subnet_ids
  weaviate_security_group_id     = module.vpc.weaviate_security_group_id
  ecs_cluster_id                 = module.ecs.cluster_id
  ecs_execution_role_arn         = module.ecs.execution_role_arn
  service_discovery_namespace_id = module.vpc.service_discovery_namespace_id
  weaviate_image                 = var.weaviate_image
  weaviate_cpu                   = var.weaviate_cpu
  weaviate_memory                = var.weaviate_memory
  weaviate_desired_count         = var.weaviate_desired_count
  enable_container_insights      = var.enable_container_insights
  log_retention_days             = var.log_retention_days
  weaviate_persistence_enabled   = var.weaviate_persistence_enabled
  vpc_id                         = module.vpc.vpc_id
}

# ElastiCache Module (Redis)
module "elasticache" {
  source = "../../modules/elasticache"

  project_name         = var.project_name
  environment          = "dev"
  database_subnet_ids  = module.vpc.database_subnet_ids
  redis_security_group_id = module.vpc.redis_security_group_id
  node_type           = var.redis_node_type
  num_cache_nodes     = var.redis_num_nodes
  redis_version       = var.redis_version
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  multi_az_enabled    = var.redis_multi_az_enabled
  snapshot_retention_limit = var.redis_snapshot_retention_limit
}

# Celery Worker Module
module "celery" {
  source = "../../modules/celery"

  project_name            = var.project_name
  environment             = "dev"
  aws_region              = var.aws_region
  private_subnet_ids      = module.vpc.private_subnet_ids
  celery_security_group_id = module.vpc.celery_security_group_id
  ecs_cluster_id          = module.ecs.cluster_id
  ecs_execution_role_arn  = module.ecs.execution_role_arn
  redis_url               = module.elasticache.redis_url
  celery_image            = var.backend_image
  celery_cpu              = var.celery_cpu
  celery_memory           = var.celery_memory
  celery_desired_count    = var.celery_desired_count
  celery_min_count        = var.celery_min_count
  celery_max_count        = var.celery_max_count
  celery_queues           = var.celery_queues
  celery_concurrency      = var.celery_concurrency
  enable_celery_beat      = var.enable_celery_beat
  enable_container_insights = var.enable_container_insights
  log_retention_days      = var.log_retention_days
  celery_environment_variables = concat([
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
      name  = "NEO4J_URI"
      value = "bolt://neo4j.nexus-learn.local:7687"
    },
    {
      name  = "WEAVIATE_URL"
      value = "http://weaviate.nexus-learn.local:8080"
    }
  ], var.celery_environment_variables)
  celery_secrets = [
    {
      name      = "POSTGRES_PASSWORD"
      valueFrom = module.rds.db_password_secret_arn
    }
  ]
}

