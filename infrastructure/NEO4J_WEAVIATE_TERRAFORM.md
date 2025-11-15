# Neo4j + Weaviate Infrastructure with Terraform

This document describes how to deploy Neo4j (Graph Database) and Weaviate (Vector Store) infrastructure on AWS using Terraform.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                      AWS VPC                             │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Backend    │  │    Neo4j     │  │   Weaviate   │  │
│  │  (ECS Fargate)│  │ (ECS Fargate)│  │ (ECS Fargate)│  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                 │           │
│         └─────────────────┴─────────────────┘           │
│                    Service Discovery                     │
│                    (Private DNS)                         │
└──────────────────────────────────────────────────────────┘
```

## Components

### Neo4j Module (`modules/neo4j/`)
- **ECS Fargate Task**: Runs Neo4j 5.15 Community Edition
- **Ports**: 
  - HTTP: 7474 (Browser UI)
  - Bolt: 7687 (Database protocol)
- **Storage**: Ephemeral (data stored in container)
- **Plugins**: APOC, Graph Data Science
- **Service Discovery**: Accessible via `neo4j.nexus-learn.local:7687`

### Weaviate Module (`modules/weaviate/`)
- **ECS Fargate Task**: Runs Weaviate 1.24.0
- **Ports**:
  - HTTP: 8080 (REST API)
  - gRPC: 50051 (gRPC API)
- **Storage**: EFS (Elastic File System) for persistence
- **Modules**: text2vec-openai, text2vec-cohere, text2vec-huggingface, etc.
- **Service Discovery**: Accessible via `weaviate.nexus-learn.local:8080`

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0
3. **AWS CLI** configured
4. **S3 Bucket** for Terraform state (configured in `backend.tf`)

## Quick Start

### 1. Configure Environment Variables

Copy the example terraform variables file:

```bash
cd infrastructure/terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and configure:

```hcl
project_name = "nexus-learn"
aws_region   = "ap-southeast-1"

# Neo4j Configuration
neo4j_image        = "neo4j:5.15-community"
neo4j_cpu         = 2048  # 2 vCPU
neo4j_memory      = 4096  # 4GB
neo4j_desired_count = 1

# Weaviate Configuration
weaviate_image          = "semitechnologies/weaviate:1.24.0"
weaviate_cpu            = 2048  # 2 vCPU
weaviate_memory         = 4096  # 4GB
weaviate_desired_count  = 1
weaviate_persistence_enabled = true
```

### 2. Initialize Terraform

```bash
cd infrastructure/terraform/environments/dev
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

This will create:
- VPC with subnets and security groups
- ECS Cluster
- Neo4j ECS Service
- Weaviate ECS Service with EFS
- Service Discovery namespace
- CloudWatch Log Groups

### 5. Get Connection Information

After deployment, get the service discovery DNS names:

```bash
terraform output neo4j_service_discovery_dns
terraform output weaviate_service_discovery_dns
```

## Configuration

### Neo4j Configuration

#### Environment Variables

Neo4j can be configured via environment variables in the ECS task definition:

- `NEO4J_AUTH`: Authentication (format: `neo4j/password`)
- `NEO4J_PLUGINS`: JSON array of plugins (e.g., `["apoc", "graph-data-science"]`)
- `NEO4J_dbms_memory_heap_initial__size`: Initial heap size (e.g., `512m`)
- `NEO4J_dbms_memory_heap_max__size`: Max heap size (e.g., `2G`)
- `NEO4J_dbms_memory_pagecache_size`: Page cache size (e.g., `1G`)

#### Using Secrets Manager

To use AWS Secrets Manager for Neo4j password:

1. Create a secret in Secrets Manager:
```bash
aws secretsmanager create-secret \
  --name nexus-learn/neo4j/password \
  --secret-string "your-secure-password"
