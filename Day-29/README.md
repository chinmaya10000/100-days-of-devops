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
git log --oneline --pretty=format:"%h %an %s"         # Check commit history
```
# Max’s Story Pull Request Workflow

## Step 3: Create Pull Request (PR) in Gitea
1. Open the **Gitea portal** in your browser.
2. Login as **Max**:
   - **Username:** max
   - **Password:** Max_pass123
3. Navigate to the repository.
4. Click **Pull Requests → New Pull Request**.
5. Select branches:
   - **Pull from (source):** story/fox-and-grapes
   - **Merge into (destination):** master
6. Fill PR details:
   - **Title:** Added fox-and-grapes story
   - **Description:** Optional summary of changes
7. Click **Create Pull Request**

---

## Step 4: Assign Reviewer
1. Open the PR.
2. On the right sidebar, click **Reviewers → Add Reviewer**
3. Select **Tom**

---

## Step 5: Review and Merge as Tom
1. Logout Max, login as **Tom**:
   - **Username:** tom
   - **Password:** Tom_pass123
2. Go to the PR `Added fox-and-grapes story`.
3. Click the **Files / Diff tab** to see all changes:
   - **Green** → added lines
   - **Red** → deleted lines
4. Merge the PR:
   - In Gitea, **merging acts as approval**
   - Click **Merge** → confirm

---

## Step 6: Verify the Merge
```bash
git checkout master
git pull origin master
cat <fox-and-grapes-story-file>  # Confirm Max’s story is in master
