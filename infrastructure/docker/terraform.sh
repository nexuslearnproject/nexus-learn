#!/bin/bash
# Terraform wrapper script for Docker Compose
# Usage: ./terraform.sh <environment> <terraform_command> [args...]
# Example: ./terraform.sh dev init
# Example: ./terraform.sh dev plan
# Example: ./terraform.sh dev apply

set -e

ENVIRONMENT=${1:-dev}
COMMAND=${2:-help}

if [ "$COMMAND" = "help" ] || [ -z "$1" ]; then
    echo "Terraform Infrastructure Management via Docker Compose"
    echo ""
    echo "Usage: $0 <environment> <command> [args...]"
    echo ""
    echo "Environments:"
    echo "  dev       - Development environment"
    echo "  staging   - Staging environment"
    echo "  prod      - Production environment"
    echo ""
    echo "Commands:"
    echo "  init      - Initialize Terraform"
    echo "  plan      - Show execution plan"
    echo "  apply     - Apply changes"
    echo "  destroy   - Destroy infrastructure"
    echo "  validate  - Validate configuration"
    echo "  fmt       - Format code"
    echo "  output    - Show outputs"
    echo "  state     - State management (use: state <subcommand>)"
    echo ""
    echo "Examples:"
    echo "  $0 dev init"
    echo "  $0 dev plan"
    echo "  $0 dev apply"
    echo "  $0 dev aplpy -auto-approve"
    echo "  $0 dev output"
    echo "  $0 dev destroy"
    exit 0
fi

# Check if AWS credentials are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Warning: AWS credentials not set in environment"
    echo "Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY"
    echo "Or create a .env file with these variables"
fi

# Change to project root
cd "$(dirname "$0")/../.."

# Run terraform command in Docker
docker-compose run --rm terraform terraform -chdir=environments/${ENVIRONMENT} ${COMMAND} "${@:3}"

