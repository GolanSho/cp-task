resource "aws_s3_bucket" "cp-task-s3" {
  bucket = "cp-task-s3-bucket"
  versioning {
    enabled = false
  }
}