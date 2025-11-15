variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "nexus-learn"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones (single AZ for cost optimization)"
  type        = list(string)
  default     = ["ap-southeast-1a"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (single subnet for cost optimization)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (single subnet for cost optimization)"
  type        = list(string)
  default     = ["10.0.11.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets (single subnet for cost optimization)"
  type        = list(string)
  default     = ["10.0.21.0/24"]
}

variable "backend_image" {
  description = "Docker image for backend (e.g., your-account.dkr.ecr.ap-southeast-1.amazonaws.com/nexus-backend:latest)"
  type        = string
  default     = ""
}

variable "backend_cpu" {
  description = "CPU units for backend (1024 = 1 vCPU, 256 = 0.25 vCPU minimum for cost optimization)"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory for backend in MB (512 MB minimum for cost optimization)"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks (1 for cost optimization)"
  type        = number
  default     = 1
}

variable "backend_min_count" {
  description = "Minimum number of backend tasks (1 for cost optimization)"
  type        = number
  default     = 1
}

variable "backend_max_count" {
  description = "Maximum number of backend tasks (2 for minimal auto-scaling)"
  type        = number
  default     = 2
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "nexus_db"
}

variable "database_username" {
  description = "Database master username"
  type        = string
  default     = "nexus_user"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for ALB (leave empty for HTTP only)"
  type        = string
  default     = ""
}

variable "cloudfront_certificate_arn" {
  description = "ARN of the SSL certificate for CloudFront"
  type        = string
  default     = ""
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution"
  type        = bool
  default     = false
}

# RDS Cost Optimization Variables
variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB (20 GB minimum, Free Tier eligible)"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "RDS maximum allocated storage for autoscaling (set to same as allocated_storage to disable)"
  type        = number
  default     = 20
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention period in days (0-1 for cost optimization)"
  type        = number
  default     = 1
}

variable "rds_performance_insights_enabled" {
  description = "Enable RDS Performance Insights (false for cost optimization)"
  type        = bool
  default     = false
}

# ECS Cost Optimization Variables
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights (false for cost optimization)"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days (1-3 for cost optimization)"
  type        = number
  default     = 1
}

# Neo4j Variables
variable "neo4j_image" {
  description = "Docker image for Neo4j"
  type        = string
  default     = "neo4j:5.15-community"
}

variable "neo4j_cpu" {
  description = "CPU units for Neo4j (1024 = 1 vCPU)"
  type        = number
  default     = 2048
}

variable "neo4j_memory" {
  description = "Memory for Neo4j in MB"
  type        = number
  default     = 4096
}

variable "neo4j_desired_count" {
  description = "Desired number of Neo4j tasks (should be 1 for single instance)"
  type        = number
  default     = 1
}

variable "neo4j_password_secret_arn" {
  description = "ARN of the Neo4j password secret in Secrets Manager (optional)"
  type        = string
  default     = ""
}

# Weaviate Variables
variable "weaviate_image" {
  description = "Docker image for Weaviate"
  type        = string
  default     = "semitechnologies/weaviate:1.24.0"
}

variable "weaviate_cpu" {
  description = "CPU units for Weaviate (1024 = 1 vCPU)"
  type        = number
  default     = 2048
}

variable "weaviate_memory" {
  description = "Memory for Weaviate in MB"
  type        = number
  default     = 4096
}

variable "weaviate_desired_count" {
  description = "Desired number of Weaviate tasks"
  type        = number
  default     = 1
}

variable "weaviate_persistence_enabled" {
  description = "Enable EFS persistence for Weaviate"
  type        = bool
  default     = true
}

# Redis/ElastiCache Variables
variable "redis_node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_nodes" {
  description = "Number of Redis cache nodes"
  type        = number
  default     = 1
}

variable "redis_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "redis_automatic_failover_enabled" {
  description = "Enable automatic failover for Redis"
  type        = bool
  default     = false
}

variable "redis_multi_az_enabled" {
  description = "Enable Multi-AZ for Redis"
  type        = bool
  default     = false
}

variable "redis_snapshot_retention_limit" {
  description = "Number of days to retain Redis snapshots"
  type        = number
  default     = 1
}

# Celery Variables
variable "celery_cpu" {
  description = "CPU units for Celery worker (1024 = 1 vCPU)"
  type        = number
  default     = 1024
}

variable "celery_memory" {
  description = "Memory for Celery worker in MB"
  type        = number
  default     = 2048
}

variable "celery_desired_count" {
  description = "Desired number of Celery workers"
  type        = number
  default     = 2
}

variable "celery_min_count" {
  description = "Minimum number of Celery workers"
  type        = number
  default     = 1
}

variable "celery_max_count" {
  description = "Maximum number of Celery workers"
  type        = number
  default     = 5
}

variable "celery_queues" {
  description = "List of Celery queues to process"
  type        = list(string)
  default     = ["langgraph", "embeddings"]
}

variable "celery_concurrency" {
  description = "Celery worker concurrency (number of concurrent tasks)"
  type        = number
  default     = 2
}

variable "enable_celery_beat" {
  description = "Enable Celery Beat scheduler"
  type        = bool
  default     = true
}

variable "celery_environment_variables" {
  description = "Additional environment variables for Celery workers"
  type        = list(map(string))
  default     = []
}

