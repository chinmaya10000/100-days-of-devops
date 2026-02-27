# 📘 Nautilus DevOps — Ansible Deployment

**Purpose:** Copy the finance `index.html` file from the jump host to all application servers in the Stratos DC using Ansible.

---

## 🔧 Directory Structure (on jump host)

/home/thor/ansible/
- inventory
- playbook.yml
- README.md

---

## 🧩 Inventory File (`inventory`)

Location: `/home/thor/ansible/inventory`

```ini
[appservers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_password=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_password=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_password=BigGr33n
```

> Note: Only the three application servers are listed under `[appservers]` as requested.

---

## 📜 Playbook (`playbook.yml`)

Location: `/home/thor/ansible/playbook.yml`  
Objective: Copy `/usr/src/finance/index.html` (on the jump host) to `/opt/finance/index.html` on all `appservers`.

```yaml
---
- name: Copy finance index file to all app servers
  hosts: appservers
  become: yes

  tasks:
    - name: Create destination directory
      file:
        path: /opt/finance
        state: directory
        mode: '0755'

    - name: Copy index.html to application servers
      copy:
        src: /usr/src/finance/index.html
        dest: /opt/finance/index.html
        mode: '0644'
```

---

## ▶️ How to Run

From `/home/thor/ansible/` on the jump host:

```bash
ansible-playbook -i inventory playbook.yml
```

No extra arguments are required.

---

## ✅ Expected Outcome

- `/opt/finance` directory exists on each application server.
- `/opt/finance/index.html` contains the same contents as `/usr/src/finance/index.html` from the jump host.

---

## 🔍 Quick Verification

From the jump host you can run an ad-hoc command to check presence and content:

```bash
# Check directory exists
ansible -i inventory appservers -a "stat /opt/finance/index.html" -u <user> --ask-pass

# View the file (or tail) on all appservers
ansible -i inventory appservers -a "cat /opt/finance/index.html" -u <user> --ask-pass
```

(Replace the `-u <user> --ask-pass` usage as appropriate for your environment; the inventory above uses per-host credentials.)

---

## ⚠️ Notes & Recommendations

- The example inventory contains plaintext passwords for demonstration. For production, use Ansible Vault or SSH key authentication to avoid storing secrets in plaintext.
- Ensure the source file `/usr/src/finance/index.html` exists on the jump host before running the playbook.
- If privilege escalation uses a different method (e.g., `become_user`), adjust the playbook or inventory accordingly.

---
