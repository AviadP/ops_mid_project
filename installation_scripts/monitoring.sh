#!/usr/bin/env bash

# install prometheus
PROMETHEUS_VERSION="2.2.1"
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar -xzvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64/

# create user
useradd --no-create-home --shell /bin/false prometheus

# create directories
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus

# set ownership
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# copy binaries
cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# copy config
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus/prometheus.yml

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# setup systemd
echo '[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/prometheus.service

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# config prometheus.yml
cat << EOF >/etc/prometheus/prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s
rule_files:
  # - "first.rules"
  # - "second.rules"
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ['prometheus.service.consul:9090']
  - job_name: "dummy_exporter"
    consul_sd_configs:
      - server: "prometheus.service.consul:8500"
        services: ['dummy']
    relabel_configs:
      - source_labels: ['__meta_consul_service']
        regex: "(.*)"
        target_label: "job"
        replacement: $1
      - source_labels: ['__meta_consul_node']
        regex: "(.*)"
        target_label: "instance"
        replacement: $1
EOF

systemctl restart prometheus

# install Grafana
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.5.4-amd64.deb
shasum -a 512 kibana-6.5.4-amd64.deb
sudo dpkg -i kibana-6.5.4-amd64.deb

IP_ADDR=$(hostname -I | awk '{ print $1 }')
sed -i 's|#server.host: "localhost"|server.host: '"$IP_ADDR"'|g' /etc/kibana/kibana.yml

# add datasource to Grafana

# add Dashboard to Grafana

sudo systemctl stop kibana.service
sudo systemctl start kibana.service


