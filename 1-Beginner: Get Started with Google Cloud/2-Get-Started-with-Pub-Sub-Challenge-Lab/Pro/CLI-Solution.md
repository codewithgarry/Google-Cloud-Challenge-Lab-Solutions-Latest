# Get Started with Pub/Sub: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Method](https://img.shields.io/badge/Method-CLI-FBBC04?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC113 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Method - Fast & Efficient

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Topic Name**: (specified in your lab)
- **Subscription Name**: (specified in your lab)

---

## 🚀 Quick Start Commands

```bash
# Set variables (replace with your lab values)
export TOPIC_NAME="your-topic-name"
export SUBSCRIPTION_NAME="your-subscription-name"
export PROJECT_ID=$(gcloud config get-value project)
```

---

## 🚀 Task 1: Create Pub/Sub Topic

```bash
# Create the topic
gcloud pubsub topics create $TOPIC_NAME

# Verify topic creation
gcloud pubsub topics list
```

**Alternative with explicit project:**
```bash
gcloud pubsub topics create $TOPIC_NAME --project=$PROJECT_ID
```

---

## 🚀 Task 2: Create Pub/Sub Subscription

```bash
# Create subscription
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME

# Verify subscription creation
gcloud pubsub subscriptions list
```

**With additional options:**
```bash
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME \
  --topic=$TOPIC_NAME \
  --ack-deadline=60 \
  --message-retention-duration=7d
```

---

## 🚀 Task 3: Publish and Pull Messages

### Publish Messages

**Single message:**
```bash
gcloud pubsub topics publish $TOPIC_NAME --message="Hello Cloud Pub/Sub"
```

**Message with attributes:**
```bash
gcloud pubsub topics publish $TOPIC_NAME \
  --message="Hello with attributes" \
  --attribute="key1=value1,key2=value2"
```

**Multiple messages:**
```bash
for i in {1..5}; do
  gcloud pubsub topics publish $TOPIC_NAME --message="Message $i"
done
```

### Pull Messages

**Pull single message:**
```bash
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --limit=1
```

**Pull with auto-acknowledgment:**
```bash
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=5
```

**Pull all available messages:**
```bash
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=100
```

---

## 🔍 Verification Commands

### Check Topic Details
```bash
# List all topics
gcloud pubsub topics list

# Get topic details
gcloud pubsub topics describe $TOPIC_NAME
```

### Check Subscription Details
```bash
# List all subscriptions
gcloud pubsub subscriptions list

# Get subscription details
gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME
```

### Check Messages in Subscription
```bash
# Check unacknowledged message count
gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME \
  --format="value(numUndeliveredMessages)"
```

---

## 🛠️ Advanced CLI Operations

### Schema Management (if required)

**Create schema file:**
```bash
cat > schema.json << 'EOF'
{
  "type": "record",
  "name": "MyRecord",
  "fields": [
    {"name": "message", "type": "string"},
    {"name": "timestamp", "type": "long"}
  ]
}
EOF
```

**Create schema:**
```bash
gcloud pubsub schemas create my-schema \
  --type=AVRO \
  --definition-file=schema.json
```

**Create topic with schema:**
```bash
gcloud pubsub topics create $TOPIC_NAME \
  --schema=my-schema \
  --message-encoding=JSON
```

### Dead Letter Queue Setup
```bash
# Create dead letter topic
gcloud pubsub topics create $TOPIC_NAME-dead-letter

# Create subscription with dead letter policy
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME \
  --topic=$TOPIC_NAME \
  --dead-letter-topic=$TOPIC_NAME-dead-letter \
  --max-delivery-attempts=5
```

### Message Filtering
```bash
# Create subscription with filter
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME-filtered \
  --topic=$TOPIC_NAME \
  --message-filter='attributes.environment="production"'
```

---

## 📊 Monitoring with CLI

### Get Metrics
```bash
# Get topic metrics
gcloud pubsub topics describe $TOPIC_NAME \
  --format="table(name,messageStoragePolicy.allowedPersistenceRegions)"

# Get subscription metrics  
gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME \
  --format="table(name,topic,ackDeadlineSeconds,messageRetentionDuration)"
```

---

## 🧹 Cleanup Commands

```bash
# Delete subscription
gcloud pubsub subscriptions delete $SUBSCRIPTION_NAME

# Delete topic
gcloud pubsub topics delete $TOPIC_NAME

# Delete schema (if created)
gcloud pubsub schemas delete my-schema
```

---

## 🎯 One-Liner Complete Solution

```bash
# Set your lab values
export TOPIC_NAME="your-topic-name"
export SUBSCRIPTION_NAME="your-subscription-name"

# Complete solution in one go
gcloud pubsub topics create $TOPIC_NAME && \
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME && \
gcloud pubsub topics publish $TOPIC_NAME --message="Hello Cloud Pub/Sub" && \
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

**Permission denied:**
```bash
# Check current project
gcloud config get-value project

# Set project if needed
gcloud config set project YOUR_PROJECT_ID
```

**Topic not found:**
```bash
# Verify topic exists
gcloud pubsub topics list --filter="name:$TOPIC_NAME"
```

**No messages to pull:**
```bash
# Check if messages were published
gcloud pubsub topics publish $TOPIC_NAME --message="Test message"
```

---

## ✅ Verification Script

```bash
#!/bin/bash
# Complete verification script

echo "🔍 Verifying Pub/Sub setup..."

# Check topic
if gcloud pubsub topics describe $TOPIC_NAME &>/dev/null; then
    echo "✅ Topic '$TOPIC_NAME' exists"
else
    echo "❌ Topic '$TOPIC_NAME' not found"
fi

# Check subscription
if gcloud pubsub subscriptions describe $SUBSCRIPTION_NAME &>/dev/null; then
    echo "✅ Subscription '$SUBSCRIPTION_NAME' exists"
else
    echo "❌ Subscription '$SUBSCRIPTION_NAME' not found"
fi

# Test message flow
gcloud pubsub topics publish $TOPIC_NAME --message="Test message"
MESSAGE_COUNT=$(gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1 2>/dev/null | wc -l)

if [ $MESSAGE_COUNT -gt 1 ]; then
    echo "✅ Message flow working"
else
    echo "❌ Message flow not working"
fi

echo "🎉 Verification complete!"
```

---

## 🔗 Related CLI References

- [gcloud pubsub topics](https://cloud.google.com/sdk/gcloud/reference/pubsub/topics)
- [gcloud pubsub subscriptions](https://cloud.google.com/sdk/gcloud/reference/pubsub/subscriptions)
- [gcloud pubsub schemas](https://cloud.google.com/sdk/gcloud/reference/pubsub/schemas)

---

**🎉 Congratulations! You've completed the Pub/Sub Challenge Lab using CLI commands!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
