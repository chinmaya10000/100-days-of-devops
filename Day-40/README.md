# Configure Apache on `kkloud` Container

## Task Overview

Set up Apache inside the `kkloud` Docker container (on **App Server 2**, Stratos Datacenter) to listen on **port 3001** on all interfaces.

---

## Steps

### 1. Access App Server 2
```bash
ssh tony@<App-Server-2-IP>
sudo su -
```

### 2. Enter the `kkloud` Container
```bash
docker ps            # Find container ID/name
docker exec -it kkloud bash
```

### 3. Install Apache2
```bash
apt update
apt install apache2 -y
```

### 4. Change Apache to Listen on Port 3001

#### Method 1: Using `sed`
```bash
sed -i 's/Listen 80/Listen 3001/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:3001>/' /etc/apache2/sites-available/000-default.conf
```

#### If `sed` is unavailable (fallback):
```bash
echo "Listen 3001" > /etc/apache2/ports.conf

cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:3001>
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
```

### 5. Restart Apache and Check Status
```bash
service apache2 restart
service apache2 status
```

### 6. Verify Apache is Listening on Port 3001

#### Option 1: Install net-tools (if not present)
```bash
apt install net-tools -y
netstat -tuln | grep 3001
```

#### Option 2: Use curl
```bash
curl -I http://localhost:3001
```
**Expected Output:**
```
HTTP/1.1 200 OK
Server: Apache/2.4.41 (Ubuntu)
```

### 7. Ensure Container Stays Running
```bash
exit
docker ps
```

---

**Note:**  
- Apache should be accessible on port 3001 on all interfaces (localhost, container IP, etc.).
- If you face issues with editors or commands, install them using `apt`.

---

**End of Task**