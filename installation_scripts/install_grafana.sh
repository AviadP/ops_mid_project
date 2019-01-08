#!/bin/bash
sudo apt-get update
sudo apt install -y libfontconfig
wget https://dl.grafana.com/oss/release/grafana_5.4.2_amd64.deb
sudo dpkg -i grafana_5.4.2_amd64.deb

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
