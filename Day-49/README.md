# Day 49 - Kubernetes Deployment: httpd

## 🧩 Task Description
The Nautilus DevOps team is exploring **Kubernetes** for application management.  
One of the tasks is to create a deployment for the `httpd` application using the latest image version.

---

## ⚙️ Requirements
- Create a **Deployment** named `httpd`.
- Use the **image** `httpd:latest`.
- The `kubectl` utility is preconfigured on the `jump_host` to interact with the Kubernetes cluster.

---

## 🛠️ Steps to Complete the Task

1. **Create the Deployment**
   ```bash
   kubectl create deployment httpd --image=httpd:latest
   ```
2. **Verify the Deployment**
   ```bash
   kubectl get deployments
   kubectl get pods
   ```

