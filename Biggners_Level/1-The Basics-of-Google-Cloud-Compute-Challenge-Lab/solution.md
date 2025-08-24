# Google Cloud Challenge Lab - Complete Solution

## Challenge Overview
Build infrastructure for web application using Google Cloud with Storage bucket, Compute Engine VM with persistent disk, and NGINX web server.

## Pre-requisites Check
```bash
# Current project and region check
PROJECT_ID=$(gcloud config get-value project)
echo "Project ID: $PROJECT_ID"
echo "Default region: $(gcloud config get-value compute/region)"
echo "Default zone: $(gcloud config get-value compute/zone)"

# Set region and zone (update these based on lab requirements)
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

---

## Task 1: Create Cloud Storage Bucket

### Method 1: Using gcloud CLI (Recommended)
```bash
# Create bucket with PROJECT_ID-bucket name
PROJECT_ID=$(gcloud config get-value project)
gsutil mb -c STANDARD -l US gs://${PROJECT_ID}-bucket

# Verify bucket creation
gsutil ls gs://${PROJECT_ID}-bucket
echo "✅ Bucket created successfully: ${PROJECT_ID}-bucket"
```

### Method 2: Using Console UI
1. **Navigation Menu** → **Cloud Storage** → **Buckets**
2. Click **CREATE BUCKET**
3. **Name**: `PROJECT_ID-bucket` (replace PROJECT_ID with actual project ID)
4. **Location type**: Multi-region
5. **Location**: United States (US)
6. **Storage class**: Standard
7. Click **CREATE**

---

## Task 2: Create Compute Engine Instance with Persistent Disk

### Step 2.1: Create the VM Instance
```bash
# Create compute instance with required specifications
gcloud compute instances create my-instance \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=my-instance,image=projects/debian-cloud/global/images/family/debian-11,mode=rw,size=10,type=projects/PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any

# Enable HTTP traffic (firewall rule)
gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
```

### Step 2.2: Create and Attach Persistent Disk
```bash
# Create persistent disk
gcloud compute disks create mydisk \
    --zone=us-central1-a \
    --size=200GB \
    --type=pd-standard

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
    --zone=us-central1-a \
    --disk=mydisk

# Verify instance and disk creation
gcloud compute instances describe my-instance --zone=us-central1-a
```

### Alternative: Console UI Method for Task 2
1. **Navigation Menu** → **Compute Engine** → **VM instances**
2. Click **CREATE INSTANCE**
3. **Configuration**:
   - **Name**: `my-instance`
   - **Region**: `us-central1`
   - **Zone**: `us-central1-a`
   - **Machine family**: General-purpose
   - **Series**: E2
   - **Machine type**: e2-medium
4. **Boot disk**:
   - Click **CHANGE**
   - **Operating system**: Debian
   - **Version**: Debian GNU/Linux 11 (bullseye)
   - **Boot disk type**: Balanced persistent disk
   - **Size**: 10 GB
   - Click **SELECT**
5. **Firewall**:
   - ✅ Allow HTTP traffic
6. Click **CREATE**

**For Persistent Disk**:
1. **Navigation Menu** → **Compute Engine** → **Disks**
2. Click **CREATE DISK**
3. **Name**: `mydisk`
4. **Region**: `us-central1`
5. **Zone**: `us-central1-a`
6. **Disk type**: Standard persistent disk
7. **Size**: 200 GB
8. Click **CREATE**
9. Go back to **VM instances**, click on `my-instance`
10. Click **EDIT**
11. Under **Additional disks**, click **ADD NEW DISK**
12. Select **Existing disk**: `mydisk`
13. Click **SAVE**

---

## Task 3: Install NGINX Web Server

### Step 3.1: SSH into the Instance
```bash
# SSH into the instance
gcloud compute ssh my-instance --zone=us-central1-a
```

### Step 3.2: Install NGINX (Run these commands in SSH)
```bash
# Update the OS
sudo apt update
sudo apt upgrade -y

# Install NGINX
sudo apt install nginx -y

# Start NGINX service
sudo systemctl start nginx

# Enable NGINX to start on boot
sudo systemctl enable nginx

