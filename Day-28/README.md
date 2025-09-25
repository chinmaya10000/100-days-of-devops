# Git Cherry-Pick Task - Day 27

## Objective
Merge a specific commit (`Update info.txt`) from the `feature` branch into the `master` branch in the `/usr/src/kodekloudrepos/blog` repository.  
Push the changes to the remote repository.

## Steps

1. **Navigate to the repository**
```bash
cd /usr/src/kodekloudrepos/blog
```
2. Check branches
```bash
sudo git branch -a
```
3. Switch to master branch
```bash
sudo git checkout master
```
4. Find the commit hash in feature branch
```bash
sudo git log feature --oneline
# Look for the commit with message: Update info.txt
# Copy the commit hash (example: 5ade80a)
```
5. Cherry-pick the commit to master
```bash
sudo git cherry-pick 5ade80a
```
6. Resolve conflicts (if any)
```bash
git add <resolved-files>
git cherry-pick --continue
```
7. Push changes to remote
```bash
sudo git push origin master
```
