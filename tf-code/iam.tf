resource "aws_iam_role" "ecs-role" {
  name               = "ecs-role"
	path = "/ecs/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance-profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs-role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role = aws_iam_role.ecs-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_param" {
  role = aws_iam_role.ecs-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "sqs_full" {
  role = aws_iam_role.ecs-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full" {
  role = aws_iam_role.ecs-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role = aws_iam_role.ecs-role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# # ECS Execution Role

resource "aws_iam_role" "ecs-execution-role" {
  name               = "ecs-execution-role"
        path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
  role = aws_iam_role.ecs-execution-role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_role-ecs" {
  role = aws_iam_role.ecs-execution-role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}
