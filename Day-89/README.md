# VSFTPD Deployment Using Ansible

## Objective
Automate installation and service management of `vsftpd` on all application servers in the Nautilus Stratos DC.

This repository contains:
- An example inventory layout
- A small idempotent playbook to install and manage the `vsftpd` service
- Guidance on running the playbook securely (avoid plaintext credentials)

---

## Prerequisites
- Control node: Ansible 2.9+ (newer is recommended)
- SSH access from the control node to all target hosts (prefer SSH key authentication)
- Sudo access (become) on target hosts for package/service management
- If you must use credentials, store them securely with Ansible Vault instead of plaintext in inventory

---

## Recommended Inventory (example)
Use groups so you can target application servers only. Do NOT commit any plaintext passwords.

Example file: `inventory` (INI format)
```ini
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony
stapp02 ansible_host=172.16.238.11 ansible_user=steve
stapp03 ansible_host=172.16.238.12 ansible_user=banner

# If you must store connection passwords, use Ansible Vault or use SSH key-based auth.
```

You can also use YAML inventories (hosts.yml) or an inventory directory layout as needed.

---

## Playbook (playbook.yml)
A small, idempotent playbook that installs vsftpd and ensures the service is enabled and running. It also demonstrates how to deploy a config template and notify a handler if config changes.

```yaml
---
- name: Install and configure vsftpd on app servers
  hosts: app_servers
  become: yes
  vars:
    vsftpd_package_name: vsftpd
    vsftpd_service_name: vsftpd

  tasks:
    - name: Install vsftpd package
      package:
        name: "{{ vsftpd_package_name }}"
        state: present
      tags: install

    - name: Deploy vsftpd configuration
      template:
        src: templates/vsftpd.conf.j2
        dest: /etc/vsftpd.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart vsftpd
      tags: config

    - name: Ensure vsftpd service is started and enabled
      service:
        name: "{{ vsftpd_service_name }}"
        state: started
        enabled: yes
      tags: service

  handlers:
    - name: restart vsftpd
      service:
        name: "{{ vsftpd_service_name }}"
        state: restarted
```

Notes:
- Use `template` to manage `/etc/vsftpd.conf` (do not leave default insecure settings).
- Handlers ensure the service restarts only when config files change.
- Use tags (`install`, `config`, `service`) to run subsets of tasks.

---

## Example template
Create `templates/vsftpd.conf.j2` and manage sensitive settings via variables or vault.

Example minimal content (templates/vsftpd.conf.j2):
```text
# Example vsftpd.conf - customize as needed
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
# additional secure settings...
```

---

## Securing Credentials
- Prefer SSH key authentication for Ansible connections.
- If you must use passwords, use Ansible Vault:
  - Create vault: `ansible-vault create group_vars/all/vault.yml`
  - Edit: `ansible-vault edit group_vars/all/vault.yml`
  - Run with: `ansible-playbook -i inventory playbook.yml --ask-vault-pass` or `--vault-id`

Do not store plaintext credentials in repository-controlled files.

---

## How to run the playbook
From your Ansible working directory (where `inventory` and `playbook.yml` reside):

- Dry run (no changes):
  ```bash
  ansible-playbook -i inventory playbook.yml --check --diff
  ```

- Normal run:
  ```bash
  ansible-playbook -i inventory playbook.yml
  ```

- If using Vault:
  ```bash
  ansible-playbook -i inventory playbook.yml --ask-vault-pass
  ```

- Limit to a host or subset:
  ```bash
  ansible-playbook -i inventory playbook.yml --limit stapp01
  ```

---

## Expected Results
- `vsftpd` package present on each target host
- `vsftpd` service running
- `vsftpd` enabled to start at boot
- Managed `/etc/vsftpd.conf` matching the deployed template

---

## Verification
On a target host (or use Ansible ad-hoc), verify service and package:

- Systemd status:
  ```bash
  sudo systemctl status vsftpd
  ```

- Check listening port (FTP default port 21):
  ```bash
  ss -ltnp | grep :21
  ```

- Verify package installed:
  Debian/Ubuntu:
  ```bash
  dpkg -l | grep vsftpd
  ```
  RHEL/CentOS:
  ```bash
  rpm -q vsftpd
  ```

- From control node, ad-hoc check:
  ```bash
  ansible -i inventory app_servers -m service -a "name=vsftpd state=started" --become
  ```

---

## Troubleshooting
- If connection errors occur, confirm SSH access and correct `ansible_user` / `ansible_host`.
- If authentication fails, ensure keys or vault credentials are correct.
- Inspect logs on target:
  ```bash
  sudo journalctl -u vsftpd -n 200
  sudo tail -n 200 /var/log/messages   # or /var/log/syslog on Debian/Ubuntu
  ```
- If package is unavailable, check target OS repositories or add appropriate package repositories.

---

## Security Considerations & Recommendations
- Disable anonymous FTP (anonymous_enable=NO).
- Use TLS/SSL for FTP if transmitting credentials; consider FTPS or SFTP instead of plain FTP.
- Limit user home directories and chroot as needed.
- Rotate and protect any secrets using Ansible Vault.
- Review `/etc/vsftpd.conf` carefully for insecure defaults.

---

## Extending the Playbook
- Add role structure (roles/vsftpd/tasks/main.yml, templates, handlers) for reuse.
- Add tests with Molecule for role-level testing.
- Add monitoring checks (Nagios/Prometheus exporters) to alert on service downtime.

---

