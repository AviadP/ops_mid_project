#!/bin/bash

wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-amd64.deb
shasum -a 512 kibana-6.5.4-amd64.deb
sudo dpkg -i kibana-6.5.4-amd64.deb

IP_ADDR="$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
sed -i 's|#server.host: "localhost"|server.host: '"$IP_ADDR"'|g' /etc/config/kibana.yml

sudo systemctl stop kibana.service
sudo systemctl start kibana.service
