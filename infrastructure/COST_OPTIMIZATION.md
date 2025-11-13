# Cost Optimization Guide - Dev Environment

This document outlines the cost-optimized architecture changes made to minimize AWS costs while maintaining functionality for development environments.

## Architecture Changes

### 1. Single Availability Zone (AZ)
**Before:** 2 AZs (ap-southeast-1a, ap-southeast-1b)  
**After:** 1 AZ (ap-southeast-1a)

**Cost Impact:**
- Reduces NAT Gateway costs by 50% (~$32/month savings)
- Reduces subnet and routing complexity
- Still maintains high availability for dev workloads

### 2. Minimal ECS Fargate Resources
**Before:** 512 CPU (0.5 vCPU), 1024 MB memory  
**After:** 256 CPU (0.25 vCPU), 512 MB memory

**Cost Impact:**
- ~50% reduction in compute costs
- Within AWS Free Tier limits (20 GB-hours/month)
- Sufficient for development workloads

### 3. Limited Auto-Scaling
**Before:** 1-5 tasks  
**After:** 1-2 tasks

**Cost Impact:**
- Prevents unexpected scaling costs
- Still allows minimal scaling for load spikes
- Reduces maximum potential costs

### 4. RDS Optimization
**Configuration:**
- Instance: `db.t3.micro` (Free Tier eligible)
- Storage: 20 GB (minimum, Free Tier covers 20GB)
- Storage Auto-scaling: Disabled
- Backup Retention: 1 day (minimum)
- Performance Insights: Disabled
- Multi-AZ: Disabled

**Cost Impact:**
- Free Tier: $0/month (first 12 months, 750 hours)
- After Free Tier: ~$15/month
- Performance Insights savings: ~$7/month
- Backup storage savings: ~$2-5/month

### 5. Disabled Expensive Features
- **Container Insights:** Disabled (saves ~$10/month)
- **Performance Insights:** Disabled (saves ~$7/month)
- **CloudFront:** Disabled (saves ~$5-10/month)
- **Log Retention:** Reduced to 1 day (saves ~$2-5/month)

## Estimated Monthly Costs

### With AWS Free Tier (First 12 Months)
| Service | Cost |
|---------|------|
| RDS db.t3.micro | $0 (750 hours free) |
| ECS Fargate (256 CPU, 512 MB) | $0-5 (within 20 GB-hours free) |
| Application Load Balancer | ~$16 |
| NAT Gateway (1x) | ~$32 |
| Data Transfer | ~$5-10 |
| S3 (Terraform state) | ~$0.50 |
| DynamoDB (state lock) | ~$0.25 |
| **Total** | **~$20-30/month** |

### After Free Tier Expires
| Service | Cost |
|---------|------|
| RDS db.t3.micro | ~$15 |
| ECS Fargate (256 CPU, 512 MB) | ~$10-15 |
| Application Load Balancer | ~$16 |
| NAT Gateway (1x) | ~$32 |
| Data Transfer | ~$5-10 |
| S3 (Terraform state) | ~$0.50 |
| DynamoDB (state lock) | ~$0.25 |
| **Total** | **~$80-90/month** |

## Cost Comparison

### Before Optimization
- 2 NAT Gateways: ~$64/month
- ECS (512 CPU, 1024 MB): ~$20-30/month
- Container Insights: ~$10/month
- Performance Insights: ~$7/month
- **Total: ~$100-110/month**

### After Optimization
- 1 NAT Gateway: ~$32/month
- ECS (256 CPU, 512 MB): ~$10-15/month
- Container Insights: Disabled
- Performance Insights: Disabled
- **Total: ~$20-30/month (Free Tier) or ~$80-90/month (after)**

**Savings: ~$20-30/month (70-80% reduction)**

## Usage-Based Cost Model

This architecture follows a **pay-per-use** model:

1. **Compute (ECS):** Charges only for running tasks
   - Minimum: 1 task running 24/7
   - Scales to 2 tasks only when CPU/memory exceeds thresholds
   - Can scale to 0 if needed (with manual intervention)

2. **Database (RDS):** Charges only when running
   - Can be stopped during off-hours (manual or scheduled)
   - Charges per hour when running

3. **Network (ALB + NAT):** Fixed costs
   - ALB: ~$16/month (always running)
   - NAT Gateway: ~$32/month (always running)
   - Data Transfer: Pay per GB

## Additional Cost Optimization Tips

### 1. Schedule RDS Stop/Start
Use AWS Instance Scheduler or Lambda to:
- Stop RDS during off-hours (nights/weekends)
- Saves ~50% of RDS costs if stopped 12 hours/day

### 2. Use Fargate Spot (Future Enhancement)
- 60-70% savings on compute
- Requires capacity provider configuration
- Suitable for dev/test workloads

### 3. Monitor Costs
Set up AWS Cost Explorer and Budgets:
```bash
# Set up budget alert at $50/month
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

### 4. Use AWS Cost Anomaly Detection
Enable to get alerts for unexpected cost spikes.

### 5. Tag Resources
Ensure all resources are tagged for cost allocation:
- Environment: dev
- Project: nexus-learn
- ManagedBy: Terraform

## Scaling Up (When Needed)

When you need more resources, update `terraform.tfvars`:

```hcl
# For more compute
backend_cpu = 512
backend_memory = 1024
backend_max_count = 5

# For more database capacity
rds_instance_class = "db.t3.small"
rds_allocated_storage = 50
rds_max_allocated_storage = 100

# Enable monitoring
enable_container_insights = true
rds_performance_insights_enabled = true
```

## Monitoring Costs

### AWS Cost Explorer
- View costs by service, time period, tags
- URL: https://console.aws.amazon.com/cost-management/home

### AWS Budgets
- Set budget alerts
- Get notified when costs exceed thresholds

### Cost Allocation Tags
All resources are tagged with:
- `Environment: dev`
- `Project: nexus-learn`
- `ManagedBy: Terraform`

Use these tags in Cost Explorer to track costs by project.

## Free Tier Limits

Monitor these Free Tier limits:

1. **RDS:** 750 hours/month of db.t2.micro or db.t3.micro
2. **ECS Fargate:** 20 GB-hours/month
3. **S3:** 5 GB storage, 20,000 GET requests
4. **Data Transfer:** 1 GB/month out

## Summary

The optimized architecture:
- ✅ Reduces costs by 70-80%
- ✅ Uses Free Tier eligible resources
- ✅ Maintains functionality for dev workloads
- ✅ Scales with actual usage
- ✅ Easy to scale up when needed

**Estimated Monthly Cost: $20-30 (Free Tier) or $80-90 (after Free Tier)**

