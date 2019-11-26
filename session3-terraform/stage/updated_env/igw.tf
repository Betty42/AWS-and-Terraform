# INTERNET GW #

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = "${aws_vpc.session3vpc.id}"

  tags = {
    Name = "igw"
  }
}