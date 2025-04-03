#!/bin/bash

# Determine a stable working directory
if [[ "$0" == /dev/fd/* ]]; then
    BASE_DIR="/tmp/limoojetcli"
    mkdir -p "$BASE_DIR/logs"
else
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

LOG_FILE="$BASE_DIR/logs/limoojet.log"
echo "[LimooJetCLI] Checking JetBackup installation..."

# Check JetBackup version
if command -v jetbackup5 >/dev/null 2>&1; then
    JB_VERSION=$(jetbackup5 --version | awk '{print $2}')
    echo "[LimooJetCLI] JetBackup version detected: $JB_VERSION"
else
    echo "[ERROR] JetBackup5 is not installed or not in PATH." | tee -a "$LOG_FILE"
    exit 1
fi

# Updated: Correct config path
CONFIG_FILE="/usr/local/jetapps/etc/jetbackup5/config.inc"

if [[ -f "$CONFIG_FILE" ]]; then
    JB_API_URL=$(grep -oP '(?<=PanelAPIURL\":\s\")[^"]+' "$CONFIG_FILE")
    JB_TOKEN=$(grep -oP '(?<=AccessToken\":\s\")[^"]+' "$CONFIG_FILE")
else
    echo "[ERROR] JetBackup config file not found: $CONFIG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

if [[ -z "$JB_API_URL" || -z "$JB_TOKEN" ]]; then
    echo "[ERROR] Could not extract API URL or Token from config." | tee -a "$LOG_FILE"
    exit 1
fi

read -p "Are you sure you want to continue using JetBackup API at $JB_API_URL? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "[LimooJetCLI] Operation aborted." | tee -a "$LOG_FILE"
    exit 1
fi

python3 "$BASE_DIR/jetbackup/main.py" "$JB_TOKEN" "$JB_API_URL" "$LOG_FILE"
