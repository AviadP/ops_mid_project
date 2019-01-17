#!/bin/bash

sudo apt-get update
sudo apt-get install openjdk-8-jre-headless -y
sudo apt-get install openjdk-8-jdk-headless -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get install apt-transport-https -y
sudo apt-get update && apt-get install logstash -y

sudo systemctl start logstash.service
