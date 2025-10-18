# 🚀 Day 50: Resource Limits in Kubernetes

### 🧩 Objective
The Nautilus DevOps team noticed performance issues in some Kubernetes-hosted applications due to improper resource allocation.  
To optimize performance and ensure fair scheduling, we will define resource **requests** and **limits** for containers.

---

### ⚙️ Task Details

Create a **Pod** named `httpd-pod` with the following specifications:

| Parameter | Value |
|------------|--------|
| **Container Name** | `httpd-container` |
| **Image** | `httpd:latest` |
| **Requests** | Memory: `15Mi`, CPU: `100m` |
| **Limits** | Memory: `20Mi`, CPU: `100m` |

---

### 📝 Manifest File — `httpd-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd-pod
spec:
  containers:
    - name: httpd-container
      image: httpd:latest
      resources:
        requests:
          memory: "15Mi"
          cpu: "100m"
        limits:
          memory: "20Mi"
          cpu: "100m"
```