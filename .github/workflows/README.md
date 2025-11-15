# GitHub Actions Workflows

This directory contains GitHub Actions workflows for CI/CD automation.

## Workflows Overview

### 1. CI (`ci.yml`)

Continuous Integration workflow that runs on every pull request and push.

**Features**:
- Backend tests (Django)
- Frontend tests (Next.js)
- Code linting
- Docker build validation
- Terraform validation

**Triggers**: Pull requests and pushes to all branches

### 2. Terraform (`terraform.yml`)

Infrastructure as Code workflow for managing AWS resources.

**Features**:
- Terraform plan (on PRs and pushes)
- Terraform apply (manual dispatch)
- Multi-environment support
- Plan artifacts for review

**Triggers**:
- Push to `main` (plan only)
- Pull requests (plan only)
- Manual dispatch (plan or apply)

**Usage**:
1. Go to Actions → Terraform
2. Click "Run workflow"
3. Select environment (dev/staging/prod)
4. Select action (plan/apply)

### 3. Deploy to Dev (`deploy-dev.yml`)

Automated deployment to Development environment.

**Features**:
- Build Docker images
- Push to ECR
- Deploy to ECS
- Run migrations
- Health checks

**Triggers**: Push to `dev` branch

### 4. Deploy to Staging (`deploy-staging.yml`)

Deployment to Staging environment with full test suite.

**Features**:
- Full test suite execution
- Build and push images
- Deploy to ECS
- Run migrations
- Health checks

**Triggers**: Push to `staging` branch

### 5. Deploy to Production (`deploy-prod.yml`)

Production deployment with safety checks and rollback.

**Features**:
- Pre-deployment checks
- Full test suite
- Backup creation
- Blue-green deployment
- Automatic rollback on failure
- Manual approval (via GitHub Environments)

**Triggers**: Push to `prod` branch

## Workflow Dependencies

```
CI → All workflows
Terraform → Infrastructure changes
Deploy Dev → Dev environment
Deploy Staging → Staging environment
Deploy Prod → Production environment
```

## Environment Variables

Workflows use the following environment variables:

- `AWS_REGION`: AWS region (default: `ap-southeast-1`)
- `ENVIRONMENT`: Deployment environment (dev/staging/prod)
- `ECR_BACKEND_REPO`: ECR repository for backend
- `ECR_FRONTEND_REPO`: ECR repository for frontend
- `ECS_CLUSTER`: ECS cluster name
- `ECS_BACKEND_SERVICE`: ECS backend service name
- `ECS_FRONTEND_SERVICE`: ECS frontend service name

## Required GitHub Secrets

- `AWS_ACCOUNT_ID`: AWS account ID
- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `TERRAFORM_BACKEND_BUCKET`: S3 bucket for Terraform state

## Deployment Scripts

Workflows use scripts from `infrastructure/scripts/`:

- `deploy-ecs.sh`: Deploy to ECS
- `run-migrations.sh`: Run database migrations
- `health-check.sh`: Post-deployment health check
- `rollback-ecs.sh`: Rollback deployment

## Troubleshooting

### Workflow Not Triggering

1. Check branch name matches trigger condition
2. Verify workflow file syntax
3. Check GitHub Actions permissions

### Deployment Failures

1. Check workflow logs in Actions tab
2. Verify AWS credentials
3. Check ECS service status
4. Review CloudWatch logs

### Terraform Failures

1. Verify Terraform state backend configuration
2. Check AWS credentials and permissions
3. Review Terraform plan output
4. Verify resource dependencies

## Best Practices

1. **Test in Dev first**: Always test changes in Dev before Staging/Prod
2. **Review plans**: Always review Terraform plans before applying
3. **Monitor deployments**: Watch workflow logs and CloudWatch metrics
4. **Use feature flags**: Implement feature flags for gradual rollouts
5. **Backup before prod**: Always create backups before production deployments

## Workflow Status Badges

Add to README.md:

```markdown
![CI](https://github.com/nexuslearnproject/nexus-learn/workflows/CI/badge.svg)
![Deploy Dev](https://github.com/nexuslearnproject/nexus-learn/workflows/Deploy%20to%20Dev/badge.svg)
```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECS Deployment](https://docs.aws.amazon.com/ecs/)
- [Terraform Documentation](https://www.terraform.io/docs)

