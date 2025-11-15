# Environment Configuration Guide

This directory contains environment-specific configuration files for different deployment stages.

## Available Environments

- **local** - Local development environment
- **qa** - Quality Assurance / Testing environment
- **staging** - Pre-production staging environment
- **production** - Production environment

## Quick Start

### 1. Switch Environment

```bash
# Switch to local development
./scripts/switch-env.sh local

# Switch to QA
./scripts/switch-env.sh qa

# Switch to staging
./scripts/switch-env.sh staging

# Switch to production
./scripts/switch-env.sh production
```

### 2. Manual Setup

```bash
# Copy environment file to root .env
cp environments/.env.local .env

# Or for other environments
cp environments/.env.qa .env
cp environments/.env.staging .env
cp environments/.env.production .env
```

## Environment Differences

### Local Development
- **Debug**: Enabled
- **Database**: Local Docker container
- **Neo4j**: Local Docker container
- **Security**: Relaxed (HTTP, localhost)
- **Logging**: DEBUG level
- **Embedding Model**: Fast model (all-MiniLM-L6-v2)

### QA Environment
- **Debug**: Enabled (for testing)
- **Database**: QA database server
- **Neo4j**: QA Neo4j instance
- **Security**: HTTPS enabled
- **Logging**: INFO level
- **Embedding Model**: Fast model (all-MiniLM-L6-v2)

### Staging Environment
- **Debug**: Disabled
- **Database**: Staging database server
- **Neo4j**: Staging Neo4j instance
- **Security**: Full security (HTTPS, secure cookies)
- **Logging**: WARNING level
- **Embedding Model**: Accurate model (all-mpnet-base-v2)

### Production Environment
- **Debug**: Disabled
- **Database**: Production database server
- **Neo4j**: Production Neo4j cluster
- **Security**: Maximum security
- **Logging**: ERROR level only
- **Embedding Model**: Accurate model (all-mpnet-base-v2)
- **Monitoring**: Sentry integration enabled

## Security Best Practices

### Before Production Deployment

1. **Change all passwords**:
   - PostgreSQL password
   - Neo4j password
   - Django secret key

2. **Use strong secrets**:
   ```bash
   # Generate Django secret key
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

3. **Use secret management**:
   - AWS Secrets Manager
   - HashiCorp Vault
   - Environment variables in CI/CD

4. **Review security settings**:
   - Ensure `SESSION_COOKIE_SECURE=True`
   - Ensure `CSRF_COOKIE_SECURE=True`
   - Verify `CORS_ALLOWED_ORIGINS` only includes your domains

## Environment Variables Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `ENVIRONMENT` | Current environment name | `local` |
| `DJANGO_SECRET_KEY` | Django secret key | `django-insecure-...` |
| `POSTGRES_DB` | PostgreSQL database name | `nexus_db` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `password123` |
| `NEO4J_PASSWORD` | Neo4j password | `neo4j_password` |
| `NEO4J_URI` | Neo4j connection URI | `bolt://neo4j:7687` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `EMBEDDING_MODEL` | Vector embedding model | `all-MiniLM-L6-v2` |
| `EMBEDDING_DIMENSIONS` | Embedding dimensions | `384` |
| `LOG_LEVEL` | Logging level | `INFO` |
| `AWS_ACCESS_KEY_ID` | AWS access key | - |
| `SENTRY_DSN` | Sentry DSN for error tracking | - |

## Docker Compose Usage

The docker-compose.yml file automatically reads from `.env` file in the root directory.

```bash
# Switch to local and start services
./scripts/switch-env.sh local
docker-compose up -d

# Switch to QA and start services
./scripts/switch-env.sh qa
docker-compose up -d
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Setup environment
  run: |
    cp environments/.env.${{ env.ENVIRONMENT }} .env
    
- name: Deploy
  run: docker-compose up -d
```

### GitLab CI Example

```yaml
before_script:
  - cp environments/.env.${CI_ENVIRONMENT_NAME} .env
```

## Troubleshooting

### Environment file not found
```bash
# Check if file exists
ls -la environments/.env.local

# Create from example if missing
cp .env.example environments/.env.local
```

### Wrong environment loaded
```bash
# Check current environment
grep "^ENVIRONMENT=" .env

# Switch to correct environment
./scripts/switch-env.sh local
```

### Services not picking up changes
```bash
# Restart services after changing .env
docker-compose down
docker-compose up -d
```

## Notes

- Never commit `.env` files to version control
- Always use `.env.example` as a template
- Keep production secrets in secure secret management systems
- Regularly rotate passwords and keys
- Review and update environment files before each deployment

