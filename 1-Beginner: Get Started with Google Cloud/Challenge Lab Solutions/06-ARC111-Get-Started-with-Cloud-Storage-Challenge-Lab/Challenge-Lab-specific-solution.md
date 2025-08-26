# ARC111: Get Started with Cloud Storage: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC111 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll demonstrate your skills with Google Cloud Storage by creating buckets, managing objects, configuring access controls, and implementing lifecycle policies.

## 📋 Challenge Tasks

### Task 1: Create Storage Buckets

**Requirements:**
- **Bucket 1**: `${PROJECT_ID}-standard-bucket` (Standard storage)
- **Bucket 2**: `${PROJECT_ID}-coldline-bucket` (Coldline storage)
- **Location**: Multi-regional (US)

### Task 2: Upload and Manage Objects

Upload files to buckets and organize them with folders.

### Task 3: Configure Bucket Permissions

Set up IAM policies and Access Control Lists (ACLs).

### Task 4: Create Lifecycle Policy

Implement automatic object lifecycle management.

### Task 5: Enable Versioning

Configure object versioning for data protection.

---

## 🚀 Quick Solution Steps

### Step 1: Set Variables

```bash
export PROJECT_ID=$(gcloud config get-value project)
export STANDARD_BUCKET=${PROJECT_ID}-standard-bucket
export COLDLINE_BUCKET=${PROJECT_ID}-coldline-bucket
```

### Step 2: Create Storage Buckets

```bash
# Create standard storage bucket
gsutil mb -l US -c STANDARD gs://$STANDARD_BUCKET

# Create coldline storage bucket
gsutil mb -l US -c COLDLINE gs://$COLDLINE_BUCKET

# Verify buckets created
gsutil ls -L gs://$STANDARD_BUCKET
gsutil ls -L gs://$COLDLINE_BUCKET
```

### Step 3: Upload Sample Files

```bash
# Create sample files
echo "This is a sample document for testing Cloud Storage" > sample-doc.txt
echo "Project: $PROJECT_ID
Date: $(date)
Storage Class: Standard" > project-info.txt

echo "This is archived data that won't be accessed frequently" > archive-data.txt

# Upload to standard bucket
gsutil cp sample-doc.txt gs://$STANDARD_BUCKET/
gsutil cp project-info.txt gs://$STANDARD_BUCKET/documents/

# Upload to coldline bucket  
gsutil cp archive-data.txt gs://$COLDLINE_BUCKET/archives/

# Create a larger file for testing
dd if=/dev/zero of=large-file.dat bs=1M count=10
gsutil cp large-file.dat gs://$STANDARD_BUCKET/large-files/
```

### Step 4: Configure Object Permissions

```bash
# Make an object publicly readable
gsutil acl ch -u AllUsers:R gs://$STANDARD_BUCKET/sample-doc.txt

# Set bucket-level permissions (make bucket publicly readable)
gsutil iam ch allUsers:objectViewer gs://$STANDARD_BUCKET

# Create a signed URL for private access (valid for 1 hour)
gsutil signurl -d 1h ~/.config/gcloud/application_default_credentials.json gs://$COLDLINE_BUCKET/archives/archive-data.txt
```

### Step 5: Enable Versioning

```bash
# Enable versioning on standard bucket
gsutil versioning set on gs://$STANDARD_BUCKET

# Verify versioning is enabled
gsutil versioning get gs://$STANDARD_BUCKET
```

### Step 6: Create Lifecycle Policy

```bash
# Create lifecycle policy JSON
cat > lifecycle-policy.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {
          "type": "SetStorageClass",
          "storageClass": "NEARLINE"
        },
        "condition": {
          "age": 30,
          "matchesStorageClass": ["STANDARD"]
        }
      },
      {
        "action": {
          "type": "SetStorageClass", 
          "storageClass": "COLDLINE"
        },
        "condition": {
          "age": 90,
          "matchesStorageClass": ["NEARLINE"]
        }
      },
      {
        "action": {
          "type": "Delete"
        },
        "condition": {
          "age": 365,
          "matchesStorageClass": ["COLDLINE"]
        }
      }
    ]
  }
}
EOF

# Apply lifecycle policy to standard bucket
gsutil lifecycle set lifecycle-policy.json gs://$STANDARD_BUCKET

# Verify lifecycle policy
gsutil lifecycle get gs://$STANDARD_BUCKET
```

### Step 7: Test Object Operations

