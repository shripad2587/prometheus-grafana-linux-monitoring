# prometheus-grafana-linux-monitoring
Linux Server Monitoring using Prometheus, Node Exporter and Grafana on AWS Platform


# 🚀 Linux Server Monitoring using Prometheus, Node Exporter & Grafana

**Author:** Shripad Desai

## 📌 Project Overview

This project demonstrates the implementation of a centralized Linux server monitoring solution using:

* AWS EC2
* Linux
* Prometheus
* Node Exporter
* Grafana

The monitoring environment consists of two Linux servers.

### Server 1 — Monitoring Server

* Prometheus
* Grafana
* Node Exporter

### Server 2 — Target Server

* Node Exporter

Prometheus collects infrastructure metrics from both Linux servers through Node Exporter, and Grafana visualizes the collected metrics through dashboards.

---

# 🏗️ Architecture

![Monitoring Architecture](architecture/monitoring-architecture.png)

### Monitoring Flow

```text
                    ┌─────────────────────────┐
                    │        Grafana          │
                    │        Port 3000        │
                    │     Visualization       │
                    └────────────┬────────────┘
                                 │
                                 │ PromQL
                                 ▼
                    ┌─────────────────────────┐
                    │       Prometheus        │
                    │        Port 9090        │
                    │    Metrics Collection   │
                    └────────────┬────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    │ Scrape /metrics         │ Scrape /metrics
                    ▼                         ▼
          ┌──────────────────┐       ┌──────────────────┐
          │    Server 1      │       │    Server 2      │
          │ Monitoring EC2   │       │ Target EC2       │
          │                  │       │                  │
          │ Node Exporter    │       │ Node Exporter    │
          │ Port 9100        │       │ Port 9100        │
          └──────────────────┘       └──────────────────┘
```

---

# 🔌 Ports

| Component     | Port | Server              |
| ------------- | ---: | ------------------- |
| Node Exporter | 9100 | Server 1 & Server 2 |
| Prometheus    | 9090 | Server 1            |
| Grafana       | 3000 | Server 1            |

For AWS EC2, Security Group rules must allow the required traffic.

For better security, allow port `9100` only from the Prometheus server rather than from `0.0.0.0/0`.

---

# 🛠️ Technologies Used

| Technology    | Purpose                       |
| ------------- | ----------------------------- |
| AWS EC2       | Compute infrastructure        |
| Linux         | Operating system              |
| Node Exporter | Exposes Linux system metrics  |
| Prometheus    | Collects and stores metrics   |
| Grafana       | Visualization and dashboards  |
| PromQL        | Query language for Prometheus |
| systemd       | Service management            |

---

# 📊 Metrics Monitored

The monitoring stack provides visibility into:

* CPU utilization
* Memory utilization
* Disk utilization
* Filesystem usage
* Network traffic
* System load
* Server uptime
* Node availability
* Filesystem statistics

---

# 🚀 Implementation

## Step 1 — Install Node Exporter on Server 1

Create the Node Exporter user:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
```

Download Node Exporter:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
```

Extract:

```bash
tar xvzf node_exporter-1.10.2.linux-amd64.tar.gz
```

Enter the directory:

```bash
cd node_exporter-1.10.2.linux-amd64
```

Copy the binary:

```bash
sudo cp node_exporter /usr/local/bin/
```

Create the systemd service:

```bash
sudo vi /etc/systemd/system/node_exporter.service
```

Use the service file available in:

```text
node-exporter/node-exporter.service
```

Start Node Exporter:

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

Verify:

```text
http://SERVER1-IP:9100/metrics
```

---

# Step 2 — Install Prometheus on Server 1

Download Prometheus:

```bash
wget https://github.com/prometheus/prometheus/releases/download/v3.10.0/prometheus-3.10.0.linux-amd64.tar.gz
```

Extract:

```bash
tar xvzf prometheus-3.10.0.linux-amd64.tar.gz
```

