output "celery_worker_service_id" {
  description = "Celery worker ECS service ID"
  value       = aws_ecs_service.celery_worker.id
}

output "celery_worker_service_name" {
  description = "Celery worker ECS service name"
  value       = aws_ecs_service.celery_worker.name
}

output "celery_worker_task_definition_arn" {
  description = "Celery worker task definition ARN"
  value       = aws_ecs_task_definition.celery_worker.arn
}

output "celery_beat_service_id" {
  description = "Celery beat ECS service ID (if enabled)"
  value       = var.enable_celery_beat ? aws_ecs_service.celery_beat[0].id : null
}

output "celery_beat_task_definition_arn" {
  description = "Celery beat task definition ARN (if enabled)"
  value       = var.enable_celery_beat ? aws_ecs_task_definition.celery_beat[0].arn : null
}

output "celery_worker_log_group_name" {
  description = "CloudWatch log group name for Celery worker"
  value       = aws_cloudwatch_log_group.celery_worker.name
}

