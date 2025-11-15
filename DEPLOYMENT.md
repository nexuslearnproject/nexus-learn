# Deployment Guide

This guide explains how to deploy the Nexus Learn application to AWS using GitHub Actions CI/CD pipelines.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [GitHub Secrets Setup](#github-secrets-setup)
- [Branch Strategy](#branch-strategy)
- [Deployment Workflows](#deployment-workflows)
- [Manual Deployment](#manual-deployment)
- [Troubleshooting](#troubleshooting)

## Overview

The deployment pipeline uses GitHub Actions to:
1. Run tests and validation on pull requests
2. Build Docker images and push to AWS ECR
3. Deploy to ECS Fargate
4. Run database migrations
5. Perform health checks

### Environments

- **Dev**: Auto-deploys on push to `dev` branch
- **Staging**: Auto-deploys on push to `staging` branch
- **Production**: Auto-deploys on push to `prod` branch (with approval)

## Prerequisites

### AWS Resources

1. **ECR Repositories** (create if not exists):
   - `nexus-backend-dev`
   - `nexus-backend-staging`
   - `nexus-backend-prod`
   - `nexus-frontend-dev`
   - `nexus-frontend-staging`
   - `nexus-frontend-prod`

2. **ECS Clusters and Services**:
   - Dev: `nexus-learn-cluster` / `nexus-learn-backend-service` / `nexus-learn-frontend-service`
   - Staging: `nexus-learn-cluster-staging` / `nexus-learn-backend-service-staging` / `nexus-learn-frontend-service-staging`
   - Prod: `nexus-learn-cluster-prod` / `nexus-learn-backend-service-prod` / `nexus-learn-frontend-service-prod`

3. **S3 Bucket** for Terraform state:
   - Bucket name: `nexus-learn-terraform-state`
   - DynamoDB table: `terraform-state-lock`

### Required Tools

- AWS CLI configured with appropriate credentials
- Docker (for local testing)
- Terraform (for infrastructure changes)

## GitHub Secrets Setup

Configure the following secrets in your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:

### Required Secrets

- `AWS_ACCOUNT_ID`: Your AWS account ID (12 digits)
- `AWS_REGION`: AWS region (e.g., `ap-southeast-1`)
- `AWS_ACCESS_KEY_ID`: AWS access key with ECR/ECS permissions
- `AWS_SECRET_ACCESS_KEY`: AWS secret access key
- `TERRAFORM_BACKEND_BUCKET`: S3 bucket name for Terraform state

### Optional Secrets

- `SLACK_WEBHOOK_URL`: For deployment notifications
- `DATABASE_URL`: Database connection string (if not using Secrets Manager)

## Branch Strategy

### Branch Flow

```
main (protected)
  ├── dev (auto-deploy to Dev)
  ├── staging (auto-deploy to Staging)
  └── prod (auto-deploy to Production)
```

### Workflow

1. **Development**: Work on feature branches → merge to `dev` → auto-deploy to Dev
2. **Staging**: Merge `dev` → `staging` → auto-deploy to Staging
3. **Production**: Merge `staging` → `prod` → deploy to Production (with approval)

## Deployment Workflows

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Triggers**: Pull requests and pushes to all branches

**Actions**:
- Run backend tests (Django)
- Run frontend tests (Next.js)
- Lint code
- Build Docker images (test only)
- Validate Terraform

### 2. Terraform Workflow (`.github/workflows/terraform.yml`)

**Triggers**:
- Push to `main` (plan only)
- Pull requests (plan only)
- Manual dispatch (plan or apply)

**Actions**:
- Terraform init, validate, format check
- Terraform plan for all environments
- Terraform apply (manual approval for prod)

**Usage**:
```bash
# Manual Terraform apply
# Go to Actions → Terraform → Run workflow
# Select environment: dev/staging/prod
# Select action: apply
```

### 3. Dev Deployment (`.github/workflows/deploy-dev.yml`)

**Triggers**: Push to `dev` branch

**Actions**:
1. Build backend and frontend Docker images
2. Push images to ECR (`nexus-backend-dev`, `nexus-frontend-dev`)
3. Update ECS services
4. Run database migrations
5. Health check

### 4. Staging Deployment (`.github/workflows/deploy-staging.yml`)

**Triggers**: Push to `staging` branch

**Actions**:
1. Run full test suite
2. Build and push Docker images
3. Deploy to ECS
4. Run migrations
5. Health check

### 5. Production Deployment (`.github/workflows/deploy-prod.yml`)

**Triggers**: Push to `prod` branch

**Actions**:
1. Pre-deployment checks
2. Run full test suite
3. Create backups (RDS snapshots)
4. Build and push Docker images
5. Blue-green deployment
6. Run migrations (with backup)
7. Health check
8. Automatic rollback on failure

## Manual Deployment

### Deploy via GitHub Actions UI

1. Go to **Actions** tab in GitHub
2. Select the workflow (e.g., "Deploy to Dev")
3. Click **Run workflow**
4. Select branch and click **Run workflow**

### Deploy via AWS CLI

#### Build and Push to ECR

```bash
# Login to ECR
aws ecr get-login-password --region ap-southeast-1 | \
  docker login --username AWS --password-stdin \
  <AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com

# Build and push backend
cd backend
docker build -t nexus-backend-dev:latest .
docker tag nexus-backend-dev:latest \
  <AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/nexus-backend-dev:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/nexus-backend-dev:latest
```

#### Deploy to ECS

```bash
./infrastructure/scripts/deploy-ecs.sh \
  --cluster nexus-learn-cluster \
  --service nexus-learn-backend-service \
  --image <AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/nexus-backend-dev:latest \
  --region ap-southeast-1
```

#### Run Migrations

```bash
./infrastructure/scripts/run-migrations.sh \
  --environment dev \
  --region ap-southeast-1
```

#### Health Check

```bash
./infrastructure/scripts/health-check.sh \
  --environment dev \
  --region ap-southeast-1
```

## Troubleshooting

### Deployment Failures

#### ECS Service Not Updating

1. Check ECS service events:
```bash
aws ecs describe-services \
  --cluster nexus-learn-cluster \
  --services nexus-learn-backend-service \
  --region ap-southeast-1 \
  --query 'services[0].events[:5]'
```

2. Check task definition:
```bash
aws ecs describe-task-definition \
  --task-definition nexus-learn-backend-task \
  --region ap-southeast-1
```

#### Image Pull Errors

1. Verify ECR repository exists:
```bash
aws ecr describe-repositories --region ap-southeast-1
```

2. Check ECS task execution role has ECR permissions

3. Verify image exists:
```bash
aws ecr describe-images \
  --repository-name nexus-backend-dev \
  --region ap-southeast-1
```

#### Migration Failures

1. Check database connectivity from ECS task
2. Verify database credentials in Secrets Manager
3. Check migration status:
```bash
./infrastructure/scripts/run-migrations.sh \
  --environment dev \
  --region ap-southeast-1
```

### Rollback

#### Automatic Rollback

Production deployments automatically rollback on failure.

#### Manual Rollback

```bash
./infrastructure/scripts/rollback-ecs.sh \
  --cluster nexus-learn-cluster-prod \
  --service nexus-learn-backend-service-prod \
  --region ap-southeast-1
```

### Health Check Failures

1. Verify ALB target group health:
```bash
aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN> \
  --region ap-southeast-1
```

2. Check application logs:
```bash
aws logs tail /ecs/nexus-learn/backend --follow --region ap-southeast-1
```

3. Verify health endpoint:
```bash
curl http://<ALB_DNS>/health/
```

## Best Practices

1. **Always test in Dev first**: Deploy to Dev before Staging/Prod
2. **Review Terraform plans**: Always review Terraform plans before applying
3. **Monitor deployments**: Watch CloudWatch logs during deployment
4. **Use feature flags**: Implement feature flags for gradual rollouts
5. **Backup before production**: Always create backups before production deployments
6. **Test rollback procedures**: Regularly test rollback procedures

## Monitoring

### CloudWatch Logs

- Backend: `/ecs/nexus-learn/backend`
- Frontend: `/ecs/nexus-learn/frontend`
- Celery Worker: `/ecs/nexus-learn/celery-worker`

### ECS Metrics

- CPU/Memory utilization
- Task count
- Service health

### ALB Metrics

- Request count
- Response time
- Error rates

## Security

1. **Secrets Management**: Use AWS Secrets Manager for sensitive data
2. **IAM Roles**: Use least privilege IAM roles
3. **Network Security**: Deploy in private subnets with security groups
4. **Image Scanning**: Enable ECR image scanning
5. **Encryption**: Enable encryption at rest and in transit

## Support

For issues or questions:
1. Check GitHub Actions logs
2. Review CloudWatch logs
3. Check AWS service health dashboards
4. Contact DevOps team

