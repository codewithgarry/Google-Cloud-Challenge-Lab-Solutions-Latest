# Get Started with Dataplex: Challenge Lab - Complete Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Data Catalog](https://img.shields.io/badge/Data%20Catalog-4CAF50?style=for-the-badge&logo=google&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-FFC107?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 45 minutes | **Credits**: 1 | **Level**: Introductory

</div>

---

## 👨‍💻 Author Profile

<div align="center">

### **CodeWithGarry** 
*Google Cloud Solutions Architect & Data Engineering Expert*

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

**🎯 Mission**: Empowering data engineers to master Google Cloud data management with Dataplex

</div>

---

## 📋 Challenge Overview

**Scenario**: You're a junior data engineer helping a development team create and manage Dataplex assets for organizing and tagging data.

**Objective**: Build a complete data lake solution using Google Cloud Dataplex with lakes, zones, assets, and data catalog integration.

**Architecture**:
```
Dataplex Lake → Raw Zone → Cloud Storage Asset → Tag Template
```

---

## 🚀 Pre-requisites Setup

```bash
# Set your project variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"  # Replace with your lab region

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Enable required APIs
gcloud services enable dataplex.googleapis.com
gcloud services enable datacatalog.googleapis.com
gcloud services enable storage.googleapis.com

echo "✅ Required APIs enabled"
```

---

## 📝 Task Solutions

### 🎯 Task 1: Create a Lake with a Raw Zone

#### **Method 1: Using gcloud CLI (Recommended)**

```bash
# Create Dataplex lake
gcloud dataplex lakes create customer-engagements \
    --location=$REGION \
    --display-name="Customer Engagements" \
    --description="Lake for customer engagement data"

# Create raw zone in the lake
gcloud dataplex zones create raw-event-data \
    --location=$REGION \
    --lake=customer-engagements \
    --display-name="Raw Event Data" \
    --type=RAW \
    --discovery-enabled \
    --resource-location-type=SINGLE_REGION

echo "✅ Lake and raw zone created successfully"
```

#### **Method 2: Using Google Cloud Console**

1. **Navigation**: **☰ Menu** → **Dataplex** → **Manage**
2. Click **🆕 CREATE LAKE**
3. **Lake Configuration**:
   - **Lake ID**: `customer-engagements`
   - **Display name**: `Customer Engagements`
   - **Region**: Your lab region (e.g., `us-central1`)
   - **Description**: `Lake for customer engagement data`
4. Click **CREATE**
5. **Create Zone in Lake**:
   - Click on the created lake
   - Click **🆕 ADD ZONE**
   - **Zone ID**: `raw-event-data`
   - **Display name**: `Raw Event Data`
   - **Zone type**: `Raw`
   - **Regional resource location type**: `Single region`
6. Click **CREATE**

---

### 🎯 Task 2: Create and Attach Cloud Storage Bucket to Zone

#### **Method 1: Using gcloud CLI (Recommended)**

```bash
# Create Cloud Storage bucket
gsutil mb -l $REGION gs://$PROJECT_ID

# Create asset in Dataplex and attach the bucket
gcloud dataplex assets create raw-event-files \
    --location=$REGION \
    --lake=customer-engagements \
    --zone=raw-event-data \
    --display-name="Raw Event Files" \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID \
    --discovery-enabled

echo "✅ Storage bucket created and attached as asset"
```

#### **Method 2: Using Google Cloud Console**

1. **Create Storage Bucket**:
   - **Navigation**: **☰ Menu** → **Cloud Storage** → **Buckets**
   - Click **🆕 CREATE BUCKET**
   - **Name**: Your project ID
   - **Location type**: Region
   - **Location**: Your lab region
   - Click **CREATE**

2. **Attach Bucket to Zone**:
   - **Navigation**: **☰ Menu** → **Dataplex** → **Manage**
   - Click on **Customer Engagements** lake
   - Click on **Raw Event Data** zone
   - Click **🆕 ADD ASSET**
   - **Asset ID**: `raw-event-files`
   - **Display name**: `Raw Event Files`
   - **Asset type**: `Storage bucket`
   - **Bucket**: Select your project ID bucket
   - **Discovery enabled**: ✅ Yes
   - Click **CREATE**

---

### 🎯 Task 3: Create and Apply Tag Template to Zone

#### **Method 1: Using gcloud CLI (Recommended)**

