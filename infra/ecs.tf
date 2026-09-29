resource "aws_ecs_cluster" "main" {
  name = "deployguard-${var.environment}"

  tags = {
    Name = "deployguard-${var.environment}-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "deployguard-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "deployguard"
      image     = "${aws_ecr_repository.app.repository_url}:v1"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "APP_VERSION"
          value = "v1"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "deployguard"
        }
      }
    }
  ])

  tags = {
    Name = "deployguard-${var.environment}-task"
  }
}