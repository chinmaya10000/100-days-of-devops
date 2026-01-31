# 🧰 Redis Deployment Fix — Kubernetes

## Overview
This document explains a recent outage where the Redis deployment entered a `Pending` state due to two typos introduced in a configuration change. It covers the observed error, root cause, exact fix steps, example manifests, and verification commands.

---

## Problem summary
Redis pods were stuck in `Pending`.

Observed error (from `kubectl describe pod <pod>`):
```
MountVolume.SetUp failed for volume "config": configmap "redis-cofig" not found
```

Root causes
- Typo in the referenced ConfigMap name: `redis-cofig` → should be `redis-config`.
- Typo in the Docker image name: `redis:alpin` → should be `redis:alpine`.

---

## Fix steps

1. Inspect cluster objects
```bash
# Check deployments, pods, and configmaps
kubectl get deployment redis-deployment -o wide
kubectl get pods -l app=redis -o wide
kubectl get configmaps
```

2. If the ConfigMap is missing, create it (example below). If it exists but the deployment references the wrong name, update the deployment.

Example ConfigMap (create this if missing):
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  redis.conf: |
    # Minimal example redis.conf
    maxmemory 256mb
    maxmemory-policy allkeys-lru
```

Create it with:
```bash
kubectl apply -f redis-config.yaml
```

3. Update the Deployment image (Option A or B)

Option A — edit manually:
```bash
kubectl edit deployment redis-deployment
```
Then update the container image to:
```yaml
image: redis:alpine
```
and ensure the volume configMap name is `redis-config`.

Option B — patch via kubectl commands (non-interactive):
```bash
# Update image
kubectl set image deployment/redis-deployment redis-container=redis:alpine

# Patch the deployment to ensure the ConfigMap volume references the correct name
kubectl patch deployment redis-deployment --patch '{
  "spec": {
    "template": {
      "spec": {
        "volumes": [
          {
            "name": "config",
            "configMap": { "name": "redis-config" }
          }
        ]
      }
    }
  }
}'
```
Note: The above strategic-merge patch replaces (or adds) a `volumes` entry named `config` with the correct ConfigMap reference. If your deployment's `volumes` list uses different ordering or names, use `kubectl edit` to be safe.

4. Rollout and verify
```bash
kubectl rollout status deployment/redis-deployment
kubectl get pods -o wide
kubectl describe pod <new-redis-pod>   # check for mounting and container status
kubectl logs <new-redis-pod>           # verify Redis started successfully
```

Expected output for healthy pod:
```
NAME                                   READY   STATUS    RESTARTS   AGE
redis-deployment-xxxxxxx-yyyyy         1/1     Running   0          1m
```

---

## Outcome
- Fixed incorrect image name and ConfigMap reference.
- Redis pods successfully scheduled, mounted, and are running.
- Cluster health restored.

---

## Troubleshooting tips
- If pods still remain `Pending`, run:
  ```bash
  kubectl describe pod <pod-name>
  kubectl get events --sort-by='.metadata.creationTimestamp'
  ```
  Look for scheduling issues (insufficient resources), PVC problems, or other volume errors.
- If ConfigMap changes don’t propagate, you may need to trigger a rollout restart:
  ```bash
  kubectl rollout restart deployment/redis-deployment
  ```
- For image pull errors, inspect `kubectl describe pod <pod>` and `kubectl logs` for details.

---

## Contact
If you need help applying these fixes or want me to generate a PR with the corrected manifests, ping the DevOps team.