Enter the directory:

```bash
cd prometheus-3.10.0.linux-amd64
```

Copy the binaries:

```bash
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
```

Create the configuration directory:

```bash
sudo mkdir -p /etc/prometheus
```

Copy the configuration:

```bash
sudo cp prometheus.yml /etc/prometheus/
```

---

# Step 3 — Configure Prometheus

Edit:

```bash
sudo vi /etc/prometheus/prometheus.yml
```

Example configuration:

```yaml
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "node_exporter"
    static_configs:
      - targets:
          - "SERVER1-IP:9100"
          - "SERVER2-IP:9100"
```

Replace the IP addresses with the appropriate addresses for your environment.

### AWS Recommendation

If Server 1 and Server 2 are in the same VPC, prefer:

```text
Server1-private-IP:9100
Server2-private-IP:9100
```

This avoids unnecessarily exposing Node Exporter to the internet.

A public IP can be used when required, but the appropriate Security Group and routing configuration must be in place.

---

# Step 4 — Create Prometheus systemd Service

Create:

```bash
sudo vi /etc/systemd/system/prometheus.service
```

Use:

```text
prometheus/prometheus.service
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

Validate the configuration:

```bash
promtool check config /etc/prometheus/prometheus.yml
```

---

# Step 5 — Install Node Exporter on Server 2

Create the user:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
```

Download:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
```

Extract:

```bash
tar xvzf node_exporter-1.10.2.linux-amd64.tar.gz
```

Copy binary:

```bash
cd node_exporter-1.10.2.linux-amd64
sudo cp node_exporter /usr/local/bin/
```

Copy/use the service definition:

```text
node-exporter/node-exporter.service
```

Start:

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

Verify:

```text
http://SERVER2-IP:9100/metrics
```

---

# Step 6 — Add Server 2 to Prometheus

On Server 1:

```bash
sudo vi /etc/prometheus/prometheus.yml
```

Ensure Server 2 is present:

```yaml
- "SERVER2-IP:9100"
```

Restart:

```bash
sudo systemctl restart prometheus
```

Open:

```text
http://SERVER1-IP:9090
```

Navigate to:

```text
Status → Targets
```

Expected result:

```text
prometheus       UP
node_exporter    UP
```

Both Linux servers should show as `UP`.

---

# Step 7 — Install Grafana on Server 1

Install Grafana:

```bash
sudo yum install -y https://dl.grafana.com/grafana-enterprise/release/12.4.2/grafana-enterprise_12.4.2_23531306697_linux_amd64.rpm
```

Start:

```bash
sudo systemctl start grafana-server
```

Enable:

```bash
sudo systemctl enable grafana-server
```

Check:

```bash
sudo systemctl status grafana-server
```

Access:

```text
http://SERVER1-IP:3000
```

Use the credentials configured during the Grafana setup.

---

# Step 8 — Connect Grafana to Prometheus

Inside Grafana:

```text
Connections
        ↓
Data Sources
        ↓
Add Data Source
        ↓
Prometheus
```

Because Grafana and Prometheus are running on Server 1, use:

```text
http://localhost:9090
```

Then click:

```text
Save & Test
```

The connection should be successful.

### Important

Do not use the public IP unnecessarily for Grafana → Prometheus communication.

The flow is:

```text
Grafana
   ↓
localhost:9090
   ↓
Prometheus
```

---

# Step 9 — Import Grafana Dashboard

Go to:

```text
Dashboards
        ↓
Import
```

Enter dashboard ID:

```text
1860
```

Select the Prometheus data source.

The dashboard provides visualization for metrics such as:

* CPU
* Memory
* Disk
* Network
* Load
* Filesystem
* Uptime

---

# 🔍 Useful PromQL Queries

## CPU Utilization

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

## Memory Utilization

```promql
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

## Disk Utilization

