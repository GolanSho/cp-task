resource "aws_ecr_repository" "sqs-image" {
  name                 = "cp-task-send-sqs-image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "sqs-task" {
  family = "cp-task-ecs-sqs-td"
  container_definitions = jsonencode([
    {
      name      = "cp-task-send-sqs-container"
      image     = "${aws_ecr_repository.sqs-image.repository_url}:latest"
      cpu       = 5
      memory    = 264
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
  execution_role_arn = aws_iam_role.ecs-execution-role.arn

  depends_on      = [aws_ecr_repository.sqs-image]
}

resource "aws_ecs_service" "sqs-service" {
  name            = "cp-task-send-sqs-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.sqs-task.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.svc-tg.arn
    container_name   = "cp-task-send-sqs-container"
    container_port   = 5000
  }

  depends_on      = [aws_ecs_cluster.cluster, aws_ecs_task_definition.sqs-task, aws_lb_target_group.svc-tg, aws_lb.nlb]
}