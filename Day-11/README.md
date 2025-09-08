# Day 11 – Deploying Nautilus Web Application on Tomcat

## 📌 Task Overview

The Nautilus application team has completed the beta version of a **Java-based application**. The goal is to deploy it on **App Server 3** using **Tomcat** running on **port 3000**. The application should be accessible via the base URL.

---

## 🛠️ Requirements

* **Application Server:** App Server 3
* **Application User:** `banner`
* **Tomcat Version:** 10.1.45
* **Tomcat Directory:** `/opt/tomcat`
* **Tomcat Port:** 3000
* **WAR File Source:** `/tmp/ROOT.war` on Jump host
* Deployment should make the app accessible directly on `http://stapp03:3000`
* Tomcat must run as `banner` and optionally as a systemd service for auto-start

---

## 📂 Deployment Steps

### 1. Install Java

```bash
# RHEL/CentOS
sudo yum install -y java-11-openjdk-devel

# Ubuntu/Debian
# sudo apt-get update
# sudo apt-get install -y openjdk-11-jdk

# Verify installation
java -version
```

### 2. Download & Extract Tomcat

```bash
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.45/bin/apache-tomcat-10.1.45.tar.gz
sudo tar -xvzf apache-tomcat-10.1.45.tar.gz
sudo mv apache-tomcat-10.1.45 tomcat
```

### 3. Fix Permissions for `banner`

```bash
sudo chown -R banner:banner /opt/tomcat
sudo chmod -R 755 /opt/tomcat
ls /opt/tomcat/bin  # Verify scripts exist
chmod +x /opt/tomcat/bin/*.sh
```

### 4. Configure Tomcat Port

```bash
vi /opt/tomcat/conf/server.xml
```

* Change `<Connector port="8080" ... />` to `<Connector port="3000" ... />`

### 5. Copy and Deploy ROOT.war

**From Jump host:**

```bash
scp /tmp/ROOT.war banner@stapp03:/tmp/
```

**On App Server 3:**

```bash
rm -rf /opt/tomcat/webapps/ROOT
mv /tmp/ROOT.war /opt/tomcat/webapps/ROOT.war
```

### 6. Start Tomcat

```bash
cd /opt/tomcat/bin
./startup.sh
```

Check logs:

```bash
tail -f /opt/tomcat/logs/catalina.out
```

### 7. Test Application

```bash
curl http://stapp03.stratos.xfusioncorp.com:3000
```

### 8. (Optional) Configure Systemd Service

```bash
sudo vi /etc/systemd/system/tomcat.service
```

Paste:

```
[Unit]
Description=Apache Tomcat Server
After=network.target

[Service]
Type=forking
User=banner
Group=banner
Environment=JAVA_HOME=/usr/lib/jvm/jre-11-openjdk
Environment=CATALINA_HOME=/opt/tomcat
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and start service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status tomcat
```

---

## ✅ Notes

* All Tomcat operations run as the `banner` user.
* WAR file deployment replaces any existing ROOT application.
* Systemd service ensures Tomcat starts automatically on server reboot.
* After deployment, the web app is accessible at `http://stapp03:3000`.
