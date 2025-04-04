#!/bin/bash

LOG_DIR="/tmp/limoojetcli/logs"
LOG_FILE="$LOG_DIR/backup_job_log_$(date +'%Y%m%d_%H%M%S').log"

mkdir -p $LOG_DIR

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

list_backup_jobs() {
    log_message "Fetching backup jobs from JetBackup API..."
    jetbackup5api -F listBackupJobs | jq '.[] | {id: ._id, name: .name}' >> $LOG_FILE
    jetbackup5api -F listBackupJobs | jq '.[] | {id: ._id, name: .name}'
}

run_backup_job() {
    echo "Enter the backup job ID to run:"
    read JOB_ID
    log_message "Running backup job ID: $JOB_ID"
    jetbackup5api -F runBackupJobManually -D "_id={$JOB_ID}" >> $LOG_FILE
}

main_menu() {
    echo "JetBackup Job Manager"
    echo "1. List all backup jobs"
    echo "2. Run a backup job"
    echo "3. Exit"

    read -p "Please choose an option (1-3): " OPTION
    case $OPTION in
        1)
            list_backup_jobs
            cat $LOG_FILE
            main_menu
            ;;
        2)
            run_backup_job
            main_menu
            ;;
        3)
            log_message "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose 1, 2, or 3."
            main_menu
            ;;
    esac
}

log_message "Script started"
main_menu
