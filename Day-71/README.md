# Jenkins Job: install-packages

## Overview
This Jenkins Freestyle job automates installing packages on the Nautilus Storage Server (`ststor01.stratos.xfusioncorp.com`) by SSH'ing from the Jenkins server and running the host package manager (`yum` or `apt-get`). The job is parameterized so the user specifies which package to install.

> Important: Do not store secrets (passwords, private keys) directly in job parameters. Use Jenkins Credentials and restrict job access to trusted users.

## Infrastructure (example)
- Jenkins server: `jenkins.stratos.xfusioncorp.com` (user: `jenkins`)
- Target storage server: `ststor01.stratos.xfusioncorp.com` (user: `natasha`)

(Passwords shown in design docs should be removed from any repo and replaced with secrets stored in a credentials manager.)

## Jenkins Job: `install-packages`
- Type: Freestyle Project
- Parameter:
  - `PACKAGE` (String) — name of the package to install (e.g., `httpd`, `vim`, `git`, `tree`)

## Build Step (Execute shell)
Example command used in the job:
```bash
ssh -o StrictHostKeyChecking=no natasha@ststor01.stratos.xfusioncorp.com \
  "sudo yum install -y $PACKAGE || sudo apt-get install -y $PACKAGE"
```

This:
- Opens SSH to the storage server as `natasha`
- Attempts to install the package with `yum` first, falls back to `apt-get`
- Runs non-interactively with `-y` so the job does not prompt

Notes:
- `StrictHostKeyChecking=no` is used to avoid the host key prompt on first connect. For production, prefer adding the host key to known_hosts instead.
- The remote `sudo` must be configured to allow passwordless sudo for `natasha`, or the job must use a method to provide the sudo password securely (not recommended via plain text).

## Recommended Secure Setup

1. SSH key pair for Jenkins
   - On the Jenkins server (as the `jenkins` user):
     ```bash
     ssh-keygen -t rsa -b 4096 -f /var/lib/jenkins/.ssh/id_rsa_install_packages -N ""
     ```
   - Copy the public key to the target host:
     ```bash
     ssh-copy-id -i /var/lib/jenkins/.ssh/id_rsa_install_packages natasha@ststor01.stratos.xfusioncorp.com
     ```
   - Restrict the private key file permissions:
     ```bash
     chmod 600 /var/lib/jenkins/.ssh/id_rsa_install_packages
     ```

2. Passwordless sudo on target (if required)
   - Edit sudoers via `visudo` and add:
     ```
     natasha ALL=(ALL) NOPASSWD: ALL
     ```
   - Prefer limiting commands rather than full NOPASSWD if possible:
     ```
     natasha ALL=(ALL) NOPASSWD: /usr/bin/yum, /usr/bin/apt-get
     ```

3. Use Jenkins Credentials (recommended)
   - Store the private SSH key in Jenkins Credentials (Kind: SSH Username with private key) and use the SSH Agent plugin or configure the job to use that credential.
   - Avoid embedding keys or passwords in job shell commands or parameters.

4. Hardening
   - Limit which users can run the job (Project-based Matrix Authorization Strategy or Folder permissions).
   - Keep an audit trail of builds and who triggered them.
   - Restrict network access to the target machines to only approved CI hosts.

## Usage (from Jenkins UI)
1. Go to Jenkins → Select job `install-packages`.
2. Click "Build with Parameters".
3. Enter a package name in `PACKAGE` (e.g., `httpd`).
4. Click "Build".
5. Monitor Console Output for install logs and success messages.

## Troubleshooting
- SSH connection failing:
  - Verify Jenkins can reach `ststor01` (ping/traceroute).
  - Check the SSH private key is correct and the public key exists in `~/.ssh/authorized_keys` for `natasha`.
  - Inspect permissions of `~/.ssh` and `authorized_keys`.

- Sudo prompts or permission denied on install:
  - Ensure `natasha` has passwordless sudo for package manager commands, or change the job to use a different mechanism (e.g., run a privileged agent on the host).
  - Check `sudo` logs on the target for failures.

- Package manager differences:
  - Some distros use `dnf` instead of `yum`, or `apt` instead of `apt-get`. You may want to improve detection logic on the remote side:
    ```bash
    if command -v yum >/dev/null 2>&1; then
      sudo yum install -y "$PACKAGE"
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y "$PACKAGE"
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y "$PACKAGE"
    else
      echo "No supported package manager found" >&2
      exit 1
    fi
    ```

## Suggested Improvements
- Validate `PACKAGE` against an allowlist before installation.
- Use configuration management tooling (Ansible) for idempotent package management across hosts.
- Add OS detection and appropriate package manager commands.
- Add logging/notification on success/failure (email, Slack).
- Move from Freestyle to a Pipeline job for better auditing, parameter validation, and credential handling.

## Example: Safer SSH invocation using Jenkins SSH credential
If using the Jenkins SSH Credentials and the SSH Agent plugin, you can drop the explicit private key path and rely on the agent to provide key-based auth. In a Pipeline job you might do:
```groovy
sshagent(['jenkins-ssh-cred-id']) {
  sh 'ssh -o StrictHostKeyChecking=no natasha@ststor01.stratos.xfusioncorp.com "sudo yum install -y $PACKAGE || sudo apt-get install -y $PACKAGE"'
}
```

## Security Reminder
- Never commit private keys, passwords, or secrets to the repository.
- Use Jenkins Credentials store and tightly control who can edit or run this job.
- Regularly rotate keys and review sudo rules.

## Contact / Owner
- CI Owner: Jenkins admin team
- Host Owner: Storage team (natasha)

## Change Log
- 1.0 — Initial README describing the `install-packages` job, setup, and recommendations.
