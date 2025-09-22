# Day 21 - Setting Up a Bare Git Repository on Storage Server

This document explains how to create a **bare Git repository** for a new application project on the Storage Server in Stratos Datacenter.

---

## Steps

### 1. Install Git
```bash
sudo yum install -y git
```

Verify installation:
```bash
git --version
```

---

### 2. Create a Bare Repository

A bare repository does not have a working directory and is used as a central repository for developers to push and pull code.

```bash
sudo mkdir -p /opt/beta.git
cd /opt/beta.git
sudo git init --bare
```

Verify:
```bash
ls -la /opt/beta.git
```

You should see directories like:
- `hooks`
- `objects`
- `refs`

---

### 3. Optional: Set Permissions

If multiple users will push to this repo, set ownership and permissions:

```bash
sudo chown -R <username>:<group> /opt/beta.git
sudo chmod -R 775 /opt/beta.git
```

---

## ✅ Result

The bare Git repository is now ready at `/opt/beta.git`.

Developers can now clone, push, and pull code from this central repository.