variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "read_capacity" {
  description = "DynamoDB read capacity units"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "DynamoDB write capacity units"
  type        = number
  default     = 5
}

variable "enable_autoscaling" {
  description = "Enable DynamoDB autoscaling"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum capacity for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity for autoscaling"
  type        = number
  default     = 10
}

