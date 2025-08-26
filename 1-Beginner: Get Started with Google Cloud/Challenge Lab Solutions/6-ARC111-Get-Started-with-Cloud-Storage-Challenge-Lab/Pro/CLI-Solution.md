# Get Started with Cloud Storage: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)
![gsutil](https://img.shields.io/badge/gsutil-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC111 | **Duration**: 15 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Solution (Cloud Shell)

This solution uses gsutil commands for efficient Cloud Storage management.

---

## ⚠️ IMPORTANT: Set Variables

```bash
# Set your lab-specific values
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="your-bucket-name-from-lab"
export LOCATION="us-central1"  # Update based on lab
export STORAGE_CLASS="STANDARD"  # Update based on lab
```

---

## 🚀 Command-Line Solutions

### Task 1: Create Cloud Storage bucket

```bash
# Create bucket with specific location and storage class
gsutil mb -l $LOCATION -c $STORAGE_CLASS gs://$BUCKET_NAME

# Verify bucket creation
gsutil ls -L -b gs://$BUCKET_NAME
```

### Task 2: Upload objects and create folders

```bash
# Upload files to bucket
gsutil cp local-file.txt gs://$BUCKET_NAME/

# Create folder structure
gsutil cp /dev/null gs://$BUCKET_NAME/folder-name/.keep

# Upload multiple files
gsutil -m cp *.txt gs://$BUCKET_NAME/documents/

# Copy files between buckets
gsutil cp gs://source-bucket/file.txt gs://$BUCKET_NAME/
```

### Task 3: Configure bucket permissions

```bash
# Make bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Set specific object ACL
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/public-file.txt

# Remove public access
gsutil iam ch -d allUsers gs://$BUCKET_NAME
```

### Task 4: Lifecycle management

```bash
# Create lifecycle configuration file
cat > lifecycle.json << EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 30}
      }
    ]
  }
}
EOF

# Apply lifecycle configuration
gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME

# View lifecycle configuration
gsutil lifecycle get gs://$BUCKET_NAME
```

---

## 🔧 Advanced gsutil Commands

### Bucket Operations
```bash
# List bucket details
gsutil ls -L -b gs://$BUCKET_NAME

# Set bucket storage class
gsutil defstorageclass set NEARLINE gs://$BUCKET_NAME

# Enable versioning
gsutil versioning set on gs://$BUCKET_NAME

# Set CORS configuration
gsutil cors set cors.json gs://$BUCKET_NAME
```

### Object Operations
```bash
# Copy with metadata
gsutil -h "Cache-Control:public,max-age=3600" cp file.txt gs://$BUCKET_NAME/

# Sync directories
gsutil -m rsync -r local-dir gs://$BUCKET_NAME/remote-dir

# Move objects
gsutil mv gs://$BUCKET_NAME/old-name.txt gs://$BUCKET_NAME/new-name.txt
```

---

## 📊 Monitoring and Logging

```bash
# Enable logging
gsutil logging set on -b gs://log-bucket gs://$BUCKET_NAME

# View bucket metadata
gsutil stat gs://$BUCKET_NAME/object.txt

# Check bucket size
gsutil du -sh gs://$BUCKET_NAME
```

---

## ✅ Verification Commands

```bash
# Verify bucket exists
gsutil ls gs://$BUCKET_NAME

# Check permissions
gsutil iam get gs://$BUCKET_NAME

# Test public access
curl -I https://storage.googleapis.com/$BUCKET_NAME/public-file.txt

# Validate lifecycle
gsutil lifecycle get gs://$BUCKET_NAME
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[Automation Solution](Automation-Solution.md)** - Scripts and Infrastructure as Code

---

## 🎖️ Skills Boost Arcade

Complete this lab efficiently using CLI commands to earn arcade points faster!

---

<div align="center">

**⚡ Pro Tip**: Master gsutil commands for professional Cloud Storage management!

</div>
