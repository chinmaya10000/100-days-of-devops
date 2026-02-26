# 🧰 Jenkins User Access Configuration - Nautilus Team

## 📋 Objective
The Nautilus team is integrating Jenkins into their CI/CD pipelines.  
This document outlines the configuration steps to set up **user access control** using the **Project-based Matrix Authorization Strategy** plugin.

---

## 🚀 Steps Performed

### 1. Login to Jenkins
- Accessed the Jenkins UI via browser.
- Logged in with:
  - **Username:** `admin`
  - **Password:** `Adm!n321`

---

### 2. Created a New User
- Navigated to: **Manage Jenkins → Manage Users → Create User**
- Added the following:
  - **Username:** `yousuf`
  - **Password:** `YchZHRcLkL`
  - **Full name:** `Yousuf`
- Clicked **Create User**.

---

### 3. Installed Required Plugin
- Installed the **Matrix Authorization Strategy** plugin:
  - **Manage Jenkins → Plugins → Available Plugins**
  - Searched and installed: `Matrix Authorization Strategy`
  - Selected **Restart Jenkins when installation is complete**.

---

### 4. Configured Global Security
- Navigated to: **Manage Jenkins → Configure Global Security**
- Under **Authorization**, selected:
  - ✅ **Project-based Matrix Authorization Strategy**
- Added users and permissions as follows:

| User      | Overall | Job | Agent | SCM | Administer |
|-----------|---------|-----|-------|-----|------------|
| admin     | ✅ Administer | ✅ All | ✅ | ✅ | ✅ |
| yousuf    | ✅ Read |     |       |     |            |
| Anonymous | ❌      | ❌  | ❌    | ❌  | ❌         |

- Saved configuration.

---

### 5. Configured Job-Level Permissions
- Opened existing job.
- Clicked **Configure → Enabled project-based security**.
- Added user `yousuf` with only **read permission**:
  - ✅ `Job → Read`
  - ❌ All other permissions (Build, Configure, Delete, etc.)
- Saved job configuration.

---

### 6. Verified Access Control
- Logged out of `admin` and logged in as:
  - **Username:** `yousuf`
  - **Password:** `YchZHRcLkL`
- Verified that:
  - Yousuf can **view jobs**.
  - Yousuf **cannot configure or build** jobs.
  - Yousuf **cannot access Manage Jenkins**.

---

## ✅ Final Access Summary

| User      | Access Type       | Description                              |
|-----------|-------------------|------------------------------------------|
| **admin** | Full Admin Access | Can manage all settings and jobs.        |
| **yousuf** | Read-Only Access | Can view existing jobs but not modify.   |
| **Anonymous** | No Access    | All permissions revoked.                 |

---

## 🔑 Key Takeaways
- **Matrix Authorization Strategy** provides granular control over user permissions.
- **Project-based security** allows per-job access control.
- Always verify permissions after configuration to ensure proper access levels.
- Keep admin credentials secure and limit administrative access.

---

## 📚 References
- [Jenkins Matrix Authorization Strategy Plugin](https://plugins.jenkins.io/matrix-auth/)
- [Jenkins Security Documentation](https://www.jenkins.io/doc/book/security/)
