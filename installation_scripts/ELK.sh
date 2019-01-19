#!/usr/bin/env bash

# install elasticsearch
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

#install kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-amd64.deb
shasum -a 512 kibana-6.5.4-amd64.deb
sudo dpkg -i kibana-6.5.4-amd64.deb

cat << EOF >/etc/kibana/kibana.yml
server.name: kibana
server.host: "0.0.0.0"
EOF

sudo systemctl stop kibana.service
sudo systemctl start kibana.service


# install logstash
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
sudo apt-get install apt-transport-https -y
sudo apt-get update && apt-get install logstash -y

sudo systemctl start logstash.service

#install consul

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -qq update &>/dev/null
sudo apt-get -yqq install unzip &>/dev/null

echo "Fetching Consul..."
cd /tmp
wget -O consul.zip https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# Setup Consul
sudo mkdir -p /opt/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /run/consul
sudo tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "midproj",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=Name tag_value=consul_srv"],
  "enable_script_checks": true,
  "server": false
}
EOF

# Create user & grant ownership of folders
sudo useradd consul
sudo chown -R consul:consul /opt/consul /etc/consul.d /run/consul


# Configure consul service
sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target
[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -config-dir /etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service

#register to consul
cat << EOCSU >/etc/consul.d/kibana.json
{"service": {
    "name": "kibana",
    "tags": ["kibana"],
    "port": 5601,
    "check": {
        "http": "http://localhost:5601",
        "interval": "10s"
        }
    }
}
EOCSU