```bash
# Create tag template
gcloud data-catalog tag-templates create protected-raw-data-template \
    --location=$REGION \
    --display-name="Protected Raw Data Template" \
    --field=id=protected-raw-data-flag,display-name="Protected Raw Data Flag",type=enum,enum-values="Y|N"

# Get the zone resource name
ZONE_RESOURCE="projects/$PROJECT_ID/locations/$REGION/lakes/customer-engagements/zones/raw-event-data"

# Create tag on the zone
gcloud data-catalog tags create \
    --location=$REGION \
    --tag-template=protected-raw-data-template \
    --tag-template-field=protected-raw-data-flag=Y \
    --resource=$ZONE_RESOURCE

echo "✅ Tag template created and applied to zone"
```

#### **Method 2: Using Google Cloud Console**

1. **Create Tag Template**:
   - **Navigation**: **☰ Menu** → **Data Catalog** → **Tag templates**
   - Click **🆕 CREATE TAG TEMPLATE**
   - **Template ID**: `protected-raw-data-template`
   - **Display name**: `Protected Raw Data Template`
   - **Location**: Your lab region
   - **Visibility**: `Public`
   - **Add Field**:
     - **Field ID**: `protected-raw-data-flag`
     - **Display name**: `Protected Raw Data Flag`
     - **Type**: `Enumerated`
     - **Values**: `Y`, `N`
   - Click **CREATE**

2. **Apply Tag to Zone**:
   - **Navigation**: **☰ Menu** → **Dataplex** → **Manage**
   - Click on **Customer Engagements** lake
   - Click on **Raw Event Data** zone
   - Click **📋 TAGS** tab
   - Click **🏷️ ADD TAG**
   - **Tag template**: `Protected Raw Data Template`
   - **Protected Raw Data Flag**: `Y`
   - Click **SAVE**

---

## 🔍 Verification Steps

### **Verify Lake and Zone Creation**
```bash
# Check lake
gcloud dataplex lakes describe customer-engagements --location=$REGION

# Check zone
gcloud dataplex zones describe raw-event-data \
    --location=$REGION \
    --lake=customer-engagements
```

### **Verify Storage Bucket and Asset**
```bash
# Check bucket
gsutil ls gs://$PROJECT_ID

# Check asset
gcloud dataplex assets describe raw-event-files \
    --location=$REGION \
    --lake=customer-engagements \
    --zone=raw-event-data
```

### **Verify Tag Template and Tags**
```bash
# Check tag template
gcloud data-catalog tag-templates describe protected-raw-data-template \
    --location=$REGION

# List tags on zone
gcloud data-catalog tags list \
    --location=$REGION \
    --resource=projects/$PROJECT_ID/locations/$REGION/lakes/customer-engagements/zones/raw-event-data
```

---

## 🐛 Troubleshooting Guide

### **Issue 1: APIs Not Enabled**
```bash
# Verify and enable required APIs
gcloud services list --enabled | grep -E "(dataplex|datacatalog)"

# Enable if missing
gcloud services enable dataplex.googleapis.com datacatalog.googleapis.com
```

### **Issue 2: Lake Creation Fails**
```bash
# Check Dataplex API availability in region
gcloud dataplex locations list

# Verify region format (should be like us-central1)
echo "Using region: $REGION"
```

### **Issue 3: Asset Attachment Issues**
```bash
# Verify bucket exists and is accessible
gsutil ls -L gs://$PROJECT_ID

# Check bucket location matches zone region
gsutil ls -L -b gs://$PROJECT_ID | grep "Location constraint"
```

### **Issue 4: Tag Template Creation Issues**
```bash
# Verify Data Catalog API is enabled
gcloud services list --enabled | grep datacatalog

# Check if template already exists
gcloud data-catalog tag-templates list --location=$REGION
```

---

## 🚀 Complete Automation Script

