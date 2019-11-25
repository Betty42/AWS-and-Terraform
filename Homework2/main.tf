
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

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


# CREATE WEBSERVERS #

resource "aws_instance" "webserver" {
  count                  = 2
  ami                    = "ami-024582e76075564db"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.igw.id]
  subnet_id              = "${element(aws_subnet.public.*.id,count.index)}"
  associate_public_ip_address = true

  tags = {
    Name = "webserver-${count.index+1}"
  }
}

# CREATE DBS #

resource "aws_instance" "DB" {
  count                  = 2
  ami                    = "ami-024582e76075564db"
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.nat.id]
  subnet_id              = "${element(aws_subnet.private.*.id,count.index)}"
  associate_public_ip_address = true

  tags = {
    Name = "db-${count.index+1}"
  }
}

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

# INTERNET GW #

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = "${aws_vpc.session3vpc.id}"

  tags = {
    Name = "igw"
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

# SECURITY GROUPS #

resource "aws_security_group" "nat" {
    vpc_id = "${aws_vpc.session3vpc.id}"
    name = "sg_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "igw" {
    vpc_id = "${aws_vpc.session3vpc.id}"  
    name = "sg_igw"
    description = "Allow traffic to pass from the public subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
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
