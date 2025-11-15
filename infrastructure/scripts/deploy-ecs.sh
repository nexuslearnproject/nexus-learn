#!/bin/bash

# Deploy ECS Service with new Docker image
# Usage: ./deploy-ecs.sh --cluster CLUSTER --service SERVICE --image IMAGE --region REGION [--blue-green]

set -e

CLUSTER=""
SERVICE=""
IMAGE=""
REGION=""
BLUE_GREEN=false

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
    --image)
      IMAGE="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --blue-green)
      BLUE_GREEN=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [[ -z "$CLUSTER" || -z "$SERVICE" || -z "$IMAGE" || -z "$REGION" ]]; then
  echo "Error: Missing required parameters"
  echo "Usage: $0 --cluster CLUSTER --service SERVICE --image IMAGE --region REGION [--blue-green]"
  exit 1
fi

echo "Deploying to ECS..."
echo "Cluster: $CLUSTER"
echo "Service: $SERVICE"
echo "Image: $IMAGE"
echo "Region: $REGION"
echo "Blue-Green: $BLUE_GREEN"

# Get current task definition
echo "Getting current task definition..."
TASK_DEFINITION=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].taskDefinition' \
  --output text)

if [[ -z "$TASK_DEFINITION" || "$TASK_DEFINITION" == "None" ]]; then
  echo "Error: Could not retrieve task definition for service $SERVICE"
  exit 1
fi

echo "Current task definition: $TASK_DEFINITION"

# Get task definition JSON
TASK_DEF_JSON=$(aws ecs describe-task-definition \
  --task-definition "$TASK_DEFINITION" \
  --region "$REGION" \
  --query 'taskDefinition' \
  --output json)

# Update image in task definition
echo "Updating image to: $IMAGE"
NEW_TASK_DEF_JSON=$(echo "$TASK_DEF_JSON" | jq --arg IMAGE "$IMAGE" '.containerDefinitions[0].image = $IMAGE')

# Remove fields that can't be set when registering new task definition
NEW_TASK_DEF_JSON=$(echo "$NEW_TASK_DEF_JSON" | jq 'del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)')

# Register new task definition
echo "Registering new task definition..."
NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
  --cli-input-json "$NEW_TASK_DEF_JSON" \
  --region "$REGION" \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

echo "New task definition ARN: $NEW_TASK_DEF_ARN"

# Update ECS service
echo "Updating ECS service..."
if [[ "$BLUE_GREEN" == true ]]; then
  echo "Using blue-green deployment..."
  aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$SERVICE" \
    --task-definition "$NEW_TASK_DEF_ARN" \
    --region "$REGION" \
    --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100" \
    --force-new-deployment \
    > /dev/null
else
  aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$SERVICE" \
    --task-definition "$NEW_TASK_DEF_ARN" \
    --region "$REGION" \
    --force-new-deployment \
    > /dev/null
fi

# Wait for service to stabilize
echo "Waiting for service to stabilize..."
aws ecs wait services-stable \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION"

echo "Deployment completed successfully!"
echo "New task definition: $NEW_TASK_DEF_ARN"

# Get deployment status
DEPLOYMENT_STATUS=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].deployments[0].status' \
  --output text)

echo "Deployment status: $DEPLOYMENT_STATUS"

if [[ "$DEPLOYMENT_STATUS" != "PRIMARY" ]]; then
  echo "Warning: Deployment status is not PRIMARY"
  exit 1
fi

echo "Deployment successful!"

