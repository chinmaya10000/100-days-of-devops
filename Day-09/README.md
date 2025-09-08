
- The directory `/run/mariadb` existed, but it was **owned by root:root**.  
- Since MariaDB runs as the `mysql` user, it did not have permission to write to this directory.

---

## Fix Implemented

1. Verified service status and logs:
   ```bash
   sudo systemctl status mariadb
   sudo cat /var/log/mariadb/mariadb.log
   sudo chown mysql:mysql /run/mariadb
   sudo systemctl restart mariadb
   sudo systemctl enable mariadb
   sudo systemctl status mariadb



