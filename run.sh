#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/logs/limoojet.log"

mkdir -p "$SCRIPT_DIR/logs"

echo "[LimooJetCLI] Checking JetBackup installation..."

# 1. Check JetBackup version
if command -v jetbackup5 >/dev/null 2>&1; then
    JB_VERSION=$(jetbackup5 --version | awk '{print $2}')
    echo "[LimooJetCLI] JetBackup version detected: $JB_VERSION"
else
    echo "[ERROR] JetBackup5 is not installed or not in PATH." | tee -a "$LOG_FILE"
    exit 1
fi

# 2. Try to fetch JetBackup API Token and URL from known paths
# Example paths: these may vary depending on JetBackup installation

CONFIG_FILE="/usr/local/jetapps/etc/jetbackup5/config.json"

if [[ -f "$CONFIG_FILE" ]]; then
    JB_API_URL=$(grep -oP '(?<="PanelAPIURL": ")[^"]+' "$CONFIG_FILE")
    JB_TOKEN=$(grep -oP '(?<="AccessToken": ")[^"]+' "$CONFIG_FILE")
else
    echo "[ERROR] JetBackup config file not found: $CONFIG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

if [[ -z "$JB_API_URL" || -z "$JB_TOKEN" ]]; then
    echo "[ERROR] Could not extract API URL or Token from config." | tee -a "$LOG_FILE"
    exit 1
fi

# Confirm action
read -p "Are you sure you want to continue using JetBackup API at $JB_API_URL? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "[LimooJetCLI] Operation aborted." | tee -a "$LOG_FILE"
    exit 1
fi

# Run Python logic
python3 "$SCRIPT_DIR/jetbackup/main.py" "$JB_TOKEN" "$JB_API_URL" "$LOG_FILE"
