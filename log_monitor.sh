#!/bin/bash

LOG_FILE="logs.log"
TEMP_FILE=$(mktemp)
declare -A start_times
declare -A job_names

echo "Job Report" > output_report.txt
echo "===========" >> output_report.txt

# Convert HH:MM:SS to seconds since midnight
time_to_seconds() {
    IFS=: read -r h m s <<< "$1"
    echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

# Read log line by line
while IFS=',' read -r timestamp job_desc action pid; do
    timestamp=$(echo "$timestamp" | xargs)
    job_desc=$(echo "$job_desc" | xargs)
    action=$(echo "$action" | xargs)
    pid=$(echo "$pid" | xargs)

    if [[ "$action" == "START" ]]; then
        start_times["$pid"]="$(time_to_seconds "$timestamp")"
        job_names["$pid"]="$job_desc"
    elif [[ "$action" == "END" ]]; then
        if [[ -n "${start_times[$pid]}" ]]; then
            end_time=$(time_to_seconds "$timestamp")
            start_time="${start_times[$pid]}"
            duration=$((end_time - start_time))
            message="OK"
            if (( duration > 600 )); then
                message="ERROR: Job took more than 10 minutes"
            elif (( duration > 300 )); then
                message="WARNING: Job took more than 5 minutes"
            fi
            mins=$((duration / 60))
            secs=$((duration % 60))
            printf "%s (%s): Duration %02d:%02d -- %s\n" "${job_names[$pid]}" "$pid" "$mins" "$secs" "$message" >> output_report.txt
        else
            echo "Missing START entry for PID $pid" >> output_report.txt
        fi
    fi
done < "$LOG_FILE"

echo "Processing complete. See output_report.txt"
