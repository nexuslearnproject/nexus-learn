terraform {
  required_version = ">= 1.0"
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = {
    Name        = "${var.project_name}-redis-subnet-group"
    Environment = var.environment
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-redis-${replace(var.redis_version, ".", "")}"
  family = "redis${var.redis_version}"

  parameter {
    name  = "maxmemory-policy"
    value = var.maxmemory_policy
  }

  tags = {
    Name        = "${var.project_name}-redis-params"
    Environment = var.environment
  }
}

# ElastiCache Replication Group (for Multi-AZ or cluster mode)
resource "aws_elasticache_replication_group" "main" {
  count = var.cluster_mode_enabled || var.multi_az_enabled || var.num_cache_nodes > 1 ? 1 : 0

  replication_group_id       = "${var.project_name}-redis"
  description                = "Redis for Celery broker and result backend"

  engine                     = "redis"
  engine_version             = var.redis_version
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [var.redis_security_group_id]

  num_cache_clusters         = var.num_cache_nodes
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled          = var.multi_az_enabled

  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window
  maintenance_window      = var.maintenance_window

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
  }
}

# ElastiCache Cluster (for single node, non-cluster mode)
resource "aws_elasticache_cluster" "main" {
  count = var.cluster_mode_enabled || var.multi_az_enabled || var.num_cache_nodes > 1 ? 0 : 1

  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [var.redis_security_group_id]
  port                 = 6379

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window         = var.snapshot_window
  maintenance_window      = var.maintenance_window

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
  }
}

