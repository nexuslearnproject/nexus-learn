output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value = var.cluster_mode_enabled || var.multi_az_enabled || var.num_cache_nodes > 1 ? (
    aws_elasticache_replication_group.main[0].primary_endpoint_address
  ) : (
    length(aws_elasticache_cluster.main) > 0 ? aws_elasticache_cluster.main[0].cache_nodes[0].address : ""
  )
}

output "redis_port" {
  description = "Redis port"
  value       = 6379
}

output "redis_url" {
  description = "Redis connection URL"
  value = var.cluster_mode_enabled || var.multi_az_enabled || var.num_cache_nodes > 1 ? (
    "redis://${aws_elasticache_replication_group.main[0].primary_endpoint_address}:6379/0"
  ) : (
    length(aws_elasticache_cluster.main) > 0 ? "redis://${aws_elasticache_cluster.main[0].cache_nodes[0].address}:6379/0" : ""
  )
}

output "redis_configuration_endpoint" {
  description = "Redis configuration endpoint (for cluster mode)"
  value = var.cluster_mode_enabled ? (
    aws_elasticache_replication_group.main[0].configuration_endpoint_address
  ) : null
}

output "redis_replication_group_id" {
  description = "Redis replication group ID"
  value = var.cluster_mode_enabled || var.multi_az_enabled || var.num_cache_nodes > 1 ? (
    aws_elasticache_replication_group.main[0].id
  ) : null
}

