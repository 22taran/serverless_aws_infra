variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
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

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

