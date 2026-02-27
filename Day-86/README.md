# 🚀 Ansible Password-less SSH Setup & Ping Test
### Nautilus DevOps – Stratos DC

This README documents how to configure password-less SSH from the Ansible controller (jump host) to App Server 2 (stapp02) and verify connectivity using Ansible.

---

## 📌 Environment (reference)

| Server   | IP            | User   | Password  | Purpose          |
|----------|---------------|--------|-----------|------------------|
| stapp01  | 172.16.238.10 | tony   | Ir0nM@n   | Nautilus App 1   |
| stapp02  | 172.16.238.11 | steve  | Am3ric@   | Nautilus App 2   |
| stapp03  | 172.16.238.12 | banner | BigGr33n  | Nautilus App 3   |
| jump_host| Dynamic       | thor   | mjolnir123| Ansible Controller |

> Note: jump_host IP is dynamic; use the current IP / DNS name to connect as `thor`.

---

## 📂 Inventory file
Path: `/home/thor/ansible/inventory`

Contents (example):
```ini
stapp02 ansible_host=172.16.238.11 ansible_user=steve
```

---

## ✅ Steps

### 1) Generate an SSH key on the jump host (as thor)
Run as user `thor` on the controller:

```bash
# recommended: 4096-bit RSA (omit -N "" to set a passphrase interactively)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

This creates:
- Private key: `~/.ssh/id_rsa`
- Public key:  `~/.ssh/id_rsa.pub`

Set restrictive permissions (if not already):
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### 2) Copy the public key to stapp02
Simplest method (ssh-copy-id):
```bash
ssh-copy-id steve@172.16.238.11
# Enter password when prompted: Am3ric@
```

If `ssh-copy-id` isn't available, use:
```bash
cat ~/.ssh/id_rsa.pub | ssh steve@172.16.238.11 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
# Enter password when prompted: Am3ric@
```

### 3) Verify password-less SSH
From the controller as `thor`:
```bash
ssh steve@172.16.238.11
# You should NOT be prompted for a password if setup succeeded.
```

If you see a password prompt, use `ssh -v steve@172.16.238.11` to collect debug output.

### 4) Test with Ansible ping
From `/home/thor` (or anywhere, pointing to the inventory):
```bash
ansible stapp02 -i /home/thor/ansible/inventory -m ping
```

Expected output:
```text
stapp02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

If Ansible is not using the correct key (non-default path), specify the private key:
```bash
ansible stapp02 -i /home/thor/ansible/inventory -m ping --private-key=/home/thor/.ssh/id_rsa
```

---

## 🔍 Troubleshooting checklist

- Permissions:
  - `~/.ssh` on controller: 700
  - `~/.ssh/id_rsa` on controller: 600
  - `~/.ssh/authorized_keys` on remote: 600
- Ensure the public key is present in `/home/steve/.ssh/authorized_keys` on stapp02.
- Verify `sshd_config` on stapp02 allows PubkeyAuthentication:
  - `PubkeyAuthentication yes`
  - `AuthorizedKeysFile .ssh/authorized_keys`
- SELinux: restorecon / correct contexts when needed:
  - `restorecon -Rv /home/steve/.ssh`
- Firewall: port 22 open between controller and stapp02.
- User/inventory mismatch: `ansible_user` must match the remote account (`steve`).
- Debug SSH with increasing verbosity:
  - `ssh -vvv steve@172.16.238.11`
- If using a non-default key filename/location, configure `ansible.cfg` or use `--private-key`.

---

## Next steps / Automation ideas
- Create an Ansible playbook to distribute controller public keys to all app servers (idempotent).
- Add all servers to the inventory and verify connectivity in one run:
```bash
ansible all -i /home/thor/ansible/inventory -m ping
```

---

## Security note
- Protect the private key (`~/.ssh/id_rsa`). Consider adding a passphrase for added security.
- Avoid committing private keys or passwords to any repository.

---
