# Troubleshooting Guide

## 1. Prometheus Target Shows DOWN

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

From Prometheus Server:

```bash
curl http://SERVER2-IP:9100/metrics
```

If the curl request fails, check:

* Node Exporter service
* Security Group
* Linux firewall
* Routing
* Correct IP address
* Port 9100

---

## 2. AWS Security Group

Node Exporter should preferably allow traffic only from the Prometheus server.

Example:

```text
Inbound TCP 9100
Source: Prometheus Server Security Group
```

Avoid exposing:

```text
TCP 9100 → 0.0.0.0/0
```

---

## 3. Prometheus Configuration Error

Run:

```bash
promtool check config /etc/prometheus/prometheus.yml
```

Check service:

```bash
sudo systemctl status prometheus
```

Check logs:

```bash
sudo journalctl -u prometheus -f
```

---

## 4. Grafana Cannot Connect to Prometheus

If both are installed on Server 1, use:

```text
http://localhost:9090
```

Test:

```bash
curl http://localhost:9090/-/healthy
```

Expected:

```text
Prometheus is Healthy.
```

---

## 5. Grafana Dashboard Shows No Data

Check the Prometheus data source.

Then verify:

```promql
up
```

Expected:

```text
1
```

Also check that the dashboard is using the correct Prometheus data source.

---

## 6. Public IP vs Private IP

If both EC2 instances are inside the same VPC, private IP communication is generally preferred.

Example:

```text
Prometheus
    |
    | Private VPC network
    |
    +---- Server1:9100
    |
    +---- Server2:9100
```

Using public IPs introduces unnecessary internet-facing exposure and may require additional networking/security configuration.

---

# Conclusion

The most common causes of monitoring issues are:

1. Node Exporter not running
2. Port 9100 blocked
3. Incorrect IP address
4. Security Group configuration
5. Prometheus configuration errors
6. Grafana connected to the wrong Prometheus endpoint
