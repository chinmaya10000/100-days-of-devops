# Redis Deployment on Kubernetes

This example demonstrates how to deploy a single Redis instance on Kubernetes using a Deployment and a ConfigMap (for Redis configuration). This setup is intended for testing; do not use this configuration as-is in production.

## Components

1. ConfigMap
   - Name: `my-redis-config`
   - Key: `redis.conf`
   - Contains Redis configuration:
   ```text
   maxmemory 2mb
   ```

2. Deployment
   - Name: `redis-deployment`
   - Image: `redis:alpine`
   - Container name: `redis-container`
   - Replicas: 1
   - CPU request: 1
   - Port: 6379

3. Volumes
   - `data` → `emptyDir` mounted at `/redis-master-data`
   - `redis-config` → ConfigMap mounted at `/redis-master` (file: `/redis-master/redis.conf`)

## Prerequisites

- kubectl configured on `jump_host` with access to the target Kubernetes cluster.
- You are using this for testing only.

## Files

- `redis-configmap.yaml` — the ConfigMap with `redis.conf`
- `redis-deployment.yaml` — the Deployment that mounts the ConfigMap and runs Redis

## Apply the resources

1. Create the ConfigMap:
```bash
kubectl apply -f redis-configmap.yaml
```

2. Create the Deployment:
```bash
kubectl apply -f redis-deployment.yaml
```

## Verify deployment

Check deployments and pods:
```bash
kubectl get deployments
kubectl get pods -l app=redis
```
Ensure the Deployment shows 1/1 available and the pod status is `Running`.

## Verify Redis configuration (maxmemory)

Exec into the Redis pod and use redis-cli to check memory info:

1. Obtain the pod name (example):
```bash
POD=$(kubectl get pods -l app=redis -o jsonpath='{.items[0].metadata.name}')
```

2. Exec and run INFO memory:
```bash
kubectl exec -it "$POD" -- redis-cli INFO memory
```

Look for the `maxmemory` line. Expected value:
```
maxmemory:2097152
```
(2 MB = 2 * 1024 * 1024 = 2097152 bytes)

## Cleanup

Remove both resources:
```bash
kubectl delete -f redis-deployment.yaml
kubectl delete -f redis-configmap.yaml
```

## Notes / Next steps

- This example mounts the ConfigMap as a file and explicitly starts Redis with that config: `redis-server /redis-master/redis.conf`. Adjust the mount path or start command if you change image/version.
- For production, consider:
  - Persistent volume (PVC) instead of `emptyDir`
  - Resource limits + requests tuned for your workloads
  - Security context, network policies, readiness/liveness probes, and backup/HA