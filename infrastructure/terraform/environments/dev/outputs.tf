output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_domain_name : null
}

output "neo4j_service_discovery_dns" {
  description = "Neo4j service discovery DNS name"
  value       = module.neo4j.neo4j_service_discovery_dns
}

output "neo4j_bolt_port" {
  description = "Neo4j Bolt port"
  value       = module.neo4j.neo4j_bolt_port
}

output "neo4j_http_port" {
  description = "Neo4j HTTP port"
  value       = module.neo4j.neo4j_http_port
}

output "weaviate_service_discovery_dns" {
  description = "Weaviate service discovery DNS name"
  value       = module.weaviate.weaviate_service_discovery_dns
}

output "weaviate_http_port" {
  description = "Weaviate HTTP port"
  value       = module.weaviate.weaviate_http_port
}

output "weaviate_grpc_port" {
  description = "Weaviate gRPC port"
  value       = module.weaviate.weaviate_grpc_port
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.elasticache.redis_endpoint
}

output "redis_url" {
  description = "Redis connection URL"
  value       = module.elasticache.redis_url
  sensitive   = true
}

output "celery_worker_service_name" {
  description = "Celery worker ECS service name"
  value       = module.celery.celery_worker_service_name
}

output "celery_beat_service_id" {
  description = "Celery beat service ID"
  value       = module.celery.celery_beat_service_id
}

