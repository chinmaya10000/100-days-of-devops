# Docker Network Setup - Ecommerce

## Overview
This README describes the steps to create a Docker network named `ecommerce` on **App Server 1** in the **Stratos Data Center**. The network is configured to use the **bridge driver** with a specific subnet and IP range.

---

## Network Details

- **Network Name:** ecommerce  
- **Driver:** bridge  
- **Subnet:** 172.28.0.0/24  
- **IP Range:** 172.28.0.0/24  

---

## Steps to Create the Network

1. **SSH into App Server 1:**
   ```bash
   ssh user@app-server1-stratos
   ```

2. **Verify Docker installation:**
   ```bash
   docker --version
   docker info
   ```

3. **Create the Docker network:**
   ```bash
   docker network create \
     --driver bridge \
     --subnet 172.28.0.0/24 \
     --ip-range 172.28.0.0/24 \
     ecommerce
   ```

4. **Verify the network:**
   ```bash
   docker network ls
   docker network inspect ecommerce
   ```

You should see the network with the correct subnet, IP range, and driver.