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

# Load balancer inti
resource "aws_elb" "load" {
  name               = "Hirak-LB"
  subnets            = ["${module.app-tier.sub_id}"]
  security_groups    = ["${module.app-tier.sec_id}"]
  # availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    # "${PROTOCOL}:${PORT}${PATH}"
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${module.app-tier.app_id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "Hirak-LB"
  }
}

module "app-tier" {
  instance_count = 2
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
  instance_count = 1
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