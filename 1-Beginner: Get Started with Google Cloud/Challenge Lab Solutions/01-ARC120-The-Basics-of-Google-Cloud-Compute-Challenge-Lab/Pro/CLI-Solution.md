# 💻 The Basics of Google Cloud Compute: Challenge Lab - CLI Mastery Solution

<div align="center">

## 🌟 **Welcome, Command-Line Virtuoso!** 🌟
*Harness the power of Google Cloud through expert CLI commands*

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Mastery](https://img.shields.io/badge/CLI%20Mastery-00D4AA?style=for-the-badge&logo=terminal&logoColor=white)

**Lab ID**: ARC120 | **Duration**: 45 minutes → **CLI Time**: 20-30 minutes | **Level**: Intermediate

</div>

---

<div align="center">

## 👨‍💻 **Crafted by CLI Expert CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-CLI%20Tutorials-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

*Empowering developers with professional-grade CLI expertise* ⚡

</div>

---

## 🎊 **Excellent Choice for Efficient Development!**

You've selected the professional developer's approach! CLI mastery demonstrates technical sophistication and enables rapid, repeatable infrastructure management. Every command in this solution is optimized for efficiency and real-world applicability.

<div align="center">

### **⚡ Why CLI Solutions Excel**
**🚀 Speed | 🔄 Repeatability | 🤖 Automation-Ready | 📝 Scriptable**

</div>

---

## ⚠️ **Command-Line Preparation Checklist**

<details open>
<summary><b>📋 Essential Environment Setup</b> <i>(Professional CLI foundation)</i></summary>

**🎯 Before executing commands, ensure you have these lab-specific values:**

- 🪣 **Bucket name**: (typically `PROJECT_ID-bucket`, verify in your lab instructions)
- 🌍 **Region**: `us-east4` (confirm in your lab requirements)
- 📍 **Zone**: `us-east4-a` (double-check your lab specifications)
- 💻 **VM instance name**: `my-instance` (unless specified otherwise in lab)
- 💾 **Disk name**: `mydisk` (verify this matches your lab requirements)

**🔧 CLI Environment Verification:**
```bash
# Verify gcloud authentication
gcloud auth list

# Confirm project configuration
gcloud config get-value project

# Check available regions/zones
gcloud compute zones list --filter="region:us-east4"
```

**💡 Pro Tip**: Keep your lab instructions open for quick reference to specific requirements!

</details>

---

## ⚡ **Professional CLI Implementation**

<details open>
<summary><b>🪣 Task 1: Create Cloud Storage Bucket</b> <i>(Professional Storage Commands)</i></summary>

### **🎯 Learning Objective**: Master gsutil commands for enterprise-grade storage management

**📚 CLI Concepts You'll Master:**
- `gsutil` command-line tool proficiency
- Bucket creation with location and class specifications
- Storage configuration best practices through CLI
- Command validation and error handling

### **⚡ Optimized CLI Implementation:**

**Step 1: Environment Variable Setup (Professional Practice)**
```bash
# Set lab-specific variables for reusability
export BUCKET_NAME="YOUR-BUCKET-NAME-FROM-LAB"  # Replace with actual lab bucket name
export REGION="us-east4"
export ZONE="us-east4-a"

# Verify variables are set correctly
echo "Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"
```

**Step 2: Create Storage Bucket with Professional Configuration**
```bash
# Create bucket with optimal configuration
gsutil mb -l US gs://$BUCKET_NAME

# Verify bucket creation and configuration
gsutil ls -L gs://$BUCKET_NAME

# Optional: Set lifecycle policies for cost optimization
# gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
```

**🔍 Command Breakdown:**
- `mb`: Make bucket command
- `-l US`: Location specification for multi-region US storage
- `gs://`: Google Storage URI scheme
- `ls -L`: List with detailed information for verification

**✅ Success Verification:**
```bash
# Confirm bucket exists
gsutil ls | grep $BUCKET_NAME
```

</details>

<details>
<summary><b>💻 Task 2: Create VM with Persistent Disk</b> <i>(Infrastructure as Code Excellence)</i></summary>

### **🎯 Learning Objective**: Master gcloud compute commands for scalable infrastructure management

**📚 CLI Concepts You'll Master:**
- Advanced `gcloud compute` command structures
- VM instance configuration through CLI parameters
- Persistent disk creation and attachment workflows
- Network and firewall rule automation

### **⚡ Professional Infrastructure Commands:**

**Step 1: Create Persistent Disk First (Best Practice)**
```bash
# Create persistent disk with optimal configuration
gcloud compute disks create mydisk \
    --size=200GB \
    --zone=$ZONE \
    --type=pd-balanced \
    --description="Lab persistent disk for my-instance"

# Verify disk creation
gcloud compute disks list --filter="name:mydisk"
```

**Step 2: Create VM Instance with Advanced Configuration**
```bash
# Create VM with comprehensive configuration
gcloud compute instances create my-instance \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=$(gcloud config get-value account) \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=my-instance,image=projects/debian-cloud/global/images/debian-11-bullseye-v20231115,mode=rw,size=10,type=projects/$(gcloud config get-value project)/zones/$ZONE/diskTypes/pd-balanced \
    --disk=name=mydisk,device-name=persistent-disk-1,mode=rw,boot=no,auto-delete=no \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any

# Alternative: Simplified version for basic requirements
# gcloud compute instances create my-instance \
#     --zone=$ZONE \
#     --machine-type=e2-medium \
#     --image-family=debian-11 \
#     --image-project=debian-cloud \
#     --boot-disk-size=10GB \
#     --boot-disk-type=pd-balanced \
#     --disk=name=mydisk,mode=rw \
#     --tags=http-server
```

**Step 3: Configure Firewall Rules for HTTP Access**
```bash
# Create firewall rule for HTTP access
gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server \
    --description="Allow HTTP traffic on port 80"

# Verify firewall rule creation
gcloud compute firewall-rules list --filter="name:default-allow-http"
```

**🔍 Advanced Command Features:**
- `--zone`: Specifies deployment zone for latency optimization
- `--machine-type`: Defines compute resources for workload requirements
- `--disk`: Attaches additional persistent storage
- `--tags`: Enables firewall rule targeting
- `--scopes`: Configures service account permissions

**✅ Infrastructure Verification:**
```bash
# Verify VM creation and status
gcloud compute instances list --filter="name:my-instance"

# Check disk attachment
gcloud compute instances describe my-instance --zone=$ZONE --format="value(disks[].deviceName)"

# Verify firewall rules
gcloud compute firewall-rules list --filter="targetTags:http-server"
```

</details>

<details>
<summary><b>🌐 Task 3: Install NGINX Web Server</b> <i>(Automated Application Deployment)</i></summary>

### **🎯 Learning Objective**: Master remote command execution and service automation through CLI

**📚 CLI Concepts You'll Master:**
- SSH command execution through gcloud compute ssh
- Remote package management and service configuration
- Automated application deployment workflows
- Service status monitoring through CLI

### **⚡ Professional Deployment Commands:**

**Step 1: Connect and Execute Installation Commands**
```bash
# Method 1: Interactive SSH session
gcloud compute ssh my-instance --zone=$ZONE

# Once connected to the VM, run these commands:
sudo apt update && sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
exit
```

**Step 2: Alternative - Remote Command Execution (Automation-Ready)**
```bash
# Method 2: Direct command execution (scriptable approach)
gcloud compute ssh my-instance --zone=$ZONE --command="
sudo apt update && 
sudo apt install -y nginx && 
sudo systemctl start nginx && 
sudo systemctl enable nginx && 
sudo systemctl status nginx --no-pager
"
```

**Step 3: Advanced - Startup Script Method (Infrastructure as Code)**
```bash
# Method 3: Using startup script for automated deployment
gcloud compute instances add-metadata my-instance \
    --zone=$ZONE \
    --metadata startup-script='#!/bin/bash
apt update
apt install -y nginx
systemctl start nginx
systemctl enable nginx
echo "NGINX installation completed via startup script" > /var/log/nginx-install.log'

# Restart instance to execute startup script
gcloud compute instances reset my-instance --zone=$ZONE
```

**🔍 Professional Verification Commands:**

**Step 1: Service Status Verification**
```bash
# Check NGINX service status remotely
gcloud compute ssh my-instance --zone=$ZONE --command="sudo systemctl is-active nginx"

# Verify NGINX is listening on port 80
gcloud compute ssh my-instance --zone=$ZONE --command="sudo netstat -tlnp | grep :80"
```

**Step 2: Web Service Testing**
```bash
# Get external IP for testing
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "External IP: $EXTERNAL_IP"

# Test web server response (if you have curl locally)
curl -I http://$EXTERNAL_IP

# Alternative: Test from the VM itself
gcloud compute ssh my-instance --zone=$ZONE --command="curl -I localhost"
```

**🚀 Advanced Monitoring Commands:**
```bash
# Monitor VM performance
gcloud compute instances get-serial-port-output my-instance --zone=$ZONE

# Check VM logs
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=$INSTANCE_ID" --limit=10

# Monitor network connectivity
gcloud compute ssh my-instance --zone=$ZONE --command="sudo ss -tuln | grep :80"
```

</details>

---

## 🏆 **CLI Mastery Achievement Unlocked!**

<div align="center">

### **🎉 Congratulations, Command-Line Expert!**

You've successfully demonstrated professional-grade CLI expertise in Google Cloud!

</div>

<details>
<summary><b>⚡ Your Advanced CLI Accomplishments</b> <i>(Professional skills mastered)</i></summary>

**🔧 Technical CLI Mastery:**
- ✅ **gsutil Proficiency**: Expert-level Cloud Storage command-line operations
- ✅ **gcloud compute Excellence**: Advanced VM and infrastructure management
- ✅ **Remote Execution**: Sophisticated SSH and remote command capabilities
- ✅ **Script Automation**: Professional-grade automation and repeatability

**🚀 DevOps Skills Acquired:**
- ✅ **Infrastructure as Code**: CLI-based infrastructure provisioning
- ✅ **Automation Scripting**: Repeatable deployment workflows
- ✅ **Environment Management**: Professional variable and configuration handling
- ✅ **Monitoring Integration**: Command-line monitoring and verification

**💼 Career Advancement:**
- ✅ **DevOps Readiness**: Essential skills for DevOps Engineer roles
- ✅ **Cloud Architecture**: Foundation for Solutions Architect positions
- ✅ **Automation Expertise**: Valuable for Site Reliability Engineer roles
- ✅ **Professional Efficiency**: Demonstrated ability to work at enterprise scale

</details>

---

<div align="center">

## 🌟 **Continue Your CLI Excellence Journey**

**Your command-line mastery opens doors to advanced cloud automation!**

### **🎯 Professional Growth Opportunities:**

**🚀 Advanced Learning Paths**
- Explore **[Automation Solution](./Automation-Solution.md)** for Infrastructure as Code
- Master **[GUI Solution](./GUI-Solution.md)** for comprehensive understanding
- Try automation frameworks like Terraform and Ansible

**📝 Document Your Expertise**
- Create CLI cheat sheets for your reference
- Build reusable scripts for future projects
- Share your command-line techniques with the community

**🤖 Automation Excellence**
- Develop custom gcloud scripts for complex workflows
- Integrate CLI commands into CI/CD pipelines
- Explore Google Cloud SDK advanced features

---

**💖 Thank you for choosing our professional CLI approach!**

*Your command-line expertise sets you apart as a cloud professional*

[![GitHub](https://img.shields.io/badge/GitHub-CLI%20Excellence%20Hub-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-CLI%20Mastery%20Channel-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

**⚡ CLI Efficiency Rating**: 4.9/5 | **🚀 Automation Potential**: Excellent | **💼 Career Impact**: High

</div>

**Required**: VM `my-instance` in `us-east4-a` with attached disk `mydisk`

#### Console Method:

**Step 1: Create VM**
1. **Compute Engine** → **VM instances** → **CREATE INSTANCE**
2. **Name**: `my-instance`
3. **Region**: `us-east4` | **Zone**: `us-east4-a`
4. **Machine type**: e2-medium
5. **Boot disk**: Debian GNU/Linux 11, 10 GB, Balanced persistent disk
6. **Firewall**: ✅ Allow HTTP traffic
7. **CREATE**

**Step 2: Create Disk**
1. **Compute Engine** → **Disks** → **CREATE DISK**
2. **Name**: `mydisk`
3. **Zone**: `us-east4-a`
4. **Size**: 200 GB
5. **CREATE**

**Step 3: Attach Disk**
1. Go to VM `my-instance` → **EDIT**
2. **Additional disks** → **ADD NEW DISK**
3. Select `mydisk` → **DONE** → **SAVE**

#### Cloud Shell:
```bash
# Create VM
gcloud compute instances create my-instance \
    --zone=us-east4-a \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-type=pd-balanced \
    --boot-disk-size=10GB \
    --tags=http-server

# Create and attach disk
gcloud compute disks create mydisk \
    --zone=us-east4-a \
    --size=200GB

gcloud compute instances attach-disk my-instance \
    --zone=us-east4-a \
    --disk=mydisk
```

---

### Task 3: Install NGINX

**Required**: SSH into VM and install NGINX

#### SSH Method:
1. **Compute Engine** → **VM instances**
2. Click **SSH** next to `my-instance`
3. Run these commands:

```bash
sudo apt update
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### Cloud Shell:
```bash
gcloud compute ssh my-instance --zone=us-east4-a --command="
sudo apt update && 
sudo apt install -y nginx && 
sudo systemctl start nginx && 
sudo systemctl enable nginx"
```

---

## ✅ Verification

1. **Check lab progress**: Click "Check my progress" after each task
2. **Test web**: Click VM's External IP → should show "Welcome to nginx!"
3. **Commands**:
```bash
# Verify bucket
gsutil ls | grep YOUR-BUCKET-NAME

# Verify VM and disk
gcloud compute instances list --filter="name:my-instance"
gcloud compute instances describe my-instance --zone=us-east4-a
```

---

<div align="center">

**© 2025 CodeWithGarry**

</div>
