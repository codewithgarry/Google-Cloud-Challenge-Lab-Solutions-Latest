# The Basics of Google Cloud Compute: Challenge Lab - Complete Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Storage](https://img.shields.io/badge/Cloud%20Storage-4CAF50?style=for-the-badge&logo=google&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)

**Lab ID**: GSP313 | **Duration**: 1 hour | **Credits**: 5 | **Level**: Introductory

</div>

---

## �‍💻 Author Profile

<div align="center">

### **CodeWithGarry** 
*Google Cloud Solutions Architect & DevOps Engineer*

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=for-the-badge&logo=twitter)](https://twitter.com/codewithgarry)

**🎯 Specializing in**: Cloud Architecture • DevOps Automation • Google Cloud Platform • Kubernetes • Infrastructure as Code

**📚 Mission**: Helping developers and engineers master cloud technologies through practical, hands-on challenge lab solutions

**🏆 Certifications**: Google Cloud Professional Cloud Architect • AWS Solutions Architect • Kubernetes Certified Administrator

---

</div>

## �📋 Challenge Overview

**Scenario**: You're a junior cloud engineer tasked with building a complete web infrastructure on Google Cloud Platform. This hands-on challenge tests your ability to create and integrate core GCP services including Cloud Storage, Compute Engine, and web server deployment.

**Objective**: Deploy a scalable web application infrastructure using Google Cloud Storage bucket, Compute Engine VM with persistent disk, and NGINX web server with proper security configurations.

**Architecture Deployed**:
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Cloud Storage │    │  Compute Engine  │    │  NGINX Server   │
│     Bucket      │◄──►│     VM Instance  │◄──►│   (Port 80)     │
│                 │    │  + Persistent    │    │                 │
│  PROJECT-bucket │    │     Disk         │    │  Web Interface  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

---


## 🚀 Pre-requisites Setup

```bash
# Comprehensive environment setup and validation
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"

echo "🔍 Environment Configuration Check"
echo "=================================="
echo "📍 Project ID: $PROJECT_ID"
echo "📍 Default region: $(gcloud config get-value compute/region)"
echo "📍 Default zone: $(gcloud config get-value compute/zone)"
echo "📍 Current user: $(gcloud config get-value account)"

# Configure optimal region and zone for performance
echo "⚙️  Configuring optimal settings..."
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Enable required APIs
echo "🔧 Enabling required Google Cloud APIs..."
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Verify authentication and permissions
echo "🔐 Verifying authentication..."
gcloud auth list
gcloud projects describe $PROJECT_ID

echo "✅ Environment setup completed successfully!"
```

---

## 📝 Challenge Tasks Solutions

### 🎯 Task 1: Create Cloud Storage Bucket

#### **Method 1: Using gcloud CLI (Recommended for Automation)**
```bash
# Create globally unique Cloud Storage bucket
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-bucket"

echo "📦 Creating Cloud Storage bucket: $BUCKET_NAME"

# Create bucket with optimal configuration
gsutil mb -c STANDARD -l US gs://$BUCKET_NAME

# Set bucket labels for better organization
gsutil label ch -l environment:challenge-lab gs://$BUCKET_NAME
gsutil label ch -l project:compute-basics gs://$BUCKET_NAME

# Configure bucket for web hosting (optional enhancement)
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Verify bucket creation and configuration
gsutil ls -L gs://$BUCKET_NAME
gsutil label get gs://$BUCKET_NAME

echo "✅ Cloud Storage bucket created successfully: $BUCKET_NAME"
echo "🌐 Bucket URL: https://storage.googleapis.com/$BUCKET_NAME"
```

#### **Advanced Bucket Configuration (Optional)**

```bash
# Enable versioning for better data management
gsutil versioning set on gs://$BUCKET_NAME

# Set lifecycle rules for cost optimization
cat > lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
```

#### **Method 2: Using Google Cloud Console UI**
1. **Navigation**: **☰ Menu** → **Cloud Storage** → **Buckets**
2. Click **🆕 CREATE BUCKET**
3. **Bucket Configuration**:
   - **🏷️ Name**: `PROJECT_ID-bucket` (replace with actual project ID)
   - **📍 Location type**: Multi-region
   - **🌍 Location**: United States (US)
   - **💾 Storage class**: Standard
   - **🔒 Access control**: Uniform (recommended)
4. **Advanced Options** (Optional):
   - **🏷️ Labels**: Add `environment=challenge-lab`
   - **🔄 Versioning**: Enable for data protection
5. Click **✅ CREATE**

---

### 🎯 Task 2: Create Compute Engine Instance with Persistent Disk

#### **Step 2.1: Create High-Performance VM Instance**
```bash
# Create production-ready Compute Engine instance
INSTANCE_NAME="my-instance"
ZONE="us-central1-a"
PROJECT_ID=$(gcloud config get-value project)

echo "💻 Creating Compute Engine instance: $INSTANCE_NAME"

# Create instance with optimized configuration
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account="$(gcloud iam service-accounts list --format='value(email)' --filter='displayName:Compute Engine default service account')" \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-server,https-server,web-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/debian-cloud/global/images/family/debian-11,mode=rw,size=10,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=environment=challenge-lab,purpose=web-server \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y nginx
        systemctl start nginx
        systemctl enable nginx
        echo "<h1>Welcome to $(hostname)</h1><p>Instance created: $(date)</p>" > /var/www/html/index.html'

echo "✅ Compute Engine instance created successfully"

# Create comprehensive firewall rules
echo "🔥 Creating advanced firewall rules..."

# HTTP traffic rule
gcloud compute firewall-rules create allow-http-web-servers \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server \
    --description="Allow HTTP traffic to web servers"

# HTTPS traffic rule (for future SSL setup)
gcloud compute firewall-rules create allow-https-web-servers \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=https-server \
    --description="Allow HTTPS traffic to web servers"

# SSH rule (if not exists)
gcloud compute firewall-rules create allow-ssh-from-anywhere \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --description="Allow SSH from anywhere" 2>/dev/null || echo "SSH rule already exists"

echo "✅ Firewall rules configured successfully"
```

#### **Step 2.2: Create and Attach High-Performance Persistent Disk**
```bash
# Create high-performance persistent disk
DISK_NAME="mydisk"
DISK_SIZE="200GB"
ZONE="us-central1-a"

echo "💾 Creating persistent disk: $DISK_NAME"

# Create disk with optimal configuration
gcloud compute disks create $DISK_NAME \
    --zone=$ZONE \
    --size=$DISK_SIZE \
    --type=pd-standard \
    --labels=environment=challenge-lab,purpose=data-storage \
    --description="Persistent disk for challenge lab web server"

echo "✅ Persistent disk created successfully"

# Attach disk to running instance
echo "🔗 Attaching disk to instance..."
gcloud compute instances attach-disk $INSTANCE_NAME \
    --zone=$ZONE \
    --disk=$DISK_NAME \
    --device-name=data-disk

echo "✅ Disk attached successfully"

# Verify instance and disk configuration
echo "📊 Verifying instance and disk setup..."
gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE \
    --format="table(name,status,machineType.basename(),disks[].source.basename())"

gcloud compute disks list --filter="name:($DISK_NAME OR $INSTANCE_NAME)" \
    --format="table(name,sizeGb,type.basename(),status,users.basename())"

echo "✅ Instance and disk verification completed"
```

#### **Disk Formatting and Mounting (Post-SSH Setup)**

```bash
# Commands to run after SSH into the instance
# These will be included in the SSH section
MOUNT_COMMANDS=$(cat << 'EOF'
# Format and mount the attached disk
sudo mkfs.ext4 -F /dev/sdb
sudo mkdir -p /mnt/data
sudo mount /dev/sdb /mnt/data
sudo chmod 755 /mnt/data

# Add to fstab for persistent mounting
echo '/dev/sdb /mnt/data ext4 defaults 0 2' | sudo tee -a /etc/fstab

# Verify mount
df -h | grep /mnt/data
EOF
)
```

#### **Alternative: Console UI Method for Task 2**
**Creating VM Instance via Console:**

1. **Navigation**: **☰ Menu** → **Compute Engine** → **VM instances**
2. Click **🆕 CREATE INSTANCE**
3. **Instance Configuration**:
   - **🏷️ Name**: `my-instance`
   - **📍 Region**: `us-central1`
   - **📍 Zone**: `us-central1-a`
   - **⚙️ Machine family**: General-purpose
   - **📊 Series**: E2
   - **💻 Machine type**: e2-medium (2 vCPU, 4 GB memory)

4. **Boot Disk Configuration**:
   - Click **🔄 CHANGE**
   - **🖥️ Operating system**: Debian
   - **📀 Version**: Debian GNU/Linux 11 (bullseye)
   - **💾 Boot disk type**: Balanced persistent disk
   - **📏 Size**: 10 GB
   - Click **✅ SELECT**

5. **Security & Access**:
   - **🔐 Service account**: Compute Engine default service account
   - **🔑 Access scopes**: Allow default access

6. **Firewall Settings**:
   - ✅ **Allow HTTP traffic**
   - ✅ **Allow HTTPS traffic** (for future SSL)

7. **Advanced Options** → **Management**:
   - **🏷️ Labels**: Add `environment=challenge-lab`
   - **📝 Startup script**:
   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y nginx
   systemctl start nginx
   systemctl enable nginx
   echo "<h1>Welcome to $(hostname)</h1>" > /var/www/html/index.html
   ```

8. Click **✅ CREATE**

**Creating Persistent Disk via Console:**

1. **Navigation**: **☰ Menu** → **Compute Engine** → **Disks**
2. Click **🆕 CREATE DISK**
3. **Disk Configuration**:
   - **🏷️ Name**: `mydisk`
   - **📍 Region**: `us-central1`
   - **📍 Zone**: `us-central1-a`
   - **💾 Disk type**: Standard persistent disk
   - **📏 Size**: 200 GB
   - **🏷️ Labels**: `environment=challenge-lab`
4. Click **✅ CREATE**

**Attaching Disk to Instance:**

1. Go to **VM instances**, click on **`my-instance`**
2. Click **✏️ EDIT**
3. Under **Additional disks**, click **➕ ADD NEW DISK**
4. Select **💾 Existing disk**: `mydisk`
5. **Device name**: `data-disk`
6. Click **✅ DONE** → **✅ SAVE**

---

### 🎯 Task 3: Install and Configure NGINX Web Server

#### **Step 3.1: Secure SSH Connection**
```bash
# Establish SSH connection to the instance
INSTANCE_NAME="my-instance"
ZONE="us-central1-a"

echo "🔐 Connecting to instance via SSH..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE

# Alternative: SSH with specific user and key
# gcloud compute ssh --ssh-key-file=~/.ssh/gcp_key $INSTANCE_NAME --zone=$ZONE
```

#### **Step 3.2: Complete NGINX Installation and Configuration**

```bash
# ==================================================
# RUN THESE COMMANDS INSIDE THE SSH SESSION
# ==================================================

# System update and security patches
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
echo "📦 Installing essential packages..."
sudo apt install -y nginx curl wget unzip htop tree

# Start and enable NGINX
echo "🌐 Starting NGINX web server..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify NGINX status
sudo systemctl status nginx --no-pager -l

# Create custom welcome page
echo "📝 Creating custom web content..."
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Challenge Lab - Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { color: #4285f4; border-bottom: 2px solid #4285f4; padding-bottom: 10px; }
        .info { background: #e8f0fe; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .success { color: #0f9d58; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="header">🚀 Google Cloud Challenge Lab</h1>
        <div class="info">
            <h2>✅ Web Server Successfully Deployed!</h2>
            <p><strong>Server:</strong> NGINX on Debian 11</p>
            <p><strong>Instance:</strong> my-instance (e2-medium)</p>
            <p><strong>Zone:</strong> us-central1-a</p>
            <p><strong>Deployed:</strong> <script>document.write(new Date());</script></p>
        </div>
        <div class="success">
            <p>🎉 Challenge Lab Tasks Completed Successfully!</p>
            <ul>
                <li>✅ Cloud Storage Bucket Created</li>
                <li>✅ Compute Engine Instance Deployed</li>
                <li>✅ Persistent Disk Attached</li>
                <li>✅ NGINX Web Server Running</li>
                <li>✅ Firewall Rules Configured</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ Custom web page created successfully"
```

#### **Step 3.3: Format and Mount Persistent Disk**

```bash
# Format and mount the attached persistent disk
echo "💾 Setting up persistent disk..."

# Check available disks
lsblk

# Format the disk (usually /dev/sdb)
sudo mkfs.ext4 -F /dev/sdb

# Create mount point
sudo mkdir -p /mnt/data

# Mount the disk
sudo mount /dev/sdb /mnt/data

# Set proper permissions
sudo chmod 755 /mnt/data
sudo chown www-data:www-data /mnt/data

# Add to fstab for persistent mounting
echo '/dev/sdb /mnt/data ext4 defaults 0 2' | sudo tee -a /etc/fstab

# Verify mount
df -h | grep /mnt/data
echo "✅ Persistent disk mounted successfully at /mnt/data"
```

#### **Step 3.4: Advanced NGINX Configuration and Security**
```bash
# Configure NGINX for production use
echo "⚙️ Configuring NGINX for optimal performance..."

# Backup original configuration
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Create optimized NGINX configuration
sudo tee /etc/nginx/sites-available/challenge-lab > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    
    server_name _;
    root /var/www/html;
    index index.html index.htm;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Main location
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/challenge-lab /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test NGINX configuration
sudo nginx -t

# Reload NGINX
sudo systemctl reload nginx

echo "✅ NGINX configuration optimized and reloaded"
```

#### **Step 3.5: Comprehensive Testing and Validation**

```bash
# Test NGINX installation locally
echo "🧪 Testing NGINX installation..."

# Test local connectivity
curl -I localhost
curl localhost | head -20

# Check NGINX status and processes
sudo systemctl is-active nginx
sudo systemctl is-enabled nginx

# Verify NGINX configuration
sudo nginx -t

# Check listening ports
sudo netstat -tlnp | grep :80
sudo ss -tlnp | grep :80

# Get instance metadata
EXTERNAL_IP=$(curl -H "Metadata-Flavor: Google" -s http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
INTERNAL_IP=$(curl -H "Metadata-Flavor: Google" -s http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/ip)
HOSTNAME=$(hostname)

echo "📊 Instance Information:"
echo "🌐 External IP: $EXTERNAL_IP"
echo "🏠 Internal IP: $INTERNAL_IP"
echo "💻 Hostname: $HOSTNAME"
echo "🌍 Test URL: http://$EXTERNAL_IP"

# Create system info page
sudo tee /var/www/html/info.html > /dev/null << EOF
<!DOCTYPE html>
<html>
<head><title>System Information</title></head>
<body>
<h1>System Information</h1>
<p><strong>Hostname:</strong> $HOSTNAME</p>
<p><strong>External IP:</strong> $EXTERNAL_IP</p>
<p><strong>Internal IP:</strong> $INTERNAL_IP</p>
<p><strong>Uptime:</strong> $(uptime)</p>
<p><strong>Disk Usage:</strong></p>
<pre>$(df -h)</pre>
</body>
</html>
EOF

echo "✅ Testing completed successfully"
echo "🚀 Access your web server at: http://$EXTERNAL_IP"
```

---

## 🔍 Comprehensive Verification and Monitoring

### 📊 **Cloud Storage Verification**

```bash
# Comprehensive bucket verification
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-bucket"

echo "📦 Verifying Cloud Storage bucket..."

# List all buckets
gsutil ls

# Detailed bucket information
gsutil ls -L gs://$BUCKET_NAME

# Check bucket metadata and labels
gsutil label get gs://$BUCKET_NAME

# Test bucket accessibility and permissions
echo "Test file from $(date)" | gsutil cp - gs://$BUCKET_NAME/test.txt
gsutil cat gs://$BUCKET_NAME/test.txt

# Bucket usage statistics
gsutil du -s gs://$BUCKET_NAME

echo "✅ Cloud Storage verification completed"
```

### 💻 **Compute Engine Verification**

```bash
# Comprehensive instance and disk verification
INSTANCE_NAME="my-instance"
ZONE="us-central1-a"

echo "💻 Verifying Compute Engine resources..."

# Instance details
gcloud compute instances list --filter="name:$INSTANCE_NAME"

# Detailed instance information
gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE \
    --format="table(name,status,machineType.basename(),scheduling.preemptible,networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)"

# Disk information
gcloud compute disks list --filter="users:$INSTANCE_NAME OR name:mydisk" \
    --format="table(name,sizeGb,type.basename(),status,users.basename(),zone.basename())"

# Firewall rules verification
gcloud compute firewall-rules list --filter="targetTags:http-server OR targetTags:https-server" \
    --format="table(name,direction,priority,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW,targetTags.list():label=TARGET_TAGS)"

# Network connectivity test
gcloud compute instances get-serial-port-output $INSTANCE_NAME --zone=$ZONE | tail -20

echo "✅ Compute Engine verification completed"
```

### 🌐 **Web Application Testing**

```bash
# Comprehensive web server testing
echo "🌐 Testing web application..."

# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE \
    --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo "🌍 External IP: $EXTERNAL_IP"
echo "🔗 Primary URL: http://$EXTERNAL_IP"
echo "📊 Info page: http://$EXTERNAL_IP/info.html"
echo "💚 Health check: http://$EXTERNAL_IP/health"

# Test HTTP connectivity
echo "🧪 Testing HTTP connectivity..."
curl -I http://$EXTERNAL_IP
curl -s http://$EXTERNAL_IP | grep -i "challenge lab"

# Test response time
echo "⏱️ Testing response time..."
curl -w "@-" -o /dev/null -s http://$EXTERNAL_IP << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF

# Test health endpoint
curl -s http://$EXTERNAL_IP/health

echo "✅ Web application testing completed"
```

### 🔐 **Security and Performance Verification**

```bash
# Security and performance checks
echo "🔐 Running security and performance verification..."

# Check SSL/TLS configuration (for future HTTPS setup)
echo "🔒 SSL/TLS readiness check..."
gcloud compute ssl-certificates list 2>/dev/null || echo "No SSL certificates (expected for HTTP setup)"

# Performance monitoring
echo "📊 Performance metrics..."
gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE \
    --format="table(cpuPlatform,machineType.basename(),status)"

# Resource utilization (if monitoring enabled)
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=$INSTANCE_NAME" \
    --limit=5 --format="table(timestamp,severity,textPayload)" 2>/dev/null || echo "Logging data not yet available"

echo "✅ Security and performance verification completed"
```

---

## 🐛 Advanced Troubleshooting Guide

### 🚨 **Issue 1: Quota Exceeded Error**

```bash
# Comprehensive quota checking and resolution
echo "📊 Checking current quotas and usage..."

# Check all quotas
gcloud compute project-info describe \
    --format="table(quotas.metric,quotas.usage,quotas.limit)" | grep -E "(CPUS|DISKS|INSTANCES|IN_USE_ADDRESSES)"

# Check regional quotas
gcloud compute regions describe us-central1 \
    --format="table(quotas.metric,quotas.usage,quotas.limit)"

# Solution: Try alternative zones/regions
ALTERNATIVE_ZONES=("us-central1-b" "us-central1-c" "us-east1-a" "us-west1-a")

for zone in "${ALTERNATIVE_ZONES[@]}"; do
    echo "🔍 Trying zone: $zone"
    gcloud config set compute/zone $zone
    # Retry instance creation
    gcloud compute instances create my-instance --zone=$zone --dry-run 2>/dev/null && echo "✅ $zone available" || echo "❌ $zone quota exceeded"
done

# Request quota increase (if needed)
echo "📝 To request quota increase:"
echo "1. Go to: https://console.cloud.google.com/iam-admin/quotas"
echo "2. Filter by service: Compute Engine API"
echo "3. Select quota and click 'EDIT QUOTAS'"
```

### 🚨 **Issue 2: Firewall Rules Not Working**

```bash
# Comprehensive firewall troubleshooting
echo "🔥 Diagnosing firewall issues..."

# List all firewall rules
gcloud compute firewall-rules list --format="table(name,direction,priority,sourceRanges.list():label=SRC_RANGES,allowed[].map().firewall_rule().list():label=ALLOW,targetTags.list():label=TARGET_TAGS)"

# Check specific HTTP rules
gcloud compute firewall-rules describe allow-http-web-servers 2>/dev/null || echo "HTTP rule missing"

# Verify instance tags
gcloud compute instances describe my-instance --zone=$(gcloud config get-value compute/zone) \
    --format="value(tags.items)"

# Create missing firewall rules
echo "🛠️ Creating comprehensive firewall rules..."

# HTTP rule
gcloud compute firewall-rules create default-allow-http-fixed \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags http-server \
    --description "Allow HTTP traffic on port 80" \
    --no-user-output-enabled 2>/dev/null || echo "HTTP rule already exists or creation failed"

# SSH rule (backup)
gcloud compute firewall-rules create default-allow-ssh-backup \
    --allow tcp:22 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow SSH access" \
    --no-user-output-enabled 2>/dev/null || echo "SSH rule already exists"

# Test connectivity
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=$(gcloud config get-value compute/zone) --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
timeout 10 nc -zv $EXTERNAL_IP 80 2>/dev/null && echo "✅ Port 80 is accessible" || echo "❌ Port 80 is not accessible"
```

### 🚨 **Issue 3: NGINX Service Failures**

```bash
# Complete NGINX troubleshooting guide
echo "🌐 Diagnosing NGINX issues..."

# SSH into instance for detailed diagnosis
gcloud compute ssh my-instance --zone=$(gcloud config get-value compute/zone) --command='
echo "🔍 NGINX Service Diagnosis:"
echo "========================="

# Check service status
sudo systemctl status nginx --no-pager -l

# Check if NGINX is running
if sudo systemctl is-active nginx >/dev/null 2>&1; then
    echo "✅ NGINX is running"
else
    echo "❌ NGINX is not running - attempting to start..."
    sudo systemctl start nginx
    sudo systemctl enable nginx
fi

# Check configuration syntax
echo "🔧 Configuration check:"
sudo nginx -t

# Check listening ports
echo "👂 Listening ports:"
sudo netstat -tlnp | grep nginx || echo "NGINX not listening on any ports"

# Check error logs
echo "📋 Recent error logs:"
sudo tail -20 /var/log/nginx/error.log 2>/dev/null || echo "No error logs found"

# Check access logs
echo "📊 Recent access logs:"
sudo tail -10 /var/log/nginx/access.log 2>/dev/null || echo "No access logs found"

# Verify web content
echo "📄 Web content check:"
ls -la /var/www/html/

# Test local connectivity
echo "🧪 Local connectivity test:"
curl -I localhost 2>/dev/null || echo "Local connection failed"

echo "✅ NGINX diagnosis completed"
'
```

### 🚨 **Issue 4: Persistent Disk Not Mounting**

```bash
# Comprehensive disk troubleshooting
echo "💾 Diagnosing persistent disk issues..."

gcloud compute ssh my-instance --zone=$(gcloud config get-value compute/zone) --command='
echo "🔍 Disk Diagnosis:"
echo "=================="

# List all block devices
echo "📀 Available block devices:"
lsblk

# Check disk partitions
echo "📊 Disk partitions:"
sudo fdisk -l 2>/dev/null | grep -E "Disk /dev/sd"

# Check current mounts
echo "🗂️ Current mounts:"
df -h

# Check fstab entries
echo "📋 fstab entries:"
cat /etc/fstab

# Attempt to mount if not mounted
if ! mountpoint -q /mnt/data; then
    echo "🛠️ Attempting to mount disk..."
    sudo mkdir -p /mnt/data
    
    # Try to mount /dev/sdb
    if [ -b /dev/sdb ]; then
        echo "Found /dev/sdb, attempting to mount..."
        sudo mount /dev/sdb /mnt/data 2>/dev/null && echo "✅ Mount successful" || {
            echo "❌ Mount failed, formatting disk..."
            sudo mkfs.ext4 -F /dev/sdb
            sudo mount /dev/sdb /mnt/data
            echo "/dev/sdb /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab
        }
    else
        echo "❌ /dev/sdb not found"
    fi
else
    echo "✅ Disk already mounted at /mnt/data"
fi

# Final verification
echo "🎯 Final disk status:"
df -h | grep -E "(Filesystem|/mnt/data)"
'
```

### 🚨 **Issue 5: Network Connectivity Problems**

```bash
# Network connectivity troubleshooting
echo "🌐 Diagnosing network connectivity..."

# Check instance network configuration
gcloud compute instances describe my-instance --zone=$(gcloud config get-value compute/zone) \
    --format="table(networkInterfaces[0].network.basename(),networkInterfaces[0].subnetwork.basename(),networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)"

# Test external connectivity
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=$(gcloud config get-value compute/zone) --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

if [ -n "$EXTERNAL_IP" ]; then
    echo "🌍 Testing external IP: $EXTERNAL_IP"
    
    # Ping test
    ping -c 3 $EXTERNAL_IP >/dev/null 2>&1 && echo "✅ Ping successful" || echo "❌ Ping failed"
    
    # Port connectivity test
    timeout 5 nc -zv $EXTERNAL_IP 80 2>/dev/null && echo "✅ HTTP port accessible" || echo "❌ HTTP port not accessible"
    timeout 5 nc -zv $EXTERNAL_IP 22 2>/dev/null && echo "✅ SSH port accessible" || echo "❌ SSH port not accessible"
    
    # HTTP response test
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP --max-time 10)
    echo "🌐 HTTP Status Code: $HTTP_STATUS"
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ Web server responding correctly"
    else
        echo "❌ Web server not responding correctly"
    fi
else
    echo "❌ No external IP assigned"
fi

# Route and DNS tests
echo "🗺️ Network route test:"
gcloud compute ssh my-instance --zone=$(gcloud config get-value compute/zone) --command='
    echo "Gateway: $(ip route | grep default)"
    echo "DNS: $(cat /etc/resolv.conf | grep nameserver)"
    echo "Internet connectivity: $(curl -s --max-time 5 http://google.com >/dev/null && echo "✅ Working" || echo "❌ Failed")"
'
```

---

## 🚀 Complete Automation Script (Professional Grade)
```bash
#!/bin/bash

# =================================================================
# Google Cloud Compute Challenge Lab - Complete Automation Script
# Professional Grade Solution with Error Handling and Monitoring
# =================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
INSTANCE_NAME="my-instance"
DISK_NAME="mydisk"
BUCKET_NAME="${PROJECT_ID}-bucket"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Function to check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if user is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        error "No active gcloud authentication found. Run: gcloud auth login"
    fi
    
    # Check if project is set
    if [ -z "$PROJECT_ID" ]; then
        error "No project ID found. Run: gcloud config set project YOUR_PROJECT_ID"
    fi
    
    # Check required APIs
    log "🔧 Enabling required APIs..."
    gcloud services enable compute.googleapis.com storage.googleapis.com --quiet
    
    success "Prerequisites check completed"
}

# Function to create storage bucket
create_storage_bucket() {
    log "📦 Creating Cloud Storage bucket: $BUCKET_NAME"
    
    if gsutil ls gs://$BUCKET_NAME >/dev/null 2>&1; then
        warning "Bucket $BUCKET_NAME already exists"
    else
        gsutil mb -c STANDARD -l US gs://$BUCKET_NAME
        gsutil label ch -l environment:challenge-lab gs://$BUCKET_NAME
        success "Cloud Storage bucket created successfully"
    fi
    
    # Verify bucket
    gsutil ls gs://$BUCKET_NAME >/dev/null || error "Failed to access bucket"
}

# Function to create compute instance
create_compute_instance() {
    log "💻 Creating Compute Engine instance: $INSTANCE_NAME"
    
    # Configure region and zone
    gcloud config set compute/region $REGION --quiet
    gcloud config set compute/zone $ZONE --quiet
    
    # Check if instance already exists
    if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE >/dev/null 2>&1; then
        warning "Instance $INSTANCE_NAME already exists"
    else
        # Create instance with startup script
        gcloud compute instances create $INSTANCE_NAME \
            --zone=$ZONE \
            --machine-type=e2-medium \
            --network-interface=network-tier=PREMIUM,subnet=default \
            --maintenance-policy=MIGRATE \
            --service-account="$(gcloud iam service-accounts list --format='value(email)' --filter='displayName:Compute Engine default service account')" \
            --scopes=https://www.googleapis.com/auth/cloud-platform \
            --tags=http-server,https-server \
            --image-family=debian-11 \
            --image-project=debian-cloud \
            --boot-disk-size=10GB \
            --boot-disk-type=pd-balanced \
            --labels=environment=challenge-lab \
            --metadata=startup-script='#!/bin/bash
                apt-get update
                apt-get install -y nginx
                systemctl start nginx
                systemctl enable nginx
                cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html><head><title>Challenge Lab Success</title>
<style>body{font-family:Arial;margin:40px;background:#f5f5f5}
.container{background:white;padding:30px;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,0.1)}
.success{color:#0f9d58;font-weight:bold}</style></head>
<body><div class="container">
<h1>� Google Cloud Challenge Lab</h1>
<p class="success">✅ Web Server Successfully Deployed!</p>
<p>Instance: $INSTANCE_NAME | Zone: $ZONE</p>
<p>Deployed: $(date)</p></div></body></html>
EOF' \
            --quiet
        
        success "Compute Engine instance created successfully"
    fi
    
    # Wait for instance to be running
    log "⏳ Waiting for instance to be ready..."
    gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status)" | grep -q "RUNNING" || {
        sleep 30
        gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status)" | grep -q "RUNNING" || error "Instance failed to start"
    }
}

