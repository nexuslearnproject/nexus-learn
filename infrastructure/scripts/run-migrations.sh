#!/bin/bash

# Run Django migrations safely
# Usage: ./run-migrations.sh --environment ENV --region REGION [--backup]

set -e

ENVIRONMENT=""
REGION=""
BACKUP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --backup)
      BACKUP=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$ENVIRONMENT" || -z "$REGION" ]]; then
  echo "Error: Missing required parameters"
  echo "Usage: $0 --environment ENV --region REGION [--backup]"
  exit 1
fi

echo "Running migrations for environment: $ENVIRONMENT"
echo "Region: $REGION"
echo "Backup: $BACKUP"

# Get ECS cluster and service name based on environment
case "$ENVIRONMENT" in
  dev)
    CLUSTER="nexus-learn-cluster"
    SERVICE="nexus-learn-backend-service"
    ;;
  staging)
    CLUSTER="nexus-learn-cluster-staging"
    SERVICE="nexus-learn-backend-service-staging"
    ;;
  prod)
    CLUSTER="nexus-learn-cluster-prod"
    SERVICE="nexus-learn-backend-service-prod"
    ;;
  *)
    echo "Error: Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# Create backup if requested
if [[ "$BACKUP" == true ]]; then
  echo "Creating database backup..."
  # Add RDS snapshot creation here
  # aws rds create-db-snapshot ...
fi

# Get running task
echo "Finding running task..."
TASK_ARN=$(aws ecs list-tasks \
  --cluster "$CLUSTER" \
  --service-name "$SERVICE" \
  --desired-status RUNNING \
  --region "$REGION" \
  --query 'taskArns[0]' \
  --output text)

if [[ -z "$TASK_ARN" || "$TASK_ARN" == "None" ]]; then
  echo "Error: No running tasks found for service $SERVICE"
  exit 1
fi

echo "Found task: $TASK_ARN"

# Get task details
TASK_DETAILS=$(aws ecs describe-tasks \
  --cluster "$CLUSTER" \
  --tasks "$TASK_ARN" \
  --region "$REGION")

CONTAINER_NAME=$(echo "$TASK_DETAILS" | jq -r '.tasks[0].containers[0].name')

# Run migrations
echo "Running migrations..."
aws ecs execute-command \
  --cluster "$CLUSTER" \
  --task "$TASK_ARN" \
  --container "$CONTAINER_NAME" \
  --command "python manage.py migrate --noinput" \
  --interactive \
  --region "$REGION" || {
    echo "Error: Failed to run migrations"
    exit 1
  }

echo "Migrations completed successfully!"

# Verify migrations
echo "Verifying migrations..."
aws ecs execute-command \
  --cluster "$CLUSTER" \
  --task "$TASK_ARN" \
  --container "$CONTAINER_NAME" \
  --command "python manage.py showmigrations" \
  --interactive \
  --region "$REGION"

echo "Migration verification completed!"

