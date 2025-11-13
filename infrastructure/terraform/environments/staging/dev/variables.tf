variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "nexus-learn"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "backend_image" {
  description = "Docker image for backend (e.g., your-account.dkr.ecr.us-east-1.amazonaws.com/nexus-backend:latest)"
  type        = string
  default     = ""
}

variable "backend_cpu" {
  description = "CPU units for backend (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Memory for backend in MB"
  type        = number
  default     = 1024
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_min_count" {
  description = "Minimum number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_max_count" {
  description = "Maximum number of backend tasks"
  type        = number
  default     = 5
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

