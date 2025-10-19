# 🧠 Day 52 - Rollback Kubernetes Deployment

## **Scenario**
Earlier today, the Nautilus DevOps team deployed a new release for an application.  
However, a customer has reported a bug in this recent release.  
The team needs to revert to the **previous version** of the deployment.

A deployment named **`nginx-deployment`** exists in the cluster.  
Your task is to **roll back this deployment to the previous revision**.

---

## **Environment Details**
- You are working on the **jump_host**.
- The `kubectl` utility is already configured to interact with the Kubernetes cluster.

---

## **Steps to Complete the Task**

### 🧩 Step 1: Verify current deployments
```bash
kubectl get deployments
```

### 🧩 Step 2: Check the rollout history of the deployment
```bash
kubectl rollout history deployment/nginx-deployment
```

### 🧩 Step 3: Roll back the deployment to the previous revision
```bash
kubectl rollout undo deployment/nginx-deployment
```
### 🧩 Step 4: Verify the rollback
```bash
kubectl rollout status deployment nginx-deployment
```