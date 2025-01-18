data "aws_vpc" "default" {
  default = true
}

# data "aws_subnet" "public" {
#   vpc_id = data.aws_vpc.default.id
#}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "nlb" {
  name               = "cp-task-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.public.*.id

  enable_deletion_protection = false

  depends_on      = [data.aws_subnets.public]
}

resource "aws_lb_target_group" "svc-tg" {
  name     = "cp-task-lb-tg"
  port     = 5000
  protocol = "TCP"
  vpc_id   = data.aws_vpc.default.id
  depends_on      = [data.aws_vpc.default]
}

resource "aws_lb_listener" "nlb-service" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 5000
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.svc-tg.arn
  }
  depends_on      = [aws_lb.nlb, aws_lb_target_group.svc-tg]
}