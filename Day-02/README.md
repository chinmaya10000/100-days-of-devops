# 100 Days of DevOps Challenge

## Day-02: Create a Temporary User with Expiry Date

### Task:
As part of the temporary assignment to the Nautilus project, a developer named **rose** requires access for a limited duration. To ensure smooth access management, a temporary user account with an expiry date is needed.  

- Create a user named `rose` on **App Server 3** in the Stratos Datacenter.  
- Set the expiry date to **2024-02-17**.  
- Ensure the username is created in lowercase as per standard protocol.

---

### Solution:

1. **Login to App Server 3**
   ```bash
   sudo useradd -e 2024-02-17 rose
   sudo chage -l rose
