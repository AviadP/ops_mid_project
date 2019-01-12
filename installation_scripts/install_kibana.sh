#!/bin/bash

wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-amd64.deb
shasum -a 512 kibana-6.5.4-amd64.deb
sudo dpkg -i kibana-6.5.4-amd64.deb

sudo systemctl start kibana.service
