output "dummy_app" {
    description = "dummp_app"
    value = "${aws_instance.dummy_app.*.public_ip}"
}

output "Grafana" {
    description = "dummp_app"
    value = "${aws_instance.monitoring.public_ip}"
}

output "Kibana" {
    description = "dummp_app"
    value = "${aws_instance.elk_stack.public_ip}"
}

output "private_key" {
    value = "${tls_private_key.midproj_private.private_key_pem}"
}
