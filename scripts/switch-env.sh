#!/bin/bash

# ============================================
# Nexus Learn - Environment Switcher Script
# ============================================
# Usage: ./scripts/switch-env.sh [local|qa|staging|production]
# ============================================

set -e

ENV_DIR="environments"
ENV_FILE=".env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment argument is provided
if [ -z "$1" ]; then
    print_error "Please specify an environment: local, qa, staging, or production"
    echo "Usage: $0 [local|qa|staging|production]"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
case $ENVIRONMENT in
    local|qa|staging|production)
        print_info "Switching to $ENVIRONMENT environment..."
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        echo "Valid options: local, qa, staging, production"
        exit 1
        ;;
esac

# Check if environment file exists
ENV_SOURCE="$ENV_DIR/.env.$ENVIRONMENT"
if [ ! -f "$ENV_SOURCE" ]; then
    print_error "Environment file not found: $ENV_SOURCE"
    exit 1
fi

# Backup current .env if it exists
if [ -f "$ENV_FILE" ]; then
    BACKUP_FILE="${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$ENV_FILE" "$BACKUP_FILE"
    print_info "Backed up current .env to $BACKUP_FILE"
fi

# Copy environment file to .env
cp "$ENV_SOURCE" "$ENV_FILE"
print_info "Switched to $ENVIRONMENT environment"

# Display current environment
CURRENT_ENV=$(grep "^ENVIRONMENT=" "$ENV_FILE" | cut -d '=' -f2)
print_info "Current environment: $CURRENT_ENV"

# Show important settings
echo ""
print_info "Key settings:"
echo "  - DJANGO_DEBUG: $(grep "^DJANGO_DEBUG=" "$ENV_FILE" | cut -d '=' -f2)"
echo "  - POSTGRES_DB: $(grep "^POSTGRES_DB=" "$ENV_FILE" | cut -d '=' -f2)"
echo "  - NEO4J_URI: $(grep "^NEO4J_URI=" "$ENV_FILE" | cut -d '=' -f2)"
echo "  - NEXT_PUBLIC_API_URL: $(grep "^NEXT_PUBLIC_API_URL=" "$ENV_FILE" | cut -d '=' -f2)"

# Warning for production
if [ "$ENVIRONMENT" = "production" ]; then
    echo ""
    print_warning "You are now using PRODUCTION environment!"
    print_warning "Please verify all settings before deploying."
fi

print_info "Done! You may need to restart your services:"
echo "  docker-compose down && docker-compose up -d"

