import sys
import subprocess
import time

# --- Logging functions ---
def log_error(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] ERROR: {message}\n")

def log_info(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] INFO: {message}\n")

# --- Confirmation from remote script ---
def bash_confirm():
    try:
        ask_url = "https://raw.githubusercontent.com/AZKwebdeveloper/limoojetcli_dev/main/confirm/ask.sh"
        result = subprocess.run(
            ["bash", "-c", f"curl -s {ask_url} | bash"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=20
        )
        answer = result.stdout.strip().lower()
        if answer == "yes":
            return True
        elif answer == "no":
            print("[!] Operation cancelled by user choice.")
        else:
            print(f"[!] Invalid confirmation response: '{answer}'")
    except subprocess.TimeoutExpired:
        print("[!] Confirmation script timed out.")
    except Exception as e:
        print(f"[!] Failed to fetch and run confirmation script: {str(e)}")
    return False

# --- Run jetbackup5api command ---
def run_jetbackup5api(command, parameters=""):
    try:
        # Prepare the command
        cmd = f"jetbackup5api {command} {parameters}"
        print(f"[INFO] Running: {cmd}")
        
        result = subprocess.run(
            cmd, 
            shell=True, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            text=True
        )

        # Output the result
        if result.returncode == 0:
            return result.stdout.strip()
        else:
            log_error(log_file, result.stderr.strip())
            print(f"[ERROR] {result.stderr.strip()}")
            return None
    except Exception as e:
        log_error(log_file, f"Error running command {command}: {str(e)}")
        return None

# --- Entry point ---
if len(sys.argv) != 3:
    print("Usage: python3 main.py <API_URL> <LOG_FILE>")
    sys.exit(1)

api_url = sys.argv[1]
log_file = sys.argv[2]

# Ask for confirmation before continuing
if not bash_confirm():
    log_info(log_file, "Operation aborted before connecting to JetBackup.")
    sys.exit("[LimooJetCLI] Operation was cancelled or confirmation failed.")

# Log Info
log_info(log_file, "Connecting to JetBackup API...")

# 1. List Backup Jobs
backup_jobs = run_jetbackup5api("backup -F listBackupJobs")
if backup_jobs:
    print("\n=== Backup Jobs List ===\n")
    print(backup_jobs)
    log_info(log_file, "Successfully fetched list of backup jobs.")

# 2. Get Specific Backup Job Details (Example: Job ID = 1)
job_details = run_jetbackup5api("backup -F getBackupJob", "-D job_id=1")
if job_details:
    print("\n=== Backup Job Details ===\n")
    print(job_details)
    log_info(log_file, "Successfully fetched backup job details.")

# 3. Run a Backup Job Manually (Example: Job ID = 1)
run_job = run_jetbackup5api("backup -F runBackupJobManually", "-D job_id=1")
if run_job:
    print("\n=== Running Backup Job Manually ===\n")
    print(run_job)
    log_info(log_file, "Successfully ran backup job manually.")

# 4. Delete a Backup Job (Example: Job ID = 1)
delete_job = run_jetbackup5api("backup -F deleteBackupJob", "-D job_id=1")
if delete_job:
    print("\n=== Backup Job Deleted ===\n")
    print(delete_job)
    log_info(log_file, "Successfully deleted backup job.")
