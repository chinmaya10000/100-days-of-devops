# Nautilus WebApp Deployment using Jenkins Pipeline

This repository contains documentation and the Jenkins pipeline configuration used to deploy the xFusionCorp Industries static website (web_app) from Gitea to the Nautilus App Servers via a Jenkins slave node (Storage Server). The Storage Server mounts the shared document root used by all App Servers running Apache on port 8080, enabling a single central deployment point behind a load balancer.

---

## Project Goal

Automate deployment of a static website hosted in a Gitea repository to a Storage Server that serves as the document root for all Nautilus App Servers. Deployment is triggered by a Jenkins pipeline running on a Jenkins Slave labeled `ststor01`.

---

## Infrastructure Overview

| Server         | Hostname                          | Purpose                                 |
|----------------|-----------------------------------|-----------------------------------------|
| Storage Server | `ststor01.stratos.xfusioncorp.com`| Jenkins Slave & Deployment Target       |
| App Servers    | `stapp01`, `stapp02`, `stapp03`   | Apache HTTP Servers (Port 8080)         |
| Load Balancer  | `stlb01.stratos.xfusioncorp.com`  | HTTP Reverse Proxy / LB                 |
| Gitea          | Hosted UI                         | Source Repository (`web_app`)           |
| Jenkins        | CI/CD Orchestrator                | Runs pipeline on slave to deploy files  |

---

## Access (provided for reference)

> Note: These credentials were provided in the original deployment notes. For production, replace with secure credentials stored in a vault or Jenkins Credentials store.

- Jenkins
  - Username: `admin`
  - Password: `Adm!n321`
- Gitea
  - Username: `sarah`
  - Password: `Sarah_pass123`
  - Repository: `web_app` (git URL used below)
- Storage Server (SSH)
  - Username: `natasha`
  - Password: `Bl@kW`
  - Deployment Path (document root): `/var/www/html`

Security reminder: do NOT keep plaintext credentials in repo README in production. Use Jenkins credentials and SSH keys.

---

## Jenkins Node (Slave) Configuration

- Node Name: `Storage Server`
- Label: `ststor01`
- Remote Root Directory: `/var/www/html`
- Launch Method: SSH
- Credentials: `natasha` (or better: SSH key managed by Jenkins)

Make sure the Jenkins master can connect to the slave using the configured credentials and that the `/var/www/html` path is writable by the Jenkins user.

---

## Jenkins Pipeline Job

- Job Name: `nautilus-webapp-job`
- Type: Pipeline (NOT Multibranch)
- Stage Name (case-sensitive): `Deploy`

Pipeline script used:

```groovy
pipeline {
    agent { label 'ststor01' }

    stages {
        stage('Deploy') {
            steps {
                sh 'rm -rf /var/www/html/*'

                git(
                    url: 'http://git.stratos.xfusioncorp.com/sarah/web_app.git',
                    branch: 'master',
                    credentialsId: 'jenkins-gitea'
                )
            }
        }
    }
}
```

Notes:
- The pipeline runs on the slave labeled `ststor01`, which should have `/var/www/html` as its remote root.
- `credentialsId: 'jenkins-gitea'` should reference a Jenkins credential that has access to the Gitea repository (username/password or token); do NOT hardcode credentials in the pipeline.

---

## Deployment & Validation

1. Run the `nautilus-webapp-job` pipeline in Jenkins.
2. After the job completes, SSH to the Storage Server and verify deployed files:

```bash
ssh natasha@ststor01.stratos.xfusioncorp.com
ls -l /var/www/html
# Expect index.html and other site content at the root of /var/www/html
```

3. Verify the site via the Load Balancer URL (App button or browser):

```
https://<LBR-URL>
```

- The site content must be available at the root path (i.e., `https://<LBR-URL>/`), not under `/web_app`.

---

## Troubleshooting

- If files are missing in `/var/www/html`:
  - Check Jenkins build logs for git checkout errors or permission errors when removing/copying files.
  - Ensure the pipeline agent used the correct label and connected to the intended slave.
- If permissions errors occur:
  - Confirm the remote root `/var/www/html` owner/group and that the Jenkins user on the slave has write permissions.
- If the site shows a directory listing or 403:
  - Confirm `index.html` exists and Apache is configured to serve it.
- If LB returns an unexpected page:
  - Verify the Storage Server export/mount is properly shared to all App Servers and that Apache on each App Server points to the same document root.
- If git authentication fails:
  - Verify the Jenkins credential `jenkins-gitea` is correctly configured and has access to `http://git.stratos.xfusioncorp.com/sarah/web_app.git`.

---

## Best Practices & Security

- Use Jenkins Credentials (username/password or token) and SSH keys — never store secrets in job scripts or README files.
- Prefer SSH key-based agent launch for Jenkins slaves; rotate keys periodically.
- Protect Gitea access with strong passwords or tokens and least privilege.
- Use CI/CD branch strategies and consider adding a build/verify stage (e.g., HTML validation) before overwriting production files.
- Keep backups or snapshots of `/var/www/html` or use versioned releases if rollback is required.

---

## Notes

- Apache is already installed and running on all App Servers on port `8080`.
- Load Balancer is pre-configured; no LB changes required for this deployment pattern.
- When editing the pipeline in Jenkins UI, remember to click Save (not only Apply).

---

## Contact / Maintainers

- Deployment owner: `sarah` (Gitea)
- Jenkins admin: `admin`

---

## License

This document is internal deployment documentation for xFusionCorp Industries. Treat as internal infrastructure documentation and handle securely.
