# Nautilus Load Balancer Setup

## Overview
This project demonstrates the setup of a **high availability stack** for the Nautilus application using **Nginx as a load balancer** (LBR) and multiple Apache app servers.  

The goal is to distribute incoming traffic across all app servers to improve performance and availability.

---

## Architecture

```
        +----------------+
        |   LBR Server   |
        |   (Nginx)      |
        +--------+-------+
                 |
  -------------------------------
  |             |               |
+------------+ +------------+ +------------+
| stapp01    | | stapp02    | | stapp03    |
| Apache 3001| | Apache 3001| | Apache 3001|
+------------+ +------------+ +------------+
```

- **LBR Server**: Nginx installed, listens on port `80`.  
- **App Servers**: Apache installed, serving application on port `3001`.  
- Requests to LBR are **proxied to upstream app servers** using round-robin load balancing.

---

## Steps to Configure

### 1. Verify Apache on App Servers

```bash
sudo systemctl status httpd        # ensure Apache is running
sudo ss -tlnp | grep httpd         # confirm listening port (3001)
curl -s http://localhost:3001      # test local application
```

### 2. Configure Nginx on LBR

Edit `/etc/nginx/nginx.conf`:

```nginx
http {
    upstream app_servers {
        server stapp01:3001;
        server stapp02:3001;
        server stapp03:3001;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://app_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

Restart Nginx:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 3. Test Load Balancer

On LBR:

```bash
for i in {1..6}; do curl -s http://localhost | grep -i Welcome; done
```

Expected output (rotating responses from app servers):

```
Welcome to xFusionCorp Industries!
Welcome to xFusionCorp Industries!
...
```

---

## Troubleshooting

**No output from LBR**

- Check if Nginx upstream points to the correct port (`3001`) of the app servers.
- Test connectivity from LBR:

    ```bash
    curl -s http://stapp01:3001
    ```

**App servers not reachable**

- Ensure Apache is running and listening on all interfaces (`0.0.0.0:3001`).
- Check firewall/SELinux rules if needed.

**IP vs Hostname**

- In lab environments, hostnames (`stapp01`, `stapp02`, `stapp03`) often work better than direct IPs.

---