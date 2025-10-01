# Day-03: Disable Root SSH Login

## Task
As part of a recent security audit, the security team required disabling direct SSH access for the root user on all application servers within the Stratos Datacenter.

## Solution Steps
1. Logged into each app server.
2. Edited the SSH configuration file:
   ```bash
   sudo vi /etc/ssh/sshd_config
   ```