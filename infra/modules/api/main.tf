# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "Serverless TODO API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# API Gateway Resource for /tasks
resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "tasks"
}

# API Gateway Resource for /tasks/{id}
resource "aws_api_gateway_resource" "task_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.tasks.id
  path_part   = "{id}"
}

# API Gateway Methods and Integrations
resource "aws_api_gateway_method" "this" {
  for_each = var.lambda_functions

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.path == "/tasks" ? aws_api_gateway_resource.tasks.id : aws_api_gateway_resource.task_id.id
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  for_each = var.lambda_functions

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.this[each.key].resource_id
  http_method = aws_api_gateway_method.this[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${each.value.function_arn}/invocations"
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = var.lambda_functions

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# CORS Configuration for OPTIONS method
resource "aws_api_gateway_method" "options" {
  for_each = toset(["/tasks", "/tasks/{id}"])

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value == "/tasks" ? aws_api_gateway_resource.tasks.id : aws_api_gateway_resource.task_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = toset(["/tasks", "/tasks/{id}"])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.options[each.value].resource_id
  http_method = aws_api_gateway_method.options[each.value].http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = toset(["/tasks", "/tasks/{id}"])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.options[each.value].resource_id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = toset(["/tasks", "/tasks/{id}"])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.options[each.value].resource_id
  http_method = aws_api_gateway_method.options[each.value].http_method
  status_code = aws_api_gateway_method_response.options[each.value].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_integration.options
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
      aws_api_gateway_method.options,
      aws_api_gateway_integration.options
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment

  tags = var.tags
}

data "aws_region" "current" {}

