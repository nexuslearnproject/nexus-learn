# Environment Setup Guide

## Overview

This project supports multiple deployment environments:
- **Local** - Development on your machine
- **QA** - Quality Assurance / Testing
- **Staging** - Pre-production environment
- **Production** - Live production environment

## Quick Start

### 1. Switch Environment

```bash
# Switch to local development (default)
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

## Environment Files Structure

```
nexus-learn/
├── .env                    # Active environment (gitignored)
├── .env.example            # Template file
├── environments/
│   ├── .env.local         # Local development
│   ├── .env.qa            # QA environment
│   ├── .env.staging       # Staging environment
│   ├── .env.production    # Production environment
│   └── README.md          # Detailed documentation
└── scripts/
    └── switch-env.sh      # Environment switcher script
```

## Environment Comparison

| Setting | Local | QA | Staging | Production |
|---------|-------|----|---------|-----------| 
| Debug | ✅ True | ✅ True | ❌ False | ❌ False |
| Database | Local Docker | QA Server | Staging Server | Prod Server |
| Neo4j | Local Docker | QA Instance | Staging Instance | Prod Cluster |
| HTTPS | ❌ HTTP | ✅ HTTPS | ✅ HTTPS | ✅ HTTPS |
| Logging | DEBUG | INFO | WARNING | ERROR |
| Embedding Model | Fast (384d) | Fast (384d) | Accurate (768d) | Accurate (768d) |
| Security | Relaxed | Standard | High | Maximum |

## Configuration Details

### Local Development (.env.local)
- **Purpose**: Development on local machine
- **Database**: Docker containers
- **Security**: Relaxed for easy development
- **Debug**: Enabled for detailed error messages
- **Use Case**: Daily development work

### QA Environment (.env.qa)
- **Purpose**: Testing and quality assurance
- **Database**: Dedicated QA database
- **Security**: Standard security (HTTPS)
- **Debug**: Enabled for testing
- **Use Case**: Pre-release testing

### Staging Environment (.env.staging)
- **Purpose**: Pre-production testing
- **Database**: Staging database (production-like)
- **Security**: High security (HTTPS, secure cookies)
- **Debug**: Disabled (production-like)
- **Use Case**: Final testing before production

### Production Environment (.env.production)
- **Purpose**: Live production system
- **Database**: Production database
- **Security**: Maximum security
- **Debug**: Disabled
- **Monitoring**: Sentry integration
- **Use Case**: Live user-facing application

## Security Checklist

Before deploying to production:

- [ ] Change all default passwords
- [ ] Generate strong Django secret key
- [ ] Update database passwords
- [ ] Update Neo4j password
- [ ] Configure AWS credentials
- [ ] Set up Sentry DSN
- [ ] Review CORS_ALLOWED_ORIGINS
- [ ] Enable all security flags
- [ ] Set up monitoring
- [ ] Configure CDN (if applicable)

## Generating Secrets

### Django Secret Key
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Strong Password
```bash
# Using openssl
openssl rand -base64 32

# Using Python
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Usage Examples

### Development Workflow
```bash
# Start local development
./scripts/switch-env.sh local
docker-compose up -d

# Test in QA environment
./scripts/switch-env.sh qa
docker-compose up -d
```

### CI/CD Integration

#### GitHub Actions
```yaml
- name: Setup environment
  run: |
    cp environments/.env.${{ env.ENVIRONMENT }} .env
```

#### GitLab CI
```yaml
before_script:
  - cp environments/.env.${CI_ENVIRONMENT_NAME} .env
```

## Troubleshooting

### Environment not switching
```bash
# Check current environment
grep "^ENVIRONMENT=" .env

# Force switch
./scripts/switch-env.sh local
```

### Services not picking up changes
```bash
# Restart services
docker-compose down
docker-compose up -d
```

### Missing environment file
```bash
# Check if file exists
ls -la environments/.env.local

# Create from example
cp .env.example environments/.env.local
```

## Best Practices

1. **Never commit .env files** - They're in .gitignore
2. **Use .env.example as template** - Keep it updated
3. **Rotate secrets regularly** - Especially in production
4. **Use secret management** - AWS Secrets Manager, Vault, etc.
5. **Review before deployment** - Always check environment settings
6. **Keep environments separate** - Don't mix local and production configs

## Additional Resources

- See `environments/README.md` for detailed documentation
- See `.env.example` for all available variables
- Check `scripts/switch-env.sh` for switching logic

