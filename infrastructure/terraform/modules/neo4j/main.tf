terraform {
  required_version = ">= 1.0"
}

# CloudWatch Log Group for Neo4j
resource "aws_cloudwatch_log_group" "neo4j" {
  name              = "/ecs/${var.project_name}/neo4j"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-neo4j-logs"
    Environment = var.environment
  }
}

# ECS Task Definition for Neo4j
resource "aws_ecs_task_definition" "neo4j" {
  family                   = "${var.project_name}-neo4j"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.neo4j_cpu
  memory                   = var.neo4j_memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "neo4j"
      image     = var.neo4j_image
      essential = true

      portMappings = [
        {
          containerPort = var.neo4j_http_port
          protocol      = "tcp"
        },
        {
          containerPort = var.neo4j_bolt_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NEO4J_AUTH"
          value = "neo4j/${var.neo4j_password != "" ? var.neo4j_password : "neo4j_password"}"
        },
        {
          name  = "NEO4J_PLUGINS"
          value = jsonencode(var.neo4j_plugins)
        },
        {
          name  = "NEO4J_dbms_memory_heap_initial__size"
          value = var.neo4j_heap_initial_size
        },
        {
          name  = "NEO4J_dbms_memory_heap_max__size"
          value = var.neo4j_heap_max_size
        },
        {
          name  = "NEO4J_dbms_memory_pagecache_size"
          value = var.neo4j_pagecache_size
        },
        {
          name  = "NEO4J_dbms_security_procedures_unrestricted"
          value = "apoc.*,gds.*"
        },
        {
          name  = "NEO4J_dbms_security_procedures_allowlist"
          value = "apoc.*,gds.*"
        },
        {
          name  = "NEO4J_dbms_security_procedures_whitelist"
          value = "apoc.*,gds.*"
        },
        {
          name  = "NEO4J_dbms_default__database"
          value = "neo4j"
        }
      ]

      secrets = var.neo4j_password_secret_arn != "" ? [
        {
          name      = "NEO4J_AUTH"
          valueFrom = "${var.neo4j_password_secret_arn}:password::"
        }
      ] : []

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.neo4j.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "neo4j"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:${var.neo4j_http_port} || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 120
      }

      mountPoints = []
      volumesFrom = []
    }
  ])

  tags = {
    Name        = "${var.project_name}-neo4j-task"
    Environment = var.environment
  }
}

# ECS Service for Neo4j
resource "aws_ecs_service" "neo4j" {
  name            = "${var.project_name}-neo4j-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.neo4j.arn
  desired_count   = var.neo4j_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.neo4j_security_group_id]
    assign_public_ip = false
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = {
    Name        = "${var.project_name}-neo4j-service"
    Environment = var.environment
  }
}

# Service Discovery for Neo4j
resource "aws_service_discovery_service" "neo4j" {
  name = "neo4j"

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_grace_period_seconds = 30
}

