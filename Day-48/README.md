# Kubernetes Pod Creation: httpd Example

The Nautilus DevOps team is diving into Kubernetes for application management.  
This guide helps you create a pod running an Apache HTTP Server (`httpd`).

---

## Pod Specifications

- **Pod Name:** `pod-httpd`
- **Container Image:** `httpd:latest`
- **Container Name:** `httpd-container`
- **Label:** `app=httpd_app`
- **Restart Policy:** `Never`

---

## Steps to Create the Pod

### 1️⃣ Create the Pod Using `kubectl` Command

```sh
kubectl run pod-httpd \
  --image=httpd:latest \
  --restart=Never \
  --labels=app=httpd_app \
  --port=80
```

This command will:
- Create a pod named `pod-httpd`
- Use the `httpd:latest` image
- Label it with `app=httpd_app`
- Name the container `httpd-container` (kubectl assigns this automatically if not set)
- Expose port 80

> **Note:** To generate a YAML file instead of directly creating the pod, use:
>
> ```sh
> kubectl run pod-httpd \
>   --image=httpd:latest \
>   --restart=Never \
>   --labels=app=httpd_app \
>   --dry-run=client -o yaml > pod-httpd.yaml
> ```

---

### 2️⃣ Apply the YAML File (if generated)

```sh
kubectl apply -f pod-httpd.yaml
```

---

### 3️⃣ Verify Pod Creation

```sh
kubectl get pods
kubectl get pod pod-httpd -o wide
kubectl describe pod pod-httpd
```

---

## Example YAML (`pod-httpd.yaml`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-httpd
  labels:
    app: httpd_app
spec:
  containers:
    - name: httpd-container
      image: httpd:latest
      ports:
        - containerPort: 80
  restartPolicy: Never
```

---

## 🧠 Notes

- The `httpd` image automatically starts an Apache HTTP Server.
- `restartPolicy: Never` ensures the pod won't be recreated automatically if it stops.
- You can access logs using:
  ```sh
  kubectl logs pod-httpd
  ```

---