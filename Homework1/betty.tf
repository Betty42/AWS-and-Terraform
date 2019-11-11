##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}


##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

}

resource "aws_ebs_volume" "extra_disk1" {
  availability_zone = "us-east-1a"
  size              = 10
  type		    = "gp2"
  encrypted         = true


  tags = {
    Name = "extra_disk"
  }
}


resource "aws_ebs_volume" "extra_disk2" {
  availability_zone = "us-east-1a"
  size              = 10
  type              = "gp2"
  encrypted         = true


  tags = {
    Name = "extra_disk"
  }
}

resource "aws_security_group" "hw1_security_group" {
  name        = "terraform-instance1-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_volume_attachment" "ebs_att1" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_disk1.id
  instance_id = aws_instance.hw1_instance1.id
}

resource "aws_volume_attachment" "ebs_att2" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_disk2.id
  instance_id = aws_instance.hw1_instance2.id
}

resource "aws_instance" "hw1_instance1" {
  ami                    = "ami-024582e76075564db"
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.hw1_security_group.id]

  tags = {
     Owner       = "199379335378"
     Name        = "hw1_instance1"
     Purpose     = "Learning"
  }
 
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo service nginx start",
      "sudo sed -i 's/Welcome to nginx!/OpsSchool Rules/g' /var/www/html/index.nginx-debian.html"
    ]
  }
}
resource "aws_instance" "hw1_instance2" {
  ami                    = "ami-024582e76075564db"
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.hw1_security_group.id]

  tags = {
     Owner       = "199379335378"
     Name        = "hw1_instance2"
     Purpose     = "Learning"
  }
 
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)

  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo service nginx start",
      "sudo sed -i 's/Welcome to nginx!/OpsSchool Rules/g' /var/www/html/index.nginx-debian.html"
    ]
  }
}
