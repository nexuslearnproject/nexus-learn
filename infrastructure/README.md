# Infrastructure as Code with Terraform

This directory contains Terraform configurations for deploying the Nexus Learn application to AWS.

## Architecture Overview

The infrastructure consists of:

- **VPC**: Virtual Private Cloud with public, private, and database subnets
- **ECS Fargate**: Container orchestration for Django backend
- **RDS PostgreSQL**: Managed database
- **Application Load Balancer**: Load balancing and SSL termination
- **CloudFront**: CDN for Next.js frontend (optional)
- **Auto Scaling**: Automatic scaling based on CPU and memory utilization

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed ([Install Terraform](https://www.terraform.io/downloads))
3. **AWS CLI** configured with credentials
4. **Docker** images pushed to ECR (Elastic Container Registry)

## Quick Start

### 1. Set Up Terraform State Backend

Before deploying, you need to create an S3 bucket and DynamoDB table for Terraform state:

```bash
# Create S3 bucket for state
aws s3 mb s3://nexus-learn-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket nexus-learn-terraform-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

### 2. Configure Backend

For each environment (dev, staging, prod):

```bash
cd infrastructure/terraform/environments/dev
cp backend.tf.example backend.tf
# Edit backend.tf with your S3 bucket name
```

### 3. Configure Variables

```bash
cd infrastructure/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Initialize Terraform

```bash
cd infrastructure/terraform/environments/dev
terraform init
```

### 5. Plan Deployment

```bash
terraform plan
```

### 6. Apply Infrastructure

```bash
terraform apply
```

## Directory Structure

```
infrastructure/
├── terraform/
│   ├── modules/              # Reusable Terraform modules
│   │   ├── vpc/            # VPC, subnets, security groups
│   │   ├── ecs/            # ECS cluster, service, auto-scaling
│   │   ├── rds/            # RDS PostgreSQL instance
│   │   ├── alb/            # Application Load Balancer
│   │   └── cloudfront/     # CloudFront distribution
│   └── environments/        # Environment-specific configs
│       ├── dev/            # Development environment
│       ├── staging/        # Staging environment
│       └── prod/           # Production environment
└── README.md
```

## Environments

### Development (`dev/`)
- Single availability zone
- Smaller instance sizes
- No deletion protection
- Lower scaling limits

### Staging (`staging/`)
- Multi-AZ for database
- Medium instance sizes
- Deletion protection enabled
- Moderate scaling limits

### Production (`prod/`)
- Multi-AZ for all resources
- Larger instance sizes
- Full deletion protection
- Higher scaling limits
- Enhanced monitoring

## Modules

### VPC Module
Creates a VPC with:
- Public subnets (for ALB)
- Private subnets (for ECS tasks)
- Database subnets (for RDS)
- NAT Gateways
- Security groups

### ECS Module
Creates:
- ECS Fargate cluster
- Task definition
- Service with auto-scaling
- CloudWatch logging
- IAM roles

### RDS Module
Creates:
- PostgreSQL database instance
- DB subnet group
- Parameter group
- Secrets Manager for password
- Automated backups

### ALB Module
Creates:
- Application Load Balancer
- Target group
- HTTP/HTTPS listeners
- Health checks

### CloudFront Module
Creates:
- S3 bucket for static files
- CloudFront distribution
- Origin Access Control

## Variables

Key variables in `terraform.tfvars`:

- `project_name`: Project name (default: "nexus-learn")
- `aws_region`: AWS region (default: "us-east-1")
- `backend_image`: Docker image URL from ECR
- `backend_cpu`: CPU units (1024 = 1 vCPU)
- `backend_memory`: Memory in MB
- `backend_desired_count`: Initial number of tasks
- `rds_instance_class`: RDS instance size

## Outputs

After deployment, you'll get:

- `alb_dns_name`: Load balancer URL
- `db_endpoint`: Database connection endpoint
- `ecs_cluster_name`: ECS cluster name
- `cloudfront_domain`: CloudFront URL (if enabled)

## Deployment Workflow

### 1. Build and Push Docker Images

```bash
# Build backend image
cd backend
docker build -t nexus-backend:latest .

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name nexus-backend --region us-east-1

# Tag and push
docker tag nexus-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/nexus-backend:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/nexus-backend:latest
```

### 2. Update Terraform Variables

Update `terraform.tfvars` with your ECR image URL.

### 3. Deploy Infrastructure

```bash
terraform apply
```

### 4. Get Outputs

```bash
terraform output
```

## Cost Optimization

- **Dev**: ~$30-50/month
- **Staging**: ~$80-120/month
- **Production**: ~$200-500/month (depending on traffic)

Tips:
- Use Fargate Spot for dev/staging (60-70% savings)
- Enable CloudFront caching
- Use reserved instances for RDS in production
- Set up auto-scaling policies

## Security Best Practices

1. **Never commit** `terraform.tfvars` or `backend.tf` with secrets
2. Use **AWS Secrets Manager** for sensitive data
3. Enable **encryption at rest** for RDS
4. Use **VPC endpoints** to avoid internet traffic
5. Enable **CloudTrail** for audit logging
6. Use **least privilege** IAM policies

## Troubleshooting

### Terraform State Locked

If state is locked:
```bash
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"<lock-id>"}}'
```

### Module Not Found

Run `terraform init` to download modules.

### Resource Already Exists

Use `terraform import` to import existing resources.

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Terraform Deploy
on:
  push:
    branches: [main]
jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      - run: terraform init
      - run: terraform plan
      - run: terraform apply -auto-approve
```

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## Support

For issues or questions, please create an issue in the repository.

