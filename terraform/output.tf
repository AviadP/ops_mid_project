output "dummy_app_private_ip" {
    description = "dummp_app"
    value = "${aws_instance.dummy_app.*.private_ip}"
}

output "private_key" {
    value = "${tls_private_key.midproj_private.private_key_pem}"
}