```

2. Update `terraform.tfvars`:
```hcl
neo4j_password_secret_arn = "arn:aws:secretsmanager:region:account:secret:nexus-learn/neo4j/password-xxxxx"
```

### Weaviate Configuration

#### Environment Variables

Weaviate configuration via environment variables:

- `QUERY_DEFAULTS_LIMIT`: Default query limit (default: `25`)
- `AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED`: Enable anonymous access (default: `true`)
- `PERSISTENCE_DATA_PATH`: Data persistence path (default: `/var/lib/weaviate`)
- `DEFAULT_VECTORIZER_MODULE`: Default vectorizer (default: `none`)
- `ENABLE_MODULES`: Comma-separated list of enabled modules
- `CLUSTER_HOSTNAME`: Cluster hostname (default: `node1`)

#### Vectorizer Modules

Available modules (configured in `weaviate_enabled_modules`):
- `text2vec-openai`: OpenAI embeddings
- `text2vec-cohere`: Cohere embeddings
- `text2vec-huggingface`: HuggingFace embeddings
- `ref2vec-centroid`: Reference vector centroid
- `generative-openai`: OpenAI generation
- `qna-openai`: OpenAI Q&A

## Connecting from Backend

### Neo4j Connection

Update your backend environment variables:

```env
NEO4J_URI=bolt://neo4j.nexus-learn.local:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your-password
```

Or use the service discovery DNS name from Terraform outputs.

### Weaviate Connection

Update your backend environment variables:

```env
WEAVIATE_URL=http://weaviate.nexus-learn.local:8080
WEAVIATE_API_KEY=  # Optional, if authentication enabled
```

## Service Discovery

Both Neo4j and Weaviate are registered with AWS Service Discovery using private DNS namespaces:

- **Namespace**: `nexus-learn.local`
- **Neo4j**: `neo4j.nexus-learn.local`
- **Weaviate**: `weaviate.nexus-learn.local`

Services within the same VPC can resolve these DNS names automatically.

## Security Groups

### Neo4j Security Group
- **Ingress**: Ports 7474 (HTTP) and 7687 (Bolt) from ECS security group
- **Egress**: All traffic

### Weaviate Security Group
- **Ingress**: 
  - Port 8080 (HTTP) from ECS security group
  - Port 50051 (gRPC) from ECS security group
  - Port 2049 (EFS) from ECS security group
- **Egress**: All traffic

## Storage

### Neo4j Storage
- **Type**: Ephemeral (container storage)
- **Persistence**: Data is lost when container stops
- **Backup**: Use Neo4j backup tools or export data regularly

### Weaviate Storage
- **Type**: EFS (Elastic File System)
- **Persistence**: Data persists across container restarts
- **Backup**: EFS snapshots or Weaviate backup API

## Monitoring

### CloudWatch Logs

Both services send logs to CloudWatch:

- **Neo4j**: `/ecs/nexus-learn/neo4j`
- **Weaviate**: `/ecs/nexus-learn/weaviate`

View logs:

```bash
aws logs tail /ecs/nexus-learn/neo4j --follow
aws logs tail /ecs/nexus-learn/weaviate --follow
```

### Container Insights

Enable Container Insights in `terraform.tfvars`:

```hcl
enable_container_insights = true
```

## Cost Optimization

### Development Environment

For cost-optimized development:

```hcl
# Neo4j
neo4j_cpu    = 1024  # 1 vCPU
neo4j_memory = 2048  # 2GB

# Weaviate
weaviate_cpu    = 1024  # 1 vCPU
weaviate_memory = 2048  # 2GB

# Logs
log_retention_days = 1
enable_container_insights = false
```

### Production Environment

For production, use the default values or scale up:

```hcl
# Neo4j
neo4j_cpu    = 4096  # 4 vCPU
neo4j_memory = 8192  # 8GB

# Weaviate
weaviate_cpu    = 4096  # 4 vCPU
weaviate_memory = 8192  # 8GB

# Logs
log_retention_days = 30
enable_container_insights = true
```

## Troubleshooting

### Neo4j Not Starting

1. Check CloudWatch logs:
```bash
aws logs tail /ecs/nexus-learn/neo4j --follow
```

2. Check ECS task status:
```bash
aws ecs describe-tasks --cluster nexus-learn-cluster --tasks <task-id>
```

3. Verify security group rules allow traffic from ECS

### Weaviate Not Starting

1. Check CloudWatch logs:
```bash
aws logs tail /ecs/nexus-learn/weaviate --follow
```

2. Verify EFS mount target is accessible:
```bash
aws efs describe-mount-targets --file-system-id <efs-id>
```

3. Check EFS security group allows traffic from Weaviate security group

### Service Discovery Not Working

1. Verify namespace exists:
```bash
aws servicediscovery list-namespaces
```

2. Check service registration:
```bash
aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=<namespace-id>
```

3. Verify VPC DNS resolution is enabled

## Updating Services

### Update Neo4j Version

```hcl
neo4j_image = "neo4j:5.16-community"
```

Then apply:
```bash
terraform apply
```

### Update Weaviate Version

```hcl
weaviate_image = "semitechnologies/weaviate:1.25.0"
```

Then apply:
```bash
terraform apply
```

## Backup and Recovery

### Neo4j Backup

1. Use Neo4j backup tools:
```bash
neo4j-admin backup --backup-dir=/backups --name=backup
```

2. Export to Cypher:
```bash
neo4j-admin database dump neo4j --to-path=/backups
```

### Weaviate Backup

1. Use Weaviate backup API:
```bash
curl -X POST http://weaviate.nexus-learn.local:8080/v1/backups/filesystem \
  -H "Content-Type: application/json" \
  -d '{"id": "backup-1", "include": ["*"]}'
```

2. Backup EFS:
```bash
aws efs create-backup --file-system-id <efs-id>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all data in Neo4j and Weaviate!

## Next Steps

1. **Configure Backend**: Update backend services to connect to Neo4j and Weaviate
2. **Set Up Monitoring**: Configure CloudWatch alarms and dashboards
3. **Enable Authentication**: Configure Weaviate authentication for production
4. **Set Up Backups**: Configure automated backups for both services
5. **Scale Up**: Adjust CPU/memory based on workload

## References

- [Neo4j Documentation](https://neo4j.com/docs/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Service Discovery](https://docs.aws.amazon.com/cloud-map/)

