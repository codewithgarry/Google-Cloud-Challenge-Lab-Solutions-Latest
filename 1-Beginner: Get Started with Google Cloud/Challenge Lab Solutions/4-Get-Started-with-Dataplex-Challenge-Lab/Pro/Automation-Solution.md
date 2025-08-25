# Get Started with Dataplex: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Automation](https://img.shields.io/badge/Method-Automation-EA4335?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Script

```bash
#!/bin/bash

# =============================================================================
# Dataplex Challenge Lab - Complete Automation
# =============================================================================

set -e

# Configuration - Update with your lab values
LAKE_NAME="your-lake-name"
ZONE_NAME="your-zone-name"  
ASSET_NAME="your-asset-name"
REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="your-bucket-name"

echo "🚀 Starting Dataplex Challenge Lab Automation"
echo "Lake: $LAKE_NAME"
echo "Zone: $ZONE_NAME"
echo "Asset: $ASSET_NAME"
echo "Region: $REGION"
echo "Bucket: $BUCKET_NAME"

# Task 1: Create Dataplex Lake
echo "📋 Task 1: Creating Dataplex Lake..."

if gcloud dataplex lakes describe $LAKE_NAME --location=$REGION &>/dev/null; then
    echo "⚠️ Lake '$LAKE_NAME' already exists"
else
    gcloud dataplex lakes create $LAKE_NAME \
        --location=$REGION \
        --display-name="$LAKE_NAME" \
        --description="Automated challenge lab data lake"
    echo "✅ Lake created successfully"
fi

# Task 2: Create Zone
echo "📋 Task 2: Creating Zone..."

if gcloud dataplex zones describe $ZONE_NAME --location=$REGION --lake=$LAKE_NAME &>/dev/null; then
    echo "⚠️ Zone '$ZONE_NAME' already exists"
else
    gcloud dataplex zones create $ZONE_NAME \
        --location=$REGION \
        --lake=$LAKE_NAME \
        --display-name="$ZONE_NAME" \
        --type=RAW \
        --resource-location-type=SINGLE_REGION \
        --description="Automated challenge lab zone"
    echo "✅ Zone created successfully"
fi

# Task 3: Create Asset
echo "📋 Task 3: Creating Asset..."

if gcloud dataplex assets describe $ASSET_NAME --location=$REGION --lake=$LAKE_NAME --zone=$ZONE_NAME &>/dev/null; then
    echo "⚠️ Asset '$ASSET_NAME' already exists"
else
    gcloud dataplex assets create $ASSET_NAME \
        --location=$REGION \
        --lake=$LAKE_NAME \
        --zone=$ZONE_NAME \
        --display-name="$ASSET_NAME" \
        --resource-type=STORAGE_BUCKET \
        --resource-name=projects/$PROJECT_ID/buckets/$BUCKET_NAME \
        --discovery-enabled \
        --description="Automated challenge lab asset"
    echo "✅ Asset created successfully"
fi

# Task 4: Verify and Test
echo "📋 Task 4: Running Verification..."

# Wait for resources to be ready
sleep 30

# Check lake status
LAKE_STATE=$(gcloud dataplex lakes describe $LAKE_NAME --location=$REGION --format="value(state)" 2>/dev/null)
if [ "$LAKE_STATE" = "ACTIVE" ]; then
    echo "✅ Lake is active"
else
    echo "⚠️ Lake state: $LAKE_STATE"
fi

# Check zone status  
ZONE_STATE=$(gcloud dataplex zones describe $ZONE_NAME --location=$REGION --lake=$LAKE_NAME --format="value(state)" 2>/dev/null)
if [ "$ZONE_STATE" = "ACTIVE" ]; then
    echo "✅ Zone is active"
else
    echo "⚠️ Zone state: $ZONE_STATE"
fi

# Check asset status
ASSET_STATE=$(gcloud dataplex assets describe $ASSET_NAME --location=$REGION --lake=$LAKE_NAME --zone=$ZONE_NAME --format="value(state)" 2>/dev/null)
if [ "$ASSET_STATE" = "ACTIVE" ]; then
    echo "✅ Asset is active"
else
    echo "⚠️ Asset state: $ASSET_STATE"
fi

# Trigger discovery
echo "🔍 Triggering data discovery..."
gcloud dataplex assets actions run $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --action=discover || echo "⚠️ Discovery trigger may need manual intervention"

echo "🎉 Dataplex Challenge Lab automation completed!"
echo "Lake: $LAKE_NAME (Region: $REGION)"
echo "Zone: $ZONE_NAME"
echo "Asset: $ASSET_NAME"
```

