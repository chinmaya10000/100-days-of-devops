# Day 10 – Website Backup Automation

## 📌 Task Overview
The production support team required a **bash script** to automate website backups.  
The script should create a compressed backup of the official website, store it locally, and copy it to the **Nautilus Backup Server** without asking for a password.

---

## 🛠️ Requirements
- **Script Name:** `/scripts/official_backup.sh`
- **Source Directory:** `/var/www/html/official`
- **Local Backup Directory:** `/backup/`
- **Remote Backup Directory:** `/backup/` on Nautilus Backup Server
- **Backup File Name:** `xfusioncorp_official.zip`
- Must run as the respective server user (`tony` on App Server 1).
- No `sudo` usage inside the script.
- Passwordless SSH should be configured between App Server 1 and Backup Server.
- `zip` package must be installed manually before running the script.

---

## 📂 Script Logic
1. Create a zip archive of `/var/www/html/official`.
2. Save the archive under `/backup/` on App Server 1.
3. Copy the archive to `/backup/` on Nautilus Backup Server.
4. Ensure the script runs non-interactively (no password prompt).

---

## 🚀 Script Example
```bash
#!/bin/bash

# Variables
SRC_DIR="/var/www/html/official"
BACKUP_DIR="/backup"
BACKUP_FILE="xfusioncorp_official.zip"
DEST_USER="clint"
DEST_HOST="stbkp01"
DEST_DIR="/backup"

# Create zip archive
zip -r ${BACKUP_DIR}/${BACKUP_FILE} ${SRC_DIR}

# Copy to Nautilus Backup Server
scp ${BACKUP_DIR}/${BACKUP_FILE} ${DEST_USER}@${DEST_HOST}:${DEST_DIR}/
