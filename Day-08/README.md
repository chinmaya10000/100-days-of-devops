# Ansible Installation on Jump Host

## Task
Install **Ansible version 4.7.0** on the Jump Host using **pip3 only**.  
Ensure the Ansible binary is available **globally** so that all users can run Ansible commands.

---

## Steps Performed

1. **Checked Python3 and pip3 availability**
   ```bash
   python3 --version
   pip3 --version
   sudo pip3 install ansible==4.7.0
   ansible --version
   ls -l /usr/local/bin/ansible
   