---

## 🏗️ Terraform Infrastructure as Code

```hcl
# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "lake_name" {
  description = "Dataplex Lake name"
}

variable "zone_name" {
  description = "Dataplex Zone name"
}

variable "asset_name" {
  description = "Dataplex Asset name"
}

variable "bucket_name" {
  description = "Cloud Storage bucket name"
}

variable "region" {
  default = "us-central1"
}

# Create Dataplex Lake
resource "google_dataplex_lake" "challenge_lake" {
  name         = var.lake_name
  location     = var.region
  project      = var.project_id
  
  display_name = var.lake_name
  description  = "Challenge lab data lake created with Terraform"
  
  labels = {
    environment = "challenge-lab"
    lab-id     = "arc117"
  }
}

# Create Dataplex Zone
resource "google_dataplex_zone" "challenge_zone" {
  name         = var.zone_name
  location     = var.region
  lake         = google_dataplex_lake.challenge_lake.name
  project      = var.project_id
  
  display_name = var.zone_name
  description  = "Challenge lab zone created with Terraform"
  type         = "RAW"
  
  resource_spec {
    location_type = "SINGLE_REGION"
  }
  
  labels = {
    environment = "challenge-lab"
    lab-id     = "arc117"
  }
}

# Create Dataplex Asset
resource "google_dataplex_asset" "challenge_asset" {
  name         = var.asset_name
  location     = var.region
  lake         = google_dataplex_lake.challenge_lake.name
  dataplex_zone = google_dataplex_zone.challenge_zone.name
  project      = var.project_id
  
  display_name = var.asset_name
  description  = "Challenge lab asset created with Terraform"
  
  resource_spec {
    name = "projects/${var.project_id}/buckets/${var.bucket_name}"
    type = "STORAGE_BUCKET"
  }
  
  discovery_spec {
    enabled = true
    
    schedule = "0 6 * * *"  # Daily at 6 AM
    
    csv_options {
      header_rows = 1
      delimiter   = ","
      encoding    = "UTF-8"
    }
    
    json_options {
      encoding = "UTF-8"
    }
  }
  
  labels = {
    environment = "challenge-lab"
    lab-id     = "arc117"
  }
}

# Outputs
output "lake_name" {
  value = google_dataplex_lake.challenge_lake.name
}

output "zone_name" {
  value = google_dataplex_zone.challenge_zone.name
}

output "asset_name" {
  value = google_dataplex_asset.challenge_asset.name
}

output "lake_console_url" {
  value = "https://console.cloud.google.com/dataplex/lakes/${google_dataplex_lake.challenge_lake.name}?project=${var.project_id}&location=${var.region}"
}
```

---

## 🐍 Python Automation

