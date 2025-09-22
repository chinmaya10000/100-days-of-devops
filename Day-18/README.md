# WordPress Deployment on xFusionCorp Infra (Stratos Datacenter)

This project hosts a WordPress website on the **App servers** using a shared storage mounted at `/var/www/html`.  
The site connects to a **MariaDB database** running on the DB server.  
The application is served by **Apache on port 8087**

---

## 🚀 Steps Performed

### 1. Database Server (DB Server)

#### Install MariaDB:
```bash
sudo dnf install -y mariadb-server
sudo systemctl enable --now mariadb
```

#### Create database and user:
```bash
sudo mysql -u root -e "CREATE DATABASE kodekloud_db3;"
sudo mysql -u root -e "CREATE USER 'kodekloud_sam'@'%' IDENTIFIED BY 'BruCStnMT5';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON kodekloud_db3.* TO 'kodekloud_sam'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
```

#### Allow remote access (if needed):
```bash
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf
sudo systemctl restart mariadb
```

---

### 2. Application Servers (All App hosts)

#### Install Apache, PHP, and dependencies:
```bash
sudo dnf install -y httpd php php-cli php-mysqlnd php-fpm php-json php-xml php-mbstring wget unzip
sudo systemctl enable --now httpd
sudo systemctl enable --now php-fpm
```

#### Configure Apache to listen on port 8087 (or 3002 in this lab):
```bash
sudo sed -i '/^Listen /c\Listen 8087' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
```

#### Verify:
```bash
sudo ss -tulnp | grep httpd
```

#### Deploy WordPress to shared storage:
```bash
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress latest.tar.gz
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
```

#### Configure WordPress DB connection:
```bash
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/kodekloud_db3/" wp-config.php
sudo sed -i "s/username_here/kodekloud_sam/" wp-config.php
sudo sed -i "s/password_here/BruCStnMT5/" wp-config.php
sudo sed -i "s/localhost/<DB_SERVER_IP>/" wp-config.php
sudo chown apache:apache wp-config.php
```

---

### 3. Verification

#### Create a DB test file:
```bash
sudo tee /var/www/html/index.php <<EOF
<?php
\$conn = new mysqli('<DB_SERVER_IP>', 'kodekloud_sam', 'BruCStnMT5', 'kodekloud_db3');
if (\$conn->connect_error) { die("Connection failed: " . \$conn->connect_error); }
echo "App is able to connect to the database using user kodekloud_sam";
EOF
sudo chown apache:apache /var/www/html/index.php
```

#### Test locally on App host:
```bash
curl http://localhost:8087/index.php
```

##### Expected Output:
```
App is able to connect to the database using user kodekloud_sam
```

#### Test via Load Balancer (LBR / App button):
- Open the LBR link from the top bar in the lab UI.
- You should see the same success message.

---

## ✅ Final Output

```
App is able to connect to the database using user kodekloud_sam
```

---

## Notes

- The directory `/var/www/html` is shared across all App hosts from the storage server.
- Only DB Server needs MariaDB configuration.
- All App servers must run Apache on the specified port (`8087`/`3002`).
- The LBR forwards requests to all App servers, so they all must be working correctly.
