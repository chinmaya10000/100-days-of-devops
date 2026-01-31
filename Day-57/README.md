# 57 - Print Envars Greeting Pod

## 🧩 Overview
This Kubernetes configuration creates a simple Pod that prints a greeting message using environment variables. It runs a shell container that echoes three variables: `GREETING`, `COMPANY`, and `GROUP`.

---

## 🏗️ Pod Details
- **Pod name:** `print-envars-greeting`  
- **Container name:** `print-env-container`  
- **Image used:** `bash` (you can substitute an image that includes `/bin/sh`, e.g., `alpine` or `busybox`)  
- **Restart policy:** `Never`  
- **Environment variables:**
  - `GREETING = "Welcome to"`
  - `COMPANY = "xFusionCorp"`
  - `GROUP = "Ltd"`

---

## 📄 Pod YAML
Create a file named `print-envars-greeting.yaml` with the following contents:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: print-envars-greeting
spec:
  containers:
    - name: print-env-container
      image: bash
      command: ["/bin/sh", "-c", 'echo "$GREETING $COMPANY $GROUP"']
      env:
        - name: GREETING
          value: "Welcome to"
        - name: COMPANY
          value: "xFusionCorp"
        - name: GROUP
          value: "Ltd"
  restartPolicy: Never
```

Note: The command uses `$GREETING`, `$COMPANY`, and `$GROUP` (shell variable expansion). The original `$(GREETING)` form is incorrect for shell variable expansion.

---

## 🚀 Steps to deploy

1. Create the YAML file:
```bash
nano print-envars-greeting.yaml
# paste the YAML above and save
```

2. Apply the configuration:
```bash
kubectl apply -f print-envars-greeting.yaml
```

3. Check Pod status:
```bash
kubectl get pods
```

4. View the Pod output (logs):
```bash
kubectl logs -f print-envars-greeting
```

---

## ✅ Expected output
```
Welcome to xFusionCorp Ltd
```

---

## Troubleshooting / Notes
- If the `bash` image is not available in your cluster, use `alpine` or `busybox` and the command will still work because both supply `/bin/sh`:
  - Example: change `image: bash` to `image: alpine` (or `image: busybox`).
- Because `restartPolicy` is `Never`, once the Pod completes and exits, it will not be restarted. Use `kubectl logs` to fetch its output after it finishes.