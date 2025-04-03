#!/bin/bash

# Define paths
BASE_DIR="/tmp/limoojetcli"
JETBACKUP_DIR="$BASE_DIR/jetbackup"
LOG_DIR="$BASE_DIR/logs"
MAIN_PY="$JETBACKUP_DIR/main.py"

# Create necessary directories
mkdir -p "$JETBACKUP_DIR" "$LOG_DIR"

# GitHub raw URL for main.py
GITHUB_RAW_URL="https://raw.githubusercontent.com/AZKwebdeveloper/limoojetcli_dev/main/jetbackup/main.py"

# Download main.py if it doesn't exist
if [ ! -f "$MAIN_PY" ]; then
    echo "[INFO] Downloading main.py from GitHub..."
    curl -s -o "$MAIN_PY" "$GITHUB_RAW_URL"
    chmod +x "$MAIN_PY"
fi

# Run main.py with arguments
python3 "$MAIN_PY" "$@"
