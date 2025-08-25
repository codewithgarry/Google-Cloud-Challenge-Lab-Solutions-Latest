# Get Started with Dataplex: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Method](https://img.shields.io/badge/Method-CLI-FBBC04?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Method - Fast & Efficient

### 📋 Lab Requirements
```bash
# Set variables (replace with your lab values)
export LAKE_NAME="your-lake-name"
export ZONE_NAME="your-zone-name"
export ASSET_NAME="your-asset-name"
export REGION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="your-bucket-name"  # From lab instructions
```

---

## 🚀 Task 1: Create Dataplex Lake

```bash
# Create the lake
gcloud dataplex lakes create $LAKE_NAME \
    --location=$REGION \
    --display-name="$LAKE_NAME" \
    --description="Challenge lab data lake"

# Verify lake creation
gcloud dataplex lakes describe $LAKE_NAME \
    --location=$REGION
```

---

## 🚀 Task 2: Create Zone in Lake

```bash
# Create raw zone
gcloud dataplex zones create $ZONE_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --display-name="$ZONE_NAME" \
    --type=RAW \
    --resource-location-type=SINGLE_REGION

# For curated zone (if specified in lab)
# gcloud dataplex zones create $ZONE_NAME \
#     --location=$REGION \
#     --lake=$LAKE_NAME \
#     --display-name="$ZONE_NAME" \
#     --type=CURATED \
#     --resource-location-type=SINGLE_REGION

# Verify zone creation
gcloud dataplex zones describe $ZONE_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME
```

---

## 🚀 Task 3: Add Asset to Zone

```bash
# Create asset (Cloud Storage bucket)
gcloud dataplex assets create $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --display-name="$ASSET_NAME" \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$PROJECT_ID/buckets/$BUCKET_NAME \
    --discovery-enabled

# Verify asset creation
gcloud dataplex assets describe $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME
```

---

## 🚀 Task 4: Trigger Data Discovery

```bash
# Trigger discovery job
gcloud dataplex assets actions run $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --action=discover

# Check discovery job status
gcloud dataplex assets actions list $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --filter="action:discover"

# List discovered entities
gcloud dataplex entities list \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME
```

---

## 🔍 Verification Commands

```bash
# List all lakes
gcloud dataplex lakes list --location=$REGION

# List all zones in lake
gcloud dataplex zones list \
    --location=$REGION \
    --lake=$LAKE_NAME

# List all assets in zone
gcloud dataplex assets list \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME

# Check lake status
gcloud dataplex lakes describe $LAKE_NAME \
    --location=$REGION \
    --format="value(state)"

# Check zone status
gcloud dataplex zones describe $ZONE_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --format="value(state)"

# Check asset status
gcloud dataplex assets describe $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --format="value(state)"
```

---

## 🎯 One-Liner Complete Solution

```bash
# Set your lab values first
export LAKE_NAME="your-lake-name"
export ZONE_NAME="your-zone-name" 
export ASSET_NAME="your-asset-name"
export REGION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="your-bucket-name"

# Complete solution
gcloud dataplex lakes create $LAKE_NAME --location=$REGION --display-name="$LAKE_NAME" && \
gcloud dataplex zones create $ZONE_NAME --location=$REGION --lake=$LAKE_NAME --display-name="$ZONE_NAME" --type=RAW --resource-location-type=SINGLE_REGION && \
gcloud dataplex assets create $ASSET_NAME --location=$REGION --lake=$LAKE_NAME --zone=$ZONE_NAME --display-name="$ASSET_NAME" --resource-type=STORAGE_BUCKET --resource-name=projects/$PROJECT_ID/buckets/$BUCKET_NAME --discovery-enabled
```

---

## 🛠️ Advanced Operations

### Create Multiple Zones
```bash
# Create both raw and curated zones
gcloud dataplex zones create ${ZONE_NAME}-raw \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --type=RAW \
    --resource-location-type=SINGLE_REGION

gcloud dataplex zones create ${ZONE_NAME}-curated \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --type=CURATED \
    --resource-location-type=SINGLE_REGION
```

### Configure Data Quality
```bash
# Create data quality job
gcloud dataplex tasks create $LAKE_NAME-dq-task \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --trigger-type=ON_DEMAND \
    --execution-service-account=dataplex-service-account@$PROJECT_ID.iam.gserviceaccount.com \
    --spark-main-class=com.google.cloud.dataplex.templates.hive.HiveDDLExtractor
```

---

## 🧹 Cleanup Commands

```bash
# Delete asset
gcloud dataplex assets delete $ASSET_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --zone=$ZONE_NAME \
    --quiet

# Delete zone
gcloud dataplex zones delete $ZONE_NAME \
    --location=$REGION \
    --lake=$LAKE_NAME \
    --quiet

# Delete lake
gcloud dataplex lakes delete $LAKE_NAME \
    --location=$REGION \
    --quiet
```

---

**🎉 Congratulations! You've completed the Dataplex Challenge Lab using CLI commands!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
