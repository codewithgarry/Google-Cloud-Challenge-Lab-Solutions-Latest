# Create a Streaming Data Lake on Cloud Storage: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

**Lab ID**: ARC110 | **Duration**: 10-15 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

Full automation for streaming data lake using Terraform, Python, and bash scripts.

---

## 🚀 One-Click Bash Automation

```bash
#!/bin/bash

# Create Streaming Data Lake - Complete Automation
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
DATA_LAKE_BUCKET="${PROJECT_ID}-data-lake"
STAGING_BUCKET="${PROJECT_ID}-staging"
REGION="us-central1"
PUBSUB_TOPIC="streaming-topic"
PUBSUB_SUBSCRIPTION="streaming-subscription"
DATAFLOW_JOB="streaming-data-lake-$(date +%s)"

echo -e "${BLUE}🚀 Starting Streaming Data Lake Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Region: $REGION${NC}"

# Task 1: Enable APIs
echo -e "\n${BLUE}🔧 Task 1: Enabling APIs...${NC}"
gcloud services enable dataflow.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable bigquery.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"

# Task 2: Create buckets
echo -e "\n${BLUE}📦 Task 2: Creating buckets...${NC}"
gsutil mb -l $REGION gs://$DATA_LAKE_BUCKET
gsutil mb -l $REGION gs://$STAGING_BUCKET

# Create folder structure
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/raw-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/processed-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/streaming-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/archive/.keep

echo -e "${GREEN}✅ Buckets and folder structure created${NC}"

# Task 3: Set up Pub/Sub
echo -e "\n${BLUE}📡 Task 3: Setting up Pub/Sub...${NC}"
gcloud pubsub topics create $PUBSUB_TOPIC
gcloud pubsub subscriptions create $PUBSUB_SUBSCRIPTION --topic=$PUBSUB_TOPIC
echo -e "${GREEN}✅ Pub/Sub configured${NC}"

# Task 4: Configure lifecycle policy
echo -e "\n${BLUE}♻️ Task 4: Configuring lifecycle policy...${NC}"
cat > lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30, "matchesStorageClass": ["STANDARD"]}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90, "matchesStorageClass": ["NEARLINE"]}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 365}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://$DATA_LAKE_BUCKET
echo -e "${GREEN}✅ Lifecycle policy applied${NC}"

# Task 5: Deploy Dataflow job
echo -e "\n${BLUE}🌊 Task 5: Deploying Dataflow streaming job...${NC}"
TEMPLATE_PATH="gs://dataflow-templates-$REGION/latest/PubSub_to_GCS_Text"
OUTPUT_DIRECTORY="gs://$DATA_LAKE_BUCKET/streaming-data/"
TEMP_LOCATION="gs://$STAGING_BUCKET/temp/"

gcloud dataflow jobs run $DATAFLOW_JOB \
    --gcs-location=$TEMPLATE_PATH \
    --region=$REGION \
    --parameters="inputTopic=projects/$PROJECT_ID/topics/$PUBSUB_TOPIC,outputDirectory=$OUTPUT_DIRECTORY,tempLocation=$TEMP_LOCATION,outputFilenamePrefix=streaming-data,outputFilenameSuffix=.txt,windowDuration=1m" \
    --max-workers=3 \
    --worker-machine-type=n1-standard-1

echo -e "${GREEN}✅ Dataflow job deployed${NC}"

# Task 6: Create BigQuery dataset
echo -e "\n${BLUE}📊 Task 6: Setting up BigQuery analytics...${NC}"
bq mk --location=$REGION --dataset $PROJECT_ID:streaming_analytics

# Wait a moment for job to start
echo -e "${YELLOW}⏳ Waiting for Dataflow job to initialize...${NC}"
sleep 30

# Task 7: Publish test data
echo -e "\n${BLUE}📤 Task 7: Publishing test streaming data...${NC}"
for i in {1..5}; do
    gcloud pubsub topics publish $PUBSUB_TOPIC \
        --message="{\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"sensor_id\": \"sensor$(printf %03d $i)\", \"temperature\": $(shuf -i 15-35 -n 1).$(shuf -i 0-9 -n 1), \"humidity\": $(shuf -i 30-70 -n 1).$(shuf -i 0-9 -n 1), \"location\": \"zone-$i\"}"
    sleep 3
done
echo -e "${GREEN}✅ Test data published${NC}"

# Task 8: Monitor setup
echo -e "\n${BLUE}📈 Task 8: Setting up monitoring...${NC}"
cat > alert-policy.yaml << EOF
displayName: "Dataflow Job System Lag Alert"
conditions:
  - displayName: "High system lag"
    conditionThreshold:
      filter: 'resource.type="dataflow_job" AND metric.type="dataflow.googleapis.com/job/system_lag"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 30
enabled: true
EOF

gcloud alpha monitoring policies create --policy-from-file=alert-policy.yaml 2>/dev/null || true
echo -e "${GREEN}✅ Monitoring configured${NC}"

# Cleanup temporary files
rm -f lifecycle.json alert-policy.yaml

# Get job details
JOB_ID=$(gcloud dataflow jobs list --region=$REGION --filter="name:$DATAFLOW_JOB" --format="value(id)" | head -n 1)

echo -e "\n${GREEN}🎉 Streaming Data Lake created successfully!${NC}"
echo -e "${GREEN}📦 Data Lake Bucket: gs://$DATA_LAKE_BUCKET${NC}"
echo -e "${GREEN}📦 Staging Bucket: gs://$STAGING_BUCKET${NC}"
echo -e "${GREEN}📡 Pub/Sub Topic: $PUBSUB_TOPIC${NC}"
echo -e "${GREEN}🌊 Dataflow Job: $DATAFLOW_JOB${NC}"
echo -e "${GREEN}📊 BigQuery Dataset: $PROJECT_ID:streaming_analytics${NC}"
echo -e "\n${BLUE}🔍 Monitor job: https://console.cloud.google.com/dataflow/jobs/$REGION/$JOB_ID${NC}"
```

