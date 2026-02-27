# Nautilus Web App Deployment Pipeline

## 📌 Overview

This repository documents the Jenkins Pipeline job used by the Nautilus DevOps team to deploy a static web application to the Storage Server. The deployed content is served by the application servers through a load balancer.

The web application repository is already cloned on the Storage Server at:
```
/var/www/html
```
The Jenkins pipeline updates this directory directly based on the requested Git branch.

---

## ⚙️ Infrastructure Details

| Server Type       | Hostname                             | IP              | User    |
|-------------------|---------------------------------------|------------------|---------|
| Storage Server    | ststor01.stratos.xfusioncorp.com      | 172.16.238.15    | natasha |
| App Server 1      | stapp01.stratos.xfusioncorp.com       | 172.16.238.10    | tony    |
| App Server 2      | stapp02.stratos.xfusioncorp.com       | 172.16.238.11    | steve   |
| App Server 3      | stapp03.stratos.xfusioncorp.com       | 172.16.238.12    | banner  |
| Load Balancer     | stlb01.stratos.xfusioncorp.com        | 172.16.238.14    | loki    |
| Jenkins Server    | jenkins.stratos.xfusioncorp.com       | 172.16.238.19    | admin   |

---

## 🔧 Jenkins Node Setup

A Jenkins agent named **Storage Server** was configured with:

- **Label:** `ststor01`
- **Remote Root Directory:** `/var/www/html`
- **Launch Method:** SSH
- **SSH User:** `natasha`
- **Executors:** `1`

Note: Do NOT store plaintext passwords or secrets in repository files. Use Jenkins Credentials (or an equivalent secrets manager) for SSH keys/passwords. The password shown in earlier documents has been redacted here—replace it in Jenkins with a credential entry or (preferably) use an SSH key.

---

## 🚀 Jenkins Pipeline Job: `nautilus-webapp-job`

- Type: Pipeline (not multibranch)
- Agent: uses node labeled `ststor01`

### Parameters

- Name: `BRANCH`  
  Type: String  
  Default: `master`  
  Description: Branch to deploy (master or feature)

Trigger or run the job from the Jenkins UI, selecting the desired `BRANCH` value before building.

---

## 📜 Pipeline Script (Jenkinsfile)

```groovy
pipeline {
    agent { label 'ststor01' }

    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Branch to deploy: master or feature')
    }

    stages {
        stage('Deploy') {
            steps {
                sh '''
                    cd /var/www/html
                    git fetch --all
                    git checkout ${BRANCH}
                    git reset --hard origin/${BRANCH}
                '''
            }
        }
    }
}
```

Notes:
- The pipeline runs on the Storage Server node and operates directly on the cloned repo at `/var/www/html`.
- No Git URL is required in the job because the repo already exists on the Storage Server.

---

## 🔄 Deployment Logic

- If `BRANCH = master`, the `master` branch is deployed.
- If `BRANCH = feature`, the `feature` branch is deployed.
- The pipeline checks out the named branch and resets the working tree to `origin/${BRANCH}` to ensure the working copy matches the remote branch.

---

## ✅ Verification Steps

After running the pipeline, verify deployment:

1. Open the Load Balancer URL:
   ```
   https://<LB-URL>/
   ```
2. Confirm:
   - The site loads at the root (no subdirectory like `/web_app`).
   - Updated content (e.g., changes in `index.html`) is visible.
   - Application servers (Apache on port 8080) are serving the latest version of `index.html`.

Manual checks on the Storage Server:
```bash
# Check current branch and latest commit
cd /var/www/html
git status
git rev-parse --abbrev-ref HEAD
git log -n 1 --oneline
```

If app servers pull or sync content from the Storage Server, ensure their sync process completed (rsync, pull script, or similar).

---

## ⏪ Rollback

To roll back to a previous commit or branch:

- Roll back to a previous commit on the same branch:
  1. Identify commit SHA: `git log -n 5 --oneline`
  2. Reset to that commit on the storage server (recommended to do from Jenkins or via a maintenance job):
     ```bash
     cd /var/www/html
     git reset --hard <commit-sha>
     ```
  3. Verify and reload services if necessary.

- Deploy a different branch:
  - Re-run the Jenkins job with `BRANCH` set to the desired branch (e.g., `master`).

Consider adding an automated rollback stage or tagging stable releases for simpler rollbacks.

---

## 🛠 Troubleshooting

- If Jenkins shows SSH/connection errors to `ststor01`:
  - Verify Jenkins credential configuration for the `ststor01` node.
  - Confirm SSH accessibility from the Jenkins master to `ststor01`.
- If `git` commands fail on `/var/www/html`:
  - Ensure repository origin is set and reachable: `git remote -v`
  - Check file permissions on `/var/www/html` for the `natasha` user.
- If the site does not reflect changes:
  - Confirm that the web servers are serving files from the expected location.
  - Check load balancer cache or CDN (if present).
  - Confirm app servers have the latest content (if they sync from the storage server).

Logs to check:
- Jenkins build logs (for the job run)
- SSH logs on the Storage Server (`/var/log/auth.log` or distro equivalent)
- Web server logs on app servers (Apache logs)

---

## 🔒 Security & Best Practices

- Do NOT store secrets in repository files. Use Jenkins Credentials or a secrets manager.
- Prefer SSH key authentication for the Jenkins agent user (`natasha`) and lock down that key.
- Limit access to the Jenkins job to authorized users.
- Consider using a multibranch pipeline or pipeline library for scaling branches and standardizing deployments.
- Add tests or a basic smoke-test stage to the pipeline to validate the site after deployment.
- Keep the storage server repository and file permissions locked down to minimize accidental changes.

---