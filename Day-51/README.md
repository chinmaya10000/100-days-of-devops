# Kubernetes Rolling Update – nginx Application

## Objective
Perform a rolling update on the existing Kubernetes deployment `nginx-deployment` to integrate a new image `nginx:1.19`, ensuring all pods are operational post-update.

---

## Prerequisites
- `kubectl` installed and configured to access the target Kubernetes cluster.
- Existing deployment named `nginx-deployment` running on the cluster.

---

## Steps Performed

### 1. Verify current deployment
```bash
kubectl get deployments
kubectl describe deployment nginx-deployment
```

### 2. Check current pods
```bash
kubectl get pods -l app=nginx
```

### 3. Update deployment image (Rolling Update)
```bash
kubectl set image deployment/nginx-container nginx=nginx:1.19
```

### 4. Monitor rollout status
```bash
kubectl rollout status deployment/nginx-deployment
```

### 5. Verify updated deployment
```bash
kubectl get deployment nginx-deployment -o wide
kubectl describe deployment nginx-deployment | grep Image
```

### 6. Confirm all pods are running
```bash
kubectl get pods -l app=nginx
```

### 7. (Optional) Rollback if needed
```bash
kubectl rollout undo deployment/nginx-deployment
```