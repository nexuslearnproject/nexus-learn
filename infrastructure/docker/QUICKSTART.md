# Quick Start: Running Terraform Infrastructure with Docker

This guide shows you how to manage AWS infrastructure using Terraform in Docker.

## Prerequisites

1. **Docker and Docker Compose** installed
2. **AWS Account** with appropriate permissions
3. **AWS Credentials** (Access Key ID and Secret Access Key)

## Step 1: Set Up AWS Credentials

Create a `.env` file in the project root (if it doesn't exist):

```bash
# From project root
cat > .env << EOF
# AWS Credentials (Required)
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key

# AWS Region (defaults to ap-southeast-1)
AWS_DEFAULT_REGION=ap-southeast-1
AWS_REGION=ap-southeast-1

# Optional: AWS Session Token (for temporary credentials)
# AWS_SESSION_TOKEN=your-session-token

# Optional: Terraform Logging
# TF_LOG=INFO
# TF_LOG_PATH=/terraform/terraform.log
EOF
```

**Important:** Never commit `.env` file to git (it's already in `.gitignore`)

## Step 2: Set Up Terraform Backend (S3 + DynamoDB)

Before running Terraform, set up the state backend:

```bash
# Run the setup script
./infrastructure/scripts/setup-terraform-backend.sh

# Or manually create:
# - S3 bucket: nexus-learn-terraform-state
# - DynamoDB table: terraform-state-lock
```

## Step 3: Configure Terraform Variables

```bash
cd infrastructure/terraform/environments/dev

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# At minimum, update: backend_image with your ECR image URL
```

## Step 4: Run Terraform Commands

### Method 1: Using the Helper Script (Recommended)

```bash
# Make script executable (if not already)
chmod +x infrastructure/docker/terraform.sh

# Initialize Terraform
./infrastructure/docker/terraform.sh dev init

# Plan infrastructure changes
./infrastructure/docker/terraform.sh dev plan

# Apply infrastructure
./infrastructure/docker/terraform.sh dev apply

# View outputs
./infrastructure/docker/terraform.sh dev output
```

### Method 2: Using Docker Compose Directly

```bash
# Initialize Terraform
docker-compose run --rm terraform terraform -chdir=environments/dev init

# Plan infrastructure
docker-compose run --rm terraform terraform -chdir=environments/dev plan

# Apply infrastructure
docker-compose run --rm terraform terraform -chdir=environments/dev apply

# Apply with auto-approve (skip confirmation)
docker-compose run --rm terraform terraform -chdir=environments/dev apply -auto-approve

# View outputs
docker-compose run --rm terraform terraform -chdir=environments/dev output
```

## Common Commands

### Initialize Terraform
```bash
./infrastructure/docker/terraform.sh dev init
```

### Plan Changes
```bash
./infrastructure/docker/terraform.sh dev plan
```

### Apply Changes
```bash
# With confirmation prompt
./infrastructure/docker/terraform.sh dev apply

# Auto-approve (skip confirmation)
./infrastructure/docker/terraform.sh dev apply -auto-approve
```

### Validate Configuration
```bash
./infrastructure/docker/terraform.sh dev validate
```

### Format Code
```bash
./infrastructure/docker/terraform.sh dev fmt
```

### View Outputs
```bash
./infrastructure/docker/terraform.sh dev output
```

### Destroy Infrastructure
```bash
# Plan destruction
./infrastructure/docker/terraform.sh dev plan -destroy

# Destroy infrastructure
./infrastructure/docker/terraform.sh dev destroy
```

### State Management
```bash
# List resources in state
./infrastructure/docker/terraform.sh dev state list

# Show specific resource
./infrastructure/docker/terraform.sh dev state show <resource_address>

# Remove resource from state
./infrastructure/docker/terraform.sh dev state rm <resource_address>
```

## Complete Workflow Example

```bash
# 1. Set up AWS credentials in .env file
# (Already done in Step 1)

# 2. Set up Terraform backend
./infrastructure/scripts/setup-terraform-backend.sh

# 3. Configure variables
cd infrastructure/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Initialize Terraform
cd ../../..  # Back to project root
./infrastructure/docker/terraform.sh dev init

# 5. Review plan
./infrastructure/docker/terraform.sh dev plan

# 6. Apply infrastructure
./infrastructure/docker/terraform.sh dev apply

# 7. Get outputs (ALB URL, DB endpoint, etc.)
./infrastructure/docker/terraform.sh dev output
```

## Troubleshooting

### AWS Credentials Not Found
**Error:** `Warning: AWS credentials not set in environment`

**Solution:**
```bash
# Ensure .env file exists in project root
# Or export credentials:
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

### Terraform Backend Not Configured
**Error:** `Error: Backend configuration changed`

**Solution:**
```bash
# Copy backend.tf.example to backend.tf
cd infrastructure/terraform/environments/dev
cp backend.tf.example backend.tf
# Edit backend.tf with your S3 bucket name
```

### Module Not Found
**Error:** `Error: Module not found`

**Solution:**
```bash
# Run terraform init
./infrastructure/docker/terraform.sh dev init
```

### Permission Denied
**Error:** `Permission denied: ./infrastructure/docker/terraform.sh`

**Solution:**
```bash
chmod +x infrastructure/docker/terraform.sh
```

### Docker Compose Not Found
**Error:** `docker-compose: command not found`

**Solution:**
```bash
# Use docker compose (newer version) instead
docker compose run --rm terraform terraform -chdir=environments/dev init
```

## Environment Variables

The Terraform Docker container uses these environment variables from `.env`:

| Variable | Description | Required |
|----------|-------------|----------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Yes |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Yes |
| `AWS_SESSION_TOKEN` | AWS session token (for temp credentials) | No |
| `AWS_DEFAULT_REGION` | AWS region | No (defaults to ap-southeast-1) |
| `AWS_REGION` | AWS region | No (defaults to ap-southeast-1) |
| `TF_LOG` | Terraform log level (DEBUG, INFO, WARN, ERROR) | No |
| `TF_LOG_PATH` | Path to log file | No |

## Docker Volumes

The Terraform service uses these volumes:
- `terraform_cache` - Caches Terraform providers and modules (persists between runs)
- `terraform_plugins` - Stores Terraform plugins (persists between runs)

These volumes speed up subsequent runs by caching downloaded providers.

## Tips

1. **Use the helper script** - It's easier and handles paths correctly
2. **Check AWS credentials** - Ensure they're set before running commands
3. **Review plan before apply** - Always run `plan` before `apply`
4. **Use profiles** - The terraform service uses the `infrastructure` profile, so it won't start with `docker-compose up`
5. **Cache volumes** - Terraform providers are cached, so subsequent runs are faster

## Next Steps

After deploying infrastructure:
1. Check outputs: `./infrastructure/docker/terraform.sh dev output`
2. Access your ALB URL from outputs
3. Monitor costs in AWS Cost Explorer
4. Set up AWS Budgets for cost alerts

For more details, see [README.md](./README.md)




