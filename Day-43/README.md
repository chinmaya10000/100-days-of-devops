# 🐳 Nginx Container Setup — Application Server 2

## 📘 Objective
Deploy an **Nginx** container using the `nginx:alpine-perl` image and make it accessible on **host port 3002**.

---

## ⚙️ Steps Performed

### 1️⃣ Pull the Docker Image
Pull the lightweight Nginx image with Perl support:
```bash
sudo docker pull nginx:alpine-perl
```

---

### 2️⃣ Verify the Image
Check if the image is available locally:
```bash
sudo docker images
```
**Expected output:**
```
REPOSITORY   TAG            IMAGE ID       CREATED       SIZE
nginx        alpine-perl    <id>           <date>        <size>
```

---

### 3️⃣ Create and Run the Container
Run a container named `ecommerce` from the pulled image, mapping host port 3002 to container port 80:
```bash
sudo docker run -d --name ecommerce -p 3002:80 nginx:alpine-perl
```
**Options Explained:**
- `-d` → Run in detached mode
- `--name ecommerce` → Assign container name
- `-p 3002:80` → Map host port 3002 to container port 80

---

### 4️⃣ Verify the Running Container
```bash
sudo docker ps
```
**Expected output:**
```
CONTAINER ID   IMAGE               COMMAND                  PORTS                  NAMES
<id>           nginx:alpine-perl   "/docker-entrypoint.…"   0.0.0.0:3002->80/tcp   ecommerce
```

---

### 5️⃣ Test Application Access
Test the Nginx service through the mapped host port:
```bash
curl http://localhost:3002
```
**Expected output:**  
Nginx default Welcome Page HTML

---