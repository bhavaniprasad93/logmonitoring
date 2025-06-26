# 🔍 Log Monitoring Application

This is a lightweight Bash-based log monitoring application that reads a job log file, calculates the duration of each job, and generates a detailed performance report.

---

## 🚀 Features

- ✅ Parses a CSV log of job `START` and `END` events
- ⏱️ Calculates the duration (in MM:SS format) of each job
- ⚠️ Flags jobs that exceed thresholds:
  - **Warning** if > 5 minutes
  - **Error** if > 10 minutes
- 📄 Generates a human-readable report: `output_report.txt`

---

## 🗂️ Log File Format

The input file (`logs.log`) should follow this format:

HH:MM:SS, job description, START|END, PID
## Example:
11:35:23,scheduled task 032, START,37980
11:35:56,scheduled task 032, END,37980

## 💻 How to Run

### 1. Setup

- Make sure the log file named `logs.log` is present in the same folder as the script.
- The script will read from this file and generate `output_report.txt`.

### 2. Run the Script

```bash
bash log_monitor.sh
```
##📋Output
Job Report
===========
scheduled task 032 (37980): Duration 00:33 -- OK
scheduled task 051 (39547): Duration 11:29 -- ERROR: Job took more than 10 minutes
background job tqc (52532): Duration 13:53 -- ERROR: Job took more than 10 minutes
