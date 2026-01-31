# Shared Volume Pod Example — Nautilus DevOps

This example demonstrates how to share a single volume between multiple containers inside the same Kubernetes Pod using the `emptyDir` volume type. Two containers mount the same volume at different paths and can read/write the same files.

- Pod name: `volume-share-nautilus`
- Volume type: `emptyDir`
- Volume name: `volume-share`
- Containers:
  - `volume-container-nautilus-1` → mounts `/tmp/news`
  - `volume-container-nautilus-2` → mounts `/tmp/cluster`

## Files

- `volume-share-nautilus.yaml` — Pod manifest (included below)
- `README.md` — this file

## Pod manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-share-nautilus
spec:
  containers:
    - name: volume-container-nautilus-1
      image: debian:latest
      command: ["sleep", "10000"]
      volumeMounts:
        - name: volume-share
          mountPath: /tmp/news

    - name: volume-container-nautilus-2
      image: debian:latest
      command: ["sleep", "10000"]
      volumeMounts:
        - name: volume-share
          mountPath: /tmp/cluster

  volumes:
    - name: volume-share
      emptyDir: {}
```

## How to deploy

1. Apply the manifest:

```bash
kubectl apply -f volume-share-nautilus.yaml
```

2. Wait for the pod to be running:

```bash
kubectl get pods
# or to watch status:
kubectl wait --for=condition=Ready pod/volume-share-nautilus --timeout=60s
```

## Test the shared volume

1. Create a file from the first container:

```bash
kubectl exec -it volume-share-nautilus -c volume-container-nautilus-1 -- bash
# inside container:
echo "Shared volume test" > /tmp/news/news.txt
cat /tmp/news/news.txt
exit
```

2. Read the file from the second container:

```bash
kubectl exec -it volume-share-nautilus -c volume-container-nautilus-2 -- bash
# inside container:
cat /tmp/cluster/news.txt
exit
```

You should see:

```
Shared volume test
```

## Cleanup

Remove the pod when finished:

```bash
kubectl delete pod volume-share-nautilus
```

## Notes and caveats

- `emptyDir` is ephemeral and tied to the Pod lifecycle — data is lost when the Pod is removed or restarted on a different node.
- Use `persistentVolumeClaim` (PVC) if you need data to persist beyond Pod lifetime or to share data across Pods.
- File permissions: containers run as root by default in this example (Debian image). If you run containers with non-root users, ensure the mounted directory permissions/ownership allow read/write access for the intended user.
- This example mounts the same `emptyDir` at different paths to demonstrate sharing; both paths point to the same underlying volume.

If you want, I can also:
- Create a version using a PVC (PersistentVolumeClaim)
- Add a brief script to automatically test write/read and report results
- Convert this to a multi-Pod example using a shared PVC

```