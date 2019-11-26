
resource "aws_iam_role" "webserver_iam_role" {
  name = "webserver_iam_role"

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

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "webserver_iam_profile" {
  name = "webserver_iam_profile"
  role = "${aws_iam_role.webserver_iam_role.name}"
}

resource "aws_iam_role_policy" "webserver_iam_policy" {
  name = "webserver_iam_policy"
  role = "${aws_iam_role.webserver_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "*"
            ]
    }
  ]
}
EOF
}