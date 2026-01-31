# 🧱 Webserver Pod with Sidecar Log Shipping (Nginx + Ubuntu)

This example demonstrates the Sidecar Pattern in Kubernetes by running a web server (nginx) alongside a sidecar container that reads and ships logs. Both containers share an `emptyDir` volume so the nginx container writes logs to a shared path and the sidecar can read/process/forward them.

## Architecture

- Pod: `webserver`
  - Container `nginx-container` (image: `nginx:latest`) — serves web content and writes logs to `/var/log/nginx`.
  - Container `sidecar-container` (image: `ubuntu:latest`) — continuously reads log files from `/var/log/nginx` (mounted from the same emptyDir).

Shared storage between the containers is provided by an `emptyDir` volume named `shared-logs`.

## Files

- `webserver.yaml` — Pod manifest (nginx + sidecar)
- `README.md` — this file

## webserver.yaml

Save the following as `webserver.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  volumes:
    - name: shared-logs
      emptyDir: {}
  containers:
    - name: nginx-container
      image: nginx:latest
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

    - name: sidecar-container
      image: ubuntu:latest
      command: ["sh", "-c", "while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"]
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
```

> Note: The example sidecar runs a simple loop that concatenates `access.log` and `error.log` (if present) every 30 seconds. In production you would replace this with a proper log shipper/agent (Fluentd, Filebeat, Vector, custom script, etc.) and handle rotation/offsets.

## Prerequisites

- Kubernetes cluster (local or managed)
- kubectl configured to talk to your cluster
- Internet access to pull `nginx:latest` and `ubuntu:latest` images (or use locally available images)

## Deployment Steps

1. Apply the Pod manifest:

   ```bash
   kubectl apply -f webserver.yaml
   ```

2. Verify the pod is running:

   ```bash
   kubectl get pods
   ```

3. Check sidecar logs (this shows the output of the cat loop):

   ```bash
   kubectl logs webserver -c sidecar-container
   ```

4. (Optional) Inspect the nginx container's log directory:

   ```bash
   kubectl exec -it webserver -c nginx-container -- ls -la /var/log/nginx
   kubectl exec -it webserver -c nginx-container -- tail -n 50 /var/log/nginx/access.log
   ```

5. (Optional) Enter the sidecar container to debug:

   ```bash
   kubectl exec -it webserver -c sidecar-container -- bash
   ```

## How it works

- Nginx writes its logs to `/var/log/nginx` inside the nginx container.
- The `shared-logs` `emptyDir` volume is mounted at the same path in the sidecar, so the sidecar can read the files written by nginx.
- `emptyDir` lives on the node’s filesystem for the lifetime of the Pod. When the Pod is removed, the data in the `emptyDir` is deleted.

## Testing tips

- Generate traffic against nginx to produce logs. For example, port-forward nginx (if nginx is listening on the pod IP):

  ```bash
  kubectl port-forward pod/webserver 8080:80
  curl http://localhost:8080/
  ```

- After generating traffic, check the sidecar logs or the files under `/var/log/nginx` to confirm entries were created.

## Cleanup

Remove the pod when finished:

```bash
kubectl delete -f webserver.yaml
```

## Limitations & Notes

- This example uses a single Pod (not a Deployment). For real workloads you will typically use a Deployment or DaemonSet and a log shipping solution that can handle multiple replicas.
- `emptyDir` is ephemeral and not suitable for long-term persistence.
- The example sidecar simply prints log files; it does not handle log rotation, offsets, checkpointing, or remote delivery guarantees.
- Running a shell loop inside an Ubuntu container is only for demonstration — use a purpose-built log agent for production.

## Suggestions for improvement / productionization

- Replace the sidecar with a log agent (Fluentd, Filebeat, Vector) that forwards logs to Elasticsearch, Loki, S3, or another sink.
- Use a Deployment + Service for scalable web serving.
- Use ConfigMaps to provide custom nginx configuration and log format.
- Use a PVC (PersistentVolume) if you need logs to survive Pod restarts (careful with multiple writers).
- Add health checks (readiness/livenessProbes) for both containers.
- Consider structured logging and JSON output to simplify parsing.

## License

This example is provided as-is for learning and demonstration purposes. Use and modify freely.

---

If you want, I can:
- Convert this Pod into a Deployment + Service example.
- Replace the sidecar with a Fluentd / Filebeat configuration and provide manifests.
- Add a sample static index.html and nginx ConfigMap so nginx serves custom content.
Which would you like next?