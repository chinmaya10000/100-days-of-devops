# Static Website Deployment using Docker Compose

## Objective

Host a static website on an `httpd` (Apache) web server using Docker Compose on **App Server 3**.

---

## Setup Details

- **Container Name:** `httpd`
- **Image Used:** `httpd:latest`
- **Host Directory (static files):** `/opt/devops`
- **Container Directory:** `/usr/local/apache2/htdocs`
- **Host Port:** `8087`
- **Container Port:** `80`
- **Compose File Path:** `/opt/docker/docker-compose.yml`

---

## Deployment Steps

1. **Navigate to the Docker Compose directory:**
   ```bash
   cd /opt/docker
   ```

2. **Launch the Apache HTTPD container using Docker Compose:**
   ```bash
   docker compose up -d
   ```

3. **Verify the container is running:**
   ```bash
   docker ps
   ```
   **Expected output:**
   ```
   CONTAINER ID   IMAGE          COMMAND              PORTS                  NAMES
   xxxxxxxx       httpd:latest   "httpd-foreground"   0.0.0.0:8087->80/tcp   httpd
   ```

4. **Check that the volume is mounted correctly:**
   ```bash
   docker inspect httpd | grep -A 5 Mounts
   ```

5. **Access the website and confirm static content is served:**
   ```bash
   curl http://localhost:8087
   ```
   You should see the static content from `/opt/devops`.

---

## Notes

- **Do not modify or delete any files inside `/opt/devops`.**
- The Docker Compose file uses a **host bind mount** to serve static files from the host directory.
- To **stop and remove the container**:
  ```bash
  docker compose down
  ```

---

## Example `docker-compose.yml`

```yaml
version: '3'
services:
  httpd:
    image: httpd:latest
    container_name: httpd
    ports:
      - "8087:80"
    volumes:
      - /opt/devops:/usr/local/apache2/htdocs
```