# Create a Streaming Data Lake on Cloud Storage: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)
![gcloud](https://img.shields.io/badge/gcloud-4285F4?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC110 | **Duration**: 30 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Solution (Cloud Shell)

This solution uses gcloud and gsutil commands for efficient streaming data lake setup.

---

## ⚠️ IMPORTANT: Set Variables

```bash
# Set your lab-specific values
export PROJECT_ID=$(gcloud config get-value project)
export DATA_LAKE_BUCKET="${PROJECT_ID}-data-lake"
export STAGING_BUCKET="${PROJECT_ID}-staging"
export REGION="us-central1"  # Update from lab
export PUBSUB_TOPIC="streaming-topic"
export PUBSUB_SUBSCRIPTION="streaming-subscription"
export DATAFLOW_JOB="streaming-data-lake"
```

---

## 🚀 Complete CLI Solution

### Task 1: Enable APIs and create buckets

```bash
# Enable required APIs
gcloud services enable dataflow.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable bigquery.googleapis.com

# Create data lake bucket
gsutil mb -l $REGION gs://$DATA_LAKE_BUCKET

# Create staging bucket
gsutil mb -l $REGION gs://$STAGING_BUCKET

# Create folder structure in data lake
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/raw-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/processed-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/streaming-data/.keep
gsutil cp /dev/null gs://$DATA_LAKE_BUCKET/archive/.keep
```

### Task 2: Set up Pub/Sub

```bash
# Create Pub/Sub topic
gcloud pubsub topics create $PUBSUB_TOPIC

# Create subscription
gcloud pubsub subscriptions create $PUBSUB_SUBSCRIPTION \
    --topic=$PUBSUB_TOPIC

# Verify topic creation
gcloud pubsub topics list
```

### Task 3: Configure lifecycle management

```bash
# Create lifecycle configuration
cat > lifecycle.json << EOF
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

# Apply lifecycle policy
gsutil lifecycle set lifecycle.json gs://$DATA_LAKE_BUCKET
```

### Task 4: Deploy Dataflow streaming job

```bash
# Set Dataflow parameters
TEMPLATE_PATH="gs://dataflow-templates-$REGION/latest/PubSub_to_GCS_Text"
OUTPUT_DIRECTORY="gs://$DATA_LAKE_BUCKET/streaming-data/"
TEMP_LOCATION="gs://$STAGING_BUCKET/temp/"

# Create Dataflow job
gcloud dataflow jobs run $DATAFLOW_JOB \
    --gcs-location=$TEMPLATE_PATH \
    --region=$REGION \
    --parameters="inputTopic=projects/$PROJECT_ID/topics/$PUBSUB_TOPIC,outputDirectory=$OUTPUT_DIRECTORY,tempLocation=$TEMP_LOCATION,outputFilenamePrefix=streaming-data,outputFilenameSuffix=.txt,windowDuration=1m"

# Monitor job status
gcloud dataflow jobs list --region=$REGION
```

### Task 5: Test streaming data

```bash
# Publish test messages
for i in {1..10}; do
    gcloud pubsub topics publish $PUBSUB_TOPIC \
        --message="{\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"sensor_id\": \"sensor$(printf %03d $i)\", \"temperature\": $(shuf -i 15-35 -n 1).$(shuf -i 0-9 -n 1), \"humidity\": $(shuf -i 30-70 -n 1).$(shuf -i 0-9 -n 1)}"
    sleep 2
done

echo "Published 10 test messages"
```

### Task 6: Monitor and verify

```bash
# Check Dataflow job status
JOB_ID=$(gcloud dataflow jobs list --region=$REGION --filter="name:$DATAFLOW_JOB" --format="value(id)")
gcloud dataflow jobs describe $JOB_ID --region=$REGION

# List files in streaming data folder
gsutil ls -la gs://$DATA_LAKE_BUCKET/streaming-data/

# Check latest file content
LATEST_FILE=$(gsutil ls gs://$DATA_LAKE_BUCKET/streaming-data/ | tail -n 1)
gsutil cat $LATEST_FILE
```

---

## 📊 Advanced Data Lake Operations

### Data Processing Pipeline
```bash
# Create BigQuery dataset for analytics
bq mk --location=$REGION --dataset $PROJECT_ID:streaming_analytics

# Create external table pointing to data lake
bq mk --table \
    --external_table_definition=gs://$DATA_LAKE_BUCKET/streaming-data/*@CSV:autodetect=true \
    $PROJECT_ID:streaming_analytics.streaming_data

# Query streaming data
bq query --use_legacy_sql=false \
    'SELECT COUNT(*) as message_count FROM `'$PROJECT_ID'.streaming_analytics.streaming_data`'
```

### Monitoring and Alerting
```bash
# Create alert policy for Dataflow job
gcloud alpha monitoring policies create --policy-from-file=- << EOF
{
  "displayName": "Dataflow Job High System Lag",
  "conditions": [
    {
      "displayName": "System lag too high",
      "conditionThreshold": {
        "filter": "resource.type=\"dataflow_job\" AND metric.type=\"dataflow.googleapis.com/job/system_lag\"",
        "comparison": "COMPARISON_GREATER_THAN",
        "thresholdValue": 30
      }
    }
  ],
  "notificationChannels": [],
  "enabled": true
}
EOF
```

### Data Retention Management
```bash
# Archive old data
gsutil -m mv gs://$DATA_LAKE_BUCKET/streaming-data/2024* gs://$DATA_LAKE_BUCKET/archive/

# Compress archived data
gsutil -m cp gs://$DATA_LAKE_BUCKET/archive/*.txt - | gzip | gsutil cp - gs://$DATA_LAKE_BUCKET/archive/archived_$(date +%Y%m%d).txt.gz

# Clean up original files
gsutil -m rm gs://$DATA_LAKE_BUCKET/archive/*.txt
```

---

## ✅ Verification Commands

```bash
# Verify bucket structure
gsutil ls -la gs://$DATA_LAKE_BUCKET/

# Check Pub/Sub topic
gcloud pubsub topics describe $PUBSUB_TOPIC

# Monitor Dataflow job
gcloud dataflow jobs list --region=$REGION --filter="name:$DATAFLOW_JOB"

# Test data ingestion
gsutil ls gs://$DATA_LAKE_BUCKET/streaming-data/ | wc -l

# Check lifecycle policy
gsutil lifecycle get gs://$DATA_LAKE_BUCKET
```

---

## 🧹 Cleanup Commands

```bash
# Stop Dataflow job
gcloud dataflow jobs cancel $JOB_ID --region=$REGION

# Delete Pub/Sub resources
gcloud pubsub subscriptions delete $PUBSUB_SUBSCRIPTION
gcloud pubsub topics delete $PUBSUB_TOPIC

# Clean up buckets (optional)
# gsutil -m rm -r gs://$DATA_LAKE_BUCKET
# gsutil -m rm -r gs://$STAGING_BUCKET
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[Automation Solution](Automation-Solution.md)** - Complete infrastructure as code

---

## 🎖️ Skills Boost Arcade

Master streaming data lakes with efficient CLI commands for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use gcloud commands for scalable data lake management!

</div>