---

## 🏗️ Terraform Infrastructure as Code

```terraform
# Streaming Data Lake - Terraform Configuration
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
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "data_lake_bucket_name" {
  description = "Data lake bucket name"
  type        = string
  default     = ""
}

# Enable APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "dataflow.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com"
  ])
  
  service = each.value
}

# Data lake bucket
resource "google_storage_bucket" "data_lake" {
  name     = var.data_lake_bucket_name != "" ? var.data_lake_bucket_name : "${var.project_id}-data-lake"
  location = var.region
  
  uniform_bucket_level_access = true
  
  lifecycle_rule {
    condition {
      age = 30
      matches_storage_class = ["STANDARD"]
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90
      matches_storage_class = ["NEARLINE"]
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# Staging bucket
resource "google_storage_bucket" "staging" {
  name     = "${var.project_id}-staging"
  location = var.region
  
  uniform_bucket_level_access = true
}

# Create folder structure
resource "google_storage_bucket_object" "folders" {
  for_each = toset([
    "raw-data/.keep",
    "processed-data/.keep", 
    "streaming-data/.keep",
    "archive/.keep"
  ])
  
  bucket  = google_storage_bucket.data_lake.name
  name    = each.value
  content = ""
}

# Pub/Sub topic
resource "google_pubsub_topic" "streaming_topic" {
  name = "streaming-topic"
}

# Pub/Sub subscription
resource "google_pubsub_subscription" "streaming_subscription" {
  name  = "streaming-subscription"
  topic = google_pubsub_topic.streaming_topic.name
  
  ack_deadline_seconds = 20
}

# BigQuery dataset
resource "google_bigquery_dataset" "streaming_analytics" {
  dataset_id  = "streaming_analytics"
  location    = var.region
  description = "Dataset for streaming data analytics"
}

# Service account for Dataflow
resource "google_service_account" "dataflow_sa" {
  account_id   = "dataflow-streaming-sa"
  display_name = "Dataflow Streaming Service Account"
}

# IAM bindings for service account
resource "google_project_iam_member" "dataflow_permissions" {
  for_each = toset([
    "roles/dataflow.worker",
    "roles/storage.admin",
    "roles/pubsub.subscriber",
    "roles/bigquery.dataEditor"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

# Outputs
output "data_lake_bucket" {
  value = google_storage_bucket.data_lake.name
}

output "staging_bucket" {
  value = google_storage_bucket.staging.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.streaming_topic.name
}

output "bigquery_dataset" {
  value = google_bigquery_dataset.streaming_analytics.dataset_id
}

output "dataflow_service_account" {
  value = google_service_account.dataflow_sa.email
}

output "dataflow_command" {
  value = <<-EOT
gcloud dataflow jobs run streaming-data-lake-job \
  --gcs-location=gs://dataflow-templates-${var.region}/latest/PubSub_to_GCS_Text \
  --region=${var.region} \
  --service-account-email=${google_service_account.dataflow_sa.email} \
  --parameters="inputTopic=projects/${var.project_id}/topics/${google_pubsub_topic.streaming_topic.name},outputDirectory=gs://${google_storage_bucket.data_lake.name}/streaming-data/,tempLocation=gs://${google_storage_bucket.staging.name}/temp/"
EOT
}
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
Streaming Data Lake Automation - Python Script
Author: CodeWithGarry
"""

import json
import time
import subprocess
from google.cloud import storage, pubsub_v1, bigquery
from google.cloud.exceptions import NotFound

class StreamingDataLakeLab:
    def __init__(self, project_id, region="us-central1"):
        self.project_id = project_id
        self.region = region
        self.data_lake_bucket = f"{project_id}-data-lake"
        self.staging_bucket = f"{project_id}-staging"
        self.topic_name = "streaming-topic"
        self.subscription_name = "streaming-subscription"
        
        # Initialize clients
        self.storage_client = storage.Client()
        self.publisher = pubsub_v1.PublisherClient()
        self.subscriber = pubsub_v1.SubscriberClient()
        self.bq_client = bigquery.Client()
        
    def enable_apis(self):
        """Enable required APIs"""
        print("🔧 Enabling APIs...")
        apis = [
            "dataflow.googleapis.com",
            "pubsub.googleapis.com", 
            "storage.googleapis.com",
            "bigquery.googleapis.com"
        ]
        
        for api in apis:
            subprocess.run(['gcloud', 'services', 'enable', api])
        print("✅ APIs enabled")
    
    def create_buckets(self):
        """Create data lake and staging buckets"""
        print("📦 Creating buckets...")
        
        # Create data lake bucket
        data_lake_bucket = self.storage_client.bucket(self.data_lake_bucket)
        data_lake_bucket.location = self.region
        data_lake_bucket = self.storage_client.create_bucket(data_lake_bucket)
        
        # Create staging bucket
        staging_bucket = self.storage_client.bucket(self.staging_bucket)
        staging_bucket.location = self.region
        staging_bucket = self.storage_client.create_bucket(staging_bucket)
        
        # Create folder structure
        folders = ["raw-data/", "processed-data/", "streaming-data/", "archive/"]
        for folder in folders:
            blob = data_lake_bucket.blob(f"{folder}.keep")
            blob.upload_from_string("")
        
        # Set lifecycle policy
        lifecycle_rules = [
            {
                "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
                "condition": {"age": 30, "matchesStorageClass": ["STANDARD"]}
            },
            {
                "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
                "condition": {"age": 90, "matchesStorageClass": ["NEARLINE"]}
            },
            {
                "action": {"type": "Delete"},
                "condition": {"age": 365}
            }
        ]
        data_lake_bucket.lifecycle_rules = lifecycle_rules
        data_lake_bucket.patch()
        
        print("✅ Buckets created with lifecycle policies")
    
    def setup_pubsub(self):
        """Set up Pub/Sub topic and subscription"""
        print("📡 Setting up Pub/Sub...")
        
        # Create topic
        topic_path = self.publisher.topic_path(self.project_id, self.topic_name)
        try:
            topic = self.publisher.create_topic(request={"name": topic_path})
            print(f"Created topic: {topic.name}")
        except Exception:
            print(f"Topic {self.topic_name} already exists")
        
        # Create subscription
        subscription_path = self.subscriber.subscription_path(
            self.project_id, self.subscription_name
        )
        try:
            subscription = self.subscriber.create_subscription(
                request={"name": subscription_path, "topic": topic_path}
            )
            print(f"Created subscription: {subscription.name}")
        except Exception:
            print(f"Subscription {self.subscription_name} already exists")
        
        print("✅ Pub/Sub configured")
    
    def deploy_dataflow_job(self):
        """Deploy Dataflow streaming job"""
        print("🌊 Deploying Dataflow job...")
        
        job_name = f"streaming-data-lake-{int(time.time())}"
        template_path = f"gs://dataflow-templates-{self.region}/latest/PubSub_to_GCS_Text"
        
        cmd = [
            'gcloud', 'dataflow', 'jobs', 'run', job_name,
            '--gcs-location', template_path,
            '--region', self.region,
            '--parameters', f"""inputTopic=projects/{self.project_id}/topics/{self.topic_name},outputDirectory=gs://{self.data_lake_bucket}/streaming-data/,tempLocation=gs://{self.staging_bucket}/temp/,outputFilenamePrefix=streaming-data,outputFilenameSuffix=.txt,windowDuration=1m"""
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Dataflow job deployed")
            return job_name
        else:
            print(f"❌ Error deploying Dataflow job: {result.stderr}")
            return None
    
    def create_bigquery_dataset(self):
        """Create BigQuery dataset for analytics"""
        print("📊 Creating BigQuery dataset...")
        
        dataset_id = f"{self.project_id}.streaming_analytics"
        dataset = bigquery.Dataset(dataset_id)
        dataset.location = self.region
        dataset.description = "Dataset for streaming data analytics"
        
        try:
            dataset = self.bq_client.create_dataset(dataset)
            print("✅ BigQuery dataset created")
        except Exception:
            print("BigQuery dataset already exists")
    
    def publish_test_data(self):
        """Publish test streaming data"""
        print("📤 Publishing test data...")
        
        topic_path = self.publisher.topic_path(self.project_id, self.topic_name)
        
        for i in range(5):
            message_data = {
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "sensor_id": f"sensor{i:03d}",
                "temperature": round(20 + (i * 2.5), 1),
                "humidity": round(40 + (i * 5), 1),
                "location": f"zone-{i+1}"
            }
            
            message_json = json.dumps(message_data)
            future = self.publisher.publish(topic_path, message_json.encode('utf-8'))
            print(f"Published message {i+1}: {future.result()}")
            time.sleep(2)
        
        print("✅ Test data published")
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting Streaming Data Lake Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📍 Region: {self.region}")
        
        try:
            # Execute all tasks
            self.enable_apis()
            self.create_buckets()
            self.setup_pubsub()
            self.create_bigquery_dataset()
            
            job_name = self.deploy_dataflow_job()
            if job_name:
                print("⏳ Waiting for Dataflow job to initialize...")
                time.sleep(30)
                self.publish_test_data()
            
            print("\n🎉 Streaming Data Lake created successfully!")
            print(f"📦 Data Lake: gs://{self.data_lake_bucket}")
            print(f"📦 Staging: gs://{self.staging_bucket}")
            print(f"📡 Topic: {self.topic_name}")
            print(f"🌊 Dataflow Job: {job_name}")
            print(f"📊 BigQuery: {self.project_id}:streaming_analytics")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return False

if __name__ == "__main__":
    import os
    
    # Get project ID
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT') or subprocess.run(
        ['gcloud', 'config', 'get-value', 'project'], 
        capture_output=True, text=True
    ).stdout.strip()
    
    # Run the lab
    lab = StreamingDataLakeLab(project_id)
    lab.run_complete_lab()
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach

---

## 🎖️ Skills Boost Arcade

Complete streaming data lake automation for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Automate data lake infrastructure for scalable streaming analytics!

</div>
