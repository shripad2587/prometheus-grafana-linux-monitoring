```bash
#!/bin/bash

set -e

VERSION="1.10.2"
ARCH="linux-amd64"

echo "Installing Node Exporter ${VERSION}..."

if ! id node_exporter >/dev/null 2>&1; then
    sudo useradd \
        --no-create-home \
        --shell /bin/false \
        node_exporter
fi

cd /tmp

wget -q \
"https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${ARCH}.tar.gz"

tar -xzf "node_exporter-${VERSION}.${ARCH}.tar.gz"

sudo cp \
"node_exporter-${VERSION}.${ARCH}/node_exporter" \
/usr/local/bin/node_exporter

sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo cp node-exporter.service \
/etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo
echo "Node Exporter status:"
sudo systemctl --no-pager status node_exporter

echo
echo "Node Exporter metrics:"
curl -s http://localhost:9100/metrics | head
```
