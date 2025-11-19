locals {
  functions = {
    getTasks = {
      handler = "getTasks.handler"
      method  = "GET"
      path    = "/tasks"
    }
    createTask = {
      handler = "createTask.handler"
      method  = "POST"
      path    = "/tasks"
    }
    updateTask = {
      handler = "updateTask.handler"
      method  = "PUT"
      path    = "/tasks/{id}"
    }
    deleteTask = {
      handler = "deleteTask.handler"
      method  = "DELETE"
      path    = "/tasks/{id}"
    }
  }
  
  # Paths to Lambda ZIP files
  zip_file_paths = {
    for k, v in local.functions : k => "${path.module}/../../../../app/backend/${k}.zip"
  }
  
  # Create placeholder ZIP files if they don't exist
  placeholder_zip_paths = {
    for k, v in local.functions : k => "${path.module}/${k}-placeholder.zip"
  }
}

# Create placeholder ZIP files if actual ZIPs don't exist
data "archive_file" "placeholder" {
  for_each = local.functions
  
  type        = "zip"
  output_path = local.placeholder_zip_paths[each.key]
  
  source {
    content = <<EOF
exports.handler = async (event) => {
  return {
    statusCode: 501,
    body: JSON.stringify({
      error: 'Function code not deployed. Please run: make package-lambda'
    })
  };
};
EOF
    filename = "${each.key}.js"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = local.functions
  name              = "/aws/lambda/${var.project_name}-${var.environment}-${each.key}"
  retention_in_days = 7

  tags = var.tags
}

# Lambda Functions
resource "aws_lambda_function" "this" {
  for_each = local.functions

  function_name = "${var.project_name}-${var.environment}-${each.key}"
  role          = var.lambda_role_arn
  handler       = each.value.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  # Use actual ZIP if it exists, otherwise use placeholder
  filename         = fileexists(local.zip_file_paths[each.key]) ? local.zip_file_paths[each.key] : local.placeholder_zip_paths[each.key]
  source_code_hash = fileexists(local.zip_file_paths[each.key]) ? filebase64sha256(local.zip_file_paths[each.key]) : data.archive_file.placeholder[each.key].output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
      NODE_ENV   = var.environment
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    data.archive_file.placeholder
  ]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${each.key}"
  })
}


