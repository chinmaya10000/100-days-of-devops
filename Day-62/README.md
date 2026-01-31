# Kubernetes Secret and Pod Deployment — Nautilus DevOps

Objective
- Securely store license/password from the jump host at `/opt/official.txt` in a Kubernetes Secret named `official` and mount it into a Pod `secret-datacenter` at `/opt/apps`.

Prerequisites
- kubectl configured to talk to the target cluster.
- The file `/opt/official.txt` must exist on the machine where you run `kubectl create secret ...` (the jump host).

Steps

1) Create the Secret
- Create the Kubernetes Secret from the local file:
```bash
kubectl create secret generic official --from-file=/opt/official.txt
```
- Verify creation:
```bash
kubectl get secrets
kubectl describe secret official
```
Note: The secret key will be named `official.txt` (the filename). When mounted, this will appear as `/opt/apps/official.txt` inside the container.

2) Create the Pod manifest
- Save the following YAML to `secret-pod.yaml`:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-datacenter
spec:
  containers:
    - name: secret-container-datacenter
      image: fedora:latest
      command: ["sleep", "3600"]
      volumeMounts:
        - name: secret-volume
          mountPath: /opt/apps
  volumes:
    - name: secret-volume
      secret:
        secretName: official
```
- Apply the manifest:
```bash
kubectl apply -f secret-pod.yaml
```

3) Verify Pod status
```bash
kubectl get pods
# Expected example:
# NAME                 READY   STATUS    RESTARTS   AGE
# secret-datacenter    1/1     Running   0          1m
```

4) Validate the secret is mounted inside the container
- Enter the container:
```bash
kubectl exec -it secret-datacenter -- /bin/bash
```
- Inside the container:
```bash
ls -l /opt/apps
cat /opt/apps/official.txt
```
You should see the file `official.txt` and its contents should match `/opt/official.txt` from the host where you created the secret.

Troubleshooting
- If the Pod is `Pending`, check events:
```bash
kubectl describe pod secret-datacenter
```
- If `kubectl exec` fails with a shell error, `fedora:latest` may not include `/bin/bash` in some minimal images — use `/bin/sh` instead:
```bash
kubectl exec -it secret-datacenter -- /bin/sh
```
- If the secret key name differs, inspect `kubectl describe secret official` to see the key names and expected filenames when mounted.

Cleanup
```bash
kubectl delete pod secret-datacenter
kubectl delete secret official
rm secret-pod.yaml
```

Notes
- Secrets are base64-encoded in the Kubernetes API; they are not encrypted by default at rest unless you enable encryption at rest in your cluster.
- Mounting the secret as a volume makes each key a file. If you need environment variables instead, use `envFrom` or `env` with `secretKeyRef`.