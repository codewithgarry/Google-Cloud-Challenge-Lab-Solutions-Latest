# Create a Streaming Data Lake on Cloud Storage: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)
![Dataflow](https://img.shields.io/badge/Dataflow-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC110 | **Duration**: 60 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 GUI Solution (Google Cloud Console)

This solution uses the Google Cloud Console to create a streaming data lake with Cloud Storage and Dataflow.

---

## ⚠️ IMPORTANT: Get Values from Your Lab

**Check your lab instructions for these specific values:**
- **Data Lake Bucket**: (usually `PROJECT_ID-data-lake`)
- **Staging Bucket**: (usually `PROJECT_ID-staging`)
- **Region**: (specified in lab)
- **Pub/Sub Topic**: (specified in lab)

---

## 📋 Step-by-Step Console Instructions

### Task 1: Create Cloud Storage buckets for data lake

1. **Navigate to Cloud Storage**
   - In the Google Cloud Console, click on the **Navigation menu** (☰)
   - Go to **Storage** → **Cloud Storage** → **Buckets**

2. **Create data lake bucket**
   - Click **CREATE BUCKET**
   - **Name**: Enter the data lake bucket name from lab
   - **Location**: Multi-region or region as specified
   - **Storage class**: **Standard**
   - **Access control**: **Uniform**
   - Click **CREATE**

3. **Create staging bucket**
   - Click **CREATE BUCKET** again
   - **Name**: Enter staging bucket name from lab
   - **Location**: Same as data lake bucket
   - **Storage class**: **Standard**
   - **Access control**: **Uniform**
   - Click **CREATE**

### Task 2: Set up Pub/Sub for streaming data

1. **Navigate to Pub/Sub**
   - Go to **Pub/Sub** → **Topics**

2. **Create topic**
   - Click **CREATE TOPIC**
   - **Topic ID**: Enter topic name from lab
   - Leave other settings as default
   - Click **CREATE**

3. **Create subscription**
   - Click on your topic name
   - Go to **Subscriptions** tab
   - Click **CREATE SUBSCRIPTION**
   - **Subscription ID**: Enter subscription name from lab
   - **Delivery type**: Pull
   - Click **CREATE**

### Task 3: Enable APIs for data processing

1. **Navigate to APIs & Services**
   - Go to **APIs & Services** → **Library**

2. **Enable required APIs**
   - Search and enable:
     - **Cloud Dataflow API**
     - **Cloud Dataprep API**
     - **Cloud Composer API**
     - **BigQuery API**

### Task 4: Create Dataflow job for streaming

1. **Navigate to Dataflow**
   - Go to **Dataflow** → **Jobs**

2. **Create job from template**
   - Click **CREATE JOB FROM TEMPLATE**
   - **Job name**: Enter name from lab
   - **Regional endpoint**: Select region from lab
   - **Dataflow template**: **Pub/Sub to Cloud Storage Text**

3. **Configure parameters**
   - **Input Pub/Sub topic**: `projects/PROJECT_ID/topics/TOPIC_NAME`
   - **Output file directory**: `gs://DATA_LAKE_BUCKET/streaming-data/`
   - **Temporary location**: `gs://STAGING_BUCKET/temp/`
   - **Output filename prefix**: `streaming-data`
   - **Output file suffix**: `.txt`

4. **Set additional parameters**
   - **Max workers**: 2
   - **Machine type**: n1-standard-1
   - **Window duration**: 1m
   - Click **RUN JOB**

### Task 5: Configure data lake structure

1. **Create folder structure in data lake bucket**
   - Go back to **Cloud Storage** → **Buckets**
   - Click on your data lake bucket
   - Click **CREATE FOLDER**
   - Create these folders:
     - `raw-data/`
     - `processed-data/`
     - `streaming-data/`
     - `archive/`

2. **Set up lifecycle policies**
   - Go to **Lifecycle** tab
   - Click **ADD A RULE**
   - **Rule scope**: Apply to all objects
   - **Action**: Move to Nearline storage
   - **Condition**: Age 30 days
   - Click **CREATE**

### Task 6: Test streaming data ingestion

1. **Publish test messages to Pub/Sub**
   - Go to **Pub/Sub** → **Topics**
   - Click on your topic
   - Click **PUBLISH MESSAGE**
   - **Message body**: 
     ```json
     {"timestamp": "2025-08-26T10:00:00Z", "sensor_id": "sensor001", "temperature": 23.5, "humidity": 45.2}
     ```
   - Click **PUBLISH**

2. **Verify data in Cloud Storage**
   - Go to **Cloud Storage** → **Buckets**
   - Navigate to your data lake bucket
   - Check `streaming-data/` folder for output files

### Task 7: Monitor streaming pipeline

1. **Monitor Dataflow job**
   - Go to **Dataflow** → **Jobs**
   - Click on your job name
   - Monitor job graph, logs, and metrics

2. **Set up monitoring alerts**
   - Go to **Monitoring** → **Alerting**
   - Click **CREATE POLICY**
   - **Resource type**: Dataflow Job
   - **Metric**: System lag
   - **Condition**: Greater than 30 seconds
   - **Notification**: Email
   - Click **SAVE**

---

## ✅ Verification Steps

1. **Verify buckets**: Check both data lake and staging buckets exist
2. **Test Pub/Sub**: Confirm messages can be published
3. **Check Dataflow**: Verify job is running without errors
4. **Validate data flow**: Confirm data appears in Cloud Storage
5. **Monitor metrics**: Check latency and throughput

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach for automation
- **[Automation Solution](Automation-Solution.md)** - Complete infrastructure as code

---

## 🎖️ Skills Boost Arcade

This lab teaches essential data lake concepts for modern data architecture!

---

<div align="center">

**💡 Pro Tip**: Data lakes enable scalable analytics on structured and unstructured data!

</div>
