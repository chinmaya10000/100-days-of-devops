# Max’s Story Pull Request Workflow

## Objective
We want to add Max’s story `fox-and-grapes` to the `master` branch **without allowing direct pushes**. All changes must be reviewed before merging.

---

## Step 1: SSH into the server
```bash
ssh max@<storage-server-ip>
# Password: Max_pass123
```
## Step 2: Check the cloned repository
```bash
cd ~
cd <repo-name>         # Enter the cloned repository
ls                     # List files
cat <story-file>       # Check Max's story
```
