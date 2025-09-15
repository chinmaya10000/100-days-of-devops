# Day 15 – Nginx with SSL Setup on App Server 1

## Objective
Prepare **App Server 1** for application deployment by installing and configuring **Nginx** with SSL and serving a basic HTML page.

---

## Steps

### 1. Install Nginx

```bash
# For CentOS/RHEL
sudo yum install -y nginx

# For Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y nginx
```

---

### 2. Move SSL Certificates

The self-signed SSL certificate and key are provided at `/tmp`.

```bash
sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
sudo mv /tmp/nautilus.key /etc/nginx/ssl/
sudo chmod 600 /etc/nginx/ssl/nautilus.key
```

---

### 3. Configure Nginx with SSL

Create a new config file:

```bash
sudo vi /etc/nginx/conf.d/ssl.conf
```

Add the following configuration:

```nginx
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate     /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}
```

---

### 4. Create index.html

```bash
echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html
```

---

### 5. Test & Restart Nginx

```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

### 6. Verify from Jump Host

```bash
curl -Ik https://<App-Server-1-IP>/
curl -k https://<App-Server-1-IP>/
```

**Expected output:**
```
HTTP/1.1 200 OK
Welcome!
```