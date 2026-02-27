# httpd role

This Ansible role installs and configures the HTTPD web server and deploys a dynamic index page rendered from a Jinja2 template. The template inserts the server name using `{{ inventory_hostname }}` so the deployed page reflects the target host.

## Purpose
- Install the latest `httpd` package (YUM)
- Ensure the `httpd` service is started
- Deploy `/var/www/html/index.html` from `templates/index.html.j2`
- Set file owner/group to the sudo user from inventory (`ansible_user`)
- Ensure file mode is `0655`

## Directory layout
Assumed layout under your `ansible/` directory:

```
ansible/
├── inventory
├── playbook.yml
└── role/
    └── httpd/
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── index.html.j2
        └── README.md
```

## Files of interest
- tasks/main.yml
  - Installs `httpd`
  - Starts `httpd`
  - Deploys the template to `/var/www/html/index.html` with:
    - owner: `{{ ansible_user }}`
    - group: `{{ ansible_user }}`
    - mode: `0655`
- templates/index.html.j2
  - Contents:
    ```
    This file was created using Ansible on {{ inventory_hostname }}
    ```

## Inventory example
(kept in `ansible/inventory`)

```
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_ssh_pass=Ir0nM@n ansible_become_pass=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_become_pass=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_ssh_pass=BigGr33n ansible_become_pass=BigGr33n
```

Playbook (`playbook.yml`):

```yaml
---
- hosts: stapp03
  become: yes
  become_user: root
  roles:
    - role/httpd
```

## How to run
From the `ansible/` directory:

```bash
ansible-playbook -i inventory playbook.yml
```

The playbook is intended to run without additional arguments.

## Verification
1. Check file content:
```bash
ansible -i inventory stapp03 -m shell -a "cat /var/www/html/index.html"
```

2. Check permissions and ownership:
```bash
ansible -i inventory stapp03 -m shell -a "stat -c '%n %U %G %a' /var/www/html/index.html"
```

Expected output (example for `stapp03`):
```
This file was created using Ansible on stapp03
/var/www/html/index.html banner banner 655
```

## Notes and assumptions
- The role uses `{{ ansible_user }}` to set owner and group of the deployed file. Ensure the inventory's `ansible_user` for the target host is the intended sudo user (in this example `banner` for `stapp03`).
- The playbook uses `become: yes` and `become_user: root` to perform package installation and file deployment.
- File mode `0655` is set as a string in the task to avoid octal parsing issues.
- If your environment uses `dnf` instead of `yum`, adjust the task accordingly or rely on the `package` module for cross-distro compatibility.

## Troubleshooting
- If the template does not render the expected hostname, verify that the host targeted is `stapp03` (inventory and playbook host selection).
- If permissions/ownership are incorrect, confirm `ansible_user` value on the host entry in `inventory`.
- If `httpd` fails to start, check the service status and journal logs on the target host:
```bash
ansible -i inventory stapp03 -m shell -a "systemctl status httpd --no-pager"
ansible -i inventory stapp03 -m shell -a "journalctl -u httpd --no-pager -n 50"
```
