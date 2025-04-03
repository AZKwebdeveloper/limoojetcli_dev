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
JB_VERSION=$(jetbackup5 -V 2>/dev/null | grep -oP '[0-9]+\\.[0-9]+\\.[0-9]+' || echo "Unknown")
echo "[LimooJetCLI] JetBackup version detected: $JB_VERSION"

# Ask for API credentials
read -p "Enter JetBackup API URL (e.g., https://yourserver:3030): " JB_API_URL
read -p "Enter JetBackup Access Token: " JB_TOKEN

# Confirm before running
read -p "Are you sure you want to continue using JetBackup API at $JB_API_URL? (y/n): " confirm
if [[ $confirm != "y" ]]; then
    echo "[LimooJetCLI] Operation aborted." | tee -a "$LOG_FILE"
    exit 1
fi

# Run Python logic
python3 "$BASE_DIR/jetbackup/main.py" "$JB_TOKEN" "$JB_API_URL" "$LOG_FILE"
