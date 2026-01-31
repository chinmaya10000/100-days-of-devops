# Jenkins on Amazon Linux 2023 — Installation & First Login

This README explains how to install Jenkins (LTS) on an Amazon Linux 2023 EC2 instance and how to perform the initial login / setup. It covers required packages, repository configuration, starting the service, opening connectivity (EC2 Security Group / firewall), and retrieving the initial admin password.

Tested assumptions:
- You have an Amazon Linux 2023 EC2 instance with a public IP or reachable private network.
- You have sudo (root) access on the instance.
- You will use the Jenkins default HTTP port 8080 for first-time setup.

Important: Always run the commands below as a user with sudo privileges.

---

## Contents
- Prerequisites
- Quick install (commands)
- Step-by-step explanation
- First login / initial setup
- Helpful commands & troubleshooting
- Optional: secure Jenkins with HTTPS
- Uninstalling Jenkins

---

## Prerequisites
- Amazon Linux 2023 with network access.
- Security Group / firewall must allow inbound TCP port 8080 from your IP (or network where you will access Jenkins).
- Java 11 or Java 17 (Jenkins supports both; this guide uses OpenJDK 17).

---

## Quick install (copy-paste)

Run these commands on the EC2 instance:

1. Update system and install Java 17:
```bash
sudo dnf update -y
sudo dnf install -y java-17-openjdk-devel
```

2. Add the official Jenkins repo and import the GPG key:
```bash
sudo curl -fsSL -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

3. Install Jenkins:
```bash
sudo dnf makecache
sudo dnf install -y jenkins
```

4. Start and enable Jenkins:
```bash
sudo systemctl enable --now jenkins
```

5. (If needed) Allow port 8080 through the host firewall (only if you run a firewall on the instance):
```bash
# If firewalld is installed & running:
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# If nftables/iptables is used, use appropriate rules or disable only for testing.
```

6. Retrieve the initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

7. Open your browser to:
```
http://<EC2_PUBLIC_IP_OR_DNS>:8080
```
Paste the password from step 6, then follow the on-screen setup (install suggested plugins and create the first admin user).

---

## Step-by-step explanation

1. Update packages and install Java
   - Jenkins requires Java 11+ (Java 17 recommended). Install OpenJDK 17:
   ```bash
   sudo dnf update -y
   sudo dnf install -y java-17-openjdk-devel
   ```
   - Confirm Java:
   ```bash
   java -version
   ```

2. Add Jenkins repository and import signing key
   - Add repo file:
   ```bash
   sudo curl -fsSL -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
   ```
   - Import key:
   ```bash
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
   ```

3. Install Jenkins and start service
   ```bash
   sudo dnf makecache
   sudo dnf install -y jenkins
   sudo systemctl daemon-reload
   sudo systemctl enable --now jenkins
   sudo systemctl status jenkins
   ```

4. Networking: EC2 Security Group and instance firewall
   - On AWS console, edit the EC2 instance's Security Group to allow inbound TCP 8080 from your IP:
     - Type: Custom TCP, Port: 8080, Source: your IP (or 0.0.0.0/0 for public access — NOT recommended).
   - If the instance runs a host firewall (firewalld), open the port as shown in the Quick install section.

5. Retrieve initial admin password and first-time web setup
   - The initial password is stored at:
   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
   - In browser, navigate to:
   ```
   http://<EC2_PUBLIC_IP_OR_DNS>:8080
   ```
   - Enter the initial password, choose "Install suggested plugins" (recommended) or select plugins manually, then create your first admin user.

---

## Helpful commands & troubleshooting

- Check Jenkins service status:
```bash
sudo systemctl status jenkins
```

- Follow Jenkins logs:
```bash
sudo journalctl -u jenkins -f
# or view the log file:
sudo less /var/log/jenkins/jenkins.log
```

- Confirm Jenkins is listening on port 8080:
```bash
sudo ss -lntp | grep 8080
```

- If initialAdminPassword file not found or empty:
  - Ensure Jenkins started successfully and has created its data directory:
  ```bash
  sudo ls -la /var/lib/jenkins/secrets
  sudo cat /var/lib/jenkins/secrets/initialAdminPassword
  ```
  - Check logs for errors (permissions, Java issues).

- Java version issues:
```bash
java -version
# If multiple Java versions installed, ensure JAVA_HOME points to Java 11/17, or remove conflicting versions.
```

- SELinux: Amazon Linux 2023 does not enable SELinux enforcing by default on official AMIs; if SELinux is enforced in your environment, ensure Jenkins has proper contexts for /var/lib/jenkins and /var/log/jenkins.

---

## Optional: Configure HTTPS (recommended for production)
A common approach is to put a reverse proxy (nginx) in front of Jenkins and terminate TLS there, or use a load balancer / AWS ALB with HTTPS. Example (brief overview):
1. Install nginx.
2. Configure nginx server block to proxy / to http://127.0.0.1:8080.
3. Obtain a TLS certificate (Let's Encrypt certbot or AWS Certificate Manager via ALB).
4. Redirect HTTP to HTTPS.

Note: If using nginx, set proxy headers required by Jenkins and increase proxy buffers if needed.

---

## Uninstall Jenkins
Remove package and optionally remove data:
```bash
sudo systemctl stop jenkins
sudo dnf remove -y jenkins
# Remove Jenkins data (WARNING: this deletes all Jenkins data):
sudo rm -rf /var/lib/jenkins /var/log/jenkins /var/cache/jenkins
```

---

## Security notes
- Do not open port 8080 to 0.0.0.0/0 in production unless you have additional access controls.
- Create a secure admin user during first login.
- Enable security settings in Jenkins (matrix-based security or roles using a plugin).
- Use HTTPS in production, and prefer an authenticated reverse proxy or AWS ALB with TLS.

---

If you want, I can:
- Provide a ready-to-run user-data script for launching an EC2 instance with Jenkins installed.
- Show an nginx reverse-proxy config for TLS + Jenkins.
- Walk you through plugin recommendations and configuring credentials / agents.
