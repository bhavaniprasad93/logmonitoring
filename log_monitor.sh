#!/bin/bash

# --------------------------------------------------------
# Log Monitoring Script
# --------------------------------------------------------
# This script reads a log file (logs.log), calculates the
# duration of jobs based on START and END timestamps,
# and generates a report flagging jobs that run too long.
# --------------------------------------------------------

LOG_FILE="logs.log"              # Input log file (CSV format)
OUTPUT_FILE="output_report.txt" # Output report to save results

# Step 1: Define associative arrays to store job info
declare -A start_times           # Maps PID to START time (in seconds)
declare -A end_times             # Maps PID to END time (in seconds)
declare -A job_names             # Maps PID to job description

# Step 2: Initialize the output report file
echo "Job Report" > "$OUTPUT_FILE"
echo "===========" >> "$OUTPUT_FILE"

echo "Reading log file: $LOG_FILE"
echo "Generating performance report..."
echo

# --------------------------------------------------------
# Function: Convert HH:MM:SS time to total seconds
# --------------------------------------------------------
time_to_seconds() {
    IFS=: read -r h m s <<< "$1"
    echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

# --------------------------------------------------------
# Read the log file and store START/END times
# --------------------------------------------------------
echo "Step 1: Parsing log entries..."

while IFS=',' read -r timestamp job_desc action pid; do
    timestamp=$(echo "$timestamp" | xargs)   # Remove leading/trailing spaces
    job_desc=$(echo "$job_desc" | xargs)
    action=$(echo "$action" | xargs)
    pid=$(echo "$pid" | xargs)

    if [[ "$action" == "START" ]]; then
        start_times["$pid"]="$(time_to_seconds "$timestamp")"
        job_names["$pid"]="$job_desc"
    elif [[ "$action" == "END" ]]; then
        end_times["$pid"]="$(time_to_seconds "$timestamp")"
    fi
done < "$LOG_FILE"

echo "Completed parsing log entries."
echo

# --------------------------------------------------------
# Match START and END, calculate duration
# --------------------------------------------------------
echo "Step 2: Calculating durations and checking thresholds..."

for pid in "${!end_times[@]}"; do
    if [[ -n "${start_times[$pid]}" ]]; then
        start="${start_times[$pid]}"
        end="${end_times[$pid]}"
        duration=$((end - start))  # Duration in seconds

        # Determine job status based on duration
        if (( duration > 600 )); then
            message="ERROR: Job took more than 10 minutes"
        elif (( duration > 300 )); then
            message="WARNING: Job took more than 5 minutes"
        else
            message="OK"
        fi

        # Convert seconds to MM:SS format
        mins=$((duration / 60))
        secs=$((duration % 60))

        # Append result to report
        printf "%s (%s): Duration %02d:%02d -- %s\n" \
            "${job_names[$pid]}" "$pid" "$mins" "$secs" "$message" >> "$OUTPUT_FILE"
    else
        echo "Missing START entry for PID $pid" >> "$OUTPUT_FILE"
    fi
done

echo
echo "✅ Processing complete!"
echo "📄 Output saved to: $OUTPUT_FILE"
