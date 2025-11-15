#!/bin/bash

# Health check after deployment
# Usage: ./health-check.sh --environment ENV --region REGION [--timeout TIMEOUT]

set -e

ENVIRONMENT=""
REGION=""
TIMEOUT=60

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
    --timeout)
      TIMEOUT="$2"
      shift 2
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
  echo "Usage: $0 --environment ENV --region REGION [--timeout TIMEOUT]"
  exit 1
fi

echo "Running health check for environment: $ENVIRONMENT"
echo "Region: $REGION"
echo "Timeout: ${TIMEOUT}s"

# Get ALB DNS name based on environment
case "$ENVIRONMENT" in
  dev)
    CLUSTER="nexus-learn-cluster"
    SERVICE="nexus-learn-backend-service"
    # Get ALB DNS from Terraform output or AWS
    ALB_DNS=$(aws elbv2 describe-load-balancers \
      --region "$REGION" \
      --query "LoadBalancers[?contains(LoadBalancerName, 'nexus-learn')].DNSName" \
      --output text | head -n 1)
    ;;
  staging)
    CLUSTER="nexus-learn-cluster-staging"
    SERVICE="nexus-learn-backend-service-staging"
    ALB_DNS=$(aws elbv2 describe-load-balancers \
      --region "$REGION" \
      --query "LoadBalancers[?contains(LoadBalancerName, 'nexus-learn-staging')].DNSName" \
      --output text | head -n 1)
    ;;
  prod)
    CLUSTER="nexus-learn-cluster-prod"
    SERVICE="nexus-learn-backend-service-prod"
    ALB_DNS=$(aws elbv2 describe-load-balancers \
      --region "$REGION" \
      --query "LoadBalancers[?contains(LoadBalancerName, 'nexus-learn-prod')].DNSName" \
      --output text | head -n 1)
    ;;
  *)
    echo "Error: Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

if [[ -z "$ALB_DNS" || "$ALB_DNS" == "None" ]]; then
  echo "Warning: Could not determine ALB DNS name, skipping HTTP health check"
else
  echo "ALB DNS: $ALB_DNS"
  HEALTH_URL="http://${ALB_DNS}/health/"
  
  echo "Checking health endpoint: $HEALTH_URL"
  
  # Wait for service to be healthy
  ELAPSED=0
  while [[ $ELAPSED -lt $TIMEOUT ]]; do
    if curl -f -s "$HEALTH_URL" > /dev/null 2>&1; then
      echo "Health check passed!"
      exit 0
    fi
    
    echo "Health check failed, retrying in 5 seconds... (${ELAPSED}/${TIMEOUT}s)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
  done
  
  echo "Error: Health check failed after ${TIMEOUT}s"
  exit 1
fi

# Check ECS service health
echo "Checking ECS service health..."
SERVICE_STATUS=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].deployments[0].status' \
  --output text)

RUNNING_COUNT=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].runningCount' \
  --output text)

DESIRED_COUNT=$(aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query 'services[0].desiredCount' \
  --output text)

echo "Service status: $SERVICE_STATUS"
echo "Running tasks: $RUNNING_COUNT / $DESIRED_COUNT"

if [[ "$SERVICE_STATUS" != "PRIMARY" ]]; then
  echo "Error: Service deployment is not PRIMARY"
  exit 1
fi

if [[ "$RUNNING_COUNT" -lt "$DESIRED_COUNT" ]]; then
  echo "Error: Not all tasks are running ($RUNNING_COUNT < $DESIRED_COUNT)"
  exit 1
fi

echo "Health check passed!"

