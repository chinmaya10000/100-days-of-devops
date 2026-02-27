# Nautilus App Deployment — Jenkins CI/CD Pipeline

This repository contains documentation for automated deployment of the Nautilus "web" application using Jenkins. The pipeline deploys the full repository to the Storage Server on every push to `master`, and the app is served by Apache on port `8080` through the load balancer.

---

## Architecture Overview

- Developers push code → Gitea repository (`master`)
- Jenkins polls SCM and detects new commits
- Jenkins job (`nautilus-app-deployment`) pulls the latest code
- Code is copied to `/var/www/html` on the Storage Server
- Apache on App Servers serves content on port `8080` behind the load balancer

---

## Features

- Automated CI/CD deployment via Jenkins
- Deploys the full repository (not only `index.html`)
- SCM polling auto-trigger (example: every 2 minutes)
- Simple password-based SSH copy (example uses `sshpass`) — see Security Recommendations
- Apache configured to listen on port `8080`

---

## Infrastructure (Reference)

| Server Name | IP            | User   | Purpose                        |
|-------------|---------------|--------|--------------------------------|
| stapp01     | 172.16.238.10 | tony   | App Server 1 (httpd -> 8080)   |
| stapp02     | 172.16.238.11 | steve  | App Server 2 (httpd -> 8080)   |
| stapp03     | 172.16.238.12 | banner | App Server 3 (httpd -> 8080)   |
| ststor01    | 172.16.238.15 | sarah  | Storage (Deployment target)    |
| jenkins     | 172.16.238.19 | admin  | Jenkins CI/CD Server           |
| gitea       | —             | sarah  | Git repository (project `web`) |

---

## Setup Steps

### 1) Install & Configure Apache on App Servers (stapp01, stapp02, stapp03)
Run on each app server:
```bash
sudo yum install -y httpd
# Change Apache listen port from 80 to 8080
sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sudo systemctl enable httpd
sudo systemctl restart httpd
```

### 2) Prepare Storage Server for Deployment (ststor01)
Ensure the web root is owned by the deployment user so Jenkins can copy files:
```bash
sudo chown -R sarah:sarah /var/www/html
# Verify permissions
ls -ld /var/www/html
```

### 3) Jenkins Job: `nautilus-app-deployment` (example configuration)

- Source Code Management
  - Repository: `http://gitea.stratos.xfusioncorp.com/sarah/web.git`
  - Branch: `master`
  - Credentials: Gitea account (username/password) or preferably a Jenkins credential with limited scope

- Build Trigger
  - Enable "Poll SCM"
  - Example schedule (every 2 minutes):
    ```
    */2 * * * *
    ```

- Build Step (Execute shell)
  Example simple deployment script (password-based — avoid in production):
  ```bash
  echo "Deploying Nautilus app..."

  # Example using sshpass (not recommended for production):
  # NOTE: Replace <SARAH_PASSWORD> with the actual password if you must,
  # or, better: use Jenkins Credentials + ssh key.
  sshpass -p "<SARAH_PASSWORD>" scp -o StrictHostKeyChecking=no -r * sarah@172.16.238.15:/var/www/html

  echo "Deployment complete."
  ```

  Recommended safer alternative using rsync over SSH + SSH key (preferred):
  ```bash
  # On Jenkins, add a deploy key or use Jenkins SSH credentials and then:
  rsync -avz --delete -e "ssh -o StrictHostKeyChecking=no" ./ sarah@172.16.238.15:/var/www/html/
  ```

---

## Developer Workflow

1. On developer workstation or on Storage Server (if editing locally):
```bash
cd ~/web
# Make changes, e.g.:
echo "Welcome to the xFusionCorp Industries" > index.html
git add .
git commit -m "Updated welcome message"
git push origin master
```

2. Jenkins polls SCM, detects the commit, runs `nautilus-app-deployment`, and deploys to `/var/www/html` on `ststor01`.

---

## Validation

- Open the app through the load balancer (or directly to an app server forwarding Apache):
  ```
  http://<LBR-URL>:8080
  ```
- Confirm the updated content appears at the root (no `/web` subdirectory).
- Check the Jenkins job console output and exit status for success.

---

## Troubleshooting

- Deployment permission issues
  - Ensure ownership and permissions:
    ```bash
    sudo chown -R sarah:sarah /var/www/html
    sudo chmod -R u+rwX /var/www/html
    ```
- Jenkins not triggering
  - Verify Poll SCM schedule is enabled and repository URL + credentials are correct.
  - Check Jenkins system logs and plugin status.
- Apache not serving content
  - Check service status and logs:
    ```bash
    sudo systemctl status httpd
    sudo journalctl -u httpd --no-pager -n 200
    tail -n 200 /var/log/httpd/error_log
    ```
- Network / Firewall
  - Verify port 8080 is allowed between load balancer and app servers.
- Partial/failed copy
  - Inspect Jenkins console output and remote permissions. Consider using `rsync` to improve reliability.

---

## Security Recommendations (IMPORTANT)

- Do NOT store plaintext passwords in Jenkins job shell steps.
- Use Jenkins Credentials (username/password or SSH private key) and the Credentials Binding plugin or SSH Agent.
- Prefer SSH keys with a restricted deploy account over `sshpass`.
- Use `rsync` with `--delete` carefully (ensure correct path) or use atomic deploy strategies (deploy to a tmp dir and symlink).
- Use HTTPS for the Gitea repo URL and restrict repo access to necessary accounts.
- Ensure minimal privileges for the `sarah` account on the storage server.

---

## Improvements / Next Steps

- Convert the deployment into a Jenkins Pipeline (Jenkinsfile) stored in the repo for easier auditing.
- Add health checks or smoke tests post-deploy.
- Add rollback capability and versioned releases on the storage server.
- Move to key-based SSH auth and remove `sshpass`.
- If scale requires, consider distributing content using a replicated storage or a deployment agent on each app server rather than a central storage copy.

---
