output "subnet_cidr_block" {
  value = "${var.cidr_block}"
}

output "db_private_ip" {
  value = "${aws_instance.app.private_ip}"
}

# output "priv_ip" {
#   value = "${module.db-tier.aws_instance.app.private_ip}"
# }