```bash
# List all objects in buckets
gsutil ls gs://$STANDARD_BUCKET/**
gsutil ls gs://$COLDLINE_BUCKET/**

# Copy object between buckets
gsutil cp gs://$STANDARD_BUCKET/sample-doc.txt gs://$COLDLINE_BUCKET/

# Move object within bucket
gsutil mv gs://$STANDARD_BUCKET/sample-doc.txt gs://$STANDARD_BUCKET/moved/sample-doc.txt

# Get object metadata
gsutil stat gs://$STANDARD_BUCKET/moved/sample-doc.txt
```

---

## 🎯 Alternative GUI Solution

1. **Create Buckets**:
   - Go to Cloud Storage > Browser
   - Click "Create Bucket"
   - Name: `${PROJECT_ID}-standard-bucket`
   - Location: Multi-region (US)
   - Storage class: Standard
   - Repeat for coldline bucket

2. **Upload Files**:
   - Open bucket
   - Click "Upload Files" or drag and drop
   - Create folders by clicking "Create Folder"

3. **Configure Permissions**:
   - Select object > Permissions tab
   - Add principal: `allUsers`
   - Role: `Storage Object Viewer`

4. **Enable Versioning**:
   - Bucket details > Configuration tab
   - Object Versioning: Enable

5. **Create Lifecycle Policy**:
   - Bucket details > Lifecycle tab
   - Add rule with conditions and actions

---

## 📊 Advanced Storage Features

### Transfer Service Setup

```bash
# Install Transfer Service (if using large datasets)
gcloud components install alpha

# Create transfer job from another cloud provider
gcloud alpha transfer jobs create \
    --source-s3-bucket=source-bucket \
    --destination-gcs-bucket=$STANDARD_BUCKET \
    --description="Transfer from AWS S3"
```

### Notifications Setup

```bash
# Create Pub/Sub topic for notifications
gcloud pubsub topics create storage-notifications

# Enable notifications for bucket changes
gsutil notification create -t storage-notifications -f json gs://$STANDARD_BUCKET
```

### Customer Managed Encryption

```bash
# Create KMS key
gcloud kms keyrings create storage-keyring --location=global
gcloud kms keys create storage-key --location=global --keyring=storage-keyring --purpose=encryption

# Upload with customer-managed encryption
gsutil -o GSUtil:encryption_key=projects/$PROJECT_ID/locations/global/keyRings/storage-keyring/cryptoKeys/storage-key \
  cp sample-doc.txt gs://$STANDARD_BUCKET/encrypted/
```

---

## ✅ Validation Checklist

1. **Buckets Created**: 
   - ✅ Standard bucket exists with correct storage class
   - ✅ Coldline bucket exists with correct storage class

2. **Objects Uploaded**:
   - ✅ Files uploaded to both buckets
   - ✅ Folder structure created

3. **Permissions Configured**:
   - ✅ Public access configured for sample object
   - ✅ Bucket-level IAM policies applied

4. **Versioning Enabled**:
   - ✅ Object versioning turned on for standard bucket

5. **Lifecycle Policy**:
   - ✅ Policy created with age-based rules
   - ✅ Storage class transitions defined

---

## 🔧 Troubleshooting

**Issue**: Bucket creation fails
- Check if bucket name is globally unique
- Verify billing is enabled
- Ensure proper permissions

**Issue**: Cannot access objects
- Check IAM permissions
- Verify ACLs are set correctly
- Confirm bucket is in correct project

**Issue**: Lifecycle policy not working
- Verify JSON syntax is correct
- Check policy conditions match your objects
- Allow time for policies to take effect (24-48 hours)

---

## 💡 Best Practices

1. **Naming Convention**: Use consistent, descriptive bucket names
2. **Storage Classes**: Choose appropriate class based on access patterns
3. **Security**: Use IAM over ACLs when possible
4. **Cost Optimization**: Implement lifecycle policies for automatic transitions
5. **Backup Strategy**: Enable versioning for critical data
6. **Monitoring**: Set up notifications for important bucket changes

---

## 📚 Key Learning Points

- **Storage Classes**: Understanding Standard, Nearline, Coldline, and Archive
- **Access Control**: IAM vs ACLs for permission management
- **Lifecycle Management**: Automated object transitions and deletion
- **Versioning**: Object version control and data protection
- **Cost Optimization**: Selecting appropriate storage classes and policies

---

## 🏆 Challenge Complete!

You've successfully demonstrated Cloud Storage fundamentals by:
- ✅ Creating buckets with different storage classes
- ✅ Managing objects and organizing data
- ✅ Configuring access controls and permissions
- ✅ Implementing lifecycle policies for cost optimization
- ✅ Enabling versioning for data protection

<div align="center">

**🎉 Congratulations! You've completed ARC111!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC125%20Storage%20APIs-blue?style=for-the-badge)](../7-ARC125-Use-APIs-to-Work-with-Cloud-Storage-Challenge-Lab/)

</div>
