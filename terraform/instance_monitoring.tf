resource "aws_instance" "monitoring" {
    ami = "${var.ami_id}"
    availability_zone = "us-east-1c"
    instance_type = "${var.instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.public_c.id}"
    vpc_security_group_ids = ["${aws_security_group.general_sg.id}"]
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.consul-join.name}"
    user_data = "${file("../installation_scripts/monitoring.sh")}"


    root_block_device {
      volume_type = "gp2"
      volume_size = 8
      delete_on_termination = true
    }

    provisioner "local-exec" {
        command = "echo ${self.id}"
    }

    tags {
          "Name" = "monitoring"
          "Project" = "Opsschool_mid_project"
    }
}
