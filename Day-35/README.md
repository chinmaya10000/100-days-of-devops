# 📘 Install Docker & Docker Compose (Day35 Task)

## 🚀 Task Description

The Nautilus DevOps team aims to containerize applications and needs Docker installed on **App Server 2**.

This includes:
- Installing Docker CE
- Installing Docker Compose
- Enabling & starting Docker service
- Verifying installation

---

## 🛠️ Installation Steps

### 1. Update System
```bash
sudo dnf update -y
```

### 2. Install Required Packages
```bash
sudo dnf -y install dnf-plugins-core
```

### 3. Add Docker CE Repository
```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### 4. Install Docker CE + Plugins
```bash
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

### 5. Start & Enable Docker
```bash
sudo systemctl enable --now docker
```

### 6. Verify Installation

**Check Docker version:**
```bash
docker --version
```

**Check Compose version (plugin):**
```bash
docker compose version
```

**(Optional) Run test container:**
```bash
docker run hello-world
```

---

## 📝 Notes

- **Amazon Linux 2023:**  
  Docker can also be installed with:
  ```bash
  sudo yum install docker -y
  ```

- **Amazon Linux 2023:**  
  If the plugin doesn’t work, you can install standalone Docker Compose:
  ```bash
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version
  ```

---

✅ With this setup, Docker and Docker Compose are ready on **App Server 2**.