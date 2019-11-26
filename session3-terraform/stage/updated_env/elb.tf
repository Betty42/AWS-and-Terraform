# create elb #

resource "aws_elb" "session3-elb" {
  name               = "session3-elb"
  subnets = "${aws_subnet.public.*.id}"
  security_groups = ["${aws_security_group.igw.id}"]

  instances                   = "${aws_instance.webservers.*.id}"
  cross_zone_load_balancing   = true
  idle_timeout                = 100
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "terraform-elb"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

resource "aws_lb_cookie_stickiness_policy" "stickyelb" {
  name                     = "stickyelb"
  load_balancer            = "${aws_elb.session3-elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 60
}