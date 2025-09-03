# 🚀 Day 06 – Cron Job Setup on Nautilus App Servers

## 📖 Overview
The Nautilus system admins team has prepared scripts to automate daily tasks.  
Before deploying them fully, they want to test with a sample cron job.

This exercise covers:
- Installing **cronie** (cron service) on all app servers.
- Enabling and starting the cron daemon.
- Adding a **root-level cron job** that runs every 5 minutes.

---

## 📝 Task Requirements
1. Install the `cronie` package on all Nautilus app servers.
2. Ensure the `crond` service is **enabled** and **running**.
3. Configure the following cron job for the root user:
   ```bash
   ssh tony@app-server-1
   sudo yum install -y cronie
   sudo systemctl enable --now crond
   sudo systemctl status crond --no-pager
   ( sudo crontab -l 2>/dev/null; echo "*/5 * * * * echo hello > /tmp/cron_text" ) | sudo crontab -
   */5 * * * * echo hello > /tmp/cron_text
   sudo crontab -l
   cat /tmp/cron_text

