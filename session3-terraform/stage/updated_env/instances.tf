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
      "sudo sed -i 's/Welcome to nginx!/OpsSchool Rules!/g' /var/www/html/index.nginx-debian.html"
    ]
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