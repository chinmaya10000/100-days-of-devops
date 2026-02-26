# Jenkins Plugin Installation Guide

## Overview
This guide details the steps to install the Git and GitLab plugins in Jenkins for the Nautilus DevOps team. Proper installation of these plugins is essential for integrating Jenkins with Git repositories and GitLab CI/CD workflows.

## Login Credentials
- Jenkins URL: `http://your-jenkins-url`  
- Username: `admin`  
- Password: `your-password`

## Step-by-Step Installation Instructions
1. **Access Jenkins**  
   Open your web browser and navigate to the Jenkins URL. Log in using the credentials provided above.

2. **Navigate to Manage Jenkins**  
   From the Jenkins dashboard, click on "Manage Jenkins" on the left sidebar.

3. **Manage Plugins**  
   Click on "Manage Plugins". This will open the Plugin Manager.

4. **Available Tab**  
   In the Plugin Manager, navigate to the "Available" tab.

5. **Search for Plugins**  
   Use the search bar to find the following plugins:  
   - Git Plugin  
   - GitLab Plugin

6. **Select Plugins**  
   Check the boxes next to the Git Plugin and GitLab Plugin to select them for installation.

7. **Install Plugins**  
   Click on the "Install without restart" button to start the installation process.

8. **Wait for Installation**  
   The plugins will be downloaded and installed. Once completed, you will see a confirmation message.

9. **Restart Jenkins (if required)**  
   In some cases, Jenkins may require a restart to finalize the installation. If prompted, follow the instructions to restart.

## Verification Steps
1. **Go Back to Manage Jenkins**  
   After installation, navigate back to "Manage Jenkins".

2. **Check Installed Plugins**  
   Click on "Manage Plugins" again and go to the "Installed" tab to verify that the Git and GitLab plugins are listed among the installed plugins.

3. **Configuration**  
   To ensure everything works correctly, configure the Git and GitLab plugin settings as per your project's requirements. 
   
4. **Create a Test Job**  
   Set up a new Jenkins job and configure it to use the Git or GitLab plugin. Ensure that it connects to your repository without issues.

5. **Run the Job**  
   Execute the job and check the console output for successful connections to the Git repository and GitLab.

By following these steps, you will successfully install and verify the necessary plugins for Jenkins.