# The Basics of Google Cloud Compute: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC120 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 GUI Solution (Google Cloud Console)

This solution uses the Google Cloud Console web interface for a beginner-friendly approach.

---

## ⚠️ IMPORTANT: Get Values from Your Lab

**Check your lab instructions for these specific values:**
- **Bucket name**: (usually `PROJECT_ID-bucket`)
- **Region**: `us-east4` 
- **Zone**: `us-east4-a`

---

## 📋 Step-by-Step Console Instructions

### Task 1: Create Cloud Storage bucket

1. **Navigate to Cloud Storage**
   - In the Google Cloud Console, click on the **Navigation menu** (☰)
   - Go to **Storage** → **Cloud Storage** → **Buckets**

2. **Create the bucket**
   - Click **CREATE BUCKET**
   - **Name your bucket**: Enter the exact bucket name from your lab instructions
   - **Choose where to store your data**:
     - Location type: **Multi-region**
     - Multi-region: **United States (US)**
   - **Choose a default storage class**: **Standard**
   - **Choose how to control access**: Keep default settings
   - **Advanced settings**: Keep defaults
   - Click **CREATE**

---

### Task 2: Create VM with persistent disk

1. **Navigate to Compute Engine**
   - In the Navigation menu, go to **Compute Engine** → **VM instances**

2. **Create VM instance**
   - Click **CREATE INSTANCE**
   - **Name**: `nucleus-jumphost-webserver1`
   - **Region**: `us-east4`
   - **Zone**: `us-east4-a`

3. **Configure machine type**
   - **Machine configuration**: General-purpose
   - **Series**: E2
   - **Machine type**: `e2-micro (1 vCPU, 1 GB memory)`

4. **Configure boot disk**
   - In **Boot disk** section, click **CHANGE**
   - **Operating system**: Debian
   - **Version**: Debian GNU/Linux 11 (bullseye)
   - **Boot disk type**: Standard persistent disk
   - **Size (GB)**: 10
   - Click **SELECT**

5. **Configure firewall**
   - Check **Allow HTTP traffic**
   - Check **Allow HTTPS traffic**

6. **Create the instance**
   - Click **CREATE**

---

### Task 3: Create HTTP Load Balancer

1. **Create instance template**
   - Go to **Compute Engine** → **Instance templates**
   - Click **CREATE INSTANCE TEMPLATE**
   - **Name**: `nucleus-web-server-template`
   - **Machine configuration**:
     - Series: E2
     - Machine type: `e2-micro`
   - **Boot disk**: Debian GNU/Linux 11
   - **Firewall**: Check both HTTP and HTTPS traffic
   - **Management** tab → **Startup script**:
     ```bash
     #!/bin/bash
     apt-get update
     apt-get install -y nginx
     service nginx start
     sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
     ```
   - Click **CREATE**

2. **Create instance group**
   - Go to **Compute Engine** → **Instance groups**
   - Click **CREATE INSTANCE GROUP**
   - Select **New managed instance group**
   - **Name**: `nucleus-web-server-group`
   - **Instance template**: `nucleus-web-server-template`
   - **Location**: Single-zone
   - **Region**: `us-east4`
   - **Zone**: `us-east4-a`
   - **Autoscaling**: Off
   - **Number of instances**: 2
   - Click **CREATE**

3. **Create firewall rule**
   - Go to **VPC network** → **Firewall**
   - Click **CREATE FIREWALL RULE**
   - **Name**: `allow-tcp-rule-503`
   - **Direction**: Ingress
   - **Targets**: Specified target tags
   - **Target tags**: `http-server`
   - **Source IP ranges**: `0.0.0.0/0`
   - **Protocols and ports**: Check TCP, port `80`
   - Click **CREATE**

4. **Create health check**
   - Go to **Network services** → **Load balancing**
   - Click **CREATE LOAD BALANCER**
   - Select **HTTP(S) Load Balancer** → **START CONFIGURATION**
   - **Internet facing or internal only**: From Internet to my VMs
   - **Global or Regional**: Global
   - **Load balancer name**: `nucleus-lb`

5. **Configure backend**
   - **Backend configuration** → **CREATE A BACKEND SERVICE**
   - **Name**: `nucleus-backend-service`
   - **Backend type**: Instance group
   - **Instance group**: `nucleus-web-server-group`
   - **Port numbers**: 80
   - **Health check** → **CREATE A HEALTH CHECK**
     - **Name**: `nucleus-health-check`
     - **Protocol**: HTTP
     - **Port**: 80
     - **Request path**: `/`
     - Click **SAVE**
   - Click **CREATE**

6. **Configure frontend**
   - **Frontend configuration** → **ADD FRONTEND IP AND PORT**
   - **Name**: `nucleus-frontend`
   - **Protocol**: HTTP
   - **IP version**: IPv4
   - **IP address**: Ephemeral
   - **Port**: 80
   - Click **DONE**

7. **Create load balancer**
   - Click **CREATE**

---

## ✅ Verification Steps

### Task 1 Verification:
- Go to **Cloud Storage** → **Buckets**
- Verify your bucket is created with the correct name

### Task 2 Verification:
- Go to **Compute Engine** → **VM instances**
- Verify `nucleus-jumphost-webserver1` is running in `us-east4-a`

### Task 3 Verification:
- Go to **Network services** → **Load balancing**
- Click on your load balancer
- Copy the frontend IP address and test in browser
- You should see the nginx welcome page

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach for efficiency
- **[Automation Solution](Automation-Solution.md)** - Scripts and Infrastructure as Code

---

## 🎖️ Skills Boost Arcade

This challenge lab is part of the **Skills Boost Arcade** program. Complete this lab to earn:
- **Arcade Points**: Contribute to your monthly total
- **Skill Badges**: Enhance your Google Cloud profile
- **Prizes**: Exclusive Google Cloud swag and credits

---

## 📚 Additional Resources

- [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)

---

<div align="center">

**💡 Pro Tip**: Practice these steps multiple times to build muscle memory for the Google Cloud Console interface!

</div>
