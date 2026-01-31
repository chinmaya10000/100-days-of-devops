# 🐍 Python Flask App Deployment on Kubernetes

This project deploys a simple Python Flask demo application on a Kubernetes cluster using a Deployment and a NodePort Service.

---

## ⚙️ Overview
- **Deployment Name:** `python-deployment-datacenter`
- **Deployment Container Name:** `python-container-datacenter`
- **Container Image:** `poroko/flask-demo-appimage`
- **Container Port (Flask Default):** `5000`
- **Service Name:** `python-deployment-datacenter` (NodePort)
- **Service Type:** `NodePort`
- **NodePort:** `32345`
- **TargetPort:** `5000`

---

## 🧩 Problem Summary

During the initial deployment the application failed to start and was not accessible. Two main issues were identified:

1. Incorrect image name in the Deployment (caused `ImagePullBackOff`).
2. Service port mismatch (Service used `8080` while the Flask app listens on `5000`).

Both issues have been corrected below.

---

## ✅ Fixes Applied

1. Use the correct image:
   - Wrong image: `poroko/flask-app-demo` (does not exist)
   - Correct image: `poroko/flask-demo-appimage`

2. Ensure Service exposes the same port the container listens on:
   - Set both `port` and `targetPort` to `5000`.
   - Keep `nodePort` = `32345`.

---

## 🛠️ Commands to Apply Fixes

Update the Deployment image (in-cluster):
```bash
kubectl set image deployment/python-deployment-datacenter \
  python-container-datacenter=poroko/flask-demo-appimage
```

Patch the Service to correct the ports:
```bash
kubectl patch svc python-deployment-datacenter \
  --type='merge' \
  -p '{
    "spec": {
      "ports": [{
        "port": 5000,
        "targetPort": 5000,
        "nodePort": 32345
      }]
    }
  }'
```

Restart the Deployment to pick up changes and watch pods:
```bash
kubectl rollout restart deployment python-deployment-datacenter
kubectl get pods -w
# Wait until pod status is Running
```

Get node(s) IP(s) and access the app:
```bash
kubectl get nodes -o wide
# Open in browser or curl:
# http://<NODE_IP>:32345
curl http://<NODE_IP>:32345
```

---

## Example Kubernetes Manifests

Deployment (example):
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-deployment-datacenter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-demo
  template:
    metadata:
      labels:
        app: flask-demo
    spec:
      containers:
      - name: python-container-datacenter
        image: poroko/flask-demo-appimage
        ports:
        - containerPort: 5000
```

Service (NodePort) (example):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-deployment-datacenter
spec:
  type: NodePort
  selector:
    app: flask-demo
  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 32345
    protocol: TCP
```

Apply manifests:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## ✅ Verification Checklist

- [ ] Deployment pods reach `Running` state (kubectl get pods).
- [ ] ImagePullBackOff no longer occurs in pod events.
- [ ] Service ports show `5000` for `PORT(S)` and `NODE-PORT` 32345 (kubectl get svc).
- [ ] Application responds at `http://<NODE_IP>:32345`.

---

If you'd like, I can:
- Generate the YAML files (deployment.yaml and service.yaml) for you,
- Or create a small readiness/liveness probe example to improve reliability. Which would you prefer?