module "infrastructure" {
  source = "../../"

  aws_region         = var.aws_region
  environment        = var.environment
  project_name       = var.project_name
  domain_name        = var.domain_name
  github_repo        = var.github_repo
  github_branch      = var.github_branch
  enable_monitoring  = var.enable_monitoring
  log_retention_days = var.log_retention_days
}