```promql
100 * (1 - node_filesystem_avail_bytes / node_filesystem_size_bytes)
```

## Network Receive

```promql
rate(node_network_receive_bytes_total[5m])
```

## Network Transmit

```promql
rate(node_network_transmit_bytes_total[5m])
```

## Server Availability

```promql
up
```

Expected:

```text
1 = UP
0 = DOWN
```

---

# 🧪 Troubleshooting

## Prometheus target is DOWN

Check Node Exporter:

```bash
sudo systemctl status node_exporter
```

Check port:

```bash
sudo ss -lntp | grep 9100
```

Test locally:

```bash
curl http://localhost:9100/metrics
```

From Server 1 test Server 2:

```bash
curl http://SERVER2-IP:9100/metrics
```

Check AWS Security Group.

---

## Check Prometheus

```bash
sudo systemctl status prometheus
```

Check configuration:

```bash
promtool check config /etc/prometheus/prometheus.yml
```

Check logs:

```bash
sudo journalctl -u prometheus -f
```

---

## Check Grafana

```bash
sudo systemctl status grafana-server
```

Check logs:

```bash
sudo journalctl -u grafana-server -f
```

---

# 🔐 AWS Security Group Recommendations

Recommended inbound rules:

| Port | Source                  | Purpose       |
| ---: | ----------------------- | ------------- |
|   22 | Your IP                 | SSH           |
| 3000 | Your IP                 | Grafana       |
| 9090 | Your IP                 | Prometheus UI |
| 9100 | Server 1 Security Group | Node Exporter |

Avoid:

```text
0.0.0.0/0 → 9100
```

unless there is a specific requirement.

For production environments, restrict monitoring ports to trusted sources.

---

# 📸 Project Screenshots

Screenshots are included in the `screenshots/` directory.

### AWS Infrastructure

![AWS EC2](screenshots/01-aws-ec2.png)

### Node Exporter Metrics

![Node Exporter](screenshots/02-node-exporter-metrics.png)

### Prometheus Targets

![Prometheus Targets](screenshots/03-prometheus-targets.png)

### Prometheus Query

![Prometheus Query](screenshots/04-prometheus-query.png)

### Grafana Data Source

![Grafana Data Source](screenshots/05-grafana-datasource.png)

### Grafana Dashboard

![Grafana Dashboard](screenshots/06-grafana-dashboard.png)

---

# 📁 Repository Structure

```text
prometheus-grafana-linux-monitoring/
│
├── architecture/
│   └── monitoring-architecture.png
│
├── prometheus/
│   ├── prometheus.yml
│   └── prometheus.service
│
├── node-exporter/
│   └── node-exporter.service
│
├── grafana/
│   └── dashboard-notes.md
│
├── scripts/
│   ├── install-node-exporter.sh
│   ├── install-prometheus.sh
│   └── install-grafana.sh
│
├── screenshots/
│   ├── 01-aws-ec2.png
│   ├── 02-node-exporter-metrics.png
│   ├── 03-prometheus-targets.png
│   ├── 04-prometheus-query.png
│   ├── 05-grafana-datasource.png
│   └── 06-grafana-dashboard.png
│
├── docs/
│   ├── SOP.md
│   ├── troubleshooting.md
│   └── security-groups.md
│
└── README.md
```

---

# 🎯 Future Enhancements

The project can be extended with:

* Prometheus Alertmanager
* Email alerts
* Slack notifications
* CPU/Memory alerts
* Disk-space alerts
* Docker monitoring
* Kubernetes monitoring
* AWS CloudWatch integration
* Blackbox Exporter
* Grafana alerting
* Terraform infrastructure deployment

---

# 👨‍💻 Author

**Shripad Desai**

DevOps / Infrastructure Engineer

Technologies: AWS | Azure | Linux | Docker | Kubernetes | Terraform | Jenkins | Prometheus | Grafana

---

⭐ If you find this project useful, consider giving the repository a star.