# Check NGINX status
sudo systemctl status nginx

# Verify NGINX is running
sudo systemctl is-active nginx
```

### Step 3.3: Configure Firewall (if needed)
```bash
# Check if UFW is active
sudo ufw status

# If UFW is active, allow HTTP
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx Full'
```

### Step 3.4: Test NGINX Installation
```bash
# Test locally
curl localhost

# Check NGINX configuration
sudo nginx -t

# Get external IP
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip
```

---

## Verification Steps

### Check Cloud Storage Bucket
```bash
# List buckets to verify creation
gsutil ls

# Check bucket details
gsutil ls -L gs://${PROJECT_ID}-bucket
```

### Check Compute Instance and Disk
```bash
# List instances
gcloud compute instances list

# List disks
gcloud compute disks list

# Check instance details
gcloud compute instances describe my-instance --zone=us-central1-a --format="table(name,status,machineType.basename(),scheduling.preemptible)"
```

### Test Web Application
```bash
# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=us-central1-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "External IP: $EXTERNAL_IP"
echo "Test URL: http://$EXTERNAL_IP"

# Test from command line
curl http://$EXTERNAL_IP
```

---

## Common Issues and Solutions

### Issue 1: Quota Exceeded
```bash
# Check quotas
gcloud compute project-info describe --format="table(quotas.metric,quotas.usage,quotas.limit)"

# Try different zone if quota issue
gcloud config set compute/zone us-central1-b
```

### Issue 2: Firewall Rule Missing
```bash
# Create HTTP firewall rule if missing
gcloud compute firewall-rules create allow-http-80 \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --description "Allow HTTP traffic on port 80"
```

### Issue 3: NGINX Not Starting
```bash
# SSH into instance and check
sudo systemctl status nginx
sudo journalctl -u nginx
sudo nginx -t
```

### Issue 4: Can't Access Web Page
```bash
# Check if instance is running
gcloud compute instances list

# Check firewall rules
gcloud compute firewall-rules list

# Test internal connectivity
sudo netstat -tlnp | grep :80
```

---

## Quick Complete Script (All Tasks)
```bash
#!/bin/bash

# Set variables
PROJECT_ID=$(gcloud config get-value project)
ZONE="us-central1-a"
REGION="us-central1"

echo "🚀 Starting Challenge Lab Solution..."

# Task 1: Create Storage Bucket
echo "📦 Creating Storage Bucket..."
gsutil mb -c STANDARD -l US gs://${PROJECT_ID}-bucket
echo "✅ Bucket created: ${PROJECT_ID}-bucket"

# Task 2: Create VM and Disk
echo "💻 Creating VM Instance..."
gcloud compute instances create my-instance \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server

echo "💾 Creating Persistent Disk..."
gcloud compute disks create mydisk \
    --zone=$ZONE \
    --size=200GB \
    --type=pd-standard

echo "🔗 Attaching Disk to Instance..."
gcloud compute instances attach-disk my-instance \
    --zone=$ZONE \
    --disk=mydisk

echo "🔥 Creating Firewall Rule..."
gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Task 3: Install NGINX (this needs to be done via SSH)
echo "🌐 SSH into instance and run these commands:"
echo "sudo apt update && sudo apt install nginx -y"
echo "sudo systemctl start nginx && sudo systemctl enable nginx"

# Get external IP for testing
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=$ZONE --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "🌍 Test URL: http://$EXTERNAL_IP"

echo "✅ Challenge Lab Setup Complete!"
```

---

## Final Testing Checklist

- [ ] ✅ Cloud Storage bucket created with name `PROJECT_ID-bucket`
- [ ] ✅ VM instance `my-instance` created with e2-medium machine type
- [ ] ✅ Persistent disk `mydisk` (200GB) created and attached
- [ ] ✅ HTTP firewall rule enabled
- [ ] ✅ NGINX installed and running
- [ ] ✅ Web application accessible via external IP
- [ ] ✅ "Welcome to nginx!" page loads successfully

**Lab completion time**: Approximately 10-15 minutes

Good luck with your challenge lab! 🚀
