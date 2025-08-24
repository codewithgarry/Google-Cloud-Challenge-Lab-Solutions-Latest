# Get Started with Dataplex: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Challenge Tasks

**Task 1**: Create a lake  
**Task 2**: Create and attach a zone to your lake  
**Task 3**: Create and attach an asset to the zone

---

## 🚀 Solutions

### Task 1: Create a Lake

#### Method 1: Google Cloud Console
1. Go to **Dataplex** → **Manage** → **Lakes**
2. Click **CREATE LAKE**
3. **Display name**: Use the name specified in lab
4. **Lake ID**: Auto-generated
5. **Region**: us-central1
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
gcloud dataplex lakes create LAKE_NAME \
    --location=us-central1 \
    --display-name="LAKE_DISPLAY_NAME"
```

---

### Task 2: Create and Attach Zone to Lake

#### Method 1: Google Cloud Console
1. Go to your created lake
2. Click **ADD ZONE**
3. **Zone type**: Raw (for raw data) or Curated (for processed data)
4. **Display name**: Use the name specified in lab
5. **Zone ID**: Auto-generated
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
# For Raw zone
gcloud dataplex zones create ZONE_NAME \
    --location=us-central1 \
    --lake=LAKE_NAME \
    --display-name="ZONE_DISPLAY_NAME" \
    --type=RAW

# For Curated zone (if needed)
gcloud dataplex zones create ZONE_NAME \
    --location=us-central1 \
    --lake=LAKE_NAME \
    --display-name="ZONE_DISPLAY_NAME" \
    --type=CURATED
```

---

### Task 3: Create and Attach Asset to Zone

#### Method 1: Google Cloud Console
1. Go to your zone
2. Click **ADD ASSETS**
3. **Asset type**: Cloud Storage bucket or BigQuery dataset
4. **Display name**: Use the name specified in lab
5. **Resource**: Select existing bucket/dataset or create new
6. Click **CREATE**

#### Method 2: Cloud Shell

#### For Cloud Storage Asset:
```bash
# First create a bucket if needed
gsutil mb gs://BUCKET_NAME

# Add bucket as asset
gcloud dataplex assets create ASSET_NAME \
    --location=us-central1 \
    --lake=LAKE_NAME \
    --zone=ZONE_NAME \
    --display-name="ASSET_DISPLAY_NAME" \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/PROJECT_ID/buckets/BUCKET_NAME
```

#### For BigQuery Asset:
```bash
# First create dataset if needed
bq mk --dataset PROJECT_ID:DATASET_NAME

# Add dataset as asset
gcloud dataplex assets create ASSET_NAME \
    --location=us-central1 \
    --lake=LAKE_NAME \
    --zone=ZONE_NAME \
    --display-name="ASSET_DISPLAY_NAME" \
    --resource-type=BIGQUERY_DATASET \
    --resource-name=projects/PROJECT_ID/datasets/DATASET_NAME
```

---

## ✅ Verification

1. **Check lake**: Go to Dataplex → Manage → Lakes
2. **Check zone**: Go to your lake and verify zone is attached
3. **Check asset**: Go to your zone and verify asset is attached

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>
