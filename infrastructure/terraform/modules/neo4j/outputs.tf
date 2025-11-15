output "neo4j_service_id" {
  description = "Neo4j ECS service ID"
  value       = aws_ecs_service.neo4j.id
}

output "neo4j_service_name" {
  description = "Neo4j ECS service name"
  value       = aws_ecs_service.neo4j.name
}

output "neo4j_task_definition_arn" {
  description = "Neo4j task definition ARN"
  value       = aws_ecs_task_definition.neo4j.arn
}

output "neo4j_http_port" {
  description = "Neo4j HTTP port"
  value       = var.neo4j_http_port
}

output "neo4j_bolt_port" {
  description = "Neo4j Bolt port"
  value       = var.neo4j_bolt_port
}

output "neo4j_service_discovery_dns" {
  description = "Neo4j service discovery DNS name"
  value       = aws_service_discovery_service.neo4j.name
}

output "neo4j_log_group_name" {
  description = "CloudWatch log group name for Neo4j"
  value       = aws_cloudwatch_log_group.neo4j.name
}

