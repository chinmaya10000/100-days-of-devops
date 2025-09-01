# Day-04 Task: Grant Script Execution Permissions

## Task Description
As part of the Nautilus project requirements, the sysadmin team developed a new bash script named `xfusioncorp.sh`.  
This script was distributed across all necessary servers, but it lacks execution permissions on **App Server 1** in the **Stratos Datacenter**.

The requirement is:
- Grant **execute permissions** to the `/tmp/xfusioncorp.sh` script.
- Ensure **all users** (owner, group, and others) have the capability to execute it.

---

## Steps Performed

1. **Checked the file permissions before changes**:
   ```bash
   ls -l /tmp/xfusioncorp.sh
   ----------
   sudo chmod 755 /tmp/xfusioncorp.sh

