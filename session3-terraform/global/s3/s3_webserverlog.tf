# the bucket resource #


resource "aws_s3_bucket" "webserver_logs_bucket" {
  bucket = "betty-tf-session3-bucket"

  tags = {
    Name = "webserver_logs"
  }
}