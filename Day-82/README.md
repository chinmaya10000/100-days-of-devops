# Ansible Playbook Setup — Nautilus DevOps

This directory contains a minimal Ansible inventory and playbook scaffolding used by the Nautilus DevOps team for testing on application servers in the Stratos DC training environment.

## Repository layout
```
/home/thor/playbook/
├── inventory        # INI inventory (hosts)
└── playbook.yml     # main playbook (expected to exist in this directory)
```

## Inventory (INI)
Path: `/home/thor/playbook/inventory`

Contents:
```ini
[appservers]
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_ssh_pass=Am3ric@
```

Notes:
- `stapp02` is the hostname used by the Stratos DC Wiki and is the only host in this inventory.
- Variables provided:
  - `ansible_host` — IP address to connect to
  - `ansible_user` — SSH username
  - `ansible_ssh_pass` — SSH password (password-based SSH is used for the training environment)

## Running the playbook
1. Change into the playbook directory:
```bash
cd /home/thor/playbook/
```

2. Run the playbook with the inventory file:
```bash
ansible-playbook -i inventory playbook.yml
```

Important:
- Run the command from `/home/thor/playbook/` (or specify full paths) — otherwise Ansible may fail to find `playbook.yml` or `inventory`.

## Common troubleshooting
- ERROR: `playbook.yml could not be found`  
  Cause: command run outside the playbook directory or `playbook.yml` is missing/renamed.  
  Fix:
  - Ensure you are in `/home/thor/playbook/`
  - Verify `playbook.yml` exists: `ls -l playbook.yml`
  - If the file is missing, restore or recreate the playbook file before running the command.

- SSH connection failures:
  - Confirm the IP in `ansible_host` is reachable: `ping 172.16.238.11`
  - Verify username/password are correct and that the server permits password authentication.

## Security note
The inventory currently stores an SSH password in plain text for training convenience. For any non-training or production use, do NOT store credentials plaintext. Recommended alternatives:
- Use SSH key authentication (preferred).
- Use Ansible Vault to encrypt sensitive files:
  - Encrypt the inventory (example): `ansible-vault encrypt inventory`
  - Run with vault password prompt: `ansible-playbook -i inventory playbook.yml --ask-vault-pass`
- Use a credential manager or secrets store (HashiCorp Vault, AWS Secrets Manager, etc.)

## Additional tips
- Verify Ansible is installed and reachable: `ansible --version`
- If you need to run against a single host in the inventory: `ansible-playbook -i inventory playbook.yml --limit stapp02`
- If the Stratos DC validation scripts are used, follow their required file layouts and variable names exactly.

---
