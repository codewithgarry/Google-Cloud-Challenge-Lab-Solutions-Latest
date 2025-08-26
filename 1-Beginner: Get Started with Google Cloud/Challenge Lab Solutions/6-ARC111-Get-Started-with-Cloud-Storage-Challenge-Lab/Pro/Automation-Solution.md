# Get Started with Cloud Storage: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

**Lab ID**: ARC111 | **Duration**: 5-10 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

This solution provides full automation through bash scripts, Terraform, and Python for Cloud Storage deployment.

---

## 🚀 One-Click Bash Automation

### Complete Lab Solution Script

```bash
#!/bin/bash

# Get Started with Cloud Storage - Complete Automation
# Author: CodeWithGarry

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Lab Configuration (Update these values from your lab)
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-storage-bucket"  # Update from lab
LOCATION="us-central1"  # Update from lab
STORAGE_CLASS="STANDARD"  # Update from lab

echo -e "${BLUE}🚀 Starting Cloud Storage Challenge Lab Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Bucket: $BUCKET_NAME${NC}"
echo -e "${YELLOW}Location: $LOCATION${NC}"

# Task 1: Create Cloud Storage bucket
echo -e "\n${BLUE}📦 Task 1: Creating Cloud Storage bucket...${NC}"
gsutil mb -l $LOCATION -c $STORAGE_CLASS gs://$BUCKET_NAME
echo -e "${GREEN}✅ Bucket created: gs://$BUCKET_NAME${NC}"

# Task 2: Upload sample objects
echo -e "\n${BLUE}📄 Task 2: Uploading sample objects...${NC}"

# Create sample files
echo "Sample content for file 1" > sample1.txt
echo "Sample content for file 2" > sample2.txt
echo "Welcome to Cloud Storage!" > welcome.txt

# Upload files
gsutil cp sample1.txt gs://$BUCKET_NAME/
gsutil cp sample2.txt gs://$BUCKET_NAME/documents/
gsutil cp welcome.txt gs://$BUCKET_NAME/public/

echo -e "${GREEN}✅ Objects uploaded successfully${NC}"

# Task 3: Configure permissions
echo -e "\n${BLUE}🔐 Task 3: Configuring bucket permissions...${NC}"

# Make specific objects publicly readable
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME/public/welcome.txt

echo -e "${GREEN}✅ Permissions configured${NC}"

# Task 4: Setup lifecycle management
echo -e "\n${BLUE}♻️ Task 4: Setting up lifecycle management...${NC}"

# Create lifecycle configuration
cat > lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 30}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 7, "matchesStorageClass": ["STANDARD"]}
      }
    ]
  }
}
EOF

# Apply lifecycle configuration
gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME

echo -e "${GREEN}✅ Lifecycle management configured${NC}"

# Cleanup temporary files
rm -f sample1.txt sample2.txt welcome.txt lifecycle.json

echo -e "\n${GREEN}🎉 Lab completed successfully!${NC}"
echo -e "${GREEN}📦 Bucket: gs://$BUCKET_NAME${NC}"
echo -e "${GREEN}🌐 Public file: https://storage.googleapis.com/$BUCKET_NAME/public/welcome.txt${NC}"
```

### Save and Run Script

```bash
# Save the script
cat > complete_storage_lab.sh << 'EOF'
# [Insert the above script here]
EOF

# Make executable and run
chmod +x complete_storage_lab.sh
./complete_storage_lab.sh
```

---

## 🏗️ Terraform Infrastructure as Code

### main.tf

```terraform
# Get Started with Cloud Storage - Terraform Configuration
# Author: CodeWithGarry

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Cloud Storage bucket name"
  type        = string
}

variable "storage_class" {
  description = "Storage class for the bucket"
  type        = string
  default     = "STANDARD"
}

# Main Cloud Storage bucket
resource "google_storage_bucket" "main_bucket" {
  name          = var.bucket_name
  location      = var.region
  storage_class = var.storage_class
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  lifecycle_rule {
    condition {
      age                   = 7
      matches_storage_class = ["STANDARD"]
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Sample objects
resource "google_storage_bucket_object" "sample_file" {
  name   = "sample.txt"
  bucket = google_storage_bucket.main_bucket.name
  content = "Hello, Cloud Storage!"
}

resource "google_storage_bucket_object" "folder_structure" {
  name   = "documents/.keep"
  bucket = google_storage_bucket.main_bucket.name
  content = ""
}

# Public access for specific objects
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.main_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
  
  condition {
    title       = "Public access for public folder"
    description = "Allow public access to objects in public/ folder"
    expression  = "resource.name.startsWith('projects/_/buckets/${var.bucket_name}/objects/public/')"
  }
}

# Outputs
output "bucket_name" {
  value = google_storage_bucket.main_bucket.name
}

output "bucket_url" {
  value = google_storage_bucket.main_bucket.url
}

output "sample_file_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.main_bucket.name}/${google_storage_bucket_object.sample_file.name}"
}
```

