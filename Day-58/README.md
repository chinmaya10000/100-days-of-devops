# 🧠 Grafana Deployment on Kubernetes

## Overview
This repository contains a simple Kubernetes manifest to deploy Grafana and expose it via a NodePort service. Grafana provides dashboards and visualizations for application metrics and logs.

---

## Deployment details
- Deployment name: `grafana-deployment-datacenter`  
- Service name: `grafana-service` (NodePort)  
- NodePort: `32000`  
- Container image: `grafana/grafana:latest`  
- Container port: `3000` (Grafana UI)

---

## Files
- `grafana-deployment.yaml` — Kubernetes manifest defining the Deployment and NodePort Service.

---

## Prerequisites
- A working Kubernetes cluster (minikube, kind, managed cluster, etc.)
- kubectl configured for the target cluster
- (Optional) Appropriate cluster permissions to create Deployments and Services

---

## Deploy

1. Apply the manifest:
```bash
kubectl apply -f grafana-deployment.yaml
```

2. Verify resources:
```bash
kubectl get deployments
kubectl get pods
kubectl get svc
```

Example output for the service:
```text
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
grafana-service   NodePort   10.0.0.45      <none>        3000:32000/TCP   1m
```

---

## Access Grafana

- From a browser open:
  http://<NodeIP>:32000

- To find a NodeIP:
  - For a multi-node cluster:
    ```bash
    kubectl get nodes -o wide
    ```
    Use the `EXTERNAL-IP` or `INTERNAL-IP` reachable from your network.
  - For minikube:
    ```bash
    minikube ip
    ```
    then visit `http://$(minikube ip):32000`

- Alternative (if you cannot access NodePort): port-forward the pod to localhost:
```bash
# find a grafana pod name
kubectl get pods -l app=grafana

# port-forward (assumes pod name is grafana-xxxxx)
kubectl port-forward pod/<grafana-pod-name> 3000:3000

# then open
http://localhost:3000
```

---

## Default credentials
- Username: `admin`  
- Password: `admin`  
Grafana will usually prompt you to change the password on first login—do so.

---

## Cleanup
To remove the Grafana deployment and service:
```bash
kubectl delete -f grafana-deployment.yaml
```

---

## Troubleshooting
- Pod not starting: check logs
  ```bash
  kubectl logs pod/<grafana-pod-name>
  ```
- Service not reachable:
  - Verify NodePort is `32000` in `kubectl get svc`.
  - Ensure cluster nodes allow traffic on the NodePort range (default 30000-32767).
  - If running in a cloud provider, ensure security groups / firewall rules permit access.
- Image pull issues: ensure cluster nodes have internet access or use a private registry if required.

---

## Security notes
- Exposing Grafana via a NodePort on a public network is not recommended for production. Consider:
  - Using an Ingress with TLS and authentication.
  - Limiting access via network policies or firewall rules.
  - Enabling and enforcing strong Grafana authentication and RBAC.

---

If you'd like, I can:
- Review or improve the existing `grafana-deployment.yaml`.
- Convert this setup to a LoadBalancer or Ingress-based deployment with TLS.
- Add persistence (PVC) for Grafana data and a proper ConfigMap/Secret for provisioning and credentials.
```