71. # Jenkins Automation – Package Installation Job

## 📘 Overview
This Jenkins job automates the installation of software packages on the **Nautilus Storage Server (`ststor01.stratos.xfusioncorp.com`)**.  
It uses a **parameterized Jenkins job** that connects via SSH to the remote server and installs the package specified by the user.

---

## 🧩 Infrastructure Details

| Server Name | Hostname | User | Password | Purpose |
|--------------|-----------|------|-----------|----------|
| **jenkins** | jenkins.stratos.xfusioncorp.com | jenkins | j@rv!s | Jenkins CI/CD Server |
| **ststor01** | ststor01.stratos.xfusioncorp.com | natasha | Bl@kW | Nautilus Storage Server |

---

## ⚙️ Jenkins Job Configuration

### **Job Name:** `install-packages`

### **Job Type:** Freestyle Project

### **Parameters:**
- **Parameter Type:** String Parameter  
- **Name:** `PACKAGE`  
- **Description:** Name of the package to install on the storage server.  
- **Example Value:** `httpd`, `tree`, `git`, etc.

---

## 🧠 Build Step

### **Build Step Type:** Execute Shell

```bash
ssh -o StrictHostKeyChecking=no natasha@ststor01.stratos.xfusioncorp.com "sudo yum install -y $PACKAGE || sudo apt-get install -y $PACKAGE"
This command:

Connects to the storage server over SSH.

Installs the specified package using yum or apt-get, depending on OS type.

Runs non-interactively (no password prompts).

🔑 Pre-Requisites
SSH Key Setup

Generate an SSH key on the Jenkins server (if not already existing):

bash
Copy code
ssh-keygen -t rsa -b 4096
Copy it to the storage server:

bash
Copy code
ssh-copy-id natasha@ststor01.stratos.xfusioncorp.com
Passwordless Sudo Access

On the storage server, edit the sudoers file:

bash
Copy code
sudo visudo
Add this line:

sql
Copy code
natasha ALL=(ALL) NOPASSWD: ALL
Jenkins Permissions

Jenkins must run as user jenkins with SSH access to the remote host.

🚀 Usage
From Jenkins Dashboard → Select job install-packages.

Click Build with Parameters.

Enter a package name in the PACKAGE field (e.g., httpd, vim, git).

Click Build.

Check Console Output for installation logs and success message.