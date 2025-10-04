# 🚀 Day 37 - Secure File Transfer using Docker

## 📘 Overview
This task focuses on **securely copying encrypted files** between a Docker host and a running container without altering the file content.  
It reinforces practical understanding of the `docker cp` command and the importance of **data integrity** in DevOps operations.

---

## 🧩 Scenario
The Nautilus DevOps team needed to move a sensitive, encrypted file into a running container for further processing.

### Task Details
- **Source File:** `/tmp/nautilus.txt.gpg`  
- **Destination Container:** `ubuntu_latest`  
- **Target Path inside Container:** `/tmp/`

---

## ⚙️ Commands Used

### 1️⃣ Check running containers
```bash
docker ps
```

### 2️⃣ Copy the encrypted file from host to container
```bash
docker cp /tmp/nautilus.txt.gpg ubuntu_latest:/tmp/
```

### 3️⃣ Verify file inside the container
```bash
docker exec -it ubuntu_latest ls /tmp/
```

### 4️⃣ Verify integrity using SHA256 checksum
```bash
# On the host
sha256sum /tmp/nautilus.txt.gpg

# Inside the container
docker exec -it ubuntu_latest sha256sum /tmp/nautilus.txt.gpg
```
✅ The SHA256 hash matched perfectly, confirming file integrity.

---

## 🧠 Key Learnings

- `docker cp` allows copying files to and from containers without rebuilding images.
- Always verify file integrity when transferring encrypted or sensitive files.
- Ensures secure and reliable file handling in containerized environments.

---

## 💡 Example Use Cases

- Moving configuration files or encrypted credentials into running containers.
- Extracting logs, backups, or reports from containers to the host.
- Rapid debugging and testing in dev environments.