# Nautilus Project - Containerized Environment Setup

## Day 38 Task

### Objective

Prepare a containerized environment for testing application features.  
**Specific goals:**
- Pull the `busybox:musl` image on **App Server 2** in the **Stratos Data Center**
- Create a new tag `busybox:media` for the image

---

### Prerequisites

- Docker installed on App Server 2
- Access credentials for App Server 2 in Stratos DC
- Network connectivity to Docker Hub

---

### Steps Performed

#### 1. Log in to App Server 2

```bash
ssh user@app-server-2.stratosdc.example.com
```

#### 2. Pull the `busybox:musl` image

```bash
docker pull busybox:musl
```

#### 3. Retag the image as `busybox:media`

```bash
docker tag busybox:musl busybox:media
```

#### 4. Verify the new image tag

```bash
docker images
```

**Expected output:**

```
REPOSITORY   TAG     IMAGE ID      SIZE
busybox      musl    <image_id>    <size>
busybox      media   <image_id>    <size>
```

---

### Outcome

- `busybox:musl` successfully pulled on App Server 2
- New tag `busybox:media` created and ready for use
- Image is available for containerized testing by developers

---

### Notes

- Both tags reference the same image ID and content.
- Developers can now use `busybox:media` for media feature testing in containers.