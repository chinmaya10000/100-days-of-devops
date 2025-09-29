# Nautilus E-commerce Application (Test Repo)

## Problem

A developer had stashed some in-progress changes in this repository.  
The team requested to restore the changes stored in **`stash@{1}`**, then commit and push them to the remote repository.  

---

## Solution

### 1. Navigate to the repository

```bash
cd /usr/src/kodekloudrepos/ecommerce
```

### 2. Verify available stashes

```bash
git stash list
```

**Example output:**
```
stash@{0}: WIP on master: added new API endpoint
stash@{1}: WIP on master: updated cart functionality
```

### 3. Restore the specific stash

```bash
git stash apply stash@{1}
```

This brings the changes from stash@{1} back into the working directory.  
The stash entry itself remains in the stash list (unlike `pop`, which removes it).

### 4. Stage the restored changes

```bash
git add .
```

### 5. Commit the changes

```bash
git commit -m "Restore changes from stash@{1}"
```

### 6. Push to remote

```bash
git push origin master
```
*(Replace `master` with `main` if that is the default branch)*

---

## Verification

**Confirm the changes are committed:**

```bash
git log --oneline
```

The latest commit should read:
```
xxxxxxx Restore changes from stash@{1}
```

**Confirm the changes are pushed to the remote:**

```bash
git fetch origin
git log origin/master --oneline | head -n 5
```

---

## Notes

- Using `apply` keeps the stash entry intact. If you are sure it’s no longer needed, you can drop it with:
    ```bash
    git stash drop stash@{1}
    ```
- Always double-check which stash index you are applying to avoid overwriting unrelated work.