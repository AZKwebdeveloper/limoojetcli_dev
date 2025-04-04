#!/bin/bash

LOG_DIR="/tmp/limoojetcli/logs"
LOG_FILE="$LOG_DIR/backup_job_log_$(date +'%Y%m%d_%H%M%S').log"

mkdir -p $LOG_DIR

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

FILTER_NAMES="database|full|email|jetbackup|config"

list_backup_jobs() {
    log_message "Fetching backup jobs from JetBackup API..."

    jetbackup5api -F listBackupJobs | awk -v filter="$FILTER_NAMES" '
        function tolower_str(str) {
            gsub(/[A-Z]/, "", str)  # dummy fallback if system lacks tolower()
            return tolower(str)
        }
        /_id:/ {
            gsub(/^[ \t]+/, "", $0)
            id=$2
        }
        /name:/ {
            full_line = $0
            gsub(/^[ \t]+/, "", full_line)
            name = $2
            for (i=3; i<=NF; i++) name = name " " $i

            name_lc = tolower(name)
            filter_lc = tolower(filter)

            if (name_lc ~ filter_lc) {
                print "---------------------------"
                printf "Name : %s\n", name
                printf "ID   : %s\n", id
                print "---------------------------"
            }
        }
    ' | tee -a "$LOG_FILE"
}

run_backup_job() {
    echo "Enter the Backup Job ID to run:"
    read JOB_ID

    if [[ -z "$JOB_ID" ]]; then
        echo "No ID entered. Operation cancelled."
        log_message "No job ID entered by admin."
        return
    fi

    echo "Are you sure you want to run backup job with ID: $JOB_ID ? [y/N]"
    read CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log_message "Running backup job ID: $JOB_ID"
        RESULT=$(jetbackup5api -F runBackupJobManually -D "_id=$JOB_ID")
        echo "$RESULT" >> "$LOG_FILE"
        
        if echo "$RESULT" | grep -q '"success": 1'; then
            echo -e "\n✅ Backup job executed successfully!"
        else
            echo -e "\n❌ Backup job execution may have failed. Check the log for details."
        fi
    else
        echo "Cancelled."
        log_message "Cancelled running job ID: $JOB_ID"
    fi
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
