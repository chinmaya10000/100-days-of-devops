# Python App - Docker Deployment

## Overview
This project contains a simple Python web application that needs to be containerized using Docker and deployed on **App Server 3**.

The application dependencies are listed in `requirements.txt` under the `src/` directory.

---

## Directory Structure

```
/python_app/
├── Dockerfile
└── src/
    ├── requirements.txt
    └── server.py
```

---

## Steps to Build and Run

### 1. Navigate to the Application Directory

```bash
cd /python_app
```

### 2. Create Dockerfile

A Dockerfile should be placed under `/python_app` with the following content:

```dockerfile
FROM python:3.9
WORKDIR /app
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .
EXPOSE 5000
CMD ["python", "server.py"]
```

### 3. Build Docker Image

```bash
docker build -t nautilus/python-app .
```

### 4. Run the Container

```bash
docker run -d --name pythonapp_nautilus -p 8097:5000 nautilus/python-app
```

### 5. Verify Container is Running

```bash
docker ps
```

Expected output:

```
CONTAINER ID   IMAGE                  PORTS
xxxxxx         nautilus/python-app    0.0.0.0:8097->5000/tcp
```

### 6. Test the Application

Use curl to test:

```bash
curl http://localhost:8097/
```

You should see the response served by `server.py`.

---