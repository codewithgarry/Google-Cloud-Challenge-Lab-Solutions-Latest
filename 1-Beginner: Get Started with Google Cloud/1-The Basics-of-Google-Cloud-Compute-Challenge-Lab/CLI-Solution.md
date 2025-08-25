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

## ⚠️ IMPORTANT: Get Values from Your Lab

**Check your lab instructions for these specific values:**
- **Bucket name**: (usually `PROJECT_ID-bucket`)
- **Region**: `us-east4` 
- **Zone**: `us-east4-a`

---

##  Solutions

### Task 1: Create Cloud Storage bucket

**Required**: Bucket with specific name (check your lab)

#### Console Method:
1. **Cloud Storage** → **Buckets** → **CREATE BUCKET**
2. **Name**: Use the exact bucket name from your lab
3. **Location**: Multi-region, United States (US)
4. **CREATE**

#### Cloud Shell:
```bash
# Replace with bucket name from your lab
gsutil mb -l US gs://YOUR-BUCKET-NAME-FROM-LAB
```

---

### Task 2: Create VM with persistent disk

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