### terraform.tfvars

```terraform
project_id    = "your-project-id"
bucket_name   = "your-bucket-name-from-lab"
region        = "us-central1"
storage_class = "STANDARD"
```

### Deploy with Terraform

```bash
# Initialize and deploy
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve

# Get outputs
terraform output
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
Get Started with Cloud Storage - Python Automation
Author: CodeWithGarry
"""

import os
import json
from google.cloud import storage
from google.cloud.exceptions import NotFound

class CloudStorageLab:
    def __init__(self, project_id, bucket_name, location="us-central1"):
        self.project_id = project_id
        self.bucket_name = bucket_name
        self.location = location
        self.client = storage.Client()
        
    def create_bucket(self):
        """Create a Cloud Storage bucket"""
        print("📦 Creating Cloud Storage bucket...")
        
        try:
            bucket = self.client.bucket(self.bucket_name)
            bucket = self.client.create_bucket(bucket, location=self.location)
            print(f"✅ Bucket created: {bucket.name}")
            return bucket
        except Exception as e:
            print(f"❌ Error creating bucket: {str(e)}")
            return None
    
    def upload_objects(self, bucket):
        """Upload sample objects to bucket"""
        print("📄 Uploading sample objects...")
        
        # Sample files to upload
        files = {
            "sample1.txt": "Sample content for file 1",
            "documents/sample2.txt": "Sample content for file 2",
            "public/welcome.txt": "Welcome to Cloud Storage!"
        }
        
        for file_path, content in files.items():
            blob = bucket.blob(file_path)
            blob.upload_from_string(content)
            print(f"✅ Uploaded: {file_path}")
    
    def configure_permissions(self, bucket):
        """Configure bucket permissions"""
        print("🔐 Configuring bucket permissions...")
        
        # Make public folder publicly readable
        policy = bucket.get_iam_policy(requested_policy_version=3)
        
        policy.bindings.append({
            "role": "roles/storage.objectViewer",
            "members": {"allUsers"},
            "condition": {
                "title": "Public access for public folder",
                "description": "Allow public access to objects in public/ folder",
                "expression": f"resource.name.startsWith('projects/_/buckets/{self.bucket_name}/objects/public/')"
            }
        })
        
        bucket.set_iam_policy(policy)
        print("✅ Permissions configured")
    
    def setup_lifecycle(self, bucket):
        """Setup lifecycle management"""
        print("♻️ Setting up lifecycle management...")
        
        lifecycle_rule = {
            "action": {"type": "Delete"},
            "condition": {"age": 30}
        }
        
        nearline_rule = {
            "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
            "condition": {"age": 7, "matchesStorageClass": ["STANDARD"]}
        }
        
        bucket.lifecycle_rules = [lifecycle_rule, nearline_rule]
        bucket.patch()
        print("✅ Lifecycle management configured")
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting Cloud Storage Challenge Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📦 Bucket: {self.bucket_name}")
        print(f"📍 Location: {self.location}")
        
        try:
            # Task 1: Create bucket
            bucket = self.create_bucket()
            if not bucket:
                return False
            
            # Task 2: Upload objects
            self.upload_objects(bucket)
            
            # Task 3: Configure permissions
            self.configure_permissions(bucket)
            
            # Task 4: Setup lifecycle
            self.setup_lifecycle(bucket)
            
            print("\n🎉 Lab completed successfully!")
            print(f"📦 Bucket: gs://{self.bucket_name}")
            print(f"🌐 Public file: https://storage.googleapis.com/{self.bucket_name}/public/welcome.txt")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return False

if __name__ == "__main__":
    # Configuration
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT') or input("Enter project ID: ")
    bucket_name = input("Enter bucket name from lab: ")
    
    # Run the lab
    lab = CloudStorageLab(project_id, bucket_name)
    lab.run_complete_lab()
```

### Run Python Script

```bash
# Install dependencies
pip install google-cloud-storage

# Set environment variable
export GOOGLE_CLOUD_PROJECT="your-project-id"

# Run the script
python3 automate_storage_lab.py
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach for efficiency

---

## 🎖️ Skills Boost Arcade

This automated solution helps you complete the challenge lab quickly while learning automation best practices for the **Skills Boost Arcade** program.

---

## 📚 Learn More

- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [gsutil Tool Documentation](https://cloud.google.com/storage/docs/gsutil)
- [Terraform Google Cloud Storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)

---

<div align="center">

**⚡ Pro Tip**: Use these automation scripts as templates for your own Cloud Storage projects!

</div>
