# Ansible Playbook — Create File on App Server 2

## Description
This repository contains an Ansible inventory and playbook to create an empty file `/tmp/file.txt` on App Server 2 (stapp02) in the Stratos DC environment.

## Files
- `/home/thor/ansible/inventory` — Ansible inventory (defines group `app2` and host `stapp02`)
- `/home/thor/ansible/playbook.yml` — Playbook that creates `/tmp/file.txt` on hosts in group `app2`

## Inventory (inventory)
```ini
[app2]
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@ ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

> Note: This example contains an SSH password in plain text for demonstration. For production use, prefer SSH keys or `ansible-vault` to protect secrets.

## Playbook (playbook.yml)
```yaml
---
- name: Create file on App Server 2
  hosts: app2
  become: yes
  tasks:
    - name: Create empty file
      file:
        path: /tmp/file.txt
        state: touch
```

## How to run
1. Open a shell in the `/home/thor/ansible/` directory (or adjust paths accordingly).
2. Execute:
```bash
ansible-playbook -i inventory playbook.yml
```

This playbook is written to run without extra parameters if the inventory contains valid connection credentials.

## Expected outcome
- The file `/tmp/file.txt` will be created on `stapp02` (172.16.238.11).
- The playbook should complete successfully and return a success summary from Ansible.

## Troubleshooting & tips
- Ensure the control node can reach `172.16.238.11` (ping / SSH).
- If SSH keys are preferred, remove `ansible_ssh_pass` from inventory and configure key-based auth for `steve`.
- To protect secrets, store the inventory or password in an encrypted vault using `ansible-vault`.
- If connectivity issues appear, re-run with increased verbosity:
```bash
ansible-playbook -i inventory playbook.yml -vvv
```

## Security note
Do not commit plaintext passwords into public repositories. Use `ansible-vault` or environment-based secrets management when storing credentials.