resource "aws_sns_topic" "alerts" {
  name = "deployguard-${var.environment}-alerts"

  tags = {
    Name = "deployguard-${var.environment}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_target" {
  alarm_name        = "deployguard-${var.environment}-unhealthy-target"
  alarm_description = "Triggers when the DeployGuard ALB detects an unhealthy ECS target"
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  tags = {
    Name = "deployguard-${var.environment}-unhealthy-target"
  }
}

resource "aws_cloudwatch_metric_alarm" "target_5xx_errors" {
  alarm_name        = "deployguard-${var.environment}-target-5xx-errors"
  alarm_description = "Triggers when the DeployGuard application returns multiple 5xx errors"
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  tags = {
    Name = "deployguard-${var.environment}-target-5xx-errors"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name        = "deployguard-${var.environment}-high-cpu"
  alarm_description = "Triggers when the DeployGuard ECS service has sustained high CPU usage"
  alarm_actions     = [aws_sns_topic.alerts.arn]
  ok_actions        = [aws_sns_topic.alerts.arn]

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 3

  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  tags = {
    Name = "deployguard-${var.environment}-high-cpu"
  }
}


resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "deployguard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "ECS CPU and memory utilization"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.app.name,
              {
                label = "CPU"
              }
            ],
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.app.name,
              {
                label = "Memory"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "ALB requests and application 5xx errors"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 300
          stat    = "Sum"

          yAxis = {
            left = {
              min = 0
            }
          }

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              {
                label = "Requests"
              }
            ],
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              {
                label = "Application 5xx errors"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "ALB target health"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 60

          yAxis = {
            left = {
              min = 0
            }
          }

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              {
                label = "Healthy targets"
                stat  = "Average"
              }
            ],
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              {
                label = "Unhealthy targets"
                stat  = "Maximum"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "Application response time"
          region  = var.aws_region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"

          yAxis = {
            left = {
              min = 0
            }
          }

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.app.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.app.arn_suffix,
              {
                label = "Average response time"
              }
            ]
          ]
        }
      }
    ]
  })
}