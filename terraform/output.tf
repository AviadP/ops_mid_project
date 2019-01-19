output "private_key" {
    value = "${tls_private_key.midproj_private.private_key_pem}"
}

output "Grafana" {
    value = "${aws_instance.monitoring.public_ip}"
}

output "Kibana" {
    value = "${aws_instance.elk_stack.public_ip}"
}
output "consul" {
    value = "${aws_instance.consul_srv.public_ip}"
}


