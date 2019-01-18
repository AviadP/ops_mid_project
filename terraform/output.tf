output "dummy_app" {
    value = "${aws_instance.dummy_app.*.public_ip}"
}

output "Grafana" {
    value = "${aws_instance.monitoring.public_ip}"
}

output "Kibana" {
    value = "${aws_instance.elk_stack.public_ip}"
}

output "private_key" {
    value = "${tls_private_key.midproj_private.private_key_pem}"
}
