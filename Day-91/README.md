# Nautilus httpd Ansible Playbook

This repository contains an Ansible playbook that installs and configures an Apache httpd web server on all application servers in the Nautilus Stratos DC environment, deploys a sample web page, and ensures ownership and permissions.

Location (on the jump host)
- Playbook: `/home/thor/ansible/playbook.yml`
- Inventory: `/home/thor/ansible/inventory`

Overview
- Target hosts: group `app` (see Inventory section)
- Privilege escalation: the playbook uses `become: yes`
- Primary actions:
  1. Install `httpd`
  2. Start and enable the `httpd` service
  3. Create `/var/www/html/index.html` with initial content
  4. Insert an extra line at the top of the file using `lineinfile`
  5. Ensure ownership `apache:apache` and permissions `0777`

Playbook tasks (summary)
- Install httpd package (uses `package:` module)
- Ensure service `httpd` is `started` and `enabled` (uses `service:`)
- Create `/var/www/html/index.html` with content:
  - "This is a Nautilus sample file, created using Ansible!"
- Insert at the top of the file:
  - "Welcome to Nautilus Group!" (uses `lineinfile` with `insertbefore: BOF`)
- Enforce owner/group `apache:apache` and `mode: "0777"` (uses `file:`)

Inventory
Ensure `/home/thor/ansible/inventory` contains the `app` group with the application hosts:

```
[app]
stapp01
stapp02
stapp03
```

Running the playbook
1. Change to the playbook directory:
   - `cd /home/thor/ansible`
2. Run:
   - `ansible-playbook -i inventory playbook.yml`

No additional arguments are required.

Expected result on each target in `app`
- Package `httpd` installed
- Service `httpd` running and enabled at boot
- File `/var/www/html/index.html` exists with contents (first line added via `lineinfile`):

```
Welcome to Nautilus Group!
This is a Nautilus sample file, created using Ansible!
```

- Ownership: `apache:apache`
- Permissions: `-rwxrwxrwx` (mode `0777`)

Notes and considerations
- This playbook assumes:
  - Target hosts are RHEL/CentOS-style systems where the Apache package is named `httpd`
  - A system user and group `apache` exist
  - SSH connectivity and Ansible control requirements are already satisfied from the jump host
- If your targets are Debian/Ubuntu (where package is `apache2` and user/group may be `www-data`), adjust the playbook accordingly.
- SELinux: if the target has SELinux enforcing, you may need to set the proper file context (for example with `seboolean`/`semanage`/`restorecon`) so httpd can serve the file.
- Idempotence:
  - The playbook is idempotent: re-running it will not duplicate lines and will maintain the desired state.
  - `lineinfile` with `insertbefore: BOF` will ensure the extra line is present at the top; it won't add duplicate lines if the same line exists.

Troubleshooting
- If the service fails to start:
  - Check logs on the target: `journalctl -u httpd` or `/var/log/httpd/error_log`
- If the file owner/group doesn't exist:
  - Verify `apache` user/group: `getent passwd apache` / `getent group apache`
- To debug Ansible run, add `-vvv` to the `ansible-playbook` command.

Validation
- The playbook has been validated by running:
  - `ansible-playbook -i inventory playbook.yml`
- Verify on a target host:
  - `sudo ls -l /var/www/html/index.html`
  - `sudo cat /var/www/html/index.html`
  - `sudo systemctl status httpd`

Tested with
- Ansible 2.9+ (behaviour should be compatible with later versions, but verify on your control node)

