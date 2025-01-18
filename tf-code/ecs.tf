data "aws_ami" "latest_ecs" {
 most_recent = true

owners = ["amazon"]
 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
     name = "virtualization-type"
     values = [
       "hvm"]
   }

 filter {
   name   = "name"
   values = ["amzn2-ami-ecs-hvm-*-x86_64-*"]
 }
}

resource "aws_ecs_cluster" "cluster" {
  name               = "cp-task-ecs-cluster"
  capacity_providers = [aws_ecs_capacity_provider.ec2_provider.name]
  # default_capacity_provider_strategy {
  #   capacity_provider = aws_ecs_capacity_provider.ec2_provider.name
  #   weight            = 1
  #   base              = 0
  # }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-sg"
  description = "ecs-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "TCP 5000"
    from_port   = 5000
    to_port     = 5000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ecs" {

  name = "cp-task-ecs-lt"

  image_id = data.aws_ami.latest_ecs.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  ebs_optimized = false
  iam_instance_profile {
    name = aws_iam_instance_profile.instance-profile.name
  }
  vpc_security_group_ids = [aws_security_group.ecs_security_group.id]

  user_data = base64encode(<<EOF
  #!/bin/bash
  echo ECS_CLUSTER='cp-task-ecs-cluster' > /etc/ecs/ecs.config
  EOF
  )
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
  vpc_zone_identifier  = [data.aws_subnets.public.ids[0],data.aws_subnets.public.ids[1],data.aws_subnets.public.ids[2]]
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
