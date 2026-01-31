# 🧱 Kubernetes Init Container Deployment — `ic-deploy-devops`

## 📘 Overview
This example demonstrates using an Init Container in Kubernetes to perform a setup task before the main application container starts.

- The init container writes a welcome message to a shared volume.
- The main container continuously reads and prints that message.

This pattern is useful when you need to perform initialization steps that cannot be baked into the main image.

---

## ⚙️ Deployment Summary

- Deployment name: `ic-deploy-devops`  
- Replicas: `1`  
- App label: `ic-devops`  
- Init container name: `ic-msg-devops`  
- Main container name: `ic-main-devops`  
- Image used: `debian:latest`  
- Shared volume name: `ic-volume-devops` (type: `emptyDir`)  
- Mount path: `/ic`  
- File written by init container: `/ic/ecommerce`  

---

## 🧩 Init Container
Name: `ic-msg-devops`  
Purpose: Write the welcome message into the shared volume before the main container starts.

Command:
```bash
/bin/bash -c "echo Init Done - Welcome to xFusionCorp Industries > /ic/ecommerce"
```

## 🚀 Main Container
Name: `ic-main-devops`  
Purpose: Continuously read and display the message written by the init container.

Command:
```bash
/bin/bash -c "while true; do cat /ic/ecommerce; sleep 5; done"
```

---

## 📄 Deployment manifest (save as ic-deploy-devops.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ic-deploy-devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ic-devops
  template:
    metadata:
      labels:
        app: ic-devops
    spec:
      initContainers:
      - name: ic-msg-devops
        image: debian:latest
        command:
          - /bin/bash
          - -c
          - >
            echo Init Done - Welcome to xFusionCorp Industries > /ic/ecommerce
        volumeMounts:
        - name: ic-volume-devops
          mountPath: /ic

      containers:
      - name: ic-main-devops
        image: debian:latest
        command:
          - /bin/bash
          - -c
          - >
            while true; do cat /ic/ecommerce; sleep 5; done
        volumeMounts:
        - name: ic-volume-devops
          mountPath: /ic

      volumes:
      - name: ic-volume-devops
        emptyDir: {}
```

---

## 🧰 How to deploy
1. Save the manifest above as `ic-deploy-devops.yaml`.
2. Apply it:
```bash
kubectl apply -f ic-deploy-devops.yaml
```
3. Verify pods:
```bash
kubectl get pods -l app=ic-devops
```
4. View logs of the pod (replace <pod-name>):
```bash
kubectl logs -f <pod-name>
```

---

## ✅ Expected output in logs
You should see the message printed every ~5 seconds:
```
Init Done - Welcome to xFusionCorp Industries
```

---

## ⚠️ Notes / Troubleshooting
- If `kubectl logs` shows nothing, ensure the pod is `Running` and not `Init:0/1` (this means the init container hasn't finished or has failed).
- If the init container fails, check its logs with:
```bash
kubectl logs <pod-name> -c ic-msg-devops
```
- Using `debian:latest` assumes `/bin/bash` is available. If you use a minimal image (e.g., `alpine`), adjust commands accordingly (e.g., use `sh`).

---