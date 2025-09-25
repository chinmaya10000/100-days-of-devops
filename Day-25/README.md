# Nautilus Git Branch Task

## Overview
This document outlines the complete workflow for creating a new Git branch `nautilus` in the `/usr/src/kodekloudrepos/media` repository, adding files, committing changes, merging back to master, and pushing all changes to the remote repository.

## Prerequisites
- Git installed and configured
- Access to the repository `/usr/src/kodekloudrepos/media`
- Source file available at `/tmp/index.html`
- Appropriate permissions to read/write to the repository

## Task Objective
Create a new Git branch called `nautilus`, add the `index.html` file from `/tmp/`, commit the changes, merge the branch back to master, and ensure all changes are pushed to the remote repository.

## Step-by-Step Instructions

### 1. Navigate to Repository
```bash
cd /usr/src/kodekloudrepos/media
```

### 2. Configure Git Environment
Set up safe directory and Git identity:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### 3. Prepare Master Branch
Ensure you're on master and have the latest changes:
```bash
git checkout master
git pull origin master
```

### 4. Create Nautilus Branch
Create and switch to the new `nautilus` branch:
```bash
sudo git checkout -b nautilus
```
> **Note:** The `-B` flag creates a new branch or resets it if it already exists.

### 5. Add Required File
Copy the file and stage it for commit:
```bash
sudo cp /tmp/index.html .
sudo git add index.html
```

### 6. Commit Changes
Commit the added file with a descriptive message:
```bash
sudo git commit -m "Added index.html as per Nautilus team request"
```

### 7. Push Nautilus Branch
Push the new branch to the remote repository:
```bash
sudo git push origin nautilus
```

### 8. Merge to Master
Switch back to master and merge the nautilus branch:
```bash
sudo git checkout master
sudo git merge nautilus
```

### 9. Push Master Branch
Push the updated master branch to remote:
```bash
sudo git push origin master
```

## Verification Commands

### Check Branch Status
```bash
sudo git branch -a
```
**Expected Output:**
```
* master
  nautilus
  remotes/origin/master
  remotes/origin/nautilus
```

### Verify File Addition
```bash
ls
```
Confirm that `index.html` appears in the repository root.

### Check Commit History
```bash
sudo git log --oneline --graph --all
```

## Important Notes

### Best Practices
- Always create new branches from `master` to ensure clean history
- Commit and push changes before merging to maintain backup
- Use descriptive commit messages
- Pull latest changes before creating new branches

### Branch Management
- The `nautilus` branch will exist both locally and remotely after completion
- Master branch will contain all changes from the nautilus branch
- Both branches will have identical content after the merge

### Troubleshooting

#### Permission Issues
If you encounter permission errors:
```bash
sudo chown -R $(whoami) /usr/src/kodekloudrepos/media
```

#### Merge Conflicts
If merge conflicts occur:
1. Resolve conflicts manually in affected files
2. Stage resolved files: `git add <filename>`
3. Complete merge: `git commit`

#### Remote Push Issues
If remote push fails:
```bash
git remote -v  # Verify remote URL
git fetch origin  # Fetch latest remote changes
```

## Repository Structure
After completion, the repository will contain:
```
/usr/src/kodekloudrepos/media/
├── index.html (newly added)
└── [other existing files]
```

## Branch Workflow Summary
1. **master** → **nautilus** (branch creation)
2. **nautilus** (file addition and commit)
3. **nautilus** → **origin/nautilus** (remote push)
4. **nautilus** → **master** (merge)
5. **master** → **origin/master** (final push)

## Success Criteria
- ✅ `nautilus` branch created successfully
- ✅ `index.html` file copied and committed
- ✅ Changes pushed to remote `nautilus` branch
- ✅ `nautilus` branch merged into `master`
- ✅ Updated `master` pushed to remote
- ✅ Both branches visible locally and remotely

## Contact
For questions or issues related to this task, please contact the development team or refer to the project documentation.

---
*This README was created for the Nautilus Git Branch Task workflow documentation.*