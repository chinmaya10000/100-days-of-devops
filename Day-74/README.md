# 🧠 Jenkins Automated Database Backup Job

This document describes how the `database-backup` Jenkins job automates periodic backups of the **kodekloud_db01** database and stores them safely on the Backup Server.

---

## 🚀 Overview

The Jenkins job `database-backup` performs the following operations automatically:

1. Connects to the **Database Server (`stdb01`)** using SSH.
2. Takes a database dump of `kodekloud_db01` using `mysqldump`.
3. Transfers the dump file to the **Jenkins Server**.
4. Copies the dump from Jenkins to the **Backup Server (`stbkp01`)**.
5. Cleans up temporary files on both servers.
6. Runs automatically every 10 minutes (`*/10 * * * *`).

---

## 🧩 Infrastructure Details

| Server Name | IP | Hostname | User | Purpose |
|-------------|----|----------|------|---------|
| **stdb01**  | 172.16.239.10 | stdb01.stratos.xfusioncorp.com | peter   | Database Server |
| **stbkp01** | 172.16.238.16 | stbkp01.stratos.xfusioncorp.com | clint   | Backup Server |
| **jenkins** | 172.16.238.19 | jenkins.stratos.xfusioncorp.com | jenkins | Jenkins CI/CD Server |

**Database credentials**
- **DB Name:** `kodekloud_db01`  
- **User:** `kodekloud_roy`  
- **Password:** `asdfgdsd`

---

## ⚙️ Jenkins Job Configuration

### Job Name
`database-backup`

### Project Type
Freestyle Project

### Build Trigger (Schedule)
```
*/10 * * * *
```
Runs every 10 minutes.

### Build Step – Execute Shell

```bash
#!/bin/bash
set -euo pipefail

DB_USER="kodekloud_roy"
DB_PASS="asdfgdsd"
DB_NAME="kodekloud_db01"
DATE_STR="$(date +%F)"
BACKUP_FILE="db_${DATE_STR}.sql"

# Hosts and users
DB_HOST="172.16.239.10"        # stdb01
DB_SSH_USER="peter"

BKP_HOST="172.16.238.16"       # stbkp01
BKP_SSH_USER="clint"
BKP_PATH="/home/clint/db_backups"

REMOTE_TMP="/tmp/${BACKUP_FILE}"
LOCAL_TMP="/tmp/${BACKUP_FILE}"

echo "Starting DB dump: ${BACKUP_FILE} at $(date)"

# Step 1: Create dump on DB server
ssh -o BatchMode=yes ${DB_SSH_USER}@${DB_HOST} "mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${REMOTE_TMP}"

# Step 2: Copy dump to Jenkins
scp ${DB_SSH_USER}@${DB_HOST}:${REMOTE_TMP} ${LOCAL_TMP}

# Step 3: Copy dump to Backup Server
scp ${LOCAL_TMP} ${BKP_SSH_USER}@${BKP_HOST}:${BKP_PATH}/

# Step 4: Cleanup
ssh ${DB_SSH_USER}@${DB_HOST} "rm -f ${REMOTE_TMP}"
rm -f ${LOCAL_TMP}

echo "Backup ${BACKUP_FILE} transferred to ${BKP_HOST}:${BKP_PATH} at $(date)"
```

---

## 🔑 SSH Configuration

Jenkins uses SSH key-based authentication for secure, passwordless access.

Generate SSH key on Jenkins host:
```bash
sudo -i -u jenkins ssh-keygen -t rsa
```

Copy Jenkins public key to DB and Backup servers:
```bash
ssh-copy-id peter@172.16.239.10
ssh-copy-id clint@172.16.238.16
```

Verify connectivity:
```bash
ssh peter@172.16.239.10 whoami
ssh clint@172.16.238.16 whoami
```

---

## 🧪 Validation Steps

1. Manual Trigger  
   From Jenkins UI → Job `database-backup` → Click "Build Now".

2. Check Console Output  
   Console should show something like:
   ```
   Starting DB dump...
   Backup db_YYYY-MM-DD.sql transferred to 172.16.238.16:/home/clint/db_backups
   Finished: SUCCESS
   ```

3. Verify Backup File on Backup Server
```bash
ssh clint@172.16.238.16
ls -lh /home/clint/db_backups/
```
You should see:
```
db_2025-11-12.sql
```

4. Verify Schedule  
   Jenkins → Job → Build History should show a new build every 10 minutes.

---

## 🛠️ Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| mysqldump: command not found | MySQL client not installed on DB server | Install `mariadb-client` or `mysql-client` |
| Host key verification failed | Missing `known_hosts` entry | Use `ssh-keyscan` to add host keys or run a first-time manual `ssh` to accept the host key |
| Permission denied (publickey) | SSH key not copied correctly | Re-run `ssh-copy-id` and verify `~/.ssh/authorized_keys` on target |
| Dump not visible on backup server | Wrong IP / folder permissions | Confirm IP and `/home/clint/db_backups` ownership and permissions |

---

## 📁 Backup Location

- Remote Path: `/home/clint/db_backups/`
- File Format: `db_YYYY-MM-DD.sql`
- Retention: Handled externally (can integrate cleanup policy if needed)

---

If you'd like, I can:
- Add a rotation/retention step to the Jenkins job to keep only N recent backups,
- Harden the script (e.g., using temporary filenames, compression, encryption, and secure handling of DB credentials),
- Convert this to a Pipeline job (Jenkinsfile) for better auditing and versioning.