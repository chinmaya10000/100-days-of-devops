# Day 20 - Nginx + PHP-FPM Setup for Nautilus App

This document explains the setup of **Nginx with PHP-FPM (v8.1)** on App Server 3 as per Nautilus infra requirements.

---

## **Steps**

### 1. Install Nginx
```bash
sudo yum install -y nginx
```

### 2. Configure Nginx to Listen on Port 8091
Edit the Nginx configuration:

```bash
sudo vi /etc/nginx/nginx.conf
```

Update the server block:

```nginx
server {
    listen 8091;
    root /var/www/html;
    index index.php index.html index.htm;
    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index index.php;
    }
}
```

### 3. Install PHP-FPM 8.1
Enable Remi repo and install PHP 8.1:

```bash
sudo yum install -y https://rpms.remirepo.net/enterprise/remi-release-9.rpm
sudo yum module reset php -y
sudo yum module enable php:remi-8.1 -y
sudo yum install -y php php-fpm php-cli php-mysqlnd php-xml php-mbstring
```

### 4. Configure PHP-FPM Socket
Edit the pool config:

```bash
sudo vi /etc/php-fpm.d/www.conf
```

Change these lines:

```ini
listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

### 5. Create Socket Directory

```bash
sudo mkdir -p /var/run/php-fpm
sudo chown -R nginx:nginx /var/run/php-fpm
```

### 6. Start & Enable Services

```bash
sudo systemctl enable nginx php-fpm
sudo systemctl restart php-fpm
sudo systemctl restart nginx
```

### 7. Verification
From jump host:

```bash
curl http://stapp03:8091/index.php
```
or

```bash
curl http://stapp03:8091/info.php
```

You should see PHP application output confirming Nginx and PHP-FPM integration is working.

---

**Notes**

- Document root: `/var/www/html`
- PHP-FPM socket: `/var/run/php-fpm/default.sock`
- Port: `8091`
- Do not modify `index.php` or `info.php` (already provided).