# Nautilus Project

This repository contains the source code for the Nautilus application.

## Repository Path

- Original repository: `/opt/cluster.git`
- Local clone on storage server: `/usr/src/kodekloudrepos`

## Branching Strategy

- `master`: Main stable branch.
- `feature-branch`: Developer branches for ongoing features.

## Rebase Instructions

To update your feature branch with the latest master **without creating a merge commit**:

```bash
# Go to repo
cd /usr/src/kodekloudrepos

# Fetch latest changes
git fetch origin

# Switch to your feature branch
git checkout feature-branch

# Rebase on top of master
git rebase origin/master

# Resolve any conflicts, then continue
git add <file>
git rebase --continue

# Push the rebased branch
git push origin feature-branch --force
