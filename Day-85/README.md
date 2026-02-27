# 📘 README – Nautilus DevOps Ansible File Creation Task

## 📌 Overview
This repository contains an Ansible inventory and playbook to create and manage a file on all application servers in the Stratos datacenter.

The playbook:
- Creates a blank file at `/opt/nfsdata.txt`
- Ensures permissions are `0755`
- Sets owner/group per host:
  - `stapp01` → `tony`
  - `stapp02` → `steve`
  - `stapp03` → `banner`

---

## 📁 Files & Locations

- Inventory: `~/playbook/inventory`
- Playbook: `~/playbook/playbook.yml`

---

## 🔧 Inventory (`inventory`)

```ini
[appservers]
stapp01 ansible_host=172.16.238.10 ansible_user=tony ansible_password=Ir0nM@n
stapp02 ansible_host=172.16.238.11 ansible_user=steve ansible_password=Am3ric@
stapp03 ansible_host=172.16.238.12 ansible_user=banner ansible_password=BigGr33n
```

---

## ▶️ Playbook (`playbook.yml`)

```yaml
---
- name: Create file on all app servers
  hosts: appservers
  become: yes

  tasks:
    - name: Create blank file /opt/nfsdata.txt
      file:
        path: /opt/nfsdata.txt
        state: touch
        mode: '0755'

    - name: Set owner for stapp01
      file:
        path: /opt/nfsdata.txt
        owner: tony
        group: tony
      when: inventory_hostname == "stapp01"

    - name: Set owner for stapp02
      file:
        path: /opt/nfsdata.txt
        owner: steve
        group: steve
      when: inventory_hostname == "stapp02"

    - name: Set owner for stapp03
      file:
        path: /opt/nfsdata.txt
        owner: banner
        group: banner
      when: inventory_hostname == "stapp03"
```

---

## 🚀 Run Command

From `~/playbook` run:

```bash
ansible-playbook -i inventory playbook.yml
```

---

## ✅ Expected Result

- `/opt/nfsdata.txt` created on all app servers
- Permissions: `0755`
- Owners / groups:
  - `stapp01` → `tony:tony`
  - `stapp02` → `steve:steve`
  - `stapp03` → `banner:banner`

---

## 📝 Notes & Tips

- The playbook uses `become: yes` to ensure the file can be created/owned at `/opt`.
- If SSH keys are preferred, remove `ansible_password` from the inventory and configure keys for `ansible_user`.
- To test a single host, add `-l stapp01` to the `ansible-playbook` command.
- Verify connectivity with `ansible -i inventory -m ping appservers`.
