# 🚀 Serverless TODO Application

A production-grade serverless TODO application built with AWS Lambda, API Gateway, DynamoDB, S3, CloudFront, and Terraform.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [Running Locally](#running-locally)
- [CI/CD Pipeline](#cicd-pipeline)
- [Costs](#costs)
- [Future Improvements](#future-improvements)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CloudFront CDN                          │
│                    (Global Content Delivery)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │   S3 Bucket    │
                    │  (Frontend)    │
                    └────────────────┘
                             │
                             │
┌────────────────────────────┴────────────────────────────────────┐
│                      API Gateway (REST)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  GET     │  │  POST    │  │   PUT    │  │  DELETE  │         │
│  │ /tasks   │  │ /tasks   │  │/tasks/id│  │/tasks/id │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
└───────┼─────────────┼─────────────┼─────────────┼──────────────┘
        │             │             │             │
        ▼             ▼             ▼             ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  Lambda     │ │  Lambda     │ │  Lambda     │ │  Lambda     │
│ getTasks    │ │ createTask  │ │ updateTask  │ │ deleteTask  │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │               │
       └───────────────┴───────────────┴───────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   DynamoDB      │
                    │   (Tasks Table)  │
                    └─────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                              │
│  GitHub → CodePipeline → CodeBuild → Deploy to AWS              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      Monitoring                                 │
│  CloudWatch Dashboards, Alarms, Logs                            │
└─────────────────────────────────────────────────────────────────┘
```

### Components

- **Frontend**: React SPA hosted on S3, distributed via CloudFront
- **API Gateway**: RESTful API with CORS support
- **Lambda Functions**: 4 serverless functions for CRUD operations
- **DynamoDB**: NoSQL database with autoscaling and TTL support
- **CloudFront**: CDN for global content delivery
- **CodePipeline/CodeBuild**: Automated CI/CD pipeline
- **CloudWatch**: Monitoring, logging, and alarms

## ✨ Features

- ✅ Full CRUD operations for TODO tasks
- ✅ Real-time task management
- ✅ Task completion tracking
- ✅ Responsive React UI
- ✅ Serverless architecture (pay-per-use)
- ✅ Auto-scaling DynamoDB
- ✅ Global CDN distribution
- ✅ Automated CI/CD pipeline
- ✅ CloudWatch monitoring and alarms
- ✅ Infrastructure as Code (Terraform)
- ✅ Multi-environment support (dev/prod)

## 📦 Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.5.0
- Node.js >= 18.x
- npm or yarn
- AWS CLI configured
- Git (for CI/CD)

## 📁 Project Structure

```
cloud/
├── infra/                          # Terraform Infrastructure
│   ├── backend.tf                  # Remote state configuration
│   ├── providers.tf                # Provider configuration
│   ├── variables.tf                # Root variables
│   ├── outputs.tf                  # Root outputs
│   ├── main.tf                     # Main infrastructure
│   ├── modules/                    # Terraform modules
│   │   ├── frontend/               # S3 + CloudFront module
│   │   ├── api/                    # API Gateway module
│   │   ├── lambda/                 # Lambda functions module
│   │   ├── database/               # DynamoDB module
│   │   ├── iam/                    # IAM roles & policies
│   │   ├── cicd/                   # CI/CD pipeline module
│   │   └── monitoring/             # CloudWatch monitoring
│   └── envs/                       # Environment configs
│       ├── dev/
│       └── prod/
├── app/
│   ├── backend/                    # Lambda functions
│   │   ├── getTasks.js
│   │   ├── createTask.js
│   │   ├── updateTask.js
│   │   ├── deleteTask.js
│   │   └── package.json
│   └── frontend/                   # React application
│       ├── src/
│       │   ├── App.jsx
│       │   ├── components/
│       │   │   ├── TaskList.jsx
│       │   │   └── AddTask.jsx
│       │   └── main.jsx
│       ├── package.json
│       └── vite.config.js
├── buildspec-frontend.yml          # Frontend build spec
├── buildspec-backend.yml           # Backend build spec
└── README.md                       # This file
```

## 🚀 Deployment

### Step 1: Configure Terraform Backend

Edit `infra/backend.tf` and update the S3 bucket and DynamoDB table names:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "serverless-todo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

**Create the backend resources first:**

```bash
# Create S3 bucket for state
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 2: Configure Environment Variables

Edit `infra/envs/dev/terraform.tfvars`:

```hcl
aws_region         = "us-east-1"
environment       = "dev"
project_name      = "serverless-todo"
domain_name       = ""  # Optional: your domain name
github_repo       = "your-username/your-repo"  # For CI/CD
github_branch     = "main"
enable_monitoring = true
log_retention_days = 7
```

### Step 3: Package Lambda Functions

```bash
cd app/backend
npm install
# Create zip files (Terraform will use these)
zip -j getTasks.zip getTasks.js
zip -r getTasks.zip node_modules/

zip -j createTask.zip createTask.js
zip -r createTask.zip node_modules/

zip -j updateTask.zip updateTask.js
zip -r updateTask.zip node_modules/

zip -j deleteTask.zip deleteTask.js
zip -r deleteTask.zip node_modules/
```

### Step 4: Deploy Infrastructure

```bash
cd infra/envs/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

### Step 5: Deploy Frontend

After Terraform deployment, get the S3 bucket name from outputs:

```bash
terraform output s3_bucket_name
```

Then build and deploy:

```bash
cd app/frontend
npm install
npm run build
aws s3 sync dist/ s3://<bucket-name>/
```

### Step 6: Update Frontend API URL

1. Get the API Gateway URL from Terraform outputs:
   ```bash
   terraform output api_gateway_url
   ```

2. Create `.env` file in `app/frontend/`:
   ```
   VITE_API_URL=https://<api-id>.execute-api.us-east-1.amazonaws.com/dev
   ```

3. Rebuild and redeploy:
   ```bash
   npm run build
   aws s3 sync dist/ s3://<bucket-name>/
   ```

4. Invalidate CloudFront cache:
   ```bash
   aws cloudfront create-invalidation \
     --distribution-id <distribution-id> \
     --paths "/*"
   ```

## 💻 Running Locally

### Backend (Lambda Functions)

1. Install dependencies:
   ```bash
   cd app/backend
   npm install
   ```

2. Set environment variables:
   ```bash
   export TABLE_NAME=serverless-todo-dev-tasks
   export AWS_REGION=us-east-1
   ```

3. Test functions locally using AWS SAM or Lambda Local:
   ```bash
   # Example: Test getTasks
   node -e "require('./getTasks').handler({}, {}, console.log)"
   ```

### Frontend

1. Install dependencies:
   ```bash
   cd app/frontend
   npm install
   ```

2. Create `.env` file:
   ```
   VITE_API_URL=https://your-api-gateway-url.execute-api.us-east-1.amazonaws.com/dev
   ```

3. Run development server:
   ```bash
   npm run dev
   ```

4. Open browser: `http://localhost:5173`

## 🔄 CI/CD Pipeline

### Setup GitHub Connection

1. In AWS Console, go to CodeStar Connections
2. Create a new GitHub connection
3. Authorize the connection
4. Update `terraform.tfvars` with your GitHub repo URL

### Pipeline Flow

1. **Source**: GitHub webhook triggers pipeline on push
2. **Build Frontend**: CodeBuild runs `buildspec-frontend.yml`
3. **Build Backend**: CodeBuild runs `buildspec-backend.yml`
4. **Deploy Frontend**: Upload to S3, invalidate CloudFront
5. **Deploy Backend**: Update Lambda function code

### Manual Pipeline Trigger

```bash
aws codepipeline start-pipeline-execution \
  --name serverless-todo-dev-pipeline
```

## 💰 Costs

### Estimated Monthly Costs (Low Traffic)

| Service | Usage | Cost |
|---------|-------|------|
| Lambda | 1M requests, 128MB, 500ms avg | ~$0.20 |
| API Gateway | 1M requests | ~$3.50 |
| DynamoDB | 5 RCU, 5 WCU | ~$0.25 |
| S3 | 1GB storage, 10GB transfer | ~$0.25 |
| CloudFront | 10GB transfer | ~$0.85 |
| CodePipeline | 10 executions/month | ~$1.00 |
| CodeBuild | 10 builds, 20 min each | ~$1.00 |
| CloudWatch | Logs & Metrics | ~$0.50 |
| **Total** | | **~$7.55/month** |

*Note: Costs vary based on usage. Free tier may apply for new AWS accounts.*

### Cost Optimization Tips

- Use DynamoDB On-Demand billing for unpredictable traffic
- Enable S3 lifecycle policies for old logs
- Set CloudWatch log retention to minimum required
- Use CloudFront caching to reduce origin requests
- Monitor and optimize Lambda memory allocation

## 🔮 Future Improvements

### Infrastructure

- [ ] Add WAF for API Gateway protection
- [ ] Implement API Gateway caching
- [ ] Add CloudFront custom domain with ACM
- [ ] Set up Route 53 for custom domain
- [ ] Add VPC configuration for Lambda (if needed)
- [ ] Implement X-Ray tracing
- [ ] Add SNS/SQS for async processing
- [ ] Multi-region deployment for DR

### Application

- [ ] Add user authentication (Cognito)
- [ ] Implement task categories/tags
- [ ] Add task due dates and reminders
- [ ] Task search and filtering
- [ ] Task sharing/collaboration
- [ ] File attachments (S3)
- [ ] Real-time updates (WebSockets/AppSync)
- [ ] Offline support (Service Workers)

### DevOps

- [ ] Add Terraform workspaces
- [ ] Implement blue/green deployments
- [ ] Add automated testing in CI/CD
- [ ] Security scanning (Snyk, OWASP)
- [ ] Infrastructure cost alerts
- [ ] Automated backup strategy
- [ ] Disaster recovery plan

### Monitoring

- [ ] Custom CloudWatch metrics
- [ ] PagerDuty/Slack integration
- [ ] Cost anomaly detection
- [ ] Performance dashboards
- [ ] Error tracking (Sentry)

## 🛠️ Troubleshooting

### Lambda Function Errors

Check CloudWatch Logs:
```bash
aws logs tail /aws/lambda/serverless-todo-dev-getTasks --follow
```

### API Gateway Issues

- Verify CORS configuration
- Check Lambda permissions
- Review API Gateway logs

### Frontend Not Loading

- Check S3 bucket policy
- Verify CloudFront distribution status
- Check browser console for errors
- Verify API URL in environment variables

### Terraform Errors

- Ensure backend bucket exists
- Check IAM permissions
- Verify provider versions
- Review variable values

## 📝 License

MIT License - feel free to use this project for learning and production purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

For issues and questions, please open an issue on GitHub.

---

**Built with ❤️ using AWS Serverless Technologies and Terraform**

