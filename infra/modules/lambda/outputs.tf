output "functions" {
  description = "Map of Lambda functions"
  value = {
    for k, v in aws_lambda_function.this : k => {
      function_name = v.function_name
      function_arn  = v.arn
      handler       = local.functions[k].handler
      method        = local.functions[k].method
      path          = local.functions[k].path
    }
  }
}

output "function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    for k, v in aws_lambda_function.this : k => v.arn
  }
}

