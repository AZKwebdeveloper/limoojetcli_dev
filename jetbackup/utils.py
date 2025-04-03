import sys
import time

def log_error(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] ERROR: {message}\n")

def log_info(log_file, message):
    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    with open(log_file, 'a') as log:
        log.write(f"[{timestamp}] INFO: {message}\n")

def confirm_action():
    answer = input("Are you sure you want to proceed? (y/n): ").lower()
    if answer != 'y':
        print("Action cancelled.")
        sys.exit(1)
