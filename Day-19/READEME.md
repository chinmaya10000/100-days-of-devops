# Day 19 - Multi-Site Apache Setup on App Server 2

## Task Summary
xFusionCorp Industries required hosting **two static websites** (`news` and `demo`) on **App Server 2** in Stratos Datacenter.  
Both websites' backups were available on the jump host. The goal was to serve them via Apache on port `8084`.

---

## Steps Performed

### 1. Install Apache
```bash
sudo yum install httpd -y
```

### 2. Configure Apache to Listen on Port 8084
Edit `/etc/httpd/conf/httpd.conf` to add:
```conf
Listen 8084
```

### 3. Create Document Roots
Copy backup files from the jump host into:
```
/var/www/html/news
/var/www/html/demo
```

### 4. Configure Virtual Hosts

Create `/etc/httpd/conf.d/news.conf`:
```apache
<VirtualHost *:8084>
    DocumentRoot "/var/www/html/news"
    <Directory "/var/www/html/news">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

Create `/etc/httpd/conf.d/demo.conf`:
```apache
<VirtualHost *:8084>
    DocumentRoot "/var/www/html/demo"
    <Directory "/var/www/html/demo">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### 5. Restart Apache
```bash
sudo systemctl restart httpd
```

### 6. Verify Websites
```bash
curl http://localhost:8084/news/
curl http://localhost:8084/demo/
```
- **news site** → "This is a sample page for our news website"
- **demo site** → "This is a sample page for our demo website"

---

## Final Result

Both static websites are successfully hosted on App Server 2:

- http://localhost:8084/news/
- http://localhost:8084/demo/