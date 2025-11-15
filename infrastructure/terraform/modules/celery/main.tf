terraform {
  required_version = ">= 1.0"
}

# CloudWatch Log Group for Celery Worker
resource "aws_cloudwatch_log_group" "celery_worker" {
  name              = "/ecs/${var.project_name}/celery-worker"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-celery-worker-logs"
    Environment = var.environment
  }
}

# CloudWatch Log Group for Celery Beat
resource "aws_cloudwatch_log_group" "celery_beat" {
  count = var.enable_celery_beat ? 1 : 0

  name              = "/ecs/${var.project_name}/celery-beat"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-celery-beat-logs"
    Environment = var.environment
  }
}

# ECS Task Definition for Celery Worker
resource "aws_ecs_task_definition" "celery_worker" {
  family                   = "${var.project_name}-celery-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.celery_cpu
  memory                   = var.celery_memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "celery-worker"
      image     = var.celery_image
      essential = true

      command = [
        "celery",
        "-A", "config.celery",
        "worker",
        "--loglevel=info",
        "--queues=${join(",", var.celery_queues)}",
        "--concurrency=${var.celery_concurrency}"
      ]

      environment = concat([
        {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "config.settings"
        },
        {
          name  = "CELERY_BROKER_URL"
          value = var.redis_url
        },
        {
          name  = "CELERY_RESULT_BACKEND"
          value = var.redis_url
        }
      ], var.celery_environment_variables)

      secrets = var.celery_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.celery_worker.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "celery-worker"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "celery -A config.celery inspect ping || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-celery-worker-task"
    Environment = var.environment
  }
}

# ECS Service for Celery Worker
resource "aws_ecs_service" "celery_worker" {
  name            = "${var.project_name}-celery-worker-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.celery_worker.arn
  desired_count   = var.celery_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.celery_security_group_id]
    assign_public_ip = false
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = {
    Name        = "${var.project_name}-celery-worker-service"
    Environment = var.environment
  }
}

# Auto Scaling Target for Celery Worker
resource "aws_appautoscaling_target" "celery_worker" {
  max_capacity       = var.celery_max_count
  min_capacity       = var.celery_min_count
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.celery_worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "celery_worker_cpu" {
  name               = "${var.project_name}-celery-worker-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.celery_worker.resource_id
  scalable_dimension = aws_appautoscaling_target.celery_worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.celery_worker.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "celery_worker_memory" {
  name               = "${var.project_name}-celery-worker-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.celery_worker.resource_id
  scalable_dimension = aws_appautoscaling_target.celery_worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.celery_worker.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# ECS Task Definition for Celery Beat (Scheduler)
resource "aws_ecs_task_definition" "celery_beat" {
  count = var.enable_celery_beat ? 1 : 0

  family                   = "${var.project_name}-celery-beat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256  # Minimal CPU for scheduler
  memory                   = 512  # Minimal memory
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "celery-beat"
      image     = var.celery_image
      essential = true

      command = [
        "celery",
        "-A", "config.celery",
        "beat",
        "--loglevel=info"
      ]

      environment = concat([
        {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "config.settings"
        },
        {
          name  = "CELERY_BROKER_URL"
          value = var.redis_url
        },
        {
          name  = "CELERY_RESULT_BACKEND"
          value = var.redis_url
        }
      ], var.celery_environment_variables)

      secrets = var.celery_secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.celery_beat[0].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "celery-beat"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.project_name}-celery-beat-task"
    Environment = var.environment
  }
}

# ECS Service for Celery Beat
resource "aws_ecs_service" "celery_beat" {
  count = var.enable_celery_beat ? 1 : 0

  name            = "${var.project_name}-celery-beat-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.celery_beat[0].arn
  desired_count   = 1  # Only one beat scheduler needed
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.celery_security_group_id]
    assign_public_ip = false
  }

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  tags = {
    Name        = "${var.project_name}-celery-beat-service"
    Environment = var.environment
  }
}

