# Jenkins Job Permissions Configuration

This README documents the steps required to configure job-level permissions in Jenkins for the `Packages` job as requested by the development team.

## Objective
Grant specific job and global permissions to two existing Jenkins users so they can perform their development tasks on the `Packages` job.

## Users & Credentials (provided)
> Note: Credentials shown here were provided by the requester. Keep them secure and rotate them if this file is stored in a shared repository.

- `sam` — `sam@pass12345`  
- `rohan` — `rohan@pass12345`  
- Jenkins admin for configuration:  
  - `admin` — `Adm!n321`

## Scope
- Apply changes only to the `Packages` job and the global authorization configuration described below.
- Do NOT modify permissions for other jobs.

## Prerequisites
- Jenkins administrator access.
- Jenkins instance accessible via the web UI.
- If "Project-based Matrix Authorization Strategy" is not present, the plugin must be installed (see below).

## High-level Steps
1. Log in to Jenkins as the admin user.
2. Enable Project-based Matrix Authorization globally and set specific global permissions.
3. Install the Project-based Matrix Authorization Strategy plugin if necessary.
4. Configure project-level security and assign permissions on the `Packages` job.
5. Verify permissions by testing login and job actions as the target users.
6. Document and screenshot changes for audit/review.

---

## Detailed Configuration Steps

### 1) Login to Jenkins
- Open the Jenkins UI in a browser.
- Login with:
  - Username: `admin`
  - Password: `Adm!n321`

### 2) Enable Project-Based Authorization (Global)
- Navigate: **Manage Jenkins → Configure Global Security**
- Under **Authorization**, select: **Project-based Matrix Authorization Strategy**
- Set the following global permissions:
  - `sam` → Overall: Read
  - `rohan` → Overall: Read
  - `admin` → Keep full permissions (leave existing admin rights)
- Remove all permissions from:
  - `Anonymous`
  - `Authenticated Users`

Important: Removing permissions from Authenticated Users restricts access globally. Ensure `sam`, `rohan`, and any other required accounts have explicit global permissions as needed.

### 3) Install Required Plugin (if not visible)
If "Project-based Matrix Authorization Strategy" is not an option:
- Go to **Manage Jenkins → Manage Plugins → Available**
- Search for: **Project-based Matrix Authorization Strategy**
- Install the plugin and restart Jenkins if prompted.

### 4) Configure Job-Level Permissions for `Packages`
- Navigate: **Dashboard → Packages → Configure**
- Under **Project-based security**, enable project-level security.
- Add and assign the following permissions:

User: `sam`
- Build — granted
- Configure — granted
- Read — granted

User: `rohan`
- Build — granted
- Cancel — granted
- Configure — granted
- Read — granted
- Update — granted
- Tag — granted

Do NOT change permissions for any other jobs.

---

## Verification
- Log out of the admin account and log in as each user to verify:
  - `sam` can view, configure, and trigger builds on `Packages`.
  - `rohan` can view, configure, trigger builds, cancel running builds, update, and tag builds on `Packages`.
- Confirm that neither `sam` nor `rohan` can access or modify other jobs unless explicitly permitted.
- Capture screenshots showing the job's permissions UI and user views for audit.

## Rollback
- If a configuration change causes problems, log in as `admin` and:
  - Revisit **Manage Jenkins → Configure Global Security** and revert authorization changes.
  - Re-open the `Packages` job configuration and restore prior project-level settings.
- Keep a copy of the screenshots taken before changes (if available) to restore previous state.

## Notes & Best Practices
- Restart Jenkins if the UI becomes unresponsive after plugin installation.
- Avoid storing plaintext credentials in public repositories. If this README is saved in a repository, consider removing or encrypting the passwords and pointing to a secure credential store instead.
- Record a changelog entry with the date, admin user who made changes, and a short description.
- Take screenshots for review/approval and attach them to the change record.

## Change Log
- 2026-02-27 — Initial README created describing job-level permission changes for `Packages`.

## Contact
For questions or help performing this configuration, contact the Jenkins admin or the development lead responsible for the `Packages` job.
