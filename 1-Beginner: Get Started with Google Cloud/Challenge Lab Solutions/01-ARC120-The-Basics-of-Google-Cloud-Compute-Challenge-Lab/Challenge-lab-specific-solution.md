# 🎓 The Basics of Google Cloud Compute: Challenge Lab - Complete Learning Solution

<div align="center">

## 🌟 **Welcome, Dedicated Learner!** 🌟
*Master every concept with our comprehensive step-by-step guide*

[![Lab Link](https://img.shields.io/badge/Lab%20Link-Access%20Now-blue?style=for-the-badge&logo=google-cloud&logoColor=white)](https://www.cloudskillsboost.google.com/focuses/1734?parent=catalog)
[![Solution Video](https://img.shields.io/badge/YouTube-Watch%20Tutorial-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

**Lab ID**: ARC120 | **Duration**: 45 minutes | **Level**: Introductory | **Learning Style**: Deep Understanding

</div>

---

<div align="center">

## 👨‍💻 **Expertly Crafted by CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe%20for%20Expertise-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

*Trusted learning partner for 50,000+ cloud professionals worldwide* ⭐

</div>

---

## 🎊 **Thank You for Choosing Deep Learning!**

You've made an excellent choice! This comprehensive solution will not only help you complete the lab but also ensure you truly understand Google Cloud Compute Engine concepts that will serve you throughout your cloud career.

---

## ⚠️ **Essential Lab Information** 

<details open>
<summary><b>📋 Get Your Lab-Specific Values</b> <i>(Critical for success)</i></summary>

**🎯 Before starting, please check your lab instructions for these specific values:**

- 🪣 **Bucket name**: (usually `PROJECT_ID-bucket`, but verify in your lab)
- 🌍 **Region**: `us-east4` (double-check in your lab instructions)
- 📍 **Zone**: `us-east4-a` (confirm this matches your lab requirements)
- 💻 **VM instance name**: `my-instance` (unless specified differently)
- 💾 **Disk name**: `mydisk` (verify this in your lab)

**💡 Pro Tip**: Each lab may have slightly different requirements, so always refer to your specific lab instructions first!

</details>

---

## 🚀 **Your Complete Learning Journey**

<div align="center">

### **Three Powerful Ways to Master This Lab**

</div>

<details open>
<summary><b>🪣 Task 1: Create Cloud Storage Bucket</b> <i>(Foundation of Cloud Storage)</i></summary>

### **🎯 Objective**: Create a secure, scalable cloud storage bucket

**📚 What You'll Learn:**
- Cloud Storage bucket creation and configuration
- Location and storage class optimization
- Naming conventions and best practices

### **🖱️ Console Method (Recommended for Learning):**

**Step 1: Navigate to Cloud Storage**
1. In the Google Cloud Console, click the **Navigation menu** (☰) 
2. Go to **Storage** → **Cloud Storage** → **Buckets**
3. Observe the clean, intuitive interface designed for efficiency

**Step 2: Create Your Bucket**
1. Click **CREATE BUCKET** (notice the prominent blue button)
2. **Name your bucket**: Enter the exact bucket name from your lab instructions
   - 💡 **Learning Note**: Bucket names must be globally unique across all of Google Cloud
3. **Choose where to store your data**:
   - **Location type**: Select **Multi-region** 
   - **Multi-region**: Choose **United States (US)**
   - 💡 **Learning Note**: Multi-region provides highest availability and durability
4. **Choose storage class**: Keep **Standard** (best for frequently accessed data)
5. Click **CREATE** and watch your first cloud resource come to life!

**🎉 Success Indicator**: You'll see your bucket listed in the Cloud Storage browser

</details>

<details>
<summary><b>💻 Task 2: Create VM with Persistent Disk</b> <i>(Infrastructure Mastery)</i></summary>

### **🎯 Objective**: Build a complete virtual machine infrastructure with attached storage

**📚 What You'll Learn:**
- Virtual machine configuration and optimization
- Persistent disk creation and attachment
- Network security and firewall configuration

### **🖱️ Console Method - Part A: Create the Virtual Machine**

**Step 1: Navigate to Compute Engine**
1. **Navigation menu** (☰) → **Compute Engine** → **VM instances**
2. Notice the powerful VM management dashboard

**Step 2: Create Your VM Instance**
1. Click **CREATE INSTANCE**
2. **Name**: Enter `my-instance` (or as specified in your lab)
3. **Region**: Select `us-east4` 
4. **Zone**: Choose `us-east4-a`
   - 💡 **Learning Note**: Choosing regions close to your users reduces latency
5. **Machine configuration**:
   - **Machine family**: General-purpose
   - **Machine type**: e2-medium (balanced performance and cost)
6. **Boot disk**: 
   - Click **CHANGE** to customize
   - **Operating system**: Debian
   - **Version**: Debian GNU/Linux 11 (bullseye)
   - **Boot disk type**: Balanced persistent disk
   - **Size**: 10 GB
   - Click **SELECT**
7. **Firewall**: 
   - ✅ Check **Allow HTTP traffic**
   - 💡 **Learning Note**: This creates automatic firewall rules for web access
8. Click **CREATE** and watch your VM initialize!

### **🖱️ Console Method - Part B: Create Persistent Disk**

**Step 1: Navigate to Disks**
1. **Compute Engine** → **Disks** 
2. Observe the disk management interface

**Step 2: Create Additional Storage**
1. Click **CREATE DISK**
2. **Name**: Enter `mydisk` (or as specified in your lab)
3. **Region**: `us-east4`
4. **Zone**: `us-east4-a` (must match your VM's zone)
   - 💡 **Learning Note**: Disks and VMs must be in the same zone for attachment
5. **Disk type**: Balanced persistent disk (good performance/cost ratio)
6. **Size**: 200 GB
7. Click **CREATE**

### **🖱️ Console Method - Part C: Attach Disk to VM**

**Step 1: Edit Your VM**
1. Go back to **VM instances**
2. Find your `my-instance` and click on it
3. Click **EDIT** (at the top of the instance details page)

**Step 2: Attach the Disk**
1. Scroll down to **Additional disks**
2. Click **ADD NEW DISK**
3. **Disk type**: Select **Existing disk**
4. **Disk**: Choose `mydisk` from the dropdown
5. **Mode**: Keep as **Read/write**
6. Click **DONE**
7. Scroll to bottom and click **SAVE**

**🎉 Success Indicator**: Your VM now shows two disks in the instance details

</details>

<details>
<summary><b>🌐 Task 3: Install NGINX Web Server</b> <i>(Application Deployment)</i></summary>

### **🎯 Objective**: Deploy and configure a production web server

**📚 What You'll Learn:**
- SSH connectivity to cloud instances
- Linux package management
- Web server installation and configuration
- Service management in Linux

### **💻 SSH Method (Recommended for Learning):**

**Step 1: Connect to Your VM**
1. Go to **Compute Engine** → **VM instances**
2. Find `my-instance` and click **SSH** button
   - 💡 **Learning Note**: Google Cloud automatically manages SSH keys for secure access
3. Wait for the SSH session to establish (usually 5-10 seconds)
4. You'll see a terminal prompt like: `username@my-instance:~$`

**Step 2: Install NGINX**
```bash
# Update package lists (always a good practice)
sudo apt update

# Install NGINX web server
sudo apt install -y nginx

# Start the NGINX service
sudo systemctl start nginx

# Enable NGINX to start automatically on boot
sudo systemctl enable nginx

# Check the status to confirm it's running
sudo systemctl status nginx
```

**Step 3: Verify Installation**
```bash
# Check if NGINX is listening on port 80
sudo netstat -tlnp | grep :80

# Test the web server locally
curl localhost
```

**🎉 Success Indicator**: You'll see HTML content from the default NGINX welcome page

### **� Test Web Access (Bonus)**
1. Go back to your VM instances list
2. Note the **External IP** of your `my-instance`
3. Open a new browser tab and visit `http://YOUR_EXTERNAL_IP`
4. You should see the "Welcome to nginx!" page

</details>

---

## 🏆 **Congratulations on Your Achievement!**

<div align="center">

### **🎉 You've Successfully Completed ARC120!**

</div>

<details>
<summary><b>✅ Your Accomplishments</b> <i>(What you've mastered)</i></summary>

**You have successfully:**
- ✅ **Created a Cloud Storage bucket** with optimal configuration
- ✅ **Built a virtual machine** with proper specifications  
- ✅ **Attached persistent storage** for scalable data management
- ✅ **Deployed a web server** using industry-standard practices
- ✅ **Applied security configurations** with firewall rules
- ✅ **Gained hands-on experience** with Google Cloud Console

**💼 Career Impact**: These fundamental skills are essential for Cloud Engineer, DevOps Engineer, and Solutions Architect roles.

</details>

---

<div align="center">

## 🌟 **Continue Your Cloud Excellence Journey**

**You're now equipped with Google Cloud Compute fundamentals!**

**🚀 Next Steps:**
- 📸 **Take a screenshot** of your completed lab
- 🎯 **Try the next challenge**: [Get Started with Pub/Sub](../02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab)
- 📚 **Explore advanced solutions** in our [Pro folder](./Pro/)
- 🤝 **Share your success** with the community

**💖 Thank you for choosing our comprehensive learning approach!**

[![GitHub](https://img.shields.io/badge/GitHub-Follow%20for%20More-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe%20for%20Tutorials-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

*Your dedication to deep learning sets you apart as a cloud professional* ⭐

</div>
