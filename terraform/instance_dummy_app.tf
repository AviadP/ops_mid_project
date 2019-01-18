resource "aws_instance" "dummy_app" {
    count = 2
    ami = "${var.ami_id}"
    availability_zone = "${var.vpc_name}"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.public_c.id}"
    vpc_security_group_ids = ["${aws_security_group.general_sg.id}"]
    associate_public_ip_address = true
    user_data = "${file("./installation_scripts/install_docker.sh")}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }

  tags {
        "Name" = "Dummp_app-${count.index+1}"
        "Project" = "Opsschool_mid_project"
}
}