```python
#!/usr/bin/env python3

"""
Google Cloud Dataplex Challenge Lab - Python Automation
"""

from google.cloud import dataplex_v1
import time

class DataplexAutomation:
    def __init__(self, project_id, lake_name, zone_name, asset_name, region, bucket_name):
        self.project_id = project_id
        self.lake_name = lake_name
        self.zone_name = zone_name
        self.asset_name = asset_name
        self.region = region
        self.bucket_name = bucket_name
        
        # Initialize client
        self.client = dataplex_v1.DataplexServiceClient()
        
        # Create resource paths
        self.parent = f"projects/{project_id}/locations/{region}"
        self.lake_path = f"{self.parent}/lakes/{lake_name}"
        self.zone_path = f"{self.lake_path}/zones/{zone_name}"
        
    def create_lake(self):
        """Create Dataplex Lake"""
        try:
            lake = dataplex_v1.Lake(
                display_name=self.lake_name,
                description="Python automation challenge lab lake"
            )
            
            operation = self.client.create_lake(
                parent=self.parent,
                lake_id=self.lake_name,
                lake=lake
            )
            
            print(f"⏳ Creating lake {self.lake_name}...")
            result = operation.result(timeout=300)
            print(f"✅ Lake created: {result.name}")
            return True
            
        except Exception as e:
            print(f"❌ Error creating lake: {e}")
            return False
    
    def create_zone(self):
        """Create Dataplex Zone"""
        try:
            zone = dataplex_v1.Zone(
                display_name=self.zone_name,
                description="Python automation challenge lab zone",
                type_=dataplex_v1.Zone.Type.RAW,
                resource_spec=dataplex_v1.Zone.ResourceSpec(
                    location_type=dataplex_v1.Zone.ResourceSpec.LocationType.SINGLE_REGION
                )
            )
            
            operation = self.client.create_zone(
                parent=self.lake_path,
                zone_id=self.zone_name,
                zone=zone
            )
            
            print(f"⏳ Creating zone {self.zone_name}...")
            result = operation.result(timeout=300)
            print(f"✅ Zone created: {result.name}")
            return True
            
        except Exception as e:
            print(f"❌ Error creating zone: {e}")
            return False
    
    def create_asset(self):
        """Create Dataplex Asset"""
        try:
            asset = dataplex_v1.Asset(
                display_name=self.asset_name,
                description="Python automation challenge lab asset",
                resource_spec=dataplex_v1.Asset.ResourceSpec(
                    name=f"projects/{self.project_id}/buckets/{self.bucket_name}",
                    type_=dataplex_v1.Asset.ResourceSpec.Type.STORAGE_BUCKET
                ),
                discovery_spec=dataplex_v1.Asset.DiscoverySpec(
                    enabled=True
                )
            )
            
            operation = self.client.create_asset(
                parent=self.zone_path,
                asset_id=self.asset_name,
                asset=asset
            )
            
            print(f"⏳ Creating asset {self.asset_name}...")
            result = operation.result(timeout=300)
            print(f"✅ Asset created: {result.name}")
            return True
            
        except Exception as e:
            print(f"❌ Error creating asset: {e}")
            return False
    
    def run_automation(self):
        """Run complete automation"""
        print("🚀 Starting Dataplex Python Automation")
        print(f"Project: {self.project_id}")
        print(f"Lake: {self.lake_name}")
        print(f"Zone: {self.zone_name}")
        print(f"Asset: {self.asset_name}")
        print("=" * 50)
        
        # Create lake
        if not self.create_lake():
            return False
            
        # Create zone
        if not self.create_zone():
            return False
            
        # Create asset
        if not self.create_asset():
            return False
        
        print("🎉 Dataplex automation completed successfully!")
        return True

def main():
    # Configuration
    PROJECT_ID = "your-project-id"  # Update
    LAKE_NAME = "your-lake-name"    # Update
    ZONE_NAME = "your-zone-name"    # Update
    ASSET_NAME = "your-asset-name"  # Update
    REGION = "us-central1"
    BUCKET_NAME = "your-bucket-name" # Update
    
    automation = DataplexAutomation(
        PROJECT_ID, LAKE_NAME, ZONE_NAME, 
        ASSET_NAME, REGION, BUCKET_NAME
    )
    automation.run_automation()

if __name__ == "__main__":
    main()
```

---

**🎉 Congratulations! You've mastered Dataplex automation!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
