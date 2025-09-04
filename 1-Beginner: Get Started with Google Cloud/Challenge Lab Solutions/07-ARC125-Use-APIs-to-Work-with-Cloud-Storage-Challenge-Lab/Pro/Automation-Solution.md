# Use APIs to Work with Cloud Storage: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

**Lab ID**: ARC125 | **Duration**: 10-15 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

Full automation using Python, Terraform, and bash scripts for Cloud Storage API management.

---

## 🚀 One-Click Bash Automation

```bash
#!/bin/bash

# Use APIs to Work with Cloud Storage - Complete Automation
# Author: CodeWithGarry

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-api-storage"
SERVICE_ACCOUNT_NAME="storage-api-sa"
API_KEY_NAME="storage-api-key"

echo -e "${BLUE}🚀 Starting Cloud Storage API Challenge Lab Automation${NC}"

# Task 1: Enable APIs
echo -e "\n${BLUE}🔧 Task 1: Enabling APIs...${NC}"
gcloud services enable storage.googleapis.com
gcloud services enable serviceusage.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"

# Task 2: Create credentials
echo -e "\n${BLUE}🔑 Task 2: Creating credentials...${NC}"

# Create service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="Storage API Service Account" || true

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin" || true

# Create key
gcloud iam service-accounts keys create ~/sa-key.json \
    --iam-account="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" || true

echo -e "${GREEN}✅ Service account created${NC}"

# Task 3: Create bucket via API
echo -e "\n${BLUE}📦 Task 3: Creating bucket via API...${NC}"
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$BUCKET_NAME\", \"location\": \"US\"}" \
    "https://storage.googleapis.com/storage/v1/b?project=$PROJECT_ID" > /dev/null 2>&1

echo -e "${GREEN}✅ Bucket created via API${NC}"

# Task 4: Upload objects
echo -e "\n${BLUE}📄 Task 4: Uploading objects via API...${NC}"
echo "Hello from API!" > api-test.txt

curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: text/plain" \
    -T api-test.txt \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=api-test.txt" > /dev/null 2>&1

echo -e "${GREEN}✅ Objects uploaded via API${NC}"

# Task 5: Configure CORS
echo -e "\n${BLUE}🌐 Task 5: Configuring CORS via API...${NC}"
curl -X PATCH \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d '{
        "cors": [{
            "origin": ["*"],
            "method": ["GET", "POST"],
            "responseHeader": ["Content-Type"],
            "maxAgeSeconds": 3600
        }]
    }' \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME" > /dev/null 2>&1

echo -e "${GREEN}✅ CORS configured via API${NC}"

# Cleanup
rm -f api-test.txt

echo -e "\n${GREEN}🎉 Lab completed successfully!${NC}"
echo -e "${GREEN}📦 Bucket: gs://$BUCKET_NAME${NC}"
echo -e "${GREEN}🔑 Service Account: ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com${NC}"
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
Use APIs to Work with Cloud Storage - Python Automation
Author: CodeWithGarry
"""

import json
import requests
import subprocess
from google.cloud import storage
from google.oauth2 import service_account

class CloudStorageAPILab:
    def __init__(self, project_id, bucket_name):
        self.project_id = project_id
        self.bucket_name = bucket_name
        self.base_url = "https://storage.googleapis.com/storage/v1"
        
    def get_access_token(self):
        """Get access token for API calls"""
        result = subprocess.run(['gcloud', 'auth', 'print-access-token'], 
                              capture_output=True, text=True)
        return result.stdout.strip()
    
    def enable_apis(self):
        """Enable required APIs"""
        print("🔧 Enabling APIs...")
        apis = [
            "storage.googleapis.com",
            "serviceusage.googleapis.com"
        ]
        
        for api in apis:
            subprocess.run(['gcloud', 'services', 'enable', api])
        print("✅ APIs enabled")
    
    def create_service_account(self):
        """Create service account for API access"""
        print("🔑 Creating service account...")
        
        sa_name = "storage-api-sa"
        sa_email = f"{sa_name}@{self.project_id}.iam.gserviceaccount.com"
        
        # Create service account
        subprocess.run([
            'gcloud', 'iam', 'service-accounts', 'create', sa_name,
            '--display-name=Storage API Service Account'
        ])
        
        # Grant permissions
        subprocess.run([
            'gcloud', 'projects', 'add-iam-policy-binding', self.project_id,
            '--member=serviceAccount:' + sa_email,
            '--role=roles/storage.admin'
        ])
        
        # Create key
        subprocess.run([
            'gcloud', 'iam', 'service-accounts', 'keys', 'create', 'sa-key.json',
            '--iam-account=' + sa_email
        ])
        
        print("✅ Service account created")
        return sa_email
    
    def create_bucket_api(self):
        """Create bucket using REST API"""
        print("📦 Creating bucket via API...")
        
        url = f"{self.base_url}/b"
        headers = {
            "Authorization": f"Bearer {self.get_access_token()}",
            "Content-Type": "application/json"
        }
        
        data = {
            "name": self.bucket_name,
            "location": "US",
            "storageClass": "STANDARD"
        }
        
        params = {"project": self.project_id}
        response = requests.post(url, headers=headers, json=data, params=params)
        
        if response.status_code in [200, 409]:  # 409 if bucket exists
            print("✅ Bucket created via API")
            return True
        else:
            print(f"❌ Error creating bucket: {response.text}")
            return False
    
    def upload_object_api(self, content, object_name):
        """Upload object using REST API"""
        print(f"📄 Uploading {object_name} via API...")
        
        url = f"https://storage.googleapis.com/upload/storage/v1/b/{self.bucket_name}/o"
        headers = {
            "Authorization": f"Bearer {self.get_access_token()}",
            "Content-Type": "text/plain"
        }
        
        params = {
            "uploadType": "media",
            "name": object_name
        }
        
        response = requests.post(url, headers=headers, data=content, params=params)
        
        if response.status_code == 200:
            print(f"✅ {object_name} uploaded via API")
            return True
        else:
            print(f"❌ Error uploading {object_name}: {response.text}")
            return False
    
    def configure_cors_api(self):
        """Configure CORS using REST API"""
        print("🌐 Configuring CORS via API...")
        
        url = f"{self.base_url}/b/{self.bucket_name}"
        headers = {
            "Authorization": f"Bearer {self.get_access_token()}",
            "Content-Type": "application/json"
        }
        
        cors_config = {
            "cors": [{
                "origin": ["*"],
                "method": ["GET", "POST"],
                "responseHeader": ["Content-Type"],
                "maxAgeSeconds": 3600
            }]
        }
        
        response = requests.patch(url, headers=headers, json=cors_config)
        
        if response.status_code == 200:
            print("✅ CORS configured via API")
            return True
        else:
            print(f"❌ Error configuring CORS: {response.text}")
            return False
    
    def list_objects_api(self):
        """List objects using REST API"""
        print("📋 Listing objects via API...")
        
        url = f"{self.base_url}/b/{self.bucket_name}/o"
        headers = {
            "Authorization": f"Bearer {self.get_access_token()}"
        }
        
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            objects = response.json().get('items', [])
            print(f"✅ Found {len(objects)} objects")
            for obj in objects:
                print(f"  - {obj['name']}")
            return objects
        else:
            print(f"❌ Error listing objects: {response.text}")
            return []
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting Cloud Storage API Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📦 Bucket: {self.bucket_name}")
        
        try:
            # Enable APIs
            self.enable_apis()
            
            # Create service account
            self.create_service_account()
            
            # Create bucket
            self.create_bucket_api()
            
            # Upload test objects
            self.upload_object_api("Hello from Python API!", "python-test.txt")
            self.upload_object_api("API automation demo", "automation-demo.txt")
            
            # Configure CORS
            self.configure_cors_api()
            
            # List objects
            self.list_objects_api()
            
            print("\n🎉 Lab completed successfully!")
            print(f"📦 Bucket: gs://{self.bucket_name}")
            print(f"🌐 API URL: https://storage.googleapis.com/storage/v1/b/{self.bucket_name}/o")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return False

if __name__ == "__main__":
    import os
    
    # Configuration
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT') or subprocess.run(
        ['gcloud', 'config', 'get-value', 'project'], 
        capture_output=True, text=True
    ).stdout.strip()
    
    bucket_name = f"{project_id}-api-storage"
    
    # Run the lab
    lab = CloudStorageAPILab(project_id, bucket_name)
    lab.run_complete_lab()
```

