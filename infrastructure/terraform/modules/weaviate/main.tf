terraform {
  required_version = ">= 1.0"
}

# CloudWatch Log Group for Weaviate
resource "aws_cloudwatch_log_group" "weaviate" {
  name              = "/ecs/${var.project_name}/weaviate"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-weaviate-logs"
    Environment = var.environment
  }
}

# EFS File System for Weaviate persistence (optional but recommended)
resource "aws_efs_file_system" "weaviate" {
  count = var.weaviate_persistence_enabled ? 1 : 0

  creation_token = "${var.project_name}-weaviate-efs"
  encrypted      = true

  tags = {
    Name        = "${var.project_name}-weaviate-efs"
    Environment = var.environment
  }
}

# EFS Security Group
resource "aws_security_group" "efs" {
  count = var.weaviate_persistence_enabled ? 1 : 0

  name        = "${var.project_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from Weaviate"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.weaviate_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-efs-sg"
    Environment = var.environment
  }
}

# EFS Mount Target
resource "aws_efs_mount_target" "weaviate" {
  count = var.weaviate_persistence_enabled ? length(var.private_subnet_ids) : 0

  file_system_id  = aws_efs_file_system.weaviate[0].id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = aws_security_group.efs[*].id
}

# ECS Task Definition for Weaviate
resource "aws_ecs_task_definition" "weaviate" {
  family                   = "${var.project_name}-weaviate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.weaviate_cpu
  memory                   = var.weaviate_memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "weaviate"
      image     = var.weaviate_image
      essential = true

      portMappings = [
        {
          containerPort = var.weaviate_http_port
          protocol      = "tcp"
        },
        {
          containerPort = var.weaviate_grpc_port
          protocol      = "tcp"
        }
      ]

      environment = concat([
        {
          name  = "QUERY_DEFAULTS_LIMIT"
          value = "25"
        },
        {
          name  = "AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED"
          value = "true"
        },
        {
          name  = "PERSISTENCE_DATA_PATH"
          value = "/var/lib/weaviate"
        },
        {
          name  = "DEFAULT_VECTORIZER_MODULE"
          value = var.weaviate_default_vectorizer
        },
        {
          name  = "ENABLE_MODULES"
          value = join(",", var.weaviate_enabled_modules)
        },
        {
          name  = "CLUSTER_HOSTNAME"
          value = "node1"
        }
      ], var.weaviate_environment_variables)

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.weaviate.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "weaviate"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:${var.weaviate_http_port}/v1/.well-known/ready || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }

      mountPoints = var.weaviate_persistence_enabled ? [
        {
          sourceVolume  = "weaviate-data"
          containerPath = "/var/lib/weaviate"
          readOnly      = false
        }
      ] : []

      volumesFrom = []
    }
  ])

  dynamic "volume" {
    for_each = var.weaviate_persistence_enabled ? [1] : []
    content {
      name = "weaviate-data"

      efs_volume_configuration {
        file_system_id     = aws_efs_file_system.weaviate[0].id
        root_directory     = "/"
        transit_encryption = "ENABLED"
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-weaviate-task"
    Environment = var.environment
  }
}

# ECS Service for Weaviate
resource "aws_ecs_service" "weaviate" {
  name            = "${var.project_name}-weaviate-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.weaviate.arn
  desired_count   = var.weaviate_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.weaviate_security_group_id]
    assign_public_ip = false
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = {
    Name        = "${var.project_name}-weaviate-service"
    Environment = var.environment
  }
}

# Service Discovery for Weaviate
resource "aws_service_discovery_service" "weaviate" {
  name = "weaviate"

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

