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
      - targets: ['localhost:9090']
  - job_name: "dummy_exporter"
    consul_sd_configs:
      - server: "127.0.0.1:8500"
        services: ['exporter']
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
sudo apt-get update
sudo apt install -y libfontconfig
wget https://dl.grafana.com/oss/release/grafana_5.4.2_amd64.deb
sudo dpkg -i grafana_5.4.2_amd64.deb

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service

# add datasource to Grafana
cat << EOF >/etc/grafana/provisioning/datasources/datasource.yaml
apiVersion: 1
datasources:
 - name: Prometheus
   type: prometheus
   orgId: 1
   url: http://localhost:9090
   access: proxy
   version: 1
   editable: false
   isDefault: true
EOF

# add Dashboard to Grafana
cat << EOF > /etc/grafana/provisioning/dashboards/dashboards.yaml
apiVersion: 1
providers:
 - name: 'default'
   orgId: 1
   folder: ''
   type: file
   options:
     path: "/var/lib/grafana/dashboards"
EOF

# create dashboard
mkdir -p /var/lib/grafana/dashboards/
cat << EOF >/var/lib/grafana/dashboards/grafana_dashboad.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 2,
  "links": [],
  "panels": [
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fill": 1,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 4,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "percentage": false,
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "rate(DummyService_errors[1m])",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Errors Rate",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": "Prometheus",
      "fill": 1,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 9
      },
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "percentage": false,
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "expr": "rate(DummyService_requests[1m])",
          "format": "time_series",
          "intervalFactor": 1,
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "Requests rate",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "refresh": "5s",
  "schemaVersion": 16,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now/d",
    "to": "now/d"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "",
  "title": "midproj_dashboard",
  "uid": "OgX4mPQiz",
  "version": 2
}
EOF

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
cat << EOCSU >/etc/consul.d/prometheus.json
{"service": {
    "name": "prometheus",
    "tags": ["prometheus", "metrics"],
    "port": 9090,
    "check": {
        "http": "http://localhost:9090",
        "interval": "10s"
        }
    }
}
EOCSU



