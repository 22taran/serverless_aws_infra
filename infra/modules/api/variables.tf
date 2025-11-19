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

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