```bash
#!/bin/bash

# Dataplex Challenge Lab - Complete Automation
set -e

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"  # Update with your lab region

echo "🚀 Starting Dataplex Challenge Lab..."

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable dataplex.googleapis.com datacatalog.googleapis.com storage.googleapis.com

# Wait for APIs to be fully enabled
sleep 30

# Task 1: Create lake with raw zone
echo "📋 Task 1: Creating Dataplex lake and raw zone..."
gcloud dataplex lakes create customer-engagements \
    --location=$REGION \
    --display-name="Customer Engagements" \
    --description="Lake for customer engagement data"

gcloud dataplex zones create raw-event-data \
    --location=$REGION \
    --lake=customer-engagements \
    --display-name="Raw Event Data" \
    --type=RAW \
    --discovery-enabled \
    --resource-location-type=SINGLE_REGION

echo "✅ Task 1 completed"

# Task 2: Create bucket and attach as asset
echo "📋 Task 2: Creating storage bucket and attaching as asset..."
gsutil mb -l $REGION gs://$PROJECT_ID

# Wait for bucket creation to propagate
sleep 10

gcloud dataplex assets create raw-event-files \
    --location=$REGION \
    --lake=customer-engagements \
    --zone=raw-event-data \
    --display-name="Raw Event Files" \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID \
    --discovery-enabled

echo "✅ Task 2 completed"

# Task 3: Create tag template and apply to zone
echo "📋 Task 3: Creating tag template and applying to zone..."
gcloud data-catalog tag-templates create protected-raw-data-template \
    --location=$REGION \
    --display-name="Protected Raw Data Template" \
    --field=id=protected-raw-data-flag,display-name="Protected Raw Data Flag",type=enum,enum-values="Y|N"

# Wait for tag template creation
sleep 10

ZONE_RESOURCE="projects/$PROJECT_ID/locations/$REGION/lakes/customer-engagements/zones/raw-event-data"

gcloud data-catalog tags create \
    --location=$REGION \
    --tag-template=protected-raw-data-template \
    --tag-template-field=protected-raw-data-flag=Y \
    --resource=$ZONE_RESOURCE

echo "✅ Task 3 completed"

# Final verification
echo "🧪 Final verification..."
echo "Lake: $(gcloud dataplex lakes describe customer-engagements --location=$REGION --format='value(displayName)')"
echo "Zone: $(gcloud dataplex zones describe raw-event-data --location=$REGION --lake=customer-engagements --format='value(displayName)')"
echo "Asset: $(gcloud dataplex assets describe raw-event-files --location=$REGION --lake=customer-engagements --zone=raw-event-data --format='value(displayName)')"
echo "Tag Template: $(gcloud data-catalog tag-templates describe protected-raw-data-template --location=$REGION --format='value(displayName)')"

echo "🎉 Dataplex Challenge Lab completed successfully!"
echo "📊 Check your Dataplex console for the complete setup"
```

---

## 📚 Key Concepts Explained

### **🏔️ Dataplex Lake**
- Central management unit for organizing data assets
- Provides unified governance and security
- Supports both raw and curated data zones

### **🗂️ Dataplex Zone**
- Logical grouping within a lake
- **Raw Zone**: For unprocessed, original data
- **Curated Zone**: For processed, refined data

### **📦 Dataplex Asset**
- Individual data resources (buckets, datasets)
- Automatically discovered and cataloged
- Enables metadata management and lineage tracking

### **🏷️ Data Catalog Tags**
- Metadata annotations for classification
- Support for custom templates and fields
- Essential for data governance and compliance

---

## ✅ Final Verification Checklist

- [ ] **Dataplex Lake**: `Customer Engagements` created in specified region
- [ ] **Raw Zone**: `Raw Event Data` created with proper configuration
- [ ] **Storage Bucket**: Project ID bucket created in correct region
- [ ] **Asset**: `Raw Event Files` attached to zone with discovery enabled
- [ ] **Tag Template**: `Protected Raw Data Template` with enum field created
- [ ] **Zone Tag**: Applied to `Raw Event Data` zone with `Y` value
- [ ] **APIs Enabled**: Dataplex and Data Catalog APIs active

**Lab completion time**: 35-45 minutes

---

<div align="center">

## 🎯 **About This Solution**

This comprehensive Dataplex challenge lab solution is crafted by **CodeWithGarry** to help you master Google Cloud data lake management and governance.

### 📞 **Connect with CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

### 🌟 **Why Choose Our Solutions?**

✅ **Data Engineering Focus**: Specialized expertise in data platforms  
✅ **Complete Coverage**: All Dataplex features and scenarios  
✅ **Governance Ready**: Best practices for data management  
✅ **Production Patterns**: Enterprise-grade implementations  

---

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Organizing the world's data, one Dataplex lake at a time."*

**Happy Learning! 🚀☁️**

</div>
