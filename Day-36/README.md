# Nginx Container Deployment on Application Server 3

## Objective

Deploy an nginx container named `nginx_3` on Application Server 3 using the `nginx:alpine` image and ensure it is running.

---

## Steps

### 1. Connect to Application Server 3

Replace `user` with your username:
```sh
ssh user@ApplicationServer3
```

---

### 2. Verify Docker Installation

Check if Docker is installed:
```sh
docker --version
```

**If Docker is not installed:**
```sh
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable --now docker
```

---

### 3. Pull Nginx Alpine Image

```sh
docker pull nginx:alpine
```

---

### 4. Run Nginx Container

```sh
docker run -d --name nginx_3 nginx:alpine
```
- `-d` → run in detached mode
- `--name nginx_3` → container name
- `nginx:alpine` → image used

---

### 5. Verify Container is Running

```sh
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE          COMMAND                  STATUS        PORTS   NAMES
xxxxxx         nginx:alpine   "/docker-entrypoint.…"   Up xx seconds         nginx_3
```

---

## Result

Container `nginx_3` is successfully deployed and running on Application Server 3.