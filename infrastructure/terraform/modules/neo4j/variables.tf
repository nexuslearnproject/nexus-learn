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
  description = "Private subnet IDs for Neo4j ECS tasks"
  type        = list(string)
}

variable "neo4j_security_group_id" {
  description = "Security group ID for Neo4j"
  type        = string
}

variable "neo4j_image" {
  description = "Docker image for Neo4j"
  type        = string
  default     = "neo4j:5.15-community"
}

variable "neo4j_cpu" {
  description = "CPU units for Neo4j (1024 = 1 vCPU)"
  type        = number
  default     = 2048  # 2 vCPU recommended for Neo4j
}

variable "neo4j_memory" {
  description = "Memory for Neo4j in MB"
  type        = number
  default     = 4096  # 4GB recommended minimum
}

variable "neo4j_desired_count" {
  description = "Desired number of Neo4j tasks (should be 1 for single instance)"
  type        = number
  default     = 1
}

variable "neo4j_password_secret_arn" {
  description = "ARN of the Neo4j password secret in Secrets Manager"
  type        = string
  default     = ""
}

variable "neo4j_password" {
  description = "Neo4j password (if not using Secrets Manager)"
  type        = string
  default     = ""
  sensitive   = true
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

variable "neo4j_heap_initial_size" {
  description = "Neo4j heap initial size (e.g., 512m)"
  type        = string
  default     = "512m"
}

variable "neo4j_heap_max_size" {
  description = "Neo4j heap max size (e.g., 2G)"
  type        = string
  default     = "2G"
}

variable "neo4j_pagecache_size" {
  description = "Neo4j pagecache size (e.g., 1G)"
  type        = string
  default     = "1G"
}

variable "neo4j_plugins" {
  description = "Neo4j plugins to enable"
  type        = list(string)
  default     = ["apoc", "graph-data-science"]
}

variable "neo4j_http_port" {
  description = "Neo4j HTTP port"
  type        = number
  default     = 7474
}

variable "neo4j_bolt_port" {
  description = "Neo4j Bolt port"
  type        = number
  default     = 7687
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID where Neo4j will run"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "service_discovery_namespace_id" {
  description = "Service discovery namespace ID (from VPC or shared namespace)"
  type        = string
}

