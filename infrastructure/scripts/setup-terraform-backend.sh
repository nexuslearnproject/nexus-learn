#!/bin/bash
# Script to set up Terraform state backend (S3 + DynamoDB)

set -e

BUCKET_NAME="${1:-nexus-learn-terraform-state}"
REGION="${2:-ap-southeast-1}"
TABLE_NAME="${3:-terraform-state-lock}"

echo "Setting up Terraform backend..."
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "DynamoDB Table: $TABLE_NAME"
echo ""

# Create S3 bucket
echo "Creating S3 bucket..."
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"
    echo "✓ S3 bucket created"
else
    echo "✓ S3 bucket already exists"
fi

# Enable versioning
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "✓ Versioning enabled"

# Enable encryption
echo "Enabling encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo "✓ Encryption enabled"

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo "✓ Public access blocked"

# Create DynamoDB table
echo "Creating DynamoDB table..."
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" 2>&1 | grep -q 'ResourceNotFoundException'; then
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION"
    echo "✓ DynamoDB table created"
    
    echo "Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"
    echo "✓ Table is active"
else
    echo "✓ DynamoDB table already exists"
fi

echo ""
echo "✓ Terraform backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Copy backend.tf.example to backend.tf in each environment"
echo "2. Update backend.tf with:"
echo "   - bucket = \"$BUCKET_NAME\""
echo "   - region = \"$REGION\""
echo "   - dynamodb_table = \"$TABLE_NAME\""
echo "3. Run 'terraform init' in each environment directory"

