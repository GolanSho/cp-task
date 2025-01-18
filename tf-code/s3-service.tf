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
      name      = "cp-task-ecs-s3-td"
      image     = "${aws_ecr_repository.s3-image.repository_url}:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
  depends_on      = [aws_ecr_repository.s3-image]
}

resource "aws_ecs_service" "s3-service" {
  name            = "cp-task-push-s3-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.s3-task.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.svc-tg.arn
    container_name   = "cp-task-push-s3-container"
    container_port   = 5000
  }
  depends_on      = [aws_ecs_cluster.cluster, aws_ecs_task_definition.task, aws_lb_target_group.svc-tg, aws_lb.nlb]
}