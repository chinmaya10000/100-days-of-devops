# Custom Apache Docker Image (Ubuntu 24.04)

## 📘 Overview
This Docker image is created for the Nautilus application development team.  
It uses **Ubuntu 24.04** as the base image and installs **Apache2**, configured to run on **port 3002** instead of the default port 80.

No other Apache settings such as document root or virtual host configuration have been modified.

---

## 🧾 Dockerfile Location
`/opt/docker/Dockerfile`

---

## 🐳 Dockerfile Content
```dockerfile
# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Install Apache2
RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Apache to listen on port 3002
RUN sed -i 's/80/3002/' /etc/apache2/ports.conf && \
    sed -i 's/:80/:3002/' /etc/apache2/sites-available/000-default.conf

# Expose port 3002
EXPOSE 3002

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
```

---

## ⚙️ Image Configuration Details

- **Base Image:** `ubuntu:24.04`
- **Installed Package:** `apache2`
- **Apache Port:** `3002`
- **Default Document Root:** `/var/www/html`
- **Startup Command:** `apache2ctl -D FOREGROUND`

---

## 🚀 How to Build and Run the Image

1. **Navigate to the directory**
    ```bash
    cd /opt/docker
    ```

2. **Build the Docker image**
    ```bash
    sudo docker build -t custom-apache:latest .
    ```

3. **Run the container**
    ```bash
    sudo docker run -d -p 3002:3002 custom-apache
    ```

4. **Verify Apache is running**
    ```bash
    curl http://localhost:3002
    ```
    You should see the Apache2 Ubuntu Default Page output.

---

## 🔍 Verification & Troubleshooting

- **Check if the container is running:**
    ```bash
    docker ps
    ```

- **View container logs:**
    ```bash
    docker logs <container_id>
    ```

- **Confirm Apache is listening on port 3002:**
    ```bash
    docker exec -it <container_id> netstat -tuln | grep 3002
    ```