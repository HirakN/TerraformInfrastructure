output "subnet_cidr_block" {
  value = "${var.cidr_block}"
}

output "db_private_ip" {
  value = "${aws_instance.app.private_ip}"
}

output "app_id" {
  value = "${aws_instance.app.id}"
}

output "sub_id" {
  value = "${aws_subnet.app-hirak.id}"
}

output "sec_id" {
  value = "${aws_security_group.app-hirak.id}"
}
# output "priv_ip" {
#   value = "${module.db-tier.aws_instance.app.private_ip}"
# }
