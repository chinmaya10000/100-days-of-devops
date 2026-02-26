# 🧰 Jenkins SSH Agent Node Setup (Java 17)

This guide explains how to configure the App Servers as SSH build agents (permanent nodes) for the Jenkins CI/CD server in the Stratos datacenter. It covers plugin installation, credentials, Java installation, directory preparation, and node configuration.

---

## 🔐 Jenkins Access

- Jenkins URL: [Jenkins Dashboard](http://jenkins.stratos.xfusioncorp.com)  
- Username: `admin`  
- Password: `Adm!n321`

> Note: These credentials were provided in the source content. Treat them as sensitive and rotate if this README becomes public.

---

## ⚙️ Jenkins Agent Configuration

Three application servers will be added as Jenkins SSH agents.

| Node Name      | Label    | Hostname                         | IP              | Remote Directory         | Username | Password |
|----------------|----------|----------------------------------|-----------------|--------------------------|----------|----------|
| App_server_1   | stapp01  | stapp01.stratos.xfusioncorp.com  | 172.16.238.10   | /home/tony/jenkins       | tony     | Ir0nM@n  |
| App_server_2   | stapp02  | stapp02.stratos.xfusioncorp.com  | 172.16.238.11   | /home/steve/jenkins      | steve    | Am3ric@  |
| App_server_3   | stapp03  | stapp03.stratos.xfusioncorp.com  | 172.16.238.12   | /home/banner/jenkins     | banner   | BigGr33n |

---

## Prerequisites

- Network connectivity (SSH) from the Jenkins controller to each app server IP.
- SSH user configured on each server with the credentials above.
- Sudo or sufficient permissions where needed on the app servers to install Java and create directories.
- Jenkins user with Manage Jenkins permissions.

---

## Step 1 — Install Required Plugin

1. Go to **Manage Jenkins → Manage Plugins → Available**.  
2. Search for and install **SSH Build Agents Plugin** (formerly “SSH Slaves”).  
3. After installation, choose **Restart Jenkins when installation is complete and no jobs are running**.  
4. Log back into Jenkins once it finishes restarting.

---

## Step 2 — Add SSH Credentials

1. Navigate to **Manage Jenkins → Credentials → System → Global credentials (unrestricted)**.  
2. Click **Add Credentials** and select **Username with password**.  
3. Enter the username and password for each app server (use the table above).  
4. Save each credential using an ID that matches its hostname/label, e.g. `stapp01`, `stapp02`, `stapp03`.

---

## Step 3 — Install Java 17 on App Servers

Jenkins agent requires Java to run the `agent.jar` agent process. Install OpenJDK 17 on each app server.

- CentOS / RHEL:
```bash
sudo yum install -y java-17-openjdk
```

- Ubuntu / Debian:
```bash
sudo apt update
sudo apt install -y openjdk-17-jre
```

- Verify:
```bash
java -version
# Expected output should show OpenJDK 17 or equivalent
```

---

## Step 4 — Prepare Remote Root Directory

Create Jenkins working directories on each app server and set ownership to the agent user:

```bash
# App Server 1
sudo mkdir -p /home/tony/jenkins
sudo chown tony:tony /home/tony/jenkins

# App Server 2
sudo mkdir -p /home/steve/jenkins
sudo chown steve:steve /home/steve/jenkins

# App Server 3
sudo mkdir -p /home/banner/jenkins
sudo chown banner:banner /home/banner/jenkins
```

Ensure the SSH user can read/write to the directory and execute the required agent processes.

---

## Step 5 — Add SSH Agent Nodes in Jenkins

1. In Jenkins: **Manage Jenkins → Manage Nodes and Clouds → New Node**.  
2. Choose **Permanent Agent**, give it a name, and configure fields as below.

Example configuration (App_server_1):

- Node Name: `App_server_1`  
- # of Executors: `1`  
- Remote root directory: `/home/tony/jenkins`  
- Labels: `stapp01`  
- Launch method: `Launch agents via SSH`  
- Host: `172.16.238.10`  
- Credentials: `stapp01` (the credential ID you created)  
- Host Key Verification Strategy: `Non verifying Verification Strategy`

Repeat for App_server_2 and App_server_3 with their respective values.

Security note: "Non verifying Verification Strategy" disables host key verification and is insecure. Prefer "Manually trusted key verification strategy" or upload the host keys to Jenkins if possible.

---

## Step 6 — Verify Connection

After saving, Jenkins will try to SSH to the node and start the agent. Check:

- Jenkins: **Manage Jenkins → Manage Nodes and Clouds → Nodes**
- Expected Status:

| Node         | Status |
|--------------|--------|
| App_server_1 | ✔ Online |
| App_server_2 | ✔ Online |
| App_server_3 | ✔ Online |

If a node remains offline, check:
- SSH connectivity from Jenkins server to node (ssh user@host).
- Credentials (username/password) and that the account is not locked.
- Java installation and `java -version`.
- File permissions on the remote directory.
- Firewall rules (port 22) and SELinux (if applicable).
- Jenkins master logs for agent connection errors.

---

## Step 7 — Test Job (Optional)

Create a test Freestyle job and restrict it to a specific label (e.g., `stapp01`).

Build step (Execute shell):
```bash
echo "Hello from $(hostname)"
```

Run the job and confirm it executes on the selected app server.

---

## Troubleshooting Tips

- Agent still failing to launch: check Jenkins logs (Manage Jenkins → System Log) and node-specific logs.
- Permission problems: ensure the remote root dir is owned by the agent user and has correct permissions.
- If SSH uses key-based auth instead of password, add the private key to Jenkins credentials (SSH Username with private key).
- Consider setting up a dedicated Jenkins agent user with limited permissions for better security.

---

## Security Recommendations

- Avoid using "Non verifying Verification Strategy" for host key verification in production.
- Prefer SSH key authentication over password-based credentials.
- Limit agent user privileges and use sudoers with minimal privileges if required.
- Store secrets in a secure vault and rotate passwords/keys regularly.

---
