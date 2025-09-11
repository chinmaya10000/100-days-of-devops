# Day12: Apache Not Reachable on Port 6300

## Task Overview
On `stapp01`, Apache was not reachable on port **6300**. The task was to troubleshoot and fix it, ensuring the service is reachable from the jump host without modifying `index.html`.

## Problems Identified
1. **Port Conflict**
   - Sendmail was using port 6300, preventing Apache from starting.
   - Command to check: `sudo netstat -tulnp | grep 6300`

2. **Firewall Block**
   - iptables had a default REJECT rule, blocking external access to port 6300.
   - Command to check: `sudo iptables -L -n`

## Fixes Applied
### Step 1: Free port 6300 and start Apache
```bash
sudo systemctl stop sendmail
sudo systemctl disable sendmail
sudo systemctl start httpd
sudo systemctl enable httpd


## Allow Apache traffic through iptables
### Step 2
```bash
sudo iptables -I INPUT -p tcp --dport 6300 -j ACCEPT
sudo iptables-save | sudo tee /etc/sysconfig/iptables
sudo systemctl restart iptables

## Test Connectivity
### Step 3
```bash
Locally: curl http://localhost:6300

From jump host: curl http://stapp01:6300