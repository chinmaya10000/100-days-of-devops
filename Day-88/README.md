# Ansible Playbook — Install and Configure HTTPD on App Servers

This repository contains a simple Ansible playbook that installs and configures an HTTPD (Apache) web server on application servers and deploys a sample HTML page.

Location
- /home/thor/ansible

Files
- inventory — Ansible inventory file listing the app servers
- playbook.yml — Main Ansible playbook to install and configure httpd

Purpose
- Install the `httpd` package
- Ensure the `httpd` service is started and enabled
- Deploy a sample `/var/www/html/index.html` using `blockinfile`
- Set appropriate ownership and permissions for the file

Requirements
- Ansible installed on the jump host
- SSH access to the target application servers
- Sudo privileges for the remote user (the playbook uses `become: yes`)
- Correct inventory configuration

Playbook overview
- Installs `httpd` (Apache)
- Starts and enables the `httpd` service
- Creates or updates `/var/www/html/index.html` with sample content
- Ensures file owner/group `apache:apache` and permissions `0644`

How to run
1. Change to the playbook directory:
```bash
cd /home/thor/ansible
```

2. Run the playbook:
```bash
ansible-playbook -i inventory playbook.yml
```

Example inventory (inventory)
```
[appservers]
app1 ansible_host=192.0.2.10 ansible_user=thor
app2 ansible_host=192.0.2.11 ansible_user=thor
```

Example playbook (playbook.yml)
```yaml
---
- name: Install and configure httpd on all app servers
  hosts: all
  become: yes

  tasks:
    - name: Install httpd package
      yum:
        name: httpd
        state: present

    - name: Ensure httpd service is started and enabled
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Add sample content to index.html
      blockinfile:
        path: /var/www/html/index.html
        create: yes
        block: |
          Welcome to XfusionCorp!

          This is  Nautilus sample file, created using Ansible!

          Please do not modify this file manually!

    - name: Set proper ownership for index.html
      file:
        path: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0644'
```

Verification
- After the playbook completes successfully, open a browser and navigate to:
```
http://<server-ip>/
```
- You should see the sample page content:
```
Welcome to XfusionCorp!

This is  Nautilus sample file, created using Ansible!

Please do not modify this file manually!
```

Troubleshooting
- Permission denied / SSH errors:
  - Verify SSH access and correct `ansible_user` in the inventory.
  - Ensure your SSH key is available to the jump host and authorized on targets.

- Package manager errors on non-RHEL systems:
  - This playbook uses `yum` (RHEL/CentOS/Amazon Linux). For Debian/Ubuntu, replace `yum` with `apt` and adjust package names/service names as needed.

- Service fails to start:
  - Check `journalctl -u httpd` or `/var/log/httpd/error_log` on the target host.
  - Confirm SELinux or firewall rules are not blocking HTTP (port 80).

Notes
- The playbook uses `become: yes` — ensure the configured `ansible_user` has sudo privileges.
- The playbook sets file ownership to `apache:apache`, which is the common user/group for httpd on RHEL-family systems. Adjust if your distro uses a different user (e.g., `www-data` on Debian/Ubuntu).

License
- Use and modify as you need. No warranty implied.

Maintainer
- Prepared for use in the Stratos DC app servers deployment.

```