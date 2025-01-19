resource "aws_ecr_repository" "s3-image" {
  name                 = "cp-task-push-s3-image"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "s3-task" {
  family = "cp-task-ecs-s3-td"
  container_definitions = jsonencode([
    {
      name      = "cp-task-push-s3-container"
      image     = "${aws_ecr_repository.s3-image.repository_url}:latest"
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

  depends_on      = [aws_ecr_repository.s3-image]
}

resource "aws_ecs_service" "s3-service" {
  name            = "cp-task-push-s3-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.s3-task.arn
  desired_count   = 1
  
  depends_on      = [aws_ecs_cluster.cluster, aws_ecs_task_definition.s3-task]
}