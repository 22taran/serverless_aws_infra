variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
  default     = ""
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for frontend"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "api_gateway_url" {
  description = "API Gateway URL"
  type        = string
  default     = ""
}

variable "lambda_functions" {
  description = "Map of Lambda functions"
  type = map(object({
    function_name = string
    function_arn  = string
    handler       = string
    method        = string
    path          = string
  }))
}

variable "cicd_role_arn" {
  description = "CI/CD role ARN (CodeBuild)"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

