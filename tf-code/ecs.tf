
resource "aws_ecs_cluster" "cluster" {
  name               = "cp-task-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_launch_template" "ecs" {

  name = "cp-task-ecs-lt"

  image_id = "ami-0ff8a91507f77f867"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  ebs_optimized = false

  user_data = base64encode("echo ECS_CLUSTER='test-cluster' > /etc/ecs/ecs.config")

}

resource "aws_autoscaling_group" "ecs-cluster" {
    name                 = "cp-task-ecs-asg"
    min_size             ="1"
    max_size             = "2"
    desired_capacity     = "1"
    health_check_type    = "EC2"
                launch_template                  {
                        id = aws_launch_template.ecs.id
                        version = "$Latest"
                }
    vpc_zone_identifier  = [data.aws_subnets.public.id]
    tag{
        key = "Name"
        value = "cp-task-ecs-ltstance"
        propagate_at_launch = true
    }
  depends_on      = [aws_launch_template.ecs, data.aws_subnets.public]
}

resource "aws_ecs_capacity_provider" "ec2_provider" {
  name = "cp-task-ec2-prov"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-cluster.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
  depends_on      = [aws_autoscaling_group.ecs-cluster]
}
