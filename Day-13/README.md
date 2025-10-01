# KodeKloud Day 13 – Securing Apache Port 6300 with iptables

## Task Overview
We have a website running on multiple application hosts in the Stratos Data Center. Apache is listening on port **6300**, which is currently open for all. The security team requested that only the Load Balancer (LBR) host should be allowed access to port 6300, and all other traffic should be blocked.  

This task involves:
1. Installing iptables on all app hosts.
2. Blocking incoming traffic to port 6300 for everyone except the LBR.
3. Making firewall rules persistent across reboots.

## Prerequisites
- Access to all app hosts via SSH.
- LBR host IP address (for example: `192.168.10.100`).
- Root or sudo privileges on each app host.

## Step 1: Install iptables

### On RHEL/CentOS:
```bash
sudo yum install -y iptables iptables-services


## Step 2: Configure Firewall Rules
### Allow LBR access to port 6300
```bash
sudo iptables -A INPUT -p tcp -s <LBR_IP> --dport 6300 -j ACCEPT

### Block all other access to port 6300
```bash
sudo iptables -A INPUT -p tcp --dport 6300 -j DROP

### Make sure SSH (port 22) is allowed:
```bash
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

## step 3: Save Rules (Persistence)
### On RHEL/CentOS:
```bash
sudo service iptables save
sudo systemctl enable iptables
sudo systemctl restart iptables
```

### On Ubuntu/Debian:
```bash
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent
```

## Step 4: Verify rules:
```bash
sudo iptables -L -n -v
```
