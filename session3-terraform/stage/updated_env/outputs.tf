output "webservers_public_ips" {
    value = aws_instance.webserver.*.public_ip
}

output "dbs_private_ips" {
    value = aws_instance.DB.*.private_ip
}

output "elb_dns_name" {
    value = aws_elb.session3-elb.dns_name
}