# Guestbook Application Deployment on Kubernetes

This repository contains the Kubernetes manifests to deploy the **Guestbook Application**, a simple app to manage guest/visitor entries. The application is structured into **backend** and **frontend** tiers using Redis and PHP.

---

## Application Architecture

### Backend Tier

1. **Redis Master**
   - Deployment: `redis-master`
   - Container: `master-redis-devops`
   - Image: `redis`
   - Replicas: 1
   - Port: 6379
   - Requests: CPU 100m, Memory 100Mi

2. **Redis Slave**
   - Deployment: `redis-slave`
   - Container: `slave-redis-devops`
   - Image: `gcr.io/google_samples/gb-redisslave:v3`
   - Replicas: 2
   - Port: 6379
   - Requests: CPU 100m, Memory 100Mi
   - Environment Variable: `GET_HOSTS_FROM=dns`

### Frontend Tier

1. **Frontend**
   - Deployment: `frontend`
   - Container: `php-redis-devops`
   - Image: `gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff`
   - Replicas: 3
   - Port: 80
   - Requests: CPU 100m, Memory 100Mi
   - Environment Variable: `GET_HOSTS_FROM=dns`
   - Service: NodePort `30009` for external access

---

## Deployment Instructions

1. Apply the manifest to deploy all resources:

```bash
kubectl apply -f guestbook.yaml
```

2. Verify all resources:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

3. Access the frontend via NodePort:

Open in a browser:

http://<node-ip>:30009

Replace `<node-ip>` with the IP of any worker node in your cluster.

---

## Kubernetes Manifest (guestbook.yaml)

# ---------------------------
# Redis Master Deployment
# ---------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-master
  labels:
    app: redis
    role: master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
      role: master
  template:
    metadata:
      labels:
        app: redis
        role: master
    spec:
      containers:
      - name: master-redis-devops
        image: redis
        resources:
          requests:
            cpu: "100m"
            memory: "100Mi"
        ports:
        - containerPort: 6379

---
# Redis Master Service
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  labels:
    app: redis
    role: master
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: master

# ---------------------------
# Redis Slave Deployment
# ---------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-slave
  labels:
    app: redis
    role: slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis
      role: slave
  template:
    metadata:
      labels:
        app: redis
        role: slave
    spec:
      containers:
      - name: slave-redis-devops
        image: gcr.io/google_samples/gb-redisslave:v3
        resources:
          requests:
            cpu: "100m"
            memory: "100Mi"
        env:
        - name: GET_HOSTS_FROM
          value: "dns"
        ports:
        - containerPort: 6379

---
# Redis Slave Service
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  labels:
    app: redis
    role: slave
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: slave

# ---------------------------
# Frontend Deployment
# ---------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: guestbook
      tier: frontend
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis-devops
        image: gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff
        resources:
          requests:
            cpu: "100m"
            memory: "100Mi"
        env:
        - name: GET_HOSTS_FROM
          value: "dns"
        ports:
        - containerPort: 80

---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30009
  selector:
    app: guestbook
    tier: frontend