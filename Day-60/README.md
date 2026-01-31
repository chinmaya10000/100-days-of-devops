# 🐳 Nautilus DevOps – Kubernetes Web Application Deployment

This project deploys a simple web application using Apache HTTP Server (`httpd`) on a Kubernetes cluster. It demonstrates usage of a PersistentVolume (hostPath), PersistentVolumeClaim, a Pod that mounts the PVC, and a NodePort Service exposing the application.

## Kubernetes Resources

- PersistentVolume
  - Name: `pv-devops`
  - Storage Class: `manual`
  - Capacity: `4Gi`
  - Access Mode: `ReadWriteOnce`
  - Type: `hostPath`
  - Host Path: `/mnt/finance`

- PersistentVolumeClaim
  - Name: `pvc-devops`
  - Storage Class: `manual`
  - Requested Storage: `2Gi`
  - Access Mode: `ReadWriteOnce`

- Pod
  - Name: `pod-devops`
  - Container Name: `container-devops`
  - Image: `httpd:latest`
  - Mount Path: `/usr/local/apache2/htdocs`
  - Mounted Volume: `pvc-devops`

- Service
  - Name: `web-devops`
  - Type: `NodePort`
  - Node Port: `30008`
  - Exposes Port: `80`

## Files in this folder

- `devops-webapp.yaml` — Kubernetes manifest with the PV, PVC, Pod, and Service definitions.

## Deployment Steps

1. Apply the manifest:

```bash
kubectl apply -f devops-webapp.yaml
```

2. Check the status of resources:

```bash
kubectl get pv
kubectl get pvc
kubectl get pods
kubectl get svc web-devops
```

3. Find a node IP to access the NodePort:

```bash
kubectl get nodes -o wide
```

Open the app in your browser:

http://<NodeIP>:30008

(Replace `<NodeIP>` with one of the cluster node IPs listed by `kubectl get nodes -o wide`.)

## Verification

To inspect details:

```bash
kubectl describe pv pv-devops
kubectl describe pvc pvc-devops
kubectl logs pod-devops
kubectl describe svc web-devops
```

Expected:
- PVC should show as Bound to the PV.
- Pod should be in `Running` state (or show the container starting logs).
- Service `web-devops` should expose port `30008`.

## Notes and Troubleshooting

- The host directory `/mnt/finance` is expected to already exist on the node(s). Confirm it exists and is accessible by kubelet and container processes.
- hostPath volumes tie pods to nodes. If your pod gets scheduled to a node that does not have `/mnt/finance`, it may fail to serve data as expected.
- Ensure node firewall/host network allows access to the NodePort (30008).
- If the Pod fails, inspect events and container logs:
  - `kubectl describe pod pod-devops`
  - `kubectl logs pod-devops`
- You can change storage sizes or the container image as needed.

## Cleanup

To remove resources:

```bash
kubectl delete -f devops-webapp.yaml
```

That's all — apply the manifest and verify the resources as shown above. If you want, I can:
- Convert the Pod into a Deployment for higher availability,
- Add a ConfigMap for custom Apache content,
- Or generate a Helm chart for repeatable installs.