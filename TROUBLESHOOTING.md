# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### 1. Lambda ZIP Files Not Found

**Error:**
```
Error: reading ZIP file (../../modules/lambda/../../../../app/backend/getTasks.zip): no such file or directory
```

**Solution:**
The Lambda module now automatically creates placeholder ZIP files if the actual ZIPs don't exist. However, you should package the Lambda functions before deploying:

```bash
# Package Lambda functions
make package-lambda

# Or manually:
cd app/backend
npm install
./../../scripts/package-lambda.sh
```

**Note:** The placeholder functions will return a 501 error until you package and deploy the actual code. After packaging, update the Lambda functions:

```bash
# After packaging, update Lambda functions
aws lambda update-function-code \
  --function-name serverless-todo-dev-getTasks \
  --zip-file fileb://app/backend/getTasks.zip

# Repeat for other functions
```

---

### 2. CloudFront Account Verification Required

**Error:**
```
Error: creating CloudFront Distribution: AccessDenied: Your account must be verified before you can add new CloudFront resources.
```

**Solution:**
This is an AWS account limitation. New AWS accounts need to be verified before creating CloudFront distributions.

**Option 1: Verify Your Account (Recommended)**
1. Go to [AWS Support Center](https://console.aws.amazon.com/support/home)
2. Create a support case
3. Request account verification for CloudFront
4. Usually takes 24-48 hours

**Option 2: Skip CloudFront Temporarily**
You can comment out the CloudFront distribution in the frontend module and use S3 website hosting directly:

1. Edit `infra/modules/frontend/main.tf`
2. Comment out the `aws_cloudfront_distribution` resource
3. Use S3 website endpoint directly (less secure, but works for testing)

**Option 3: Use Existing CloudFront Distribution**
If you already have a CloudFront distribution, you can reference it instead of creating a new one.

---

### 3. DynamoDB KMS Key Not Found

**Error:**
```
Error: creating AWS DynamoDB Table: KMS validation error: Key 'arn:aws:kms:...' does not exist
```

**Solution:**
This error occurs when DynamoDB tries to use a KMS key that doesn't exist. The configuration has been updated to use AWS-managed encryption (default).

**Option 1: Refresh Terraform State (Recommended)**
If you have existing state with a KMS key configured:

```bash
# Refresh the state
terraform refresh

# Or if the table doesn't exist yet, just re-run apply
terraform apply
```

**Option 2: Remove KMS Key from State**
If the table exists in state with a KMS key:

```bash
# Check current state
terraform state show module.infrastructure.module.database.aws_dynamodb_table.tasks

# If needed, remove and re-import (be careful!)
terraform state rm module.infrastructure.module.database.aws_dynamodb_table.tasks
terraform import module.infrastructure.module.database.aws_dynamodb_table.tasks serverless-todo-dev-tasks
```

**Option 3: Use Custom KMS Key (Advanced)**
If you want to use a custom KMS key:

1. Create or use an existing KMS key
2. Add to `infra/modules/database/variables.tf`:
   ```hcl
   variable "kms_key_arn" {
     description = "KMS key ARN for DynamoDB encryption (optional)"
     type        = string
     default     = null
   }
   ```
3. Update `infra/modules/database/main.tf`:
   ```hcl
   server_side_encryption {
     enabled     = true
     kms_key_arn = var.kms_key_arn
   }
   ```

**Note:** The current configuration uses AWS-managed encryption (no KMS key required), which is free and sufficient for most use cases.

---

### 4. Terraform Backend Configuration Warning

**Warning:**
```
Warning: Backend configuration ignored
```

**Solution:**
This is expected when running Terraform from `envs/dev/`. The backend configuration in the root `backend.tf` will be used when you run `terraform init` from the environment directory. This warning is harmless.

---

### 5. S3 Bucket Already Exists

**Error:**
```
Error: creating S3 bucket: BucketAlreadyExists
```

**Solution:**
S3 bucket names must be globally unique. The module uses random suffixes, but if you see this error:

1. Change the `project_name` in `terraform.tfvars`
2. Or manually delete the conflicting bucket (if safe to do so)
3. Or use a different AWS region

---

### 6. DynamoDB Table Already Exists

**Error:**
```
Error: creating DynamoDB table: ResourceInUseException
```

**Solution:**
1. Check if the table exists: `aws dynamodb describe-table --table-name serverless-todo-dev-tasks`
2. If it exists and you want to recreate it, delete it first:
   ```bash
   aws dynamodb delete-table --table-name serverless-todo-dev-tasks
   ```
3. Wait for deletion to complete, then run `terraform apply` again

**Warning:** This will delete all data in the table!

---

### 7. IAM Role Already Exists

**Error:**
```
Error: creating IAM role: EntityAlreadyExists
```

**Solution:**
1. Delete the existing role:
   ```bash
   aws iam delete-role --role-name serverless-todo-dev-lambda-execution
   ```
2. Or import it into Terraform state:
   ```bash
   terraform import module.infrastructure.module.iam.aws_iam_role.lambda_execution serverless-todo-dev-lambda-execution
   ```

---

### 8. API Gateway Deployment Issues

**Error:**
```
Error: creating API Gateway deployment: BadRequestException
```

**Solution:**
1. Ensure all Lambda integrations are created first
2. Check that Lambda permissions are set correctly
3. Verify API Gateway methods are properly configured
4. Try running `terraform apply` again (sometimes it's a timing issue)

---

### 9. Lambda Function Update Errors

**Error:**
```
Error: updating Lambda function: InvalidParameterValueException
```

**Solution:**
1. Ensure the ZIP file exists and is valid
2. Check file size (Lambda has a 50MB limit for direct upload)
3. Verify the handler name matches the function name
4. Check runtime compatibility

---

### 10. CodePipeline GitHub Connection Issues

**Error:**
```
Error: CodeStar connection not ready
```

**Solution:**
1. Go to AWS Console → CodeStar Connections
2. Find your connection and check its status
3. If "Pending", click "Update pending connection" and authorize it
4. Wait for status to change to "Available"
5. Run `terraform apply` again

---

### 11. CloudWatch Logs Permission Errors

**Error:**
```
Error: creating CloudWatch log group: AccessDenied
```

**Solution:**
1. Ensure the Lambda execution role has CloudWatch Logs permissions
2. Check IAM policy includes:
   ```json
   {
     "Effect": "Allow",
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*"
   }
   ```

---

### 12. Terraform State Lock Issues

**Error:**
```
Error: Error acquiring the state lock
```

**Solution:**
1. Check if another Terraform process is running
2. If not, manually release the lock:
   ```bash
   aws dynamodb delete-item \
     --table-name terraform-state-lock \
     --key '{"LockID":{"S":"your-lock-id"}}'
   ```
3. Or wait for the lock to timeout (usually 5 minutes)

---

### 13. Module Path Issues

**Error:**
```
Error: Failed to load module
```

**Solution:**
1. Ensure you're running Terraform from the correct directory (`infra/envs/dev/`)
2. Check that module paths are correct (relative paths from the module location)
3. Run `terraform init` to download modules

---

## Quick Fixes Checklist

Before asking for help, try these:

- [ ] Run `terraform init` to ensure modules are downloaded
- [ ] Run `make package-lambda` to create Lambda ZIP files
- [ ] Check AWS credentials: `aws sts get-caller-identity`
- [ ] Verify AWS region is correct
- [ ] Check Terraform version: `terraform version` (should be >= 1.5.0)
- [ ] Review Terraform plan: `terraform plan`
- [ ] Check AWS service quotas/limits
- [ ] Verify account has necessary permissions
- [ ] Check CloudFront account verification status

---

## Getting Help

If you're still stuck:

1. **Check the logs:**
   ```bash
   terraform apply -auto-approve 2>&1 | tee terraform.log
   ```

2. **Enable debug mode:**
   ```bash
   export TF_LOG=DEBUG
   terraform apply
   ```

3. **Check AWS Service Health:**
   - Visit [AWS Service Health Dashboard](https://status.aws.amazon.com/)

4. **Review Documentation:**
   - [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
   - [AWS Service Documentation](https://docs.aws.amazon.com/)

---

**Last Updated**: 2024

