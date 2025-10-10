# Demo Image Creation from Running Container

## Overview

This document explains how to create a Docker image `demo:datacenter` from an existing running container `ubuntu_latest` on **Application Server 1**.  
This allows backing up container changes and creating reusable images for deployment.

---

## Prerequisites

- Docker installed on **Application Server 1**.
- Running container named `ubuntu_latest`.
- Access to push images to a Docker registry (optional).

---

## Steps to Create the Image

### 1. **Verify running container**

```bash
docker ps
```
Ensure `ubuntu_latest` is listed as a running container.

### 2. **Commit the container as a new image**

```bash
docker commit ubuntu_latest demo:datacenter
```
- `ubuntu_latest` → name of the container.
- `demo:datacenter` → new image name and tag.

### 3. **Verify the new image**

```bash
docker images
```
You should see `demo:datacenter` in the list.

### 4. **(Optional) Push image to Docker registry**

```bash
docker tag demo:datacenter <registry_url>/demo:datacenter
docker push <registry_url>/demo:datacenter
```
Replace `<registry_url>` with your registry URL.

---

## Notes

- The container will continue running after committing the image.
- Use meaningful tags for images to manage versions effectively.
- Images created this way include all current container changes (installed packages, modified files, etc.).