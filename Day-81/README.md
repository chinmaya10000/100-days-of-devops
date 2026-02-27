# xFusionCorp Static Website Deployment Pipeline

This repository is part of the xFusionCorp Industries DevOps workflow for deploying a static website from a Gitea repo to a central storage server and propagating those files to application servers via a Jenkins CI/CD pipeline.

## 🚀 Project Overview

Goal: Automatically deploy website content from the `sarah/web` Gitea repository to the Storage Server (`ststor01`) so that updates are immediately available on all application servers through a shared mount and validated by a Jenkins pipeline job named `deploy-job`.

## 🏗️ Architecture

| Server | Purpose |
|--------|---------|
| **ststor01** | Central storage server (website files under `/var/www/html`) |
| **stapp01, stapp02, stapp03** | Application servers that mount the storage server's `/var/www/html` and run Apache on port `8080` |
| **stlb01** | Load balancer exposing the public URL `http://stlb01:8091` |
| **jenkins** | CI/CD server running the deployment pipeline |

Because the application servers mount `ststor01`'s `/var/www/html`, updating the files on the storage server instantly reflects across the cluster.

## 🔧 Jenkins Pipeline (deploy-job)

The pipeline performs two stages: deploy and test.

### Stage: Deploy
- Connects to `ststor01` over SSH as user `natasha`
- Changes directory to `/var/www/html`
- Pulls the latest content from the `master` branch of the Gitea repo

Example (remote command executed from Jenkins):
```bash
ssh -o StrictHostKeyChecking=no natasha@ststor01 "cd /var/www/html && git pull origin master"
```

### Stage: Test
- Verifies website availability by requesting the load balancer URL
- Fails the build if the HTTP status is not 200

Example test command:
```bash
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://stlb01:8091)
if [ "$STATUS" -ne 200 ]; then
  echo "Application test failed! HTTP Status: $STATUS"
  exit 1
fi
```

### Example Jenkinsfile
This Jenkinsfile demonstrates the pipeline implementation:
```groovy
pipeline {
    agent any

    stages {
        stage('Deploy') {
            steps {
                echo "Deploying website to storage server..."
                sh '''
                    ssh -o StrictHostKeyChecking=no natasha@ststor01 "cd /var/www/html && git pull origin master"
                '''
            }
        }

        stage('Test') {
            steps {
                echo "Testing website..."
                sh '''
                    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://stlb01:8091)
                    if [ "$STATUS" -ne 200 ]; then
                        echo "Application test failed! HTTP Status: $STATUS"
                        exit 1
                    fi
                '''
            }
        }
    }
}
```

## 🔐 Authentication (Passwordless SSH)
Recommended approach for Jenkins to run remote commands on `ststor01`:

1. On the Jenkins server (as the Jenkins user), generate an SSH keypair if not already present:
   ```bash
   ssh-keygen -t ed25519 -C "jenkins@xFusionCorp" -f ~/.ssh/id_ed25519 -N ""
   ```
2. Copy the public key to `natasha@ststor01`:
   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub natasha@ststor01
   ```
   Or manually append the public key to `~/.ssh/authorized_keys` for user `natasha` on `ststor01`.
3. Confirm `ssh natasha@ststor01` from Jenkins server succeeds without a password prompt.

Security notes:
- Limit the allowed commands and source IP for the key if possible (e.g., via `authorized_keys` options or SSH forced commands).
- Use a dedicated Jenkins deploy user on `ststor01` rather than a personal account where feasible.
- Ensure proper file permissions on `~/.ssh` and `authorized_keys`.

## ✅ Expected Result

Visiting:
http://stlb01:8091

Should display the deployed site content (for example, an `index.html` with a message like):
```
Welcome to xFusionCorp Industries
```

## 📦 Key Benefits
- Automated CI/CD deployment from Gitea to production storage
- Centralized content distribution for multiple application servers
- Fast propagation with zero-downtime updates
- Automated functional verification via pipeline tests

## 📚 Recommended Validation Screenshots
- Updated `index.html` in Gitea (show recent commit)
- Jenkins job configuration (pipeline definition)
- Successful pipeline output (console log)
- Website response in browser (http://stlb01:8091)

## Troubleshooting tips
- If `git pull` fails on `ststor01`, verify repository remote, branch, and file permissions in `/var/www/html`.
- If SSH from Jenkins fails, check key presence, permissions on `~/.ssh`, and `sshd` logs on `ststor01`.
- If the test fails with non-200 status, check Apache on app servers (port 8080), LB config, and mount health for `/var/www/html`.

