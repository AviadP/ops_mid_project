#!/bin/bash

sudo apt-get update
apt-get install openjdk-8-jre-headless -y
apt-get install openjdk-8-jdk-headless -y

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.deb
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.deb.sha512
shasum -a 512 -c elasticsearch-6.5.4.deb.sha512
sudo dpkg -i elasticsearch-6.5.4.deb

sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service

sudo systemctl start elasticsearch.service

