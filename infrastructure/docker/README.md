# Terraform Infrastructure Management in Docker

This directory contains Docker-based tools for managing AWS infrastructure using Terraform.

## Prerequisites

1. **Docker and Docker Compose** installed
2. **AWS Credentials** configured:
   - Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in your `.env` file
   - Or export them as environment variables

## Quick Start

### Method 1: Using the Helper Script (Recommended)

```bash
# Make the script executable
chmod +x infrastructure/docker/terraform.sh

# Initialize Terraform for dev environment
./infrastructure/docker/terraform.sh dev init

# Plan infrastructure changes
./infrastructure/docker/terraform.sh dev plan

# Apply infrastructure changes
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

# Apply with auto-approve (no confirmation)
docker-compose run --rm terraform terraform -chdir=environments/dev apply -auto-approve

# View outputs
docker-compose run --rm terraform terraform -chdir=environments/dev output

# Destroy infrastructure
docker-compose run --rm terraform terraform -chdir=environments/dev destroy
```

## Environment Variables

Add these to your `.env` file:

```bash
# AWS Credentials (Required)
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key

# Optional: AWS Session Token (for temporary credentials)
AWS_SESSION_TOKEN=your-session-token

# AWS Region (defaults to ap-southeast-1)
AWS_DEFAULT_REGION=ap-southeast-1
AWS_REGION=ap-southeast-1

# Optional: Terraform Logging
TF_LOG=INFO
TF_LOG_PATH=/terraform/terraform.log
```

## Available Environments

- **dev** - Development environment (`environments/dev/`)
- **staging** - Staging environment (`environments/staging/dev/`)
- **prod** - Production environment (`environments/prod/dev/`)

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
./infrastructure/docker/terraform.sh dev apply

# Auto-approve (skip confirmation)
./infrastructure/docker/terraform.sh dev apply -auto-approve
```

### View Outputs
```bash
./infrastructure/docker/terraform.sh dev output
```

### Validate Configuration
```bash
./infrastructure/docker/terraform.sh dev validate
```

### Format Code
```bash
./infrastructure/docker/terraform.sh dev fmt
```

### Destroy Infrastructure
```bash
./infrastructure/docker/terraform.sh dev destroy
```

### State Management
```bash
# List resources in state
./infrastructure/docker/terraform.sh dev state list

# Show specific resource
./infrastructure/docker/terraform.sh dev state show <resource_address>
```

## Setup Steps

1. **Configure Backend** (if not already done):
   ```bash
   cd infrastructure/terraform/environments/dev
   cp backend.tf.example backend.tf
   # Edit backend.tf with your S3 bucket name
   ```

2. **Configure Variables**:
   ```bash
   cd infrastructure/terraform/environments/dev
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Set Up Terraform Backend** (S3 + DynamoDB):
   ```bash
   ./infrastructure/scripts/setup-terraform-backend.sh
   ```

4. **Initialize Terraform**:
   ```bash
   ./infrastructure/docker/terraform.sh dev init
   ```

5. **Plan and Apply**:
   ```bash
   ./infrastructure/docker/terraform.sh dev plan
   ./infrastructure/docker/terraform.sh dev apply
   ```

## Troubleshooting

### AWS Credentials Not Found
- Ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in `.env` file
- Or export them as environment variables before running commands

### Terraform State Locked
If state is locked, you can force unlock:
```bash
docker-compose run --rm terraform terraform -chdir=environments/dev force-unlock <lock-id>
```

### Module Not Found
Run `terraform init` to download modules:
```bash
./infrastructure/docker/terraform.sh dev init
```

### Permission Denied
Make the helper script executable:
```bash
chmod +x infrastructure/docker/terraform.sh
```

## Volumes

The Terraform service uses these volumes:
- `terraform_cache` - Caches Terraform providers and modules
- `terraform_plugins` - Stores Terraform plugins

These volumes persist between container runs for faster subsequent operations.

## Integration with CI/CD

You can use this Docker setup in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Terraform Plan
  run: |
    docker-compose run --rm terraform terraform -chdir=environments/dev plan
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Notes

- The Terraform service uses the `infrastructure` profile, so it won't start automatically with `docker-compose up`
- Terraform state is stored in S3 (configured in `backend.tf`)
- All Terraform operations run in an isolated Docker container
- The working directory is `/terraform` inside the container
- Terraform logs can be enabled via `TF_LOG` environment variable