---

## 🏗️ Terraform Configuration

```terraform
# Cloud Storage API Lab - Terraform Configuration

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
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

# Enable APIs
resource "google_project_service" "storage_api" {
  service = "storage.googleapis.com"
}

resource "google_project_service" "serviceusage_api" {
  service = "serviceusage.googleapis.com"
}

# Service Account for API access
resource "google_service_account" "storage_api_sa" {
  account_id   = "storage-api-sa"
  display_name = "Storage API Service Account"
  description  = "Service account for Cloud Storage API lab"
}

# Grant Storage Admin role
resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.storage_api_sa.email}"
}

# Create service account key
resource "google_service_account_key" "storage_api_key" {
  service_account_id = google_service_account.storage_api_sa.name
}

# Storage bucket for API testing
resource "google_storage_bucket" "api_bucket" {
  name     = "${var.project_id}-api-storage"
  location = "US"
  
  cors {
    origin          = ["*"]
    method          = ["GET", "POST"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }
  
  uniform_bucket_level_access = true
}

# Sample objects
resource "google_storage_bucket_object" "sample_files" {
  for_each = {
    "api-test.txt"    = "Hello from Terraform API!"
    "demo.txt"        = "Terraform automation demo"
    "config.json"     = jsonencode({
      "environment" = "test"
      "created_by"  = "terraform"
    })
  }
  
  bucket  = google_storage_bucket.api_bucket.name
  name    = each.key
  content = each.value
}

# Outputs
output "bucket_name" {
  value = google_storage_bucket.api_bucket.name
}

output "service_account_email" {
  value = google_service_account.storage_api_sa.email
}

output "service_account_key" {
  value     = base64decode(google_service_account_key.storage_api_key.private_key)
  sensitive = true
}

output "api_endpoint" {
  value = "https://storage.googleapis.com/storage/v1/b/${google_storage_bucket.api_bucket.name}/o"
}
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach with curl

---

## 🎖️ Skills Boost Arcade

Master Cloud Storage APIs with comprehensive automation for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: API automation is essential for scalable cloud operations!

</div>
