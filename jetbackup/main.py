import sys
import time
import subprocess
import requests
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# --- Logging functions ---
def log_error(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] ERROR: {message}\n")

def log_info(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] INFO: {message}\n")

# --- Confirmation via remote script ---
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

# --- Entry point ---
if len(sys.argv) != 4:
    print("Usage: python3 main.py <API_TOKEN> <API_URL> <LOG_FILE>")
    sys.exit(1)

token = sys.argv[1]
api_url = sys.argv[2]
log_file = sys.argv[3]

# Ask for confirmation before continuing
if not bash_confirm():
    log_info(log_file, "Operation aborted before connecting to JetBackup.")
    sys.exit("[LimooJetCLI] Operation was cancelled or confirmation failed.")

# Prepare headers
headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

log_info(log_file, "Connecting to JetBackup API...")

try:
    response = requests.get(f"{api_url}/api/v1/backup_jobs", headers=headers, verify=False)
    if response.status_code == 200:
        data = response.json()
        log_info(log_file, "Successfully fetched backup jobs.")
        for job in data.get("data", []):
            print(f"[+] Job: {job['name']} (ID: {job['id']})")
    else:
        log_error(log_file, f"Failed to fetch jobs. Status: {response.status_code}, Body: {response.text}")
except Exception as e:
    log_error(log_file, f"Exception occurred: {str(e)}")
    print("[!] Could not connect to JetBackup API. Check the logs for more info.")
