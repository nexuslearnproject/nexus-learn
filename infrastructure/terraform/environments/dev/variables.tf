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

