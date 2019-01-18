###############################################################################
# PROVIDER
###############################################################################

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  region     = "${var.vpc_region}"
}

variable "key_name" {
  description = "Temporary app AWS key name"
  default = "midproj_key"
}

resource "tls_private_key" "midproj_private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.midproj_private.public_key_openssh}"

  depends_on = ["tls_private_key.midproj_private"]
}

##################################################################################
# RESOURCES
##################################################################################

### Network Elements ###
resource "aws_vpc" "ops_mid_proj" {
    cidr_block           = "10.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "vpc_ops_mid_proj"
        "Project" = "Opsschool_mid_project"
    }
}

resource "aws_subnet" "public_c" {
    vpc_id = "${aws_vpc.ops_mid_proj.id}"
    cidr_block = "10.10.3.0/24"
    availability_zone = "us-east-1c"
    map_public_ip_on_launch = false

    tags {
        "Name" = "public_c"
        "Project" = "Opsschool_mid_project"
    }
}

resource "aws_internet_gateway" "igw" {
   vpc_id = "${aws_vpc.ops_mid_proj.id}"
}

resource "aws_route_table" "local" {
    vpc_id     = "${aws_vpc.ops_mid_proj.id}"

    tags {
        "Name" = "localRouting"
        "Project" = "Opsschool_mid_project"
    }
}

resource "aws_route_table" "toIGW" {
    vpc_id     = "${aws_vpc.ops_mid_proj.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        "Name" = "routeToIGW"
        "Project" = "Opsschool_mid_project"
    }
}
resource "aws_route_table_association" "publicCtoIGW" {
    route_table_id = "${aws_route_table.toIGW.id}"
    subnet_id = "${aws_subnet.public_c.id}"
}
