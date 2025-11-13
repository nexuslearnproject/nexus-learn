# How to Run Terraform Infrastructure with Docker

## Quick Start (3 Steps)

### 1. Set Up AWS Credentials
Create `.env` file in project root:
```bash
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_DEFAULT_REGION=ap-southeast-1
```

### 2. Set Up Terraform Backend
```bash
./infrastructure/scripts/setup-terraform-backend.sh
```

### 3. Run Terraform
```bash
# Initialize
./infrastructure/docker/terraform.sh dev init

# Plan
./infrastructure/docker/terraform.sh dev plan

# Apply
./infrastructure/docker/terraform.sh dev apply
```

## Common Commands

```bash
# Initialize Terraform
./infrastructure/docker/terraform.sh dev init

# Plan changes
./infrastructure/docker/terraform.sh dev plan

# Apply changes
./infrastructure/docker/terraform.sh dev apply

# Apply without confirmation
./infrastructure/docker/terraform.sh dev apply -auto-approve

# View outputs (ALB URL, DB endpoint)
./infrastructure/docker/terraform.sh dev output

# Destroy infrastructure
./infrastructure/docker/terraform.sh dev destroy
```

## Using Docker Compose Directly

```bash
# Initialize
docker-compose run --rm terraform terraform -chdir=environments/dev init

# Plan
docker-compose run --rm terraform terraform -chdir=environments/dev plan

# Apply
docker-compose run --rm terraform terraform -chdir=environments/dev apply
```

## Troubleshooting

**AWS credentials not found?**
- Ensure `.env` file exists with AWS credentials
- Or export: `export AWS_ACCESS_KEY_ID=...`

**Permission denied?**
- Run: `chmod +x infrastructure/docker/terraform.sh`

**Backend not configured?**
- Copy: `cp infrastructure/terraform/environments/dev/backend.tf.example backend.tf`
- Edit `backend.tf` with your S3 bucket name

For detailed guide, see: `infrastructure/docker/QUICKSTART.md`
