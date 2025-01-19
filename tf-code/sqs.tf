resource "aws_sqs_queue" "sqs_queue" {
  name = "cp-task-sqs"
	tags = {
    "terraform_managed"      = "yes"
  }

}
