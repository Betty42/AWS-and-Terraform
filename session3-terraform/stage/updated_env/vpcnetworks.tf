##################################################################################
# RESOURCES
##################################################################################

# VPC #

resource "aws_vpc" "session3vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = "true" #gives you an internal host name
    
  tags = {
    Name = "session3vpc"
  }
}

# PUBLIC SUBNETS #

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets_cidr)}"
  vpc_id = "${aws_vpc.session3vpc.id}"
  cidr_block = "${element(var.public_subnets_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  
  tags = {
    Name = "PUBSubnet-${count.index+1}"
  }
}

# PRIVATE SUBNETS #

resource "aws_subnet" "private" {
  count = "${length(var.private_subnets_cidr)}"
  vpc_id = "${aws_vpc.session3vpc.id}"
  cidr_block = "${element(var.private_subnets_cidr,count.index)}"
  availability_zone = "${element(var.azs,count.index)}"
  tags = {
    Name = "PRIVSubnet-${count.index+1}"
  }
}


# PRIVATE ROUTE TABLE #

resource "aws_route_table" "private_route_table" {
    count  = 2
    vpc_id = "${aws_vpc.session3vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${element(aws_nat_gateway.nat_gw.*.id,count.index)}"
    }
    tags = {
        Name = "Private route table-${count.index+1}"
    }
}
 
resource "aws_route_table_association" "pr_subnet" {
  count = "${length(var.private_subnets_cidr)}"
  subnet_id = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id,count.index)}"
}


# PUBLIC ROUTE TABLES #

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.session3vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.internet-gw.id}"
  }

  tags = {
        Name = "Public_route_table"
  }
}

resource "aws_route_table_association" "pub_subnet" {
  count = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}