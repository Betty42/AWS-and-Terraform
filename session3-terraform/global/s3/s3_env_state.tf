# create the s3 backend resource #

resource "aws_s3_bucket" "session3state" {
  bucket = "betty-tf-session3-bucket"

  versioning {
    enabled = true
  }


  tags = {
    Name = "session 3 state bucket"
  }
}


# modules #


