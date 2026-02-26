# Jenkins Parameterized Job Setup

This guide explains how to create and test a simple parameterized job in Jenkins. The job demonstrates how to pass and use parameters in a build.

---

## Overview

A parameterized job lets you supply inputs (parameters) when starting a build. This example creates a Freestyle job that accepts a string parameter (`Stage`) and a choice parameter (`env`) and prints those values to the console.

> Security note: The credentials shown here are for demonstration only. Do not store real credentials in a public repository. Use Jenkins credentials store or environment variables for production secrets.

---

## Demo Login Details (demo only)

- **Jenkins URL:** [Your Jenkins Server URL]  
- **Username:** `admin`  
- **Password:** `Adm!n321`

---

## Steps to Create the Job

### 1. Create a New Job
1. On the Jenkins dashboard, click **New Item**.  
2. Enter the job name: `parameterized-job`.  
3. Select **Freestyle project** and click **OK**.

### 2. Add Parameters
1. On the job configuration page, check **This project is parameterized**.  
2. Add a **String Parameter**:
   - **Name:** `Stage`  
   - **Default Value:** `Build`
3. Add a **Choice Parameter**:
   - **Name:** `env`  
   - **Choices:**  
     ```
     Development
     Staging
     Production
     ```

### 3. Add Build Step
1. Scroll to the **Build** section.  
2. Click **Add build step → Execute shell**.  
3. Enter the following script:
```bash
echo "Stage is: $Stage"
echo "Environment is: $env"
```

### 4. Save and Build
1. Click **Save**.  
2. Click **Build with Parameters**.  
3. Select parameter values:
   - `Stage`: `Build`  
   - `env`: `Staging`  
4. Click **Build**.

---

## Verify the Output
After the build completes, open **Console Output**. You should see output similar to:

```
Stage is: Build
Environment is: Staging
Finished: SUCCESS
```

---

## Troubleshooting

- If parameters don’t appear on the **Build with Parameters** page, ensure **This project is parameterized** is checked in the job configuration.
- If Jenkins requests plugin updates:
  1. Go to **Manage Jenkins → Manage Plugins → Available** (or **Updates**).  
  2. Install required plugins (for example, _Parameterized Trigger Plugin_, if needed).  
  3. Restart Jenkins when installation is complete and no jobs are running.  
  4. Refresh the Jenkins UI if it appears unresponsive after restart.
- If environment variables don't appear inside the shell step, try wrapping variable names with braces (e.g., `${Stage}`) or echo the full environment to debug: `env | sort`.

---

## Expected Result

A Jenkins Freestyle job named `parameterized-job` should successfully build and print the selected parameter values in the console output.

Example console output:

```
Stage is: Build
Environment is: Staging
Finished: SUCCESS
```

---

## Next Steps (optional)
- Convert the job to a Pipeline (Jenkinsfile) to store job logic in source control.
- Replace demo credentials with secure Jenkins credentials.
- Add unit/acceptance tests or build steps for the actual work performed in each `Stage`/`env`.
- Automate job creation with Job DSL or Jenkins Configuration as Code (JCasC).

---