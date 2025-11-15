variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Celery workers"
  type        = list(string)
}

variable "celery_security_group_id" {
  description = "Security group ID for Celery workers"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID where Celery workers will run"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "redis_url" {
  description = "Redis connection URL for Celery broker and result backend"
  type        = string
}

variable "celery_image" {
  description = "Docker image for Celery worker"
  type        = string
}

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

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "celery_environment_variables" {
  description = "Additional environment variables for Celery workers"
  type        = list(map(string))
  default     = []
}

variable "celery_secrets" {
  description = "Secrets for Celery workers (from Secrets Manager)"
  type        = list(map(string))
  default     = []
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70.0
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80.0
}

