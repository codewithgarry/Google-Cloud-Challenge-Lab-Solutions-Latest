# Get Started with Pub/Sub: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC113 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Challenge Tasks

**Task 1**: Create a Pub/Sub topic  
**Task 2**: Create a Pub/Sub subscription  
**Task 3**: Publish and pull a message

---

## 🚀 Solutions

### Task 1: Create Pub/Sub Topic

#### Method 1: Google Cloud Console
1. Go to **Pub/Sub** → **Topics**
2. Click **CREATE TOPIC**
3. **Topic ID**: Use the specified topic name from lab
4. Click **CREATE**

#### Method 2: Cloud Shell
```bash
# Replace TOPIC_NAME with the name specified in your lab
gcloud pubsub topics create TOPIC_NAME
```

---

### Task 2: Create Pub/Sub Subscription

#### Method 1: Google Cloud Console
1. Go to **Pub/Sub** → **Subscriptions**
2. Click **CREATE SUBSCRIPTION**
3. **Subscription ID**: Use the specified subscription name from lab
4. **Topic**: Select the topic created in Task 1
5. **Delivery Type**: Pull
6. Click **CREATE**

#### Method 2: Cloud Shell
```bash
# Replace SUBSCRIPTION_NAME and TOPIC_NAME with names from your lab
gcloud pubsub subscriptions create SUBSCRIPTION_NAME --topic=TOPIC_NAME
```

---

### Task 3: Publish and Pull Messages

#### Publish a Message
```bash
# Replace TOPIC_NAME with your topic name
gcloud pubsub topics publish TOPIC_NAME --message="Hello Cloud Pub/Sub"
```

#### Pull a Message
```bash
# Replace SUBSCRIPTION_NAME with your subscription name
gcloud pubsub subscriptions pull SUBSCRIPTION_NAME --auto-ack
```

---

### Additional Tasks (if required in your lab)

#### Create Schema (if needed)
```bash
# Create schema file
cat > schema.json << 'EOF'
{
  "type": "record",
  "name": "Avro",
  "fields": [
    {"name": "StringField", "type": "string"}
  ]
}
EOF

# Create schema
gcloud pubsub schemas create SCHEMA_NAME --type=AVRO --definition-file=schema.json
```

#### Create Topic with Schema
```bash
gcloud pubsub topics create TOPIC_NAME --schema=SCHEMA_NAME --message-encoding=JSON
```

#### Create Snapshot
```bash
gcloud pubsub snapshots create SNAPSHOT_NAME --subscription=SUBSCRIPTION_NAME
```

#### Set up Cloud Scheduler (if needed)
```bash
gcloud scheduler jobs create pubsub JOB_NAME \
    --schedule="0 */2 * * *" \
    --topic=TOPIC_NAME \
    --message-body="Scheduled message"
```

---

## ✅ Verification

1. **Check topics**: `gcloud pubsub topics list`
2. **Check subscriptions**: `gcloud pubsub subscriptions list`
3. **Test message flow**: Publish and pull messages as shown above

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>
