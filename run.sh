#!/bin/bash

# Define working directory
if [[ "$0" == /dev/fd/* ]]; then
    BASE_DIR="/tmp/limoojetcli"
    mkdir -p "$BASE_DIR/logs"
else
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

LOG_FILE="$BASE_DIR/logs/limoojet.log"
mkdir -p "$(dirname "$LOG_FILE")"

echo "[LimooJetCLI] Checking JetBackup CLI..."

# Get JetBackup version
JB_VERSION=$(jetbackup5 -V 2>/dev/null | grep -oP '[0-9]+\.[0-9]+\.[0-9]+' || echo "Unknown")
echo "[LimooJetCLI] JetBackup version detected: $JB_VERSION"

# Detect control panel and define JB_API_URL
SERVER_IP=$(hostname -I | awk '{print $1}')
if systemctl is-active --quiet cpanel; then
    JB_API_URL="https://$SERVER_IP:2087/cgi/addons/jetbackup5/api.cgi"
    echo "[LimooJetCLI] Detected cPanel. Using API URL: $JB_API_URL"
elif systemctl is-active --quiet directadmin; then
    JB_API_URL="https://$SERVER_IP:2222/CMD_PLUGINS_ADMIN/jetbackup5/index.raw?api=1"
    echo "[LimooJetCLI] Detected DirectAdmin. Using API URL: $JB_API_URL"
else
    JB_API_URL="http://127.0.0.1:3030"
    echo "[LimooJetCLI] No control panel detected. Using default standalone API URL: $JB_API_URL"
fi

# Ask for token only
read -p "Enter JetBackup Access Token: " JB_TOKEN

# Confirm
read -p "Use API at $JB_API_URL with provided token. Continue? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "[LimooJetCLI] Operation aborted." | tee -a "$LOG_FILE"
    exit 1
fi

# Run Python logic
python3 "$BASE_DIR/jetbackup/main.py" "$JB_TOKEN" "$JB_API_URL" "$LOG_FILE"
