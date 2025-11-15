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
  description = "Private subnet IDs for Weaviate ECS tasks"
  type        = list(string)
}

variable "weaviate_security_group_id" {
  description = "Security group ID for Weaviate"
  type        = string
}

variable "weaviate_image" {
  description = "Docker image for Weaviate"
  type        = string
  default     = "semitechnologies/weaviate:1.24.0"
}

variable "weaviate_cpu" {
  description = "CPU units for Weaviate (1024 = 1 vCPU)"
  type        = number
  default     = 2048  # 2 vCPU recommended
}

variable "weaviate_memory" {
  description = "Memory for Weaviate in MB"
  type        = number
  default     = 4096  # 4GB recommended minimum
}

variable "weaviate_desired_count" {
  description = "Desired number of Weaviate tasks"
  type        = number
  default     = 1
}

variable "weaviate_http_port" {
  description = "Weaviate HTTP port"
  type        = number
  default     = 8080
}

variable "weaviate_grpc_port" {
  description = "Weaviate gRPC port"
  type        = number
  default     = 50051
}

variable "weaviate_environment_variables" {
  description = "Additional environment variables for Weaviate"
  type        = list(map(string))
  default     = []
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

variable "ecs_cluster_id" {
  description = "ECS cluster ID where Weaviate will run"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for service discovery"
  type        = string
}

variable "weaviate_persistence_enabled" {
  description = "Enable persistence for Weaviate data"
  type        = bool
  default     = true
}

variable "weaviate_default_vectorizer" {
  description = "Default vectorizer module (none, text2vec-openai, etc.)"
  type        = string
  default     = "none"
}

variable "weaviate_enabled_modules" {
  description = "Enabled Weaviate modules"
  type        = list(string)
  default     = ["text2vec-openai", "text2vec-cohere", "text2vec-huggingface", "ref2vec-centroid", "generative-openai", "qna-openai"]
}

variable "service_discovery_namespace_id" {
  description = "Service discovery namespace ID (from VPC or shared namespace)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EFS security group"
  type        = string
}

