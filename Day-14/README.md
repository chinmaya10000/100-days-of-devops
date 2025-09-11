# Day 14: Apache Service Setup on App Servers

## Objective
Ensure that **Apache (httpd)** is installed, running, and listening on **port 8088** on all application servers in the Stratos DC.

---

## Steps Taken

### 1. Identify the App Servers
Example servers in Stratos DC:

- `stapp01`
- `stapp02`
- `stapp03`

---

### 2. Check Apache Status
```bash
sudo systemctl status httpd   # RHEL/CentOS
sudo systemctl status apache2 # Ubuntu/Debian

### 3. Resolve Port Conflicts
```bash
sudo ss -tulpn | grep 8088
# Stop Sendmail if not needed
sudo systemctl stop sendmail
sudo systemctl disable sendmail

### 4. Start and Enable Apache
```bash
sudo systemctl start httpd   # RHEL/CentOS
sudo systemctl enable httpd  # RHEL/CentOS


### 5. Verify Apache is Running on Port 8088
```bash
sudo ss -tulpn | grep httpd

### 6. Test locally:
```bash
curl http://localhost:8088
```