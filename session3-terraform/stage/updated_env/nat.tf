# CREATE EIP #

resource "aws_eip" "nat_eip" {
  count      = 2
  vpc        = true
}


# NAT GW #

resource "aws_nat_gateway" "nat_gw" {
  count         = "${length(var.public_subnets_cidr)}"
  allocation_id = "${element(aws_eip.nat_eip.*.id,count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id,count.index)}"
  depends_on    = ["aws_internet_gateway.internet-gw", "aws_subnet.public"]

  tags = {
    Name = "gw NAT"
  }
}