resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/deployguard-${var.environment}"
  retention_in_days = 7

  tags = {
    Name = "deployguard-${var.environment}-logs"
  }
}