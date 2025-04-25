#!/bin/bash

# Amazon Linux 2 CIS Benchmark Audit with HTML Report
# By: [Your Name/Org] | For internal use

set -e

AUDIT_DIR="/var/tmp/AMAZON2-CIS-Audit"
HTML_REPORT="/var/tmp/amazon2_cis_report.html"

echo "[+] Updating system..."
sudo yum update -y

echo "[+] Enabling EPEL and installing dependencies..."
sudo amazon-linux-extras enable epel
sudo yum install -y epel-release
sudo yum install -y ansible git curl unzip

echo "[+] Installing goss..."
curl -fsSL https://goss.rocks/install | sudo GOSS_DST=/usr/local/bin sh
sudo chmod +x /usr/local/bin/goss

echo "[+] Cloning CIS Audit repo..."
if [ ! -d "$AUDIT_DIR" ]; then
    git clone https://github.com/ansible-lockdown/AMAZON2-CIS-Audit.git "$AUDIT_DIR"
else
    echo "[*] Repo already exists."
fi

cd "$AUDIT_DIR"

echo "[+] Ensuring goss.yml is present..."
if [ ! -f "goss.yml" ]; then
    curl -o goss.yml https://raw.githubusercontent.com/ansible-lockdown/AMAZON2-CIS-Audit/main/goss.yml
fi

echo "[+] Running Goss tests..."
/usr/local/bin/goss -g goss.yml render > rendered-goss.yml
/usr/local/bin/goss -g rendered-goss.yml validate --format documentation > "$HTML_REPORT"

echo "[✓] HTML report generated at: $HTML_REPORT"
