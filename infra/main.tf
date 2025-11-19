locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM Module
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  dynamodb_table_name = module.database.table_name
  lambda_role_arn     = module.iam.lambda_execution_role_arn
  tags                = local.common_tags
}

# API Gateway Module
module "api" {
  source = "./modules/api"

  project_name     = var.project_name
  environment      = var.environment
  lambda_functions = module.lambda.functions
  tags             = local.common_tags
}

# Frontend Module
module "frontend" {
  source = "./modules/frontend"

  project_name = var.project_name
  environment  = var.environment
  domain_name  = var.domain_name
  api_url      = module.api.api_gateway_url
  tags         = local.common_tags
}

# CI/CD Module
module "cicd" {
  source = "./modules/cicd"

  project_name           = var.project_name
  environment            = var.environment
  github_repo            = var.github_repo
  github_branch          = var.github_branch
  s3_bucket_name         = module.frontend.s3_bucket_name
  cloudfront_distribution_id = module.frontend.cloudfront_distribution_id
  api_gateway_id         = module.api.api_gateway_id
  lambda_functions       = module.lambda.functions
  cicd_role_arn          = module.iam.cicd_role_arn
  codepipeline_role_arn  = module.iam.codepipeline_role_arn
  tags                   = local.common_tags
}

# Monitoring Module
module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/monitoring"

  project_name     = var.project_name
  environment      = var.environment
  lambda_functions = module.lambda.functions
  api_gateway_id   = module.api.api_gateway_id
  log_retention_days = var.log_retention_days
  tags             = local.common_tags
}