# Function to create and attach persistent disk
create_persistent_disk() {
    log "💾 Creating persistent disk: $DISK_NAME"
    
    if gcloud compute disks describe $DISK_NAME --zone=$ZONE >/dev/null 2>&1; then
        warning "Disk $DISK_NAME already exists"
    else
        gcloud compute disks create $DISK_NAME \
            --zone=$ZONE \
            --size=200GB \
            --type=pd-standard \
            --labels=environment=challenge-lab \
            --quiet
        
        success "Persistent disk created successfully"
    fi
    
    # Check if disk is already attached
    if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(disks[].source)" | grep -q $DISK_NAME; then
        warning "Disk already attached to instance"
    else
        log "🔗 Attaching disk to instance..."
        gcloud compute instances attach-disk $INSTANCE_NAME \
            --zone=$ZONE \
            --disk=$DISK_NAME \
            --device-name=data-disk \
            --quiet
        
        success "Disk attached successfully"
    fi
}

# Function to configure firewall rules
configure_firewall() {
    log "🔥 Configuring firewall rules..."
    
    # HTTP rule
    if gcloud compute firewall-rules describe allow-http-web-servers >/dev/null 2>&1; then
        warning "HTTP firewall rule already exists"
    else
        gcloud compute firewall-rules create allow-http-web-servers \
            --direction=INGRESS \
            --priority=1000 \
            --network=default \
            --action=ALLOW \
            --rules=tcp:80 \
            --source-ranges=0.0.0.0/0 \
            --target-tags=http-server \
            --description="Allow HTTP traffic to web servers" \
            --quiet
        
        success "HTTP firewall rule created"
    fi
    
    # HTTPS rule (for future use)
    if gcloud compute firewall-rules describe allow-https-web-servers >/dev/null 2>&1; then
        warning "HTTPS firewall rule already exists"
    else
        gcloud compute firewall-rules create allow-https-web-servers \
            --direction=INGRESS \
            --priority=1000 \
            --network=default \
            --action=ALLOW \
            --rules=tcp:443 \
            --source-ranges=0.0.0.0/0 \
            --target-tags=https-server \
            --description="Allow HTTPS traffic to web servers" \
            --quiet
        
        success "HTTPS firewall rule created"
    fi
}

