provider "aws" {
  region="eu-central-1"
}

resource "aws_vpc" "hirak-vpc" {
  cidr_block = "10.99.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "hirak-vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.hirak-vpc.id}"

  tags {
    Name = "hirak-ig"
  }
}

resource "aws_route_table" "public-hirak" {
  vpc_id = "${aws_vpc.hirak-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "hirak-rt"
  }
}

data "template_file" "app_init" {
  template = "${file("./scripts/app_user_data.sh")}"

  vars {
    priv = "${module.db-tier.db_private_ip}" 
  }
}

module "app-tier" {
  name = "app-hirak"
  source = "./modules/tier/"
  vpc_id = "${aws_vpc.hirak-vpc.id}" 
  route_table_id = "${aws_route_table.public-hirak.id}"
  cidr_block = "10.99.0.0/24"
  user_data = "${data.template_file.app_init.rendered}"
  ami_id = "ami-c4c3a7ab"
  public_ip = true

  ingress = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }]
}

module "db-tier" {
  name = "db-hirak"
  source = "./modules/tier/"
  vpc_id = "${aws_vpc.hirak-vpc.id}" 
  # Default route table fetch
  route_table_id = "${aws_vpc.hirak-vpc.main_route_table_id}"
  cidr_block = "10.99.1.0/24"
  user_data = ""
  ami_id = "ami-93cda9fc"

  ingress = [{
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = "${module.app-tier.subnet_cidr_block}"
  }]
}