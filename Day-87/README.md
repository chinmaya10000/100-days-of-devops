# Ansible Samba Installation Playbook

Overview
--------
This project automates installation of the `samba` package on all Nautilus application servers using Ansible. The playbook is designed to be executed from the jump host without extra CLI arguments when run from the playbook directory.

Repository layout
-----------------
/home/thor/playbook/
- inventory
- playbook.yml

Inventory file path: `/home/thor/playbook/inventory`  
Playbook file path: `/home/thor/playbook/playbook.yml`

Inventory (example)
-------------------
The current inventory contains host connection details. **Do not keep plain-text passwords in a repo.** Use Ansible Vault or SSH keys instead.

Example (already in repo):
```
[app_servers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=BigGr33n
```

Playbook (summary)
------------------
Path: `/home/thor/playbook/playbook.yml`

Purpose: Install the `samba` package on all hosts in the `app_servers` group.

Key snippet:
```yaml
- name: Install samba on all app servers
  hosts: app_servers
  become: yes
  tasks:
    - name: Install samba package
      yum:
        name: samba
        state: present
```

Prerequisites
-------------
- Ansible installed on the jump host.
- Network connectivity from the jump host to the target hosts.
- Valid credentials or SSH key access for the users specified in inventory.
- The user executing the playbook (e.g., `thor`) should have permission to read the playbook directory and run ansible-playbook.

How to run
----------
From the playbook directory:

1. Change into the directory:
   ```
   cd /home/thor/playbook
   ```

2. Execute the playbook with the included inventory:
   ```
   ansible-playbook -i inventory playbook.yml
   ```

Permissions
-----------
Set permissions so the playbook is runnable but sensitive files are restricted:

- Playbook and non-sensitive files: readable by group (e.g., 755 for directories, 644 for files).
- Inventory (contains secrets in your example): restrict to owner only:
  ```
  chmod 700 /home/thor/playbook
  chmod 600 /home/thor/playbook/inventory
  chmod 644 /home/thor/playbook/playbook.yml
  ```
- Ensure the executing user (thor) owns the files:
  ```
  chown -R thor:thor /home/thor/playbook
  ```

Security recommendations (important)
------------------------------------
- Do NOT store plaintext passwords in inventory. Use one of:
  - SSH key-based auth (preferred).
  - Ansible Vault to encrypt the inventory or variables:
    - Create a vault file:
      ```
      ansible-vault create group_vars/all/vault.yml
      ```
    - Or encrypt strings inline:
      ```
      ansible-vault encrypt_string 'Ir0nM@n' --name 'ansible_ssh_pass'
      ```
  - Use `ansible.cfg` and inventory plugins (like `aws_ec2`, `yaml` inventories) if applicable.
- Limit file permissions for any file containing secrets to 600 or 400.

Suggested improvements
----------------------
- Move host-specific secrets into `group_vars/` or `host_vars/` and encrypt with Ansible Vault.
- Use SSH keys and agent forwarding for better security and automation.
- Add `ansible.cfg` in the repo to set defaults (inventory path, remote_user, host_key_checking).
- Add idempotent verification tasks or a handler to restart services if needed.
- Add CI or linting (ansible-lint) for playbook quality checks.
- Consider using `package` module instead of `yum` for cross-distro compatibility (if you expand beyond RHEL/CentOS).

Verification / Troubleshooting
-----------------------------
- Verify connectivity / credentials:
  ```
  ansible -i inventory app_servers -m ping
  ```
- Check logs on failure; re-run with increased verbosity:
  ```
  ansible-playbook -i inventory playbook.yml -vvv
  ```
- If `yum` fails, confirm target hosts have proper repos and connectivity to package mirrors.
- If privilege escalation fails, ensure configured user can `become` and `sudo` is set up.

Expected result
---------------
After successful run, the `samba` package will be installed on all servers in the `app_servers` group. You can verify by running:
```
ansible -i inventory app_servers -a "rpm -q samba" --become
```
