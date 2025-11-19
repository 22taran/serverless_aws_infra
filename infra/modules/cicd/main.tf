# S3 Bucket for Artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-${var.environment}-artifacts-${random_id.artifact_suffix.hex}"

  tags = var.tags
}

resource "random_id" "artifact_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CodeBuild Project for Frontend
resource "aws_codebuild_project" "frontend" {
  name          = "${var.project_name}-${var.environment}-frontend-build"
  description   = "Build project for frontend"
  build_timeout = 60
  service_role  = var.cicd_role_arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.artifacts.bucket
    name     = "frontend-build"
    packaging = "NONE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "S3_BUCKET"
      value = var.s3_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }

    environment_variable {
      name  = "API_GATEWAY_URL"
      value = var.api_gateway_url
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = <<-EOT
version: 0.2

phases:
  pre_build:
    commands:
      - echo Preparing static website...
      - cd app/frontend
      - echo "Creating deployment directory..."
      - mkdir -p dist
  build:
    commands:
      - echo Build started on `date`
      - echo Copying static HTML file...
      - cp index.html dist/
      - |
        if [ -n "$$API_GATEWAY_URL" ]; then
          echo "Injecting API URL: $$API_GATEWAY_URL"
          sed -i "s|https://YOUR_API_GATEWAY_URL.execute-api.us-east-1.amazonaws.com/dev|$$API_GATEWAY_URL|g" dist/index.html
        fi
      - echo "Static website ready"
      - echo Build completed on `date`
  post_build:
    commands:
      - echo Build phase completed
      - echo Deploying to S3...
      - echo "S3_BUCKET=$$S3_BUCKET"
      - echo "CLOUDFRONT_DISTRIBUTION_ID=$$CLOUDFRONT_DISTRIBUTION_ID"
      - |
        if [ -n "$$S3_BUCKET" ]; then
          echo "Syncing files to S3 bucket: $$S3_BUCKET"
          aws s3 sync dist/ s3://$$S3_BUCKET/ --delete
          echo "Files deployed to S3 successfully"
        else
          echo "Warning: S3_BUCKET not set, skipping S3 deployment"
        fi
      - |
        if [ -n "$$CLOUDFRONT_DISTRIBUTION_ID" ]; then
          echo "Invalidating CloudFront cache..."
          aws cloudfront create-invalidation \
            --distribution-id $$CLOUDFRONT_DISTRIBUTION_ID \
            --paths "/*"
          echo "CloudFront cache invalidated successfully"
        else
          echo "Warning: CLOUDFRONT_DISTRIBUTION_ID not set, skipping cache invalidation"
        fi
artifacts:
  files:
    - '**/*'
  base-directory: app/frontend/dist
EOT
  }

  tags = var.tags
}

# CodeBuild Project for Backend
resource "aws_codebuild_project" "backend" {
  name          = "${var.project_name}-${var.environment}-backend-build"
  description   = "Build project for backend Lambda functions"
  build_timeout = 60
  service_role  = var.cicd_role_arn

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.artifacts.bucket
    name      = "backend-build"
    packaging = "NONE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "LAMBDA_FUNCTIONS"
      value = join(",", [for k, v in var.lambda_functions : v.function_name])
    }

    environment_variable {
      name  = "API_GATEWAY_ID"
      value = var.api_gateway_id
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = <<-EOT
version: 0.2

phases:
  pre_build:
    commands:
      - echo Installing Node.js dependencies...
      - cd app/backend
      - npm install
      - echo Dependencies installed
  build:
    commands:
      - echo Build started on `date`
      - echo Packaging Lambda functions...
      - |
        for func in getTasks createTask updateTask deleteTask; do
          echo "Packaging $$func..."
          zip -j $$func.zip $$func.js
          zip -r $$func.zip node_modules/
          echo "$$func packaged successfully"
        done
      - echo Build completed on `date`
  post_build:
    commands:
      - echo Deploying Lambda functions...
      - |
        for func in getTasks createTask updateTask deleteTask; do
          echo "Updating $$func..."
          aws lambda update-function-code \
            --function-name $${func} \
            --zip-file fileb://$$func.zip || echo "Function $$func may not exist yet"
        done
      - echo Deployment completed
artifacts:
  files:
    - '**/*.zip'
  base-directory: app/backend
EOT
  }

  tags = var.tags
}


# GitHub Connection (CodeStar Connections)
resource "aws_codestarconnections_connection" "github" {
  count         = var.github_repo != "" ? 1 : 0
  name          = "${var.project_name}-${var.environment}-github"
  provider_type = "GitHub"

  tags = var.tags
}

