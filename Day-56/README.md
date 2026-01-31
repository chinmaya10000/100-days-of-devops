# 56 - Nginx Kubernetes Deployment

This project deploys a highly-available, scalable static Nginx website on a Kubernetes cluster using a Deployment and a NodePort Service.

---

## Summary

- Deployment name: `nginx-deployment`  
- Container name: `nginx-container`  
- Image: `nginx:latest`  
- Replicas: `3`  
- Container port: `80`

- Service name: `nginx-service`  
- Service type: `NodePort`  
- NodePort: `30011`  
- Service port -> target port: `80 -> 80`

The Deployment runs 3 replicas of the Nginx pod for availability. The NodePort Service exposes the pods outside the cluster on port `30011` of every node.

---

## Files

- `nginx-deployment.yaml` — Deployment manifest
- `nginx-service.yaml` — NodePort Service manifest

Example manifests are included below.

### nginx-deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
```

### nginx-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30011
```

---

## How to deploy

1. Apply the Deployment:
```bash
kubectl apply -f nginx-deployment.yaml
```

2. Apply the Service:
```bash
kubectl apply -f nginx-service.yaml
```

3. Verify Deployment, Pods and Service:
```bash
kubectl get deployments
kubectl get pods
kubectl get svc nginx-service
```

Example output for the deployment (expected):
```text
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment  3/3     3            3           1m
```

---

## Access the application

Open your browser or use curl to access the Nginx server:

```bash
http://<NodeIP>:30011
```

Replace `<NodeIP>` with the IP address of any Kubernetes node (use `kubectl get nodes -o wide` to list node IPs).

If you're using a local cluster (e.g., minikube), you can run:
```bash
minikube ip
# then: http://<minikube-ip>:30011
```
or use
```bash
minikube service nginx-service --url
```

---

## Troubleshooting

- Ensure NodePort `30011` is within the allowed range (default: `30000-32767`) and not already in use.
- If you cannot reach the service from outside the cluster:
  - Verify node firewall rules allow inbound traffic on `30011`.
  - Confirm the service is targeting pods with the correct label: `app: nginx`.
  - Check pod logs and status:
    ```bash
    kubectl get pods -l app=nginx
    kubectl logs <nginx-pod-name>
    kubectl describe pod <nginx-pod-name>
    kubectl describe svc nginx-service
    ```
- For cluster environments like GKE, AKS, EKS, you may need to configure cloud provider firewall rules or use a LoadBalancer Service type instead for a managed external IP.

---

## Notes

- This deployment serves the default Nginx static page. To serve custom content, mount a ConfigMap, an emptyDir with a build step, or use a custom image containing your static site files.
- Consider using a Service of type `LoadBalancer` or an Ingress controller for production environments (to obtain stable external IPs, TLS termination, and path/host routing).

---

## License

This repository has no explicit license. Add one if you plan to share publicly (e.g., MIT, Apache-2.0).