# Function to wait for NGINX and test
test_deployment() {
    log "🧪 Testing deployment..."
    
    # Get external IP
    EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    
    if [ -z "$EXTERNAL_IP" ]; then
        error "No external IP found for instance"
    fi
    
    log "🌍 External IP: $EXTERNAL_IP"
    
    # Wait for web server to be ready
    log "⏳ Waiting for web server to be ready..."
    for i in {1..30}; do
        if curl -s --max-time 5 http://$EXTERNAL_IP >/dev/null 2>&1; then
            success "Web server is responding"
            break
        fi
        if [ $i -eq 30 ]; then
            error "Web server not responding after 30 attempts"
        fi
        sleep 10
    done
    
    # Test HTTP response
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP --max-time 10)
    if [ "$HTTP_STATUS" = "200" ]; then
        success "HTTP test passed (Status: $HTTP_STATUS)"
    else
        warning "HTTP test returned status: $HTTP_STATUS"
    fi
}

# Function to display final results
display_results() {
    log "📊 Deployment Summary"
    echo "=================================="
    
    # Project and region info
    echo -e "${PURPLE}Project ID:${NC} $PROJECT_ID"
    echo -e "${PURPLE}Region:${NC} $REGION"
    echo -e "${PURPLE}Zone:${NC} $ZONE"
    echo ""
    
    # Storage bucket info
    echo -e "${PURPLE}Cloud Storage Bucket:${NC}"
    echo "  Name: $BUCKET_NAME"
    echo "  URL: https://storage.googleapis.com/$BUCKET_NAME"
    echo ""
    
    # Instance info
    echo -e "${PURPLE}Compute Engine Instance:${NC}"
    EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
    echo "  Name: $INSTANCE_NAME"
    echo "  External IP: $EXTERNAL_IP"
    echo "  Zone: $ZONE"
    echo "  Machine Type: e2-medium"
    echo ""
    
    # Disk info
    echo -e "${PURPLE}Persistent Disk:${NC}"
    echo "  Name: $DISK_NAME"
    echo "  Size: 200GB"
    echo "  Type: pd-standard"
    echo ""
    
    # Web server info
    echo -e "${PURPLE}Web Server:${NC}"
    echo "  URL: http://$EXTERNAL_IP"
    echo "  Server: NGINX on Debian 11"
    echo "  Status: $(curl -s --max-time 5 http://$EXTERNAL_IP >/dev/null && echo "✅ Online" || echo "❌ Offline")"
    echo ""
    
    success "Challenge Lab completed successfully!"
    echo ""
    echo -e "${GREEN}🎉 Access your web application at: ${BLUE}http://$EXTERNAL_IP${NC}"
}

