# Nautilus Project

This repository contains the source code for the Nautilus application.

## Repository Info

- Original repo: `/opt/cluster.git`
- Local clone on storage server: `/usr/src/kodekloudrepos`

## Situation / Problem

One of the developers is working on a **feature branch**, and the work is still in progress.  
Meanwhile, **new changes have been pushed to the `master` branch**.  

The developer wants to **update their feature branch with the latest master** without:  

- Losing any of their ongoing work.  
- Creating any merge commits (so no `git merge` with a commit).  

## Solution: Rebase Feature Branch on Master

Follow these steps to safely rebase the feature branch:

```bash
# Go to the repo
cd /usr/src/kodekloudrepos

# Fetch the latest changes from remote
git fetch origin

# Switch to your feature branch
git checkout feature-branch

# Rebase your feature branch on top of master
git rebase origin/master

# If there are conflicts, fix them in the files and then
git add <file-with-conflict>
git rebase --continue

# After successful rebase, push the updated feature branch
git push origin feature-branch --force
