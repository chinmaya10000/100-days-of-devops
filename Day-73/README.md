# copy-logs — README

## Overview
This repository contains documentation for the Jenkins job `copy-logs`. The job periodically collects Apache logs from App Server 1 and stores them on the Storage Server for centralized inspection.

Do NOT store secrets (passwords/private keys) in job configuration or scripts. Use Jenkins Credentials to hold any private keys or secrets.

## Architecture
- Jenkins job: `copy-logs` (Freestyle or Pipeline)
- Source (App Server 1): stapp01.stratos.xfusioncorp.com (example IP: 172.16.238.10)
  - Source log files:
    - /var/log/httpd/access_log
    - /var/log/httpd/error_log
- Destination (Storage Server): ststor01.stratos.xfusioncorp.com (example IP: 172.16.238.15)
  - Destination directory:
    - /usr/src/sysops
- Jenkins master/agent: jenkins.stratos.xfusioncorp.com

## Purpose
- Centralize Apache access and error logs for monitoring, troubleshooting, and retention.
- Ensure regular copies are available on the storage server.

## Scheduling
The original job ran every 2 minutes:
```
*/2 * * * *
```
Note: Running every 2 minutes is aggressive. Consider increasing the interval (for example every 5–15 minutes) unless you require very high-frequency ingestion.

## Secure Setup (recommended)
1. Create SSH credentials in Jenkins (Credentials → System → Global credentials):
   - Source key credential (example id: `stapp01-ssh`) — SSH key for `tony` on App Server 1.
   - Destination key credential (example id: `ststor01-ssh`) — SSH key for `natasha` on Storage Server.

2. Use Jenkins' built-in credentials bindings (or the SSH Agent plugin) to expose keys only at runtime. Do NOT hardcode passwords or private keys in job scripts.

3. Pre-populate known_hosts on the Jenkins agent or use `StrictHostKeyChecking=accept-new` only for initial onboarding. Prefer explicit host-key management for production.

## Recommended Transfer Method
- Prefer rsync over SSH (incremental transfers) or a log-shipping agent:
  - rsync: efficient incremental file transfer; preserves bandwidth and reduces load.
  - Filebeat / Fluentd / rsyslog: more robust, handles rotation, retries, and structured forwarding.

If you must use Jenkins to copy files, transfer in a safe, atomic way:
- Pull logs from source with rsync to a temporary directory on the agent.
- Push to the destination writing to a temporary filename (e.g. `access_log.part`) then `mv` to the final filename to avoid partial files being consumed.

## Example placeholders (do NOT include real secrets)
- Jenkins credential IDs:
  - Source SSH credential id: `stapp01-ssh`
  - Destination SSH credential id: `ststor01-ssh`
- Shell steps should reference these credentials and not include passwords.

## Verification
On the Storage Server (as the storage user):
```bash
ssh natasha@172.16.238.15
ls -l /usr/src/sysops
# Expect to see:
# access_log
# error_log
```

Check Jenkins console output for:
- Successful rsync/scp operations
- Any error messages indicating permission, connectivity, or missing files

## Troubleshooting
- Permission denied: verify the SSH key and username, and that the public key is in the remote user's `~/.ssh/authorized_keys`.
- Host key verification failures: ensure the Jenkins agent has a correct `~/.ssh/known_hosts` entry for the remote hosts.
- Empty or truncated logs: verify log rotation settings on the App Server and coordinate transfer timing around rotation events.
- High load or repeated identical transfers: switch to rsync or a log agent to avoid copying unchanged files.

## Long-term recommendation
Use a log-forwarding solution (Filebeat/Fluentd/rsyslog → central logging stack such as Elasticsearch/Fluentd/Graylog) instead of copying raw log files via Jenkins. This provides reliability, backpressure handling, metadata enrichment, and easier search/alerting.

## Contacts
- DevOps: xFusionCorp DevOps Team
- For urgent issues: Pager or on-call contact listed in internal runbook

## Change log
- 1.0 — Initial README describing `copy-logs` job and secure recommendations.

```