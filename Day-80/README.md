# Nautilus App Deployment — CI/CD Pipeline (Jenkins)

This README describes the CI/CD setup used to deploy the Nautilus web application and automatically restart Apache on the application servers via Jenkins.

> Last updated: 2026-02-27

---

## Overview

Two Jenkins jobs implement the pipeline:

1. **nautilus-app-deployment**
   - Pulls latest code from the Gitea `web` repository.
   - Deploys changes to the shared `/var/www/html` on the Storage Server.
   - Triggers the downstream job `manage-services` on successful build.

2. **manage-services**
   - Restarts Apache (`httpd`) on all three app servers.
   - Runs only when the upstream job succeeds.

---

## Infrastructure

| Role | Hostname | IP | User | Purpose |
|------|----------|----:|------|---------|
| Storage Server | ststor01.stratos.xfusioncorp.com | 172.16.238.15 | natasha | Shared webroot `/var/www/html` |
| App Server 1 | stapp01.stratos.xfusioncorp.com | 172.16.238.10 | tony | App server |
| App Server 2 | stapp02.stratos.xfusioncorp.com | 172.16.238.11 | steve | App server |
| App Server 3 | stapp03.stratos.xfusioncorp.com | 172.16.238.12 | banner | App server |
| Jenkins Server | jenkins.stratos.xfusioncorp.com | 172.16.238.19 | jenkins | CI/CD orchestration |

Gitea repository:
- http://git.stratos.xfusioncorp.com/sarah/web.git

---

## Prerequisites

- Jenkins has network access to all target servers.
- SSH access from Jenkins to the target users (natasha, tony, steve, banner) is configured using a deploy key.
- Target app servers have sudoers rules that allow passwordless restart/status for `httpd` for the deploy users.
- Jenkins credentials configured for the Git repo (recommended: store as Jenkins Credentials rather than plaintext).

---

## SSH Key Setup (on Jenkins)

Generate an SSH key pair on the Jenkins server (run as Jenkins user or the user that executes the jobs):

```bash
ssh-keygen -t rsa -b 4096 -C "jenkins@stratos" -f /var/lib/jenkins/.ssh/id_rsa
```

Copy the public key to the target accounts:

```bash
ssh-copy-id natasha@ststor01.stratos.xfusioncorp.com
ssh-copy-id tony@stapp01.stratos.xfusioncorp.com
ssh-copy-id steve@stapp02.stratos.xfusioncorp.com
ssh-copy-id banner@stapp03.stratos.xfusioncorp.com
```

Notes:
- Use `-o StrictHostKeyChecking=no` in automation only if you understand the security implications.
- Ensure correct permissions on `.ssh` and `authorized_keys` on target servers.

---

## Sudo Configuration (on App Servers)

Add the following line to `/etc/sudoers.d/nautilus-deploy` (use `visudo -f /etc/sudoers.d/nautilus-deploy`):

```text
tony ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd, /bin/systemctl status httpd
steve ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd, /bin/systemctl status httpd
banner ALL=(ALL) NOPASSWD: /bin/systemctl restart httpd, /bin/systemctl status httpd
```

Adjust file ownership and permissions per your OS policy (typically `440`).

---

## Jenkins Job: nautilus-app-deployment

SCM (Git)
- Repo URL: `http://git.stratos.xfusioncorp.com/sarah/web.git`
- Credentials: (store securely in Jenkins Credentials; DO NOT hardcode in job)
  - Example shown in documentation: `sarah / Sarah_pass123` — rotate & secure this credential.
- Branch: `master`

Build Step (Execute Shell) — example:

```bash
ssh -o StrictHostKeyChecking=no natasha@ststor01.stratos.xfusioncorp.com "
  cd /var/www/html && git pull origin master
"
```

Post-build:
- Trigger downstream project: `manage-services`
- Trigger condition: only if build is Stable / SUCCESS

Notes:
- Consider adding a checkout stage on Jenkins agent as an alternative to remote `git pull`.
- Use Jenkins credentials plugin and environment variables for any secrets.

---

## Jenkins Job: manage-services

This downstream job connects to each app server and restarts httpd.

Build Step (Execute Shell) — full script:

```bash
#!/bin/bash
HOSTS=(
  "tony@stapp01.stratos.xfusioncorp.com"
  "steve@stapp02.stratos.xfusioncorp.com"
  "banner@stapp03.stratos.xfusioncorp.com"
)

for host in "${HOSTS[@]}"; do
  echo "Restarting httpd on $host"
  ssh -o StrictHostKeyChecking=no "$host" "sudo systemctl restart httpd"
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "Failed to restart httpd on $host (exit $rc)"
    exit $rc
  fi
  echo "Success on $host"
done
```

Notes:
- Consider running `sudo systemctl status httpd` (or `systemctl is-active httpd`) after restart as verification.
- Add error handling/logging and retries where appropriate.

---

## Validation Checklist

- [ ] `/var/www/html` updated with latest repo contents on `ststor01`.
- [ ] Apache restarted successfully on all app servers.
- [ ] Load balancer shows latest content at the root URL.
- [ ] Both Jenkins jobs show SUCCESS.

Recommended verification commands:
```bash
# On storage server
ssh natasha@ststor01.stratos.xfusioncorp.com "ls -la /var/www/html && git -C /var/www/html rev-parse --short HEAD"

# On each app server
ssh tony@stapp01.stratos.xfusioncorp.com "sudo systemctl is-active httpd && sudo systemctl status httpd --no-pager"
```

---

## Troubleshooting

- SSH failures:
  - Ensure Jenkins public key is in `~/.ssh/authorized_keys` for the target user.
  - Check `sshd` config and firewall rules.
- Git pull issues on storage server:
  - Verify repository URL, network/DNS, and credentials.
  - Run `git -C /var/www/html fetch --all` and inspect `git status`.
- sudo failures:
  - Verify `/etc/sudoers.d/` entry and file permissions.
  - Test manual `sudo systemctl restart httpd` as the target user.
- Jenkins job fails:
  - Inspect console log for the failing step.
  - Re-run with debug output (add `set -x` at top of shell steps for trace).

---

## Security Considerations

- Do NOT store plaintext credentials in repo or job configuration; use Jenkins Credentials store.
- Use limited-scope deploy keys; restrict them to required repositories and users.
- Limit sudo rules to only the exact commands required.
- Rotate SSH keys and credentials periodically.
- Consider using bastion/jump host, or a configuration management/orchestration tool (Ansible, Salt, etc.) for safer, auditable deployments.
- Consider signing/validating releases or using CI artifacts rather than `git pull` on production/critical storage servers.

---

## Improvements / Next Steps

- Move to immutable artifacts (build -> archive -> deploy) instead of remote `git pull`.
- Add automated tests and artifact verification before triggering restart.
- Use centralized secrets manager for credentials (HashiCorp Vault, Jenkins Credentials with proper access controls).
- Add monitoring/alerting for service restarts and deployment failures.
- Add rollback steps and health checks before updating the load balancer.

---

