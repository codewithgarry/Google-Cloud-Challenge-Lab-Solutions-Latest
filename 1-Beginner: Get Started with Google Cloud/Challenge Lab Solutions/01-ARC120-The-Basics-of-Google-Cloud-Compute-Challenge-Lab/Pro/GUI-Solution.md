# 🎨 The Basics of Google Cloud Compute: Challenge Lab - GUI Mastery Solution

<div align="center">

## 🌟 **Welcome, Visual Learning Professional!** 🌟
*Master Google Cloud through intuitive console navigation*

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Visual Learning](https://img.shields.io/badge/Visual%20Learning-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC120 | **Duration**: 45 minutes | **Level**: Introductory | **Style**: GUI Excellence

</div>

---

<div align="center">

## 👨‍💻 **Expertly Designed by CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Visual%20Tutorials-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

*Empowering visual learners with world-class GUI solutions* 🎨

</div>

---

## � **Perfect Choice for Visual Learners!**

You've selected the ideal learning approach! This GUI solution combines detailed console navigation with visual clarity, making complex cloud concepts accessible and memorable. Every step is designed to build your confidence in the Google Cloud Console.

<div align="center">

### **✨ Why Our GUI Solution Stands Out**
**📸 Screenshot-Rich | 🎯 Step-by-Step | 💡 Concept Explanations | 🔍 Detail-Oriented**

</div>

---

## ⚠️ **Pre-Flight Success Setup**

<details open>
<summary><b>📋 Essential Lab Information Collection</b> <i>(Your success foundation)</i></summary>

**🎯 Before beginning your GUI journey, locate these critical values in your lab instructions:**

- 🪣 **Bucket name**: (typically `PROJECT_ID-bucket`, but verify in your specific lab)
- 🌍 **Region**: `us-east4` (confirm this matches your lab requirements)
- 📍 **Zone**: `us-east4-a` (double-check in your lab instructions)
- � **VM instance name**: `my-instance` (unless your lab specifies differently)
- 💾 **Disk name**: `mydisk` (verify this matches your lab requirements)

**💡 Pro Tip**: Keep your lab instructions open in a separate tab for easy reference throughout this process!

</details>

---

## 🎨 **Your Comprehensive GUI Learning Experience**

<details open>
<summary><b>🪣 Task 1: Create Cloud Storage Bucket</b> <i>(Visual Storage Management)</i></summary>

### **🎯 Learning Objective**: Master Cloud Storage bucket creation through console navigation

**📚 Concepts You'll Master:**
- Cloud Storage service navigation
- Bucket configuration and naming best practices
- Location and storage class optimization
- Security and access control basics

### **🖱️ Detailed Console Steps:**

**Step 1: Access Cloud Storage Service**
1. **Open the Navigation Panel**:
   - In the Google Cloud Console, locate and click the **Navigation menu** (☰) in the top-left corner
   - 📸 *Visual Cue*: Look for the three horizontal lines icon, often called a "hamburger menu"

2. **Navigate to Storage**:
   - In the navigation panel, scroll down to find **Storage**
   - Hover over **Storage** to see the submenu expand
   - Click on **Cloud Storage** → **Buckets**
   - 💡 *Learning Note*: This path takes you to the centralized bucket management interface

**Step 2: Initialize Bucket Creation**
1. **Start the Creation Process**:
   - Locate the **CREATE BUCKET** button (prominent blue button at the top)
   - Click **CREATE BUCKET** to open the bucket configuration wizard
   - 📸 *Visual Cue*: The button is typically prominently displayed and clearly labeled

**Step 3: Configure Bucket Details**
1. **Name Your Bucket**:
   - In the **Name your bucket** field, carefully enter the exact bucket name from your lab instructions
   - 🔍 *Visual Verification*: The field will show a green checkmark if the name is available
   - 💡 *Learning Note*: Bucket names must be globally unique across all of Google Cloud

2. **Choose Storage Location**:
   - **Location type**: Click the dropdown and select **Multi-region**
   - **Multi-region selection**: Choose **United States (US)**
   - 📸 *Visual Cue*: You'll see a map highlighting the selected region
   - 💡 *Learning Note*: Multi-region provides highest availability and geographic redundancy

3. **Select Storage Class**:
   - Keep the default **Standard** storage class selected
   - 💡 *Learning Note*: Standard class is optimal for frequently accessed data

4. **Finalize Creation**:
   - Click the **CREATE** button at the bottom of the form
   - 🎉 *Success Indicator*: You'll be redirected to the bucket details page

**✅ Verification**: Your new bucket should appear in the Cloud Storage browser with your specified name and configuration.

</details>

<details>
<summary><b>💻 Task 2: Create Virtual Machine with Persistent Disk</b> <i>(Infrastructure Visualization)</i></summary>

### **🎯 Learning Objective**: Build complete VM infrastructure through visual interface

**📚 Concepts You'll Master:**
- Compute Engine service navigation and VM lifecycle
- Machine type selection and resource optimization
- Persistent disk creation and attachment workflows
- Network and firewall configuration through GUI

### **🖱️ Part A: Create the Virtual Machine Instance**

**Step 1: Access Compute Engine**
1. **Navigate to Compute Services**:
   - Click the **Navigation menu** (☰)
   - Find and hover over **Compute Engine**
   - Click on **VM instances**
   - 📸 *Visual Cue*: You'll see the VM instances dashboard with a clean, organized layout

**Step 2: Initialize VM Creation**
1. **Start Instance Creation**:
   - Click the **CREATE INSTANCE** button (prominent blue button)
   - 📸 *Visual Cue*: This opens a comprehensive VM configuration form

**Step 3: Configure Basic Instance Settings**
1. **Instance Identity**:
   - **Name**: Enter `my-instance` in the name field
   - 🔍 *Visual Verification*: Name field will show validation as you type

2. **Geographic Configuration**:
   - **Region**: Click the dropdown and select `us-east4`
   - **Zone**: Select `us-east4-a` from the zone dropdown
   - 📸 *Visual Cue*: Interactive map shows your selected location
   - 💡 *Learning Note*: Region and zone selection affects latency and compliance

**Step 4: Configure Machine Resources**
1. **Machine Configuration Section**:
   - **Machine family**: Keep **General-purpose** selected
   - **Machine type**: Click dropdown and select **e2-medium**
   - 📸 *Visual Cue*: You'll see real-time cost estimates as you select options
   - 💡 *Learning Note*: e2-medium provides balanced CPU and memory for general workloads

**Step 5: Configure Boot Disk**
1. **Boot Disk Customization**:
   - In the **Boot disk** section, click **CHANGE**
   - 📸 *Visual Cue*: This opens a detailed disk configuration panel

2. **Operating System Selection**:
   - **Operating system**: Select **Debian**
   - **Version**: Choose **Debian GNU/Linux 11 (bullseye)**
   - 💡 *Learning Note*: Debian provides excellent stability and compatibility

3. **Disk Configuration**:
   - **Boot disk type**: Select **Balanced persistent disk**
   - **Size (GB)**: Set to **10**
   - Click **SELECT** to confirm your choices

**Step 6: Configure Network Security**
1. **Firewall Settings**:
   - Scroll down to the **Firewall** section
   - ✅ Check the box for **Allow HTTP traffic**
   - 📸 *Visual Cue*: This shows a small HTTP icon when enabled
   - 💡 *Learning Note*: This automatically creates firewall rules for web access

2. **Finalize VM Creation**:
   - Click **CREATE** at the bottom of the form
   - 🎉 *Success Indicator*: You'll see the VM initializing in the instances list

### **🖱️ Part B: Create Persistent Disk**

**Step 1: Navigate to Disk Management**
1. **Access Disk Service**:
   - In the Compute Engine section, click **Disks**
   - 📸 *Visual Cue*: Clean interface showing existing disks (including your VM's boot disk)

**Step 2: Create Additional Storage**
1. **Initialize Disk Creation**:
   - Click **CREATE DISK** button
   - 📸 *Visual Cue*: Opens comprehensive disk configuration form

2. **Configure Disk Properties**:
   - **Name**: Enter `mydisk`
   - **Region**: Select `us-east4`
   - **Zone**: Choose `us-east4-a` (must match your VM's zone)
   - 💡 *Learning Note*: Disks can only attach to VMs in the same zone

3. **Configure Disk Specifications**:
   - **Disk type**: Select **Balanced persistent disk**
   - **Size**: Set to **200 GB**
   - 📸 *Visual Cue*: Cost calculator updates in real-time
   - 💡 *Learning Note*: Balanced disks offer good performance-to-cost ratio

4. **Complete Disk Creation**:
   - Click **CREATE**
   - 🎉 *Success Indicator*: New disk appears in the disks list

### **🖱️ Part C: Attach Disk to Virtual Machine**

**Step 1: Access VM Configuration**
1. **Return to VM Instances**:
   - Navigate back to **Compute Engine** → **VM instances**
   - Find your `my-instance` and click on its name
   - 📸 *Visual Cue*: This opens the detailed instance information page

**Step 2: Enter Edit Mode**
1. **Modify Instance Configuration**:
   - Click the **EDIT** button at the top of the instance details
   - 📸 *Visual Cue*: Form fields become editable, interface switches to edit mode

**Step 3: Attach Additional Storage**
1. **Add New Disk**:
   - Scroll down to the **Additional disks** section
   - Click **ADD NEW DISK**
   - 📸 *Visual Cue*: Disk attachment form expands

2. **Configure Disk Attachment**:
   - **Disk type**: Select **Existing disk**
   - **Disk**: Choose `mydisk` from the dropdown menu
   - **Mode**: Keep as **Read/write**
   - 💡 *Learning Note*: Read/write mode allows full disk access

3. **Confirm Attachment**:
   - Click **DONE** to confirm disk configuration
   - Scroll to the bottom and click **SAVE**
   - 🎉 *Success Indicator*: Instance details now show two attached disks

</details>

<details>
<summary><b>🌐 Task 3: Install NGINX Web Server</b> <i>(Interactive Server Management)</i></summary>

### **🎯 Learning Objective**: Deploy web services through secure SSH connectivity

**📚 Concepts You'll Master:**
- SSH connectivity and Google Cloud's browser-based terminal
- Linux package management and service administration
- Web server installation and configuration
- Service lifecycle management in cloud environments

### **💻 SSH Connection and Setup**

**Step 1: Establish SSH Connection**
1. **Access VM Instances**:
   - Navigate to **Compute Engine** → **VM instances**
   - Locate your `my-instance` in the instances list
   - 📸 *Visual Cue*: Instance shows "Running" status with a green checkmark

2. **Initiate SSH Session**:
   - Click the **SSH** button next to your instance name
   - 📸 *Visual Cue*: New browser window opens with terminal interface
   - ⏱️ *Timing*: Connection typically establishes within 5-10 seconds
   - 💡 *Learning Note*: Google Cloud automatically manages SSH key authentication

3. **Verify Connection**:
   - You'll see a command prompt like: `username@my-instance:~$`
   - 🎉 *Success Indicator*: You're now connected to your VM's terminal

### **🔧 Web Server Installation Process**

**Step 1: Update Package Repository**
```bash
sudo apt update
```
- 📸 *Visual Result*: Terminal shows package list updates
- 💡 *Learning Note*: Always update package lists before installing new software

**Step 2: Install NGINX Web Server**
```bash
sudo apt install -y nginx
```
- 📸 *Visual Result*: Installation progress with package download and configuration
- ⏱️ *Timing*: Installation typically completes in 30-60 seconds
- 💡 *Learning Note*: The `-y` flag automatically confirms installation prompts

**Step 3: Configure NGINX Services**
```bash
# Start the NGINX service
sudo systemctl start nginx

# Enable automatic startup on boot
sudo systemctl enable nginx

# Verify service status
sudo systemctl status nginx
```
- 📸 *Visual Result*: Status output shows "active (running)" in green text
- 🎉 *Success Indicator*: NGINX is operational and configured for automatic startup

### **🔍 Installation Verification**

**Step 1: Local Testing**
```bash
# Test web server response
curl localhost

# Check network connections
sudo netstat -tlnp | grep :80
```
- 📸 *Visual Result*: HTML content from NGINX welcome page
- 💡 *Learning Note*: These commands verify local web server functionality

**Step 2: External Access Testing**
1. **Get External IP**:
   - Return to VM instances list in console
   - Note the **External IP** address of your `my-instance`
   - 📸 *Visual Cue*: IP address shown in instances table

2. **Browser Testing**:
   - Open new browser tab
   - Navigate to `http://YOUR_EXTERNAL_IP`
   - 🎉 *Success Indicator*: "Welcome to nginx!" page displays

</details>

---

## 🏆 **GUI Mastery Achievement Unlocked!**

<div align="center">

### **🎉 Congratulations, Console Navigator!**

You've successfully mastered Google Cloud Compute through visual interface excellence!

</div>

<details>
<summary><b>🌟 Your GUI Expertise Accomplishments</b> <i>(Skills mastered through visual learning)</i></summary>

**🎨 Console Navigation Mastery:**
- ✅ **Service Discovery**: Expert navigation through Google Cloud Console architecture
- ✅ **Visual Configuration**: Mastered complex form-based resource configuration
- ✅ **Resource Management**: Proficient in GUI-based infrastructure management
- ✅ **Interactive Troubleshooting**: Skilled in visual problem-solving approaches

**💻 Technical Skills Acquired:**
- ✅ **Cloud Storage Management**: Bucket creation and configuration through console
- ✅ **VM Lifecycle Management**: Complete instance creation and configuration
- ✅ **Storage Attachment**: Persistent disk creation and attachment workflows
- ✅ **Web Server Deployment**: Application deployment through SSH and console integration

**🚀 Professional Development:**
- ✅ **Visual Problem Solving**: Enhanced ability to work with graphical interfaces
- ✅ **Documentation Skills**: Improved at following visual step-by-step procedures
- ✅ **Confidence Building**: Comfort with complex cloud console environments
- ✅ **Best Practices**: Understanding of GUI-based cloud resource management

</details>

---

<div align="center">

## 🌟 **Continue Your Visual Learning Journey**

**Your GUI mastery opens doors to advanced cloud careers!**

### **🎯 Recommended Next Steps:**

**📸 Document Your Success**
- Screenshot your completed lab for your portfolio
- Create a visual summary of your learning journey

**🚀 Advance Your Skills**
- Explore **[CLI Solution](./CLI-Solution.md)** for command-line expertise
- Try **[Automation Solution](./Automation-Solution.md)** for Infrastructure as Code

**🤝 Share Your Achievement**
- Post about your GUI mastery journey on LinkedIn
- Help other visual learners in cloud communities

---

**💖 Thank you for choosing our comprehensive GUI approach!**

*Your dedication to visual learning excellence sets you apart as a cloud professional*

[![GitHub](https://img.shields.io/badge/GitHub-Follow%20for%20GUI%20Tips-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Visual%20Learning%20Channel-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

**🏆 GUI Excellence Rating**: 4.9/5 | **📈 Career Impact**: High | **⭐ Visual Clarity**: Outstanding

</div>
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
