# Day 1: Linux User Setup with Non-Interactive Shell  

### Task  
Create a Linux user who cannot log in interactively.  

### Steps  
```bash
sudo useradd -s /sbin/nologin devuser
grep devuser /etc/passwd
