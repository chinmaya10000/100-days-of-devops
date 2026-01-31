# nginx + php-fpm Pod Fix Guide

## Summary
This README describes a reproducible issue and the steps to fix an nginx + PHP-FPM pod that stopped serving PHP files because the two containers in the same Pod mounted the shared volume at different paths.

## Root cause
The nginx and php-fpm containers mounted the same shared volume at different mount paths:

- nginx-container: `/var/www/html`
- php-fpm-container: `/usr/share/nginx/html`

Nginx looked for `index.php` under `/var/www/html` while PHP-FPM looked under `/usr/share/nginx/html`, so PHP files could not be found/executed.

## Solution overview
Ensure both containers mount the shared volume at the same path (for example, `/var/www/html`). If the pod is unmanaged (not part of a Deployment/ReplicaSet), delete and recreate it with the corrected pod spec.

## Prerequisites
- kubectl configured to talk to the cluster
- access to the pod YAML (or ability to export it)
- PHP file to copy into the pod (e.g., `index.php`)

## Step-by-step fix

1. Export the current pod definition
```bash
kubectl get pod nginx-phpfpm -o yaml > pod-fixed.yaml
```

2. Edit `pod-fixed.yaml`
- Open `pod-fixed.yaml` in your editor.
- Find the `containers:` section and ensure both containers mount the shared volume to the exact same path, e.g. `/var/www/html`.

Example snippet to use in the pod spec:
```yaml
containers:
  - name: php-fpm-container
    image: php:7.2-fpm-alpine
    volumeMounts:
      - name: shared-files
        mountPath: /var/www/html

  - name: nginx-container
    image: nginx:latest
    volumeMounts:
      - name: shared-files
        mountPath: /var/www/html
      - name: nginx-config-volume
        mountPath: /etc/nginx/nginx.conf
        subPath: nginx.conf
```

3. Recreate the Pod
If the pod is not managed by a higher-level controller (Deployment/ReplicaSet), delete and recreate it:
```bash
kubectl delete pod nginx-phpfpm
kubectl apply -f pod-fixed.yaml
```
Wait for the pod to become `Running`:
```bash
kubectl get pods
```

4. Copy the PHP file into the document root
From your jump host:
```bash
kubectl cp /home/thor/index.php nginx-phpfpm:/var/www/html -c nginx-container
```

5. Verify both containers see the same file
List the directory in both containers:
```bash
kubectl exec -it nginx-phpfpm -c nginx-container -- ls /var/www/html
kubectl exec -it nginx-phpfpm -c php-fpm-container -- ls /var/www/html
```
Expected output:
```
index.php
```

6. Test the website
Access via the lab Website button or NodePort (example):
```
http://<NodeIP>:30008
```
You should see the PHP page rendered.

## Verification commands
Check file contents from both containers:
```bash
kubectl exec -it nginx-phpfpm -c nginx-container -- cat /var/www/html/index.php
kubectl exec -it nginx-phpfpm -c php-fpm-container -- cat /var/www/html/index.php
```

Validate nginx config and PHP-FPM connectivity:
```bash
kubectl exec -it nginx-phpfpm -c nginx-container -- nginx -t
kubectl exec -it nginx-phpfpm -c nginx-container -- curl http://127.0.0.1:8099/index.php
```

## Troubleshooting
- If `kubectl apply -f pod-fixed.yaml` fails, inspect YAML for indentation/errors.
- If the file is not visible in one container, confirm `volumeMounts.name` matches a `volumes` entry in the Pod spec.
- If PHP returns 502/504 from nginx, check PHP-FPM is running and listening on the expected socket/port and that nginx upstream points to it.
- If you use `subPath` for nginx config, ensure correct `subPath` value and that the file exists in the ConfigMap/volume.

## Recommendations (best practices)
- Prefer Deployments/ReplicaSets instead of creating naked pods so changes are declarative and pods are managed.
- Use a PersistentVolumeClaim (PVC) for shared files rather than ephemeral emptyDir if persistence is required.
- Keep the document root path consistent and documented; set it via environment variables if helpful.
- Use a ConfigMap for `nginx.conf` and mount it read-only.
- Add readiness/liveness probes to ensure traffic is only sent to healthy containers.

## Example minimal Pod volume section (for reference)
```yaml
volumes:
  - name: shared-files
    emptyDir: {}
  - name: nginx-config-volume
    configMap:
      name: nginx-config
```

---

If you'd like, I can:
- produce a corrected `pod-fixed.yaml` example based on your current YAML (paste it here),
- convert this into a Deployment manifest,
- or add a small healthcheck config for nginx and php-fpm.