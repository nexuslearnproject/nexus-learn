# AWS Redis + Celery Infrastructure Guide

This guide explains how to deploy Redis (ElastiCache) and Celery workers on AWS using Terraform.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      AWS VPC                             │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Backend    │  │   Celery     │  │   Celery     │  │
│  │  (ECS Fargate)│  │   Workers    │  │     Beat     │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                  │                 │           │
│         └──────────────────┴─────────────────┘           │
│                         │                                 │
│                         ▼                                 │
│              ┌──────────────────┐                         │
│              │ ElastiCache Redis│                         │
│              │  (Managed Redis) │                         │
│              └──────────────────┘                         │
└──────────────────────────────────────────────────────────┘
```

## Components

### 1. ElastiCache Module (`modules/elasticache/`)
- **Managed Redis**: AWS ElastiCache for Redis
- **High Availability**: Optional Multi-AZ and automatic failover
- **Encryption**: At-rest and in-transit encryption support
- **Snapshots**: Automated backups
- **Subnet Group**: Deployed in database subnets for isolation

### 2. Celery Module (`modules/celery/`)
- **Celery Workers**: ECS Fargate tasks for async processing
- **Celery Beat**: Optional scheduler for periodic tasks
- **Auto Scaling**: CPU and memory-based scaling
- **Queue Support**: Multiple queues (langgraph, embeddings)
- **CloudWatch Logs**: Centralized logging

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured
4. **S3 Bucket** for Terraform state (configured in `backend.tf`)

## Deployment

### 1. Configure Variables

Edit `infrastructure/terraform/environments/dev/terraform.tfvars`:

```hcl
# Redis Configuration
redis_node_type = "cache.t3.micro"  # Free tier eligible
redis_num_nodes = 1
redis_version = "7.0"
redis_automatic_failover_enabled = false  # Cost optimization
redis_multi_az_enabled = false
redis_snapshot_retention_limit = 1

# Celery Configuration
celery_cpu = 1024  # 1 vCPU
celery_memory = 2048  # 2GB
celery_desired_count = 2
celery_min_count = 1
celery_max_count = 5
celery_concurrency = 2
celery_queues = ["langgraph", "embeddings"]
enable_celery_beat = true
```

### 2. Initialize Terraform

```bash
cd infrastructure/terraform/environments/dev
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

This will create:
- ElastiCache Redis cluster
- Celery worker ECS service
- Celery beat ECS service (if enabled)
- Security groups and networking
- Auto-scaling configuration

### 5. Get Connection Information

After deployment:

```bash
terraform output redis_endpoint
terraform output redis_url
terraform output celery_worker_service_name
```

## Configuration

### ElastiCache Configuration

#### Node Types

**Development:**
- `cache.t3.micro` - Free tier eligible, 0.5GB RAM
- Single node, no Multi-AZ

**Production:**
- `cache.t3.medium` or larger
- Multi-AZ enabled
- Automatic failover enabled
- Snapshot retention: 7-30 days

#### Redis Version

- **7.0**: Latest stable (recommended)
- **6.2**: Previous stable
- **6.0**: Older version

#### Security

- **Encryption at Rest**: Enabled by default
- **Encryption in Transit**: Optional (requires auth token)
- **VPC Only**: Accessible only from within VPC
- **Security Groups**: Restrict access to ECS and Celery workers

### Celery Configuration

#### Worker Settings

```hcl
celery_cpu = 1024  # 1 vCPU per worker
celery_memory = 2048  # 2GB per worker
celery_concurrency = 2  # 2 concurrent tasks per worker
celery_queues = ["langgraph", "embeddings"]
```

#### Auto Scaling

Workers scale based on:
- **CPU Utilization**: Target 70%
- **Memory Utilization**: Target 80%
- **Min Workers**: 1
- **Max Workers**: 5 (configurable)

#### Celery Beat

Scheduler for periodic tasks:
- Single instance (no scaling)
- Minimal resources (256 CPU, 512MB memory)
- Optional: Can be disabled if not needed

## Connection Strings

### From Backend API

The backend automatically receives Redis connection via environment variables:

```env
CELERY_BROKER_URL=redis://<elasticache-endpoint>:6379/0
CELERY_RESULT_BACKEND=redis://<elasticache-endpoint>:6379/0
REDIS_HOST=<elasticache-endpoint>
REDIS_PORT=6379
```

### From Celery Workers

Celery workers receive the same configuration automatically.

## Monitoring

### CloudWatch Logs

**Celery Worker Logs:**
```bash
aws logs tail /ecs/nexus-learn/celery-worker --follow
```

**Celery Beat Logs:**
```bash
aws logs tail /ecs/nexus-learn/celery-beat --follow
```

### ECS Service Status

```bash
aws ecs describe-services \
  --cluster nexus-learn-cluster \
  --services nexus-learn-celery-worker-service
```

