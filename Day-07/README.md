# Day06 – Passwordless SSH Setup for thor User

## Problem Statement
The system admins team of xFusionCorp Industries has set up some scripts on the jump host that run at regular intervals and perform operations on all app servers in the Stratos Datacenter.

To ensure these scripts work properly, we must configure **passwordless SSH access** from the `thor` user on the jump host to all app servers through their respective sudo users.

- App Server 1 → `tony@app01`
- App Server 2 → `steve@app02`
- App Server 3 → `banner@app03`

---

## Solution

### 1. Switch to `thor` user on Jump Host
```bash
ssh thor@jump_host
ssh-keygen -t rsa -b 4096
ssh-copy-id -i ~/.ssh/id_rsa.pub tony@app01