# Main execution flow
main() {
    echo -e "${BLUE}"
    echo "================================================================"
    echo "🚀 Google Cloud Compute Challenge Lab - Automated Solution"
    echo "================================================================"
    echo -e "${NC}"
    
    check_prerequisites
    create_storage_bucket
    create_compute_instance
    create_persistent_disk
    configure_firewall
    test_deployment
    display_results
    
    echo -e "${GREEN}"
    echo "================================================================"
    echo "✅ Challenge Lab Automation Completed Successfully!"
    echo "================================================================"
    echo -e "${NC}"
}

# Error handling
trap 'error "Script failed at line $LINENO"' ERR

# Run main function
main "$@"
```

---

## 📊 Performance Monitoring and Optimization

- [ ] ✅ Cloud Storage bucket created with name `PROJECT_ID-bucket`
- [ ] ✅ VM instance `my-instance` created with e2-medium machine type
- [ ] ✅ Persistent disk `mydisk` (200GB) created and attached
- [ ] ✅ HTTP firewall rule enabled
- [ ] ✅ NGINX installed and running
- [ ] ✅ Web application accessible via external IP
- [ ] ✅ "Welcome to nginx!" page loads successfully

**Lab completion time**: Approximately 10-15 minutes

---

## 📚 Additional Resources & Learning Materials

### 🎓 **Recommended Learning Path**
- [Google Cloud Skills Boost](https://www.cloudskillsboost.google/)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Compute Engine Best Practices](https://cloud.google.com/compute/docs/best-practices)
- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)

### 🛠️ **Advanced Topics to Explore**
- Container deployment with GKE
- Load balancing and auto-scaling
- Infrastructure as Code with Terraform
- CI/CD pipelines with Cloud Build
- Monitoring with Cloud Operations Suite

---

<div align="center">

## 🎯 **About This Solution**

This comprehensive challenge lab solution is crafted by **CodeWithGarry** to help you master Google Cloud Platform fundamentals through practical, hands-on experience.

### 📞 **Connect with CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=for-the-badge&logo=twitter)](https://twitter.com/codewithgarry)

### 🌟 **Why Choose Our Solutions?**

✅ **Professional Grade**: Production-ready code and best practices  
✅ **Comprehensive**: Covers all challenge scenarios and edge cases  
✅ **Well Documented**: Step-by-step explanations and troubleshooting  
✅ **Automation Ready**: Complete scripts for quick deployment  
✅ **Community Driven**: Regular updates and community support  

### 🎁 **Support the Project**

If this solution helped you succeed in your challenge lab:
- ⭐ **Star** this repository
- 🍴 **Fork** for your own learning
- 📢 **Share** with fellow cloud engineers
- 💝 **Subscribe** to our YouTube channel for more content

---

### 📝 **License & Usage**

This solution is provided under MIT License. Feel free to use, modify, and distribute for educational purposes.

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

---

*"Empowering the next generation of cloud engineers, one challenge lab at a time."*

**Happy Learning! 🚀☁️**

</div>
