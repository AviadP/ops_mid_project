########### Security Group ##################
resource "aws_security_group" "general_sg" {
    name        = "GeneralSG"
    description = "default VPC security group"
    vpc_id      = "${aws_vpc.ops_mid_proj.id}"

### Consul http port ###
    ingress {
        from_port       = 8500
        to_port         = 8500
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

### SSH port #######
  ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

### Kibana port ###
  ingress {
        from_port       = 5601
        to_port         = 5601
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
### Grafana port ###
  ingress {
        from_port       = 3000
        to_port         = 3000
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = []
        self            = true
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

}