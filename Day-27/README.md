# Git Revert Task - Day 27

This repository `/usr/src/kodekloudrepos/beta` required reverting the latest commit (HEAD) due to issues reported by the application development team.

## Objective
- Revert the most recent commit (HEAD) to the previous commit.
- Ensure the new revert commit uses the message: **`revert beta`** (all lowercase).

## Steps Performed

1. Navigate to the repository:
   ```bash
   cd /usr/src/kodekloudrepos/beta
   ```

2. View commit history (to confirm HEAD and previous commit):
   ```bash
   sudo git log --oneline
   ```

3. Revert the latest commit:
   ```bash
   sudo git revert HEAD --no-edit
   ```
4. Amend the commit message to match the requirement:
   ```bash
   sudo git commit --amend -m "revert beta"
   ```
5. Verify the history:
   ```bash
   sudo git log --oneline
   ```