### ElastiCache Metrics

Monitor in CloudWatch:
- `CPUUtilization`
- `NetworkBytesIn/Out`
- `CacheHits/CacheMisses`
- `Evictions`
- `ReplicationLag`

## Cost Optimization

### Development Environment

```hcl
# Minimal configuration
redis_node_type = "cache.t3.micro"  # ~$15/month
celery_desired_count = 1
celery_cpu = 512  # 0.5 vCPU
celery_memory = 1024  # 1GB
enable_celery_beat = false  # Disable if not needed
```

**Estimated Monthly Cost:**
- ElastiCache: ~$15-20
- Celery Workers (2x): ~$30-40
- Total: ~$45-60/month

### Production Environment

```hcl
# Production configuration
redis_node_type = "cache.t3.medium"  # ~$60/month
redis_multi_az_enabled = true
redis_automatic_failover_enabled = true
celery_desired_count = 3
celery_cpu = 2048  # 2 vCPU
celery_memory = 4096  # 4GB
```

**Estimated Monthly Cost:**
- ElastiCache: ~$120-150
- Celery Workers (3x): ~$150-200
- Total: ~$270-350/month

## Troubleshooting

### Redis Connection Issues

1. **Check Security Groups:**
```bash
aws ec2 describe-security-groups --group-ids <redis-sg-id>
```

2. **Verify Subnet Group:**
```bash
aws elasticache describe-cache-subnet-groups
```

3. **Test Connection from ECS:**
```bash
# SSH into ECS task and test
redis-cli -h <redis-endpoint> -p 6379 ping
```

### Celery Workers Not Starting

1. **Check ECS Service Status:**
```bash
aws ecs describe-services \
  --cluster nexus-learn-cluster \
  --services nexus-learn-celery-worker-service
```

2. **Check Task Logs:**
```bash
aws logs tail /ecs/nexus-learn/celery-worker --follow
```

3. **Verify Redis Connection:**
```bash
# Check if Redis URL is correct in task definition
aws ecs describe-task-definition \
  --task-definition nexus-learn-celery-worker
```

### Tasks Not Processing

1. **Check Worker Status:**
```bash
# From within Celery worker container
celery -A config.celery inspect active
```

2. **Check Queue Configuration:**
```bash
celery -A config.celery inspect registered
```

3. **Verify Redis Connectivity:**
```bash
redis-cli -h <redis-endpoint> ping
```

## Scaling

### Manual Scaling

```bash
aws ecs update-service \
  --cluster nexus-learn-cluster \
  --service nexus-learn-celery-worker-service \
  --desired-count 5
```

### Auto Scaling

Auto-scaling is configured automatically:
- Scales up when CPU > 70% or Memory > 80%
- Scales down when utilization drops
- Cooldown periods prevent thrashing

### Queue-Specific Scaling

To scale specific queues, create separate ECS services:

```hcl
# High-priority queue
celery_queues = ["langgraph"]

# Background queue
celery_queues = ["embeddings"]
```

## Security Best Practices

1. **VPC Isolation**: Redis only accessible from VPC
2. **Security Groups**: Restrict to ECS and Celery workers only
3. **Encryption**: Enable encryption at rest
4. **Secrets**: Use Secrets Manager for sensitive data
5. **IAM Roles**: Least privilege access

## Migration from Docker Compose

### Step 1: Export Data (if needed)

```bash
# Backup Redis data
redis-cli --rdb /backup/redis.rdb
```

### Step 2: Update Configuration

Update environment variables to use ElastiCache endpoint instead of `redis:6379`.

### Step 3: Deploy

```bash
terraform apply
```

### Step 4: Verify

```bash
# Test async task submission
curl -X POST https://<alb-dns>/api/ai/ask-async/ \
  -H "Content-Type: application/json" \
  -d '{"student_id": "test", "question": "test"}'
```

## Production Checklist

- [ ] Enable Multi-AZ for Redis
- [ ] Enable automatic failover
- [ ] Set appropriate snapshot retention
- [ ] Configure CloudWatch alarms
- [ ] Set up backup strategy
- [ ] Enable encryption in transit
- [ ] Configure auto-scaling policies
- [ ] Set up monitoring dashboard
- [ ] Document runbooks
- [ ] Test failover scenarios

## Next Steps

1. **Monitoring**: Set up CloudWatch dashboards
2. **Alerts**: Configure alarms for Redis and Celery
3. **Backup**: Automate Redis snapshots
4. **Performance**: Tune Celery concurrency
5. **Cost**: Monitor and optimize resource usage

## References

- [AWS ElastiCache Documentation](https://docs.aws.amazon.com/elasticache/)
- [Celery Documentation](https://docs.celeryq.dev/)
- [ECS Auto Scaling](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html)

