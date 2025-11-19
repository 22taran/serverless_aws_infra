# 🚀 Quick Start Guide

This guide will help you deploy the Serverless TODO application in under 30 minutes.

## Prerequisites Checklist

- [ ] AWS Account with admin access
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform >= 1.5.0 installed
- [ ] Node.js >= 18.x installed
- [ ] Git installed

## Step-by-Step Deployment

### 1. Clone and Setup (2 minutes)

```bash
# If cloning from repo
git clone <your-repo-url>
cd cloud

# Or if already in the directory
cd /path/to/cloud
```

### 2. Create Terraform Backend (5 minutes)

```bash
# Set your bucket name
export TF_STATE_BUCKET="terraform-state-bucket-$(date +%s)"
export AWS_REGION="us-east-1"

# Create S3 bucket for Terraform state
aws s3 mb s3://$TF_STATE_BUCKET --region $AWS_REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $TF_STATE_BUCKET \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $AWS_REGION

# Wait for table to be active
aws dynamodb wait table-exists --table-name terraform-state-lock
```

### 3. Configure Terraform Backend (2 minutes)

Edit `infra/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket-1234567890"  # Use your bucket name
    key            = "serverless-todo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### 4. Configure Environment (2 minutes)

Edit `infra/envs/dev/terraform.tfvars`:

```hcl
aws_region         = "us-east-1"
environment       = "dev"
project_name      = "serverless-todo"
domain_name       = ""  # Leave empty for now
github_repo       = ""  # Leave empty if not using CI/CD
github_branch     = "main"
enable_monitoring = true
log_retention_days = 7
```

### 5. Package Lambda Functions (3 minutes)

```bash
# Package all Lambda functions
make package-lambda

# Or manually:
cd app/backend
npm install
./../../scripts/package-lambda.sh
```

### 6. Deploy Infrastructure (10 minutes)

```bash
# Initialize Terraform
cd infra/envs/dev
terraform init

# Review the plan
terraform plan

# Apply (type 'yes' when prompted)
terraform apply
```

**Save the outputs!** You'll need:
- `api_gateway_url` - For frontend configuration
- `s3_bucket_name` - For frontend deployment
- `cloudfront_distribution_id` - For cache invalidation

### 7. Configure Frontend API URL (2 minutes)

```bash
# Get the API URL from Terraform output
cd infra/envs/dev
API_URL=$(terraform output -raw api_gateway_url)
echo "API URL: $API_URL"

# Create .env file
cd ../../app/frontend
echo "VITE_API_URL=$API_URL" > .env
```

### 8. Deploy Frontend (3 minutes)

```bash
# Get S3 bucket name from Terraform
cd infra/envs/dev
S3_BUCKET=$(terraform output -raw s3_bucket_name)
CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id)

# Deploy frontend
cd ../../..
make deploy-frontend S3_BUCKET=$S3_BUCKET CLOUDFRONT_DISTRIBUTION_ID=$CLOUDFRONT_ID
```

### 9. Access Your Application (1 minute)

```bash
# Get CloudFront URL
cd infra/envs/dev
terraform output cloudfront_domain_name
```

Open the CloudFront domain name in your browser! 🎉

## Verification

### Test API Endpoints

```bash
# Get API URL
API_URL=$(cd infra/envs/dev && terraform output -raw api_gateway_url)

# Test GET /tasks
curl $API_URL/tasks

# Test POST /tasks
curl -X POST $API_URL/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Task", "description": "This is a test"}'

# Test PUT /tasks/{id}
# (Use the taskId from the POST response)
curl -X PUT $API_URL/tasks/<task-id> \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Test DELETE /tasks/{id}
curl -X DELETE $API_URL/tasks/<task-id>
```

### Check CloudWatch Logs

```bash
# View Lambda logs
aws logs tail /aws/lambda/serverless-todo-dev-getTasks --follow
```

## Troubleshooting

### Lambda Functions Not Found

If Terraform fails because zip files don't exist:
```bash
make package-lambda
cd infra/envs/dev
terraform apply
```

### Frontend Not Loading

1. Check S3 bucket policy allows CloudFront
2. Verify CloudFront distribution is deployed
3. Check browser console for CORS errors
4. Verify API URL in `.env` file

### API Gateway CORS Issues

CORS is configured in the API Gateway module. If you see CORS errors:
1. Check API Gateway stage is deployed
2. Verify OPTIONS methods are configured
3. Check browser console for specific error

## Next Steps

- [ ] Set up CI/CD pipeline (see README.md)
- [ ] Configure custom domain
- [ ] Set up monitoring alerts
- [ ] Review and optimize costs

## Cleanup

To destroy all resources:

```bash
cd infra/envs/dev
terraform destroy
```

**Note:** This will delete all resources including DynamoDB data!

---

**Need Help?** Check the main [README.md](./README.md) for detailed documentation.

