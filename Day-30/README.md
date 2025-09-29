# Nautilus Application (Test Repo)

## Problem
A developer accidentally pushed extra test commits into this repository.  
The requirement is to clean the commit history so that only the following remain:

1. **Initial commit**  
2. **add data.txt file**

Additionally, this `README.md` file should exist in the repository, but without creating a third commit.

---

## Solution (Interactive Rebase Method)

Follow the steps below to rewrite the history:

### 1. Go to the repository
```bash
cd /usr/src/kodekloudrepos/apps
```
2. Switch to the main branch
```bash
git checkout master   # or 'main' if that is the default branch
```
3. Start an interactive rebase from the root
```bash
git rebase -i --root
```
This opens an editor showing all commits, for example:
```
pick abc111 Initial commit
pick def222 add data.txt file
pick ghi333 unwanted commit
pick jkl444 test commit
```
4. Keep only the required commits  
Keep Initial commit and add data.txt file.

Delete the lines for all other commits.

It should look like:
```
pick abc111 Initial commit
pick def222 add data.txt file
```
Save and exit.


5. Push the cleaned history  
Since history has been rewritten, you must force push:
```bash
git push origin master --force
```
**Verification**  
Check the history:
```bash
git log --oneline
```
Expected output:
```
def222 add data.txt file
abc111 Initial commit
```
Check the README is present:
```bash
cat README.md
```
**Notes**
- Replace `master` with `main` if your repository uses that branch name.
- Force pushing rewrites history — ensure no one else is working on the branch before doing this.
- You can create a backup branch before rewriting, e.g.:
```bash
git branch backup-old-history
```