#!/usr/bin/env python3
import os
import subprocess
import sys
from datetime import datetime

LOG_DIR = "/tmp/limoojetcli/logs/"
LOG_FILE = os.path.join(LOG_DIR, "limoojet.log")


def log(message):
    os.makedirs(LOG_DIR, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as log_file:
        log_file.write(f"[{timestamp}] {message}\n")
    print(message)


def list_backup_jobs():
    log("Listing backup jobs...")
    try:
        result = subprocess.run(
            ["jetbackup5api", "backup", "-F", "listBackupJobs"],
            capture_output=True, text=True, check=True
        )
        log("Backup jobs retrieved successfully.")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        log(f"Error listing backup jobs: {e.stderr}")


def run_backup_job(job_id):
    log(f"Attempting to run backup job with ID: {job_id}")
    confirm = input(f"Are you sure you want to run backup job ID {job_id}? [y/N]: ").strip().lower()
    if confirm != 'y':
        log("Operation canceled by user.")
        return
    try:
        result = subprocess.run(
            ["jetbackup5api", "backup", "-F", "runBackupJobManually", "-D", f"job_id={job_id}"],
            capture_output=True, text=True, check=True
        )
        log(f"Backup job {job_id} started successfully.")
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        log(f"Error running backup job {job_id}: {e.stderr}")


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 main.py list")
        print("  python3 main.py run <job_id>")
        return

    command = sys.argv[1]

    if command == "list":
        list_backup_jobs()
    elif command == "run" and len(sys.argv) == 3:
        run_backup_job(sys.argv[2])
    else:
        print("Invalid command or missing job_id.")


if __name__ == "__main__":
    main()
