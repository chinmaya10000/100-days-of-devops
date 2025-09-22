# Nautilus Git Repository Clone

This repository has been cloned from `/opt/demo.git` to the Storage Server in the Stratos Data Center.  
It is intended for use by the Nautilus application development team.

## Repository Location

Cloned path on the Storage Server:

```
/usr/src/kodekloudrepos/demo
```

## Setup Instructions

1. **Ensure you are the `natasha` user**:
    ```bash
    whoami
    ```

2. **Navigate to the target directory:**
    ```bash
    cd /usr/src/kodekloudrepos
    ```

3. **Clone the repository into a subdirectory:**
    ```bash
    git clone /opt/demo.git demo
    ```

4. **Verify the clone:**
    ```bash
    cd demo
    git status
    ```

    **Expected output:**
    ```
    On branch master
    No commits yet
    nothing to commit
    ```

## Notes

- Do not modify the original repository in `/opt/demo.git`.
- No permissions or directories should be altered in `/usr/src/kodekloudrepos`.
- The repository is now ready for development by the Nautilus team.

## Commands Reference

- **Clone repository:**  
  `git clone /opt/demo.git demo`

- **Check status:**  
  `git status`

- **Check remote:**  
  `git remote -v`