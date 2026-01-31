# MySQL Deployment on Kubernetes

This repository contains Kubernetes manifests to deploy a single-replica MySQL 8.0 server with persistent storage, secrets, and a NodePort service for external access (demo purpose).

> WARNING: The examples below include cleartext credentials for demonstration only. Do NOT commit real secrets to a public repository. Prefer creating secrets at deploy time (kubectl create secret ...) or use a secret management system.

## Components

- PersistentVolume (PV)
  - name: `mysql-pv`
  - capacity: `250Mi`
  - accessModes: `ReadWriteOnce`
  - storageClassName: `manual`
  - hostPath: `/mnt/data/mysql` (hostPath is for local/demo use only)
- PersistentVolumeClaim (PVC)
  - name: `mysql-pv-claim`
  - requests: `250Mi`
  - storageClassName: `manual`
- Secrets
  - `mysql-root-pass` → MySQL root password
  - `mysql-user-pass` → MySQL app user + password
  - `mysql-db-url` → database name
- Deployment
  - name: `mysql-deployment`
  - image: `mysql:8.0`
  - mounts PV at `/var/lib/mysql`
  - env vars populated from Kubernetes Secrets:
    - `MYSQL_ROOT_PASSWORD` ← root password secret
    - `MYSQL_DATABASE` ← database name secret
    - `MYSQL_USER` ← user secret
    - `MYSQL_PASSWORD` ← user password secret
- Service
  - type: `NodePort`
  - name: `mysql`
  - nodePort: `30007`
  - exposes MySQL port `3306`

---

## Example Manifests

Save each manifest into the same directory (or separate files) and apply with `kubectl apply -f <file>` or `kubectl apply -f .` if all files are in the same directory.

### 1) PersistentVolume (pv.yaml)
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data/mysql
```

### 2) PersistentVolumeClaim (pvc.yaml)
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
  storageClassName: manual
```

### 3) Secrets (recommended: create at deploy-time, not as files)

Recommended (create secrets via kubectl at deploy time):

```bash
kubectl create secret generic mysql-root-pass --from-literal=password='YUIidhb667'
kubectl create secret generic mysql-user-pass --from-literal=username='kodekloud_aim' --from-literal=password='BruCStnMT5'
kubectl create secret generic mysql-db-url --from-literal=database='kodekloud_db3'
```

If you must store them as files for an offline demo, create secrets manifests (opaque) but avoid committing to source control.

### 4) Deployment (deployment.yaml)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-root-pass
                  key: password
            - name: MYSQL_DATABASE
              valueFrom:
                secretKeyRef:
                  name: mysql-db-url
                  key: database
            - name: MYSQL_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: username
            - name: MYSQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-user-pass
                  key: password
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim
```

### 5) NodePort Service (service.yaml)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
      nodePort: 30007
```

---

## Deployment Steps

1. Ensure directory contains the YAML files listed above (or adjust filenames).
2. Create secrets (preferred):
   - see kubectl create secret commands above.
3. Apply manifests:
```bash
kubectl apply -f .
```
4. Verify resources:
```bash
kubectl get pv,pvc
kubectl get deploy mysql-deployment
kubectl get pods -l app=mysql
kubectl get svc mysql
```

## Connect to MySQL

From any host that can reach a cluster node IP (replace <NodeIP> with a node address):

```bash
mysql -h <NodeIP> -P 30007 -u kodekloud_aim -p
# Enter: BruCStnMT5
# Database: kodekloud_db3
```

If running locally (eg: kind, minikube), use the node IP returned by `minikube ip` or access via `kubectl port-forward`:

```bash
kubectl port-forward svc/mysql 3306:3306
# then connect to localhost:3306
mysql -h 127.0.0.1 -P 3306 -u kodekloud_aim -p
```

## Notes & Best Practices

- hostPath PV is suitable only for single-node demos. For production use dynamic volumes backed by cloud block storage (AWS EBS, GCP PD, Azure Disk) or a CSI driver.
- Do NOT store secrets (passwords) in plaintext in your repo. Use external secret stores (Vault, SealedSecrets, cloud KMS, etc.) or create secrets during deployment.
- Consider using StatefulSet instead of Deployment for production MySQL clusters to get stable network IDs and storage per replica.
- NodePort exposes the DB on cluster nodes; for production consider a LoadBalancer or a Bastion host + private access, and restrict access with network policies / firewalls.
- Back up your MySQL data regularly. PersistentVolumeReclaimPolicy: Retain prevents accidental data loss on PV deletion.

---

If you want, I can:
- split the manifests into separate files and produce them here,
- produce a Kubernetes Job for initial DB/schema bootstrap,
- or generate instructions to migrate to a StatefulSet with dynamic provisioning.