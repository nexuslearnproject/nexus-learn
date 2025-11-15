output "weaviate_service_id" {
  description = "Weaviate ECS service ID"
  value       = aws_ecs_service.weaviate.id
}

output "weaviate_service_name" {
  description = "Weaviate ECS service name"
  value       = aws_ecs_service.weaviate.name
}

output "weaviate_task_definition_arn" {
  description = "Weaviate task definition ARN"
  value       = aws_ecs_task_definition.weaviate.arn
}

output "weaviate_http_port" {
  description = "Weaviate HTTP port"
  value       = var.weaviate_http_port
}

output "weaviate_grpc_port" {
  description = "Weaviate gRPC port"
  value       = var.weaviate_grpc_port
}

output "weaviate_service_discovery_dns" {
  description = "Weaviate service discovery DNS name"
  value       = aws_service_discovery_service.weaviate.name
}

output "weaviate_log_group_name" {
  description = "CloudWatch log group name for Weaviate"
  value       = aws_cloudwatch_log_group.weaviate.name
}

output "weaviate_efs_id" {
  description = "EFS file system ID for Weaviate persistence"
  value       = var.weaviate_persistence_enabled ? aws_efs_file_system.weaviate[0].id : null
}

