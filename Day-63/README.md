# Iron Gallery Kubernetes Deployment (iron-namespace-xfusion)

This repository contains a Kubernetes manifest and instructions to deploy the Iron Gallery frontend and its MariaDB backend into a dedicated namespace `iron-namespace-xfusion`.

## Components
- Namespace: `iron-namespace-xfusion`
- Iron Gallery frontend
  - Deployment: `iron-gallery-deployment-xfusion`
  - Container: `iron-gallery-container-xfusion`
  - Image: `kodekloud/irongallery:2.0`
  - Replicas: 1
  - Labels: `run: iron-gallery`
  - Resource limits: `cpu: 50m`, `memory: 100Mi`
  - Volumes:
    - `config` mounted at `/usr/share/nginx/html/data` (emptyDir)
    - `images` mounted at `/usr/share/nginx/html/uploads` (emptyDir)
  - Service: `iron-gallery-service-xfusion` (NodePort)
    - port: 80 -> targetPort: 80
    - nodePort: 32678

- Iron DB (MariaDB)
  - Deployment: `iron-db-deployment-xfusion`
  - Container: `iron-db-container-xfusion`
  - Image: `kodekloud/irondb:2.0`
  - Replicas: 1
  - Labels: `db: mariadb`
  - Environment:
    - `MYSQL_DATABASE=database_host`
    - `MYSQL_ROOT_PASSWORD=Root@12345`
    - `MYSQL_USER=ironuser`
    - `MYSQL_PASSWORD=User@12345`
  - Volume:
    - `db` mounted at `/var/lib/mysql` (PersistentVolumeClaim: `iron-db-pvc-xfusion`)
  - Service: `iron-db-service-xfusion` (ClusterIP)
    - port: 3306 -> targetPort: 3306

> Note: The manifest uses an RWO PVC (`iron-db-pvc-xfusion`) for MariaDB persistence; ensure your cluster has a default StorageClass.

## Deploy
1. Apply the manifest:
```bash
kubectl apply -f iron-gallery-deployment.yaml
```

2. Verify resources in the namespace:
```bash
kubectl get all -n iron-namespace-xfusion
kubectl get pvc -n iron-namespace-xfusion
```

3. Get a node IP (use any worker node address) and open the app:
```bash
kubectl get nodes -o wide
# Open in browser:
# http://<node_ip>:32678
```

You should see the Iron Gallery installation page. If you do not, check pod logs:
```bash
kubectl logs deploy/iron-gallery-deployment-xfusion -n iron-namespace-xfusion
kubectl logs deploy/iron-db-deployment-xfusion -n iron-namespace-xfusion
```

## Troubleshooting
- If PVC remains `Pending` ensure a StorageClass is available and your cluster supports dynamic provisioning.
- If MariaDB fails on startup, check env variables and pod logs.
- Verify Services and selectors match Deployment labels.

## Cleanup
```bash
kubectl delete -f iron-gallery-deployment.yaml
kubectl delete namespace iron-namespace-xfusion
```