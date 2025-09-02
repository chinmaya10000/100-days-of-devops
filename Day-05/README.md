# Day-05: SELinux Configuration

## Task:
As part of the security hardening measures at xFusionCorp Industries, the security team requested the following actions on **App Server 2** in the Stratos Datacenter:

1. Install the required **SELinux packages**.  
2. **Permanently disable SELinux** by updating the configuration file `/etc/selinux/config`.  
   - Set `SELINUX=disabled`.  
3. No reboot is required immediately, as a maintenance reboot is already scheduled.  
4. The final status of SELinux after reboot should be **disabled**.  

---

## Steps Performed:

1. **SSH into App Server 2**  
   ```bash
   ssh user@appserver2
   sudo yum install -y selinux-policy selinux-policy-targeted
   sudo vi /etc/selinux/config
   SELINUX=disabled
   cat /etc/selinux/config | grep SELINUX

