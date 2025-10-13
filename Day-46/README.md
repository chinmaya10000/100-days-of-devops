# Nautilus Application Docker Setup

This repository contains a Docker Compose setup to deploy the Nautilus Application stack on an app server. It includes a **PHP web server** and a **MariaDB database**.

---

## Services

### 1. Web (PHP + Apache)
- **Container name:** `php_host`
- **Image:** `php:8.2-apache`
- **Ports:** Host `6400` → Container `80`
- **Volume:** Host `/var/www/html` → Container `/var/www/html`
- **Purpose:** Serves the PHP application.

### 2. Database (MariaDB)
- **Container name:** `mysql_host`
- **Image:** `mariadb:latest`
- **Ports:** Host `3306` → Container `3306`
- **Volume:** Host `/var/lib/mysql` → Container `/var/lib/mysql`
- **Environment Variables:**
  - `MYSQL_DATABASE=database_host`
  - `MYSQL_USER=custom_user`
  - `MYSQL_PASSWORD=ComplexP@ss123!`
  - `MYSQL_ROOT_PASSWORD=RootComplexP@ss123!`
- **Purpose:** Stores application data.

---

## Setup Instructions

1. Navigate to the directory containing `docker-compose.yml`:
   ```bash
   cd /opt/data
   ```
2. Start the stack:
   ```bash
   sudo docker compose up -d
   ```
3. Check running containers:
   ```bash
   sudo docker ps
   ```
4. Access the PHP app via:
   ```bash
   curl http://<server-ip>:6400/
   ```
5. Stop the stack:
   ```bash
   sudo docker compose down
   ```