# The Basics of Google Cloud Compute: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Compute Engine](https://img.shields.io/badge/Compute%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: GSP313 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Challenge Tasks

**Task 1**: Create a bucket  
**Task 2**: Create a Compute Engine instance  
**Task 3**: Create the bucket and instance as specified

---

## 🚀 Solutions

### Task 1: Create Cloud Storage Bucket

#### Method 1: Google Cloud Console
1. Go to **Cloud Storage** → **Buckets**
2. Click **CREATE BUCKET**
3. **Name**: `PROJECT_ID-bucket` (replace PROJECT_ID with your actual project ID)
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
5. **Zone**: `us-central1-a`
6. **Machine type**: `e2-medium`
7. **Boot disk**: Debian GNU/Linux 11 (bullseye)
8. **Firewall**: ✅ Allow HTTP traffic
9. Click **CREATE**

#### Method 2: Cloud Shell
```bash
gcloud compute instances create my-instance \
    --zone=us-central1-a \
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
3. **Name**: `mydisk`
4. **Zone**: `us-central1-a`
5. **Size**: 200 GB
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
gcloud compute disks create mydisk \
    --zone=us-central1-a \
    --size=200GB
```

#### Attach disk to instance:
```bash
gcloud compute instances attach-disk my-instance \
    --zone=us-central1-a \
    --disk=mydisk
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
