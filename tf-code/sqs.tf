resource "aws_sqs_queue" "sqs_queue" {
  name = "cp-task-sqs"
	tags = {
    "terraform_managed"      = "yes"
  }

}

resource "aws_sqs_queue_policy" "sqs_policy" {
  count = 0
  queue_url = aws_sqs_queue.sqs_queue.id
  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::chkp-aws-rnd-avanan-candi-jh-temp:user/candidate-user"
      },
      "Action": "SQS:*",
      "Resource": "arn:aws:sqs:us-east-1:chkp-aws-rnd-avanan-candi-jh-temp:${aws_sqs_queue.sqs_queue.name}"
    }
  ]
}
POLICY
  depends_on = [
    aws_sqs_queue.sqs_queue
  ]
}
