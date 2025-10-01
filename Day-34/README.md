# Nautilus Git Automatic Release Tagging

This repository supports the Nautilus application, with a workflow designed to automatically create release tags upon pushes to `master`. The release tags are generated using a git server-side hook.

---

## Automatic Release Tagging via Git Hook

### Overview

Whenever changes are pushed to the `master` branch, a **post-update git hook** on the bare repository (`/opt/news.git`) automatically creates a release tag in the format:

```
release-YYYY-MM-DD
```

- The date corresponds to the current date of the push.
- The hook ensures idempotency: if a release tag for the current date already exists, it will not be recreated.
- Actions are logged in `hooks/post-update.log` for auditing purposes.

---

## Repository Structure

- **Bare repo**: `/opt/news.git` (on Stratos DC Storage server)
- **Working clone**: `/usr/src/kodekloudrepos/news`

---

## Hook Implementation

- Location: `/opt/news.git/hooks/post-update`
- Trigger: Runs automatically after a successful `git push` to the bare repo.
- Behavior:
  - Checks for updates to `refs/heads/master`.
  - Creates a tag `release-YYYY-MM-DD` pointing to the latest master commit.
  - Skips creation if today's tag already exists.
  - Logs its actions to `post-update.log`.

---

## Usage & Testing

### To trigger the hook and create a release tag:

```bash
# 1. Checkout master branch
git checkout master

# 2. Merge your feature branch
git merge feature-branch -m "Merge feature-branch into master"

# 3. Push changes to origin
git push origin master

# 4. Fetch tags from origin and verify today's release tag
git fetch origin --tags
git tag -l | grep "release-$(date +%F)"
```

**Expected Output:**
```
release-YYYY-MM-DD
```
Where `YYYY-MM-DD` is today's date.

---

## Notes

- The hook only runs when pushing to the `master` branch.
- Tags are created server-side in `/opt/news.git`. To see them locally, run `git fetch --tags`.
- The hook will not overwrite an existing tag for the same day (idempotent).
- Audit logs are available in `/opt/news.git/hooks/post-update.log`.

---

## Troubleshooting

- If the tag does not appear, check the server's `post-update.log` for errors.
- Ensure the hook script is executable: `chmod +x /opt/news.git/hooks/post-update`
- For manual verification of tags on the server:
  ```bash
  cd /opt/news.git
  git tag -l | grep "release-$(date +%F)"
  ```

---

## Contact

For issues regarding the release tagging automation, contact the Nautilus application development team.
