# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = concat(
            [
              for k, v in var.lambda_functions : [
                "AWS/Lambda",
                "Invocations",
                "FunctionName",
                v.function_name,
                {
                  stat   = "Sum"
                  period = 300
                  label  = "${k} Invocations"
                }
              ]
            ],
            [
              for k, v in var.lambda_functions : [
                "AWS/Lambda",
                "Errors",
                "FunctionName",
                v.function_name,
                {
                  stat   = "Sum"
                  period = 300
                  label  = "${k} Errors"
                }
              ]
            ],
            [
              for k, v in var.lambda_functions : [
                "AWS/Lambda",
                "Duration",
                "FunctionName",
                v.function_name,
                {
                  stat   = "Average"
                  period = 300
                  label  = "${k} Duration"
                }
              ]
            ]
          )
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda Functions Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/ApiGateway",
              "Count",
              "ApiName",
              "${var.project_name}-${var.environment}-api",
              {
                stat   = "Sum"
                period = 300
                label  = "API Requests"
              }
            ],
            [
              "AWS/ApiGateway",
              "4XXError",
              "ApiName",
              "${var.project_name}-${var.environment}-api",
              {
                stat   = "Sum"
                period = 300
                label  = "4XX Errors"
              }
            ],
            [
              "AWS/ApiGateway",
              "5XXError",
              "ApiName",
              "${var.project_name}-${var.environment}-api",
              {
                stat   = "Sum"
                period = 300
                label  = "5XX Errors"
              }
            ],
            [
              "AWS/ApiGateway",
              "Latency",
              "ApiName",
              "${var.project_name}-${var.environment}-api",
              {
                stat   = "Average"
                period = 300
                label  = "API Latency"
              }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "API Gateway Metrics"
          period  = 300
        }
      }
    ]
  })
}

# CloudWatch Alarms for Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.lambda_functions

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This metric monitors ${each.key} lambda errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value.function_name
  }

  tags = var.tags
}

# CloudWatch Alarm for API Gateway 5XX Errors
resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = "${var.project_name}-${var.environment}-api"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# CloudWatch Log Retention Policy
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "API-Gateway-Execution-Logs_${var.api_gateway_id}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

data "aws_region" "current" {}

