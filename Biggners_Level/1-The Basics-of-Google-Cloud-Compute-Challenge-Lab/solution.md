# The Basics of Google Cloud Compute: Challenge Lab

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

## ⚠️ **IMPORTANT: Check Your Lab Instructions**

**Before starting, note these values from YOUR lab instructions:**
- **Bucket name**: `qwiklabs-gcp-01-[YOUR-LAB-ID]-bucket` 
- **Region**: `us-east4` (as specified in lab)
- **Zone**: `us-east4-a` (as specified in lab)
- **Project ID**: Check top of your lab page

---

## 📋 Challenge Tasks

**Task 1**: Create a Cloud Storage bucket  
**Task 2**: Create and attach a persistent disk to a Compute Engine instance  
**Task 3**: Install a NGINX web server

---

## 🚀 Solutions

### Task 1: Create Cloud Storage bucket

**Required**: Create bucket named `qwiklabs-gcp-01-[YOUR-LAB-ID]-bucket` (US multi-region)

#### Method 1: Google Cloud Console
1. Go to **Cloud Storage** → **Buckets**
2. Click **CREATE BUCKET**
3. **Name**: Copy the exact bucket name from your lab instructions (e.g., `qwiklabs-gcp-01-944f5f1bd5e1-bucket`)
4. **Location type**: Multi-region
5. **Location**: United States (US)
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
# Replace with the exact bucket name from your lab instructions
BUCKET_NAME="qwiklabs-gcp-01-944f5f1bd5e1-bucket"
gsutil mb -c STANDARD -l US gs://$BUCKET_NAME
```

---

### Task 2: Create and attach persistent disk to Compute Engine instance

**Required Configuration**:
- **Instance name**: `my-instance`
- **Series**: E2
- **Machine type**: `e2-medium`
- **Boot disk**: New balanced persistent disk, 10 GB, Debian GNU/Linux 11 (bullseye)
- **Location**: `us-east4` region, `us-east4-a` zone
- **Firewall**: Allow HTTP traffic
- **Disk name**: `mydisk`
- **Disk size**: 200GB

#### Method 1: Google Cloud Console

**Step 1: Create VM Instance**
1. Go to **Compute Engine** → **VM instances**
2. Click **CREATE INSTANCE**
3. **Name**: `my-instance`
4. **Region**: `us-east4`
5. **Zone**: `us-east4-a`
6. **Machine configuration**:
   - **Series**: E2
   - **Machine type**: e2-medium
7. **Boot disk**: Click **CHANGE**
   - **Operating system**: Debian
   - **Version**: Debian GNU/Linux 11 (bullseye)
   - **Boot disk type**: Balanced persistent disk
   - **Size**: 10 GB
   - Click **SELECT**
8. **Firewall**: ✅ Allow HTTP traffic
9. Click **CREATE**

**Step 2: Create Persistent Disk**
1. Go to **Compute Engine** → **Disks**
2. Click **CREATE DISK**
3. **Name**: `mydisk`
4. **Region**: `us-east4`
5. **Zone**: `us-east4-a`
6. **Disk type**: Standard persistent disk
7. **Size**: 200 GB
8. Click **CREATE**

**Step 3: Attach Disk to Instance**
1. Go to **Compute Engine** → **VM instances**
2. Click on `my-instance`
3. Click **EDIT**
4. Under **Additional disks**, click **ADD NEW DISK**
5. **Disk**: Select `mydisk`
6. **Mode**: Read/write
7. Click **DONE** → **SAVE**

#### Method 2: Cloud Shell
```bash
# Create VM instance
gcloud compute instances create my-instance \
    --zone=us-east4-a \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --boot-disk-type=pd-balanced \
    --boot-disk-size=10GB \
    --tags=http-server

# Create persistent disk
gcloud compute disks create mydisk \
    --zone=us-east4-a \
    --size=200GB \
    --type=pd-standard

# Attach disk to instance
gcloud compute instances attach-disk my-instance \
    --zone=us-east4-a \
    --disk=mydisk
```

---

### Task 3: Install NGINX web server

**Required**: SSH into instance, update OS, install NGINX, confirm it's running

#### Method 1: Using SSH in Console
1. Go to **Compute Engine** → **VM instances**
2. Click **SSH** next to `my-instance`
3. In the SSH terminal, run these commands:

```bash
# Update the OS
sudo apt update

