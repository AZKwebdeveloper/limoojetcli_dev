import sys
import requests
from jetbackup.utils import log_error, log_info, confirm_action

if len(sys.argv) != 4:
    print("Usage: python3 main.py <API_TOKEN> <API_URL> <LOG_FILE>")
    sys.exit(1)

token = sys.argv[1]
api_url = sys.argv[2]
log_file = sys.argv[3]

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

log_info(log_file, "Connecting to JetBackup API...")
confirm_action()

try:
    response = requests.get(f"{api_url}/api/v1/backup_jobs", headers=headers)
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
