#!/bin/bash

# Rollback ECS service to previous task definition
# Usage: ./rollback-ecs.sh --cluster CLUSTER --service SERVICE --region REGION

set -e

CLUSTER=""
SERVICE=""
REGION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --cluster)
      CLUSTER="$2"
      shift 2
      ;;
    --service)
      SERVICE="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$CLUSTER" || -z "$SERVICE" || -z "$REGION" ]]; then
  echo "Error: Missing required parameters"
  echo "Usage: $0 --cluster CLUSTER --service SERVICE --region REGION"
  exit 1
fi

echo "Rolling back ECS service..."
echo "Cluster: $CLUSTER"
echo "Service: $SERVICE"
echo "Region: $REGION"

# Get current task definition
CURRENT_TASK_DEF=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].taskDefinition' \
  --output text)

echo "Current task definition: $CURRENT_TASK_DEF"

# Get previous task definition (revision - 1)
CURRENT_REVISION=$(echo "$CURRENT_TASK_DEF" | awk -F: '{print $NF}')
PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

TASK_DEF_FAMILY=$(echo "$CURRENT_TASK_DEF" | awk -F: '{print $1":"$2}')
PREVIOUS_TASK_DEF="${TASK_DEF_FAMILY}:${PREVIOUS_REVISION}"

echo "Rolling back to: $PREVIOUS_TASK_DEF"

# Verify previous task definition exists
if ! aws ecs describe-task-definition \
  --task-definition "$PREVIOUS_TASK_DEF" \
  --region "$REGION" > /dev/null 2>&1; then
  echo "Error: Previous task definition not found: $PREVIOUS_TASK_DEF"
  exit 1
fi

# Update service to previous task definition
echo "Updating service to previous task definition..."
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$PREVIOUS_TASK_DEF" \
  --region "$REGION" \
  --force-new-deployment \
  > /dev/null

# Wait for service to stabilize
echo "Waiting for rollback to complete..."
aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION"

echo "Rollback completed successfully!"
echo "Service rolled back to: $PREVIOUS_TASK_DEF"

