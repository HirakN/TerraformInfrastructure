variable "vpc_id" {
  description = "The VPC id to launch the tiered architecture into"
}

variable "cidr_block" {
  description = "The CIDR block of the tier subnet"
}

variable "name" {
  description = "name to be used for tagging instances"
}

variable "user_data" {
  description = "user data to supply to the instance"
}

variable "route_table_id" {
  description = "id of route table to associate with the subnet"
}

variable "ami_id" {
  description = "The ID of the AMI to spin up in the subnet"
}

variable "public_ip" {
  default = false
  description = "true/false for assignment of public IP"
}

variable "instance_count" {
  description = "Number of EC2 instances to launch"
}

variable "ingress" {
  type = "list"
}