# Install NGINX
sudo apt install -y nginx

# Start NGINX service
sudo systemctl start nginx

# Enable NGINX to start on boot
sudo systemctl enable nginx

# Confirm NGINX is running
sudo systemctl status nginx
```

#### Method 2: Using Cloud Shell
```bash
# SSH into the instance and run commands
gcloud compute ssh my-instance --zone=us-east4-a --command="
sudo apt update && 
sudo apt install -y nginx && 
sudo systemctl start nginx && 
sudo systemctl enable nginx && 
sudo systemctl status nginx
"
```

---

## ✅ Verification Steps

### Check Progress in Lab Interface
1. **Task 1**: Click "Check my progress" - bucket should be created
2. **Task 2**: Click "Check my progress" - instance and disk should be attached  
3. **Task 3**: Click "Check my progress" - NGINX should be installed

### Test Web Application
1. Go to **Compute Engine** → **VM instances**
2. Find the **External IP** of `my-instance`
3. Click the External IP link OR open `http://EXTERNAL_IP/` in browser
4. You should see **"Welcome to nginx!"** page

### Manual Verification Commands
```bash
# Check bucket exists
gsutil ls | grep qwiklabs-gcp-01

# Check instance is running
gcloud compute instances list --filter="name:my-instance"

# Check disk is attached
gcloud compute instances describe my-instance --zone=us-east4-a \
    --format="value(disks[].source.basename())"

# Check NGINX is running (after SSH)
curl http://$(gcloud compute instances describe my-instance \
    --zone=us-east4-a --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
```

---

## 🚨 Common Issues & Solutions

**Issue**: Bucket name already exists
- **Solution**: Use the exact bucket name from your lab instructions

**Issue**: Instance won't start  
- **Solution**: Ensure you're using `us-east4-a` zone as specified

**Issue**: Can't access web page
- **Solution**: Verify HTTP firewall rule is enabled and NGINX is running

**Issue**: SSH connection fails
- **Solution**: Wait for instance to fully boot, then try SSH again

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>

---

## 🚀 Solutions

### Task 1: Create Cloud Storage Bucket

#### Method 1: Google Cloud Console
1. Go to **Cloud Storage** → **Buckets**
2. Click **CREATE BUCKET**
3. **Name**: `<PROJECT_ID>-bucket` (replace <PROJECT_ID> with your actual project ID)
4. **Location**: Multi-region, United States (US)
5. Click **CREATE**

#### Method 2: Cloud Shell
```bash
PROJECT_ID=$(gcloud config get-value project)
gsutil mb gs://$PROJECT_ID-bucket
```

---

### Task 2: Create Compute Engine Instance

#### Method 1: Google Cloud Console
1. Go to **Compute Engine** → **VM instances**
2. Click **CREATE INSTANCE**
3. **Name**: `my-instance`
4. **Region**: `us-central1`
5. **Zone**: `<Replace-With-Provided-In-Lab>`
6. **Machine type**: `e2-medium`
7. **Boot disk**: Debian GNU/Linux 11 (bullseye)
8. **Firewall**: ✅ Allow HTTP traffic
9. Click **CREATE**

#### Method 2: Cloud Shell
```bash
gcloud compute instances create my-instance \
    --zone=<REPLACE-ZONE-PROVIDED-IN-LAB> \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=http-server
```

---

### Task 3: Create Persistent Disk (if required)

#### Method 1: Google Cloud Console
1. Go to **Compute Engine** → **Disks**
2. Click **CREATE DISK**
3. **Name**: `<Replace-With-Disk-Name-Provided-In-Lab>`
4. **Zone**: `<Replace-With-Provided-In-Lab>`
5. **Size**: 200 GB
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
gcloud compute disks create <Replace-With-Disk-Name-Provided-In-Lab> \
    --zone=<Replace-With-Provided-In-Lab> \
    --size=200GB
```

#### Attach disk to instance:
```bash
gcloud compute instances attach-disk my-instance \
    --zone=<Replace-With-Provided-In-Lab> \
    --disk=<Replace-With-Disk-Name-Provided-In-Lab>
```

---

## ✅ Verification

1. **Check bucket**: Go to Cloud Storage → Buckets
2. **Check instance**: Go to Compute Engine → VM instances
3. **Check disk**: Go to Compute Engine → Disks

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>
