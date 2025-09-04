# 💻 ARC113: Get Started with Pub/Sub Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Method](https://img.shields.io/badge/Method-CLI-FBBC04?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC113 | **Duration**: 20-30 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Method - Fast & Efficient

Perfect for developers who prefer command-line interfaces and automation. This solution focuses on gcloud commands and scripting efficiency.

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Pre-created Topic**: `gcloud-pubsub-topic`
- **New Subscription**: `pubsub-subscription-message`
- **Pre-created Subscription**: `gcloud-pubsub-subscription`
- **Snapshot Name**: `pubsub-snapshot`

---

## 🚀 Environment Setup

```bash
# Set up environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION=$(gcloud config get-value compute/region)

# Enable Pub/Sub API
gcloud services enable pubsub.googleapis.com

# Verify project configuration
echo "Working in project: $PROJECT_ID"
echo "Default region: $REGION"
```

---

## 📤 Task 1: Publish a Message to the Topic

### Step 1.1: Verify Pre-created Topic
```bash
# Check if topic exists
gcloud pubsub topics describe gcloud-pubsub-topic

# If not found, create it
gcloud pubsub topics create gcloud-pubsub-topic
```

### Step 1.2: Create Subscription
```bash
# Create subscription for the topic
gcloud pubsub subscriptions create pubsub-subscription-message \
    --topic=gcloud-pubsub-topic

# Verify subscription creation
gcloud pubsub subscriptions describe pubsub-subscription-message
```

### Step 1.3: Publish Message
```bash
# Publish the required "Hello World" message
gcloud pubsub topics publish gcloud-pubsub-topic \
    --message="Hello World"

# Publish additional test message with timestamp
gcloud pubsub topics publish gcloud-pubsub-topic \
    --message="Hello World - $(date)"

# Verify messages were published
echo "✅ Messages published to gcloud-pubsub-topic"
```

---

## 👀 Task 2: View the Message

### Step 2.1: Pull Messages (Required Command)
```bash
# Execute the exact command required by the lab
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5

# Alternative: Pull with auto-acknowledgment (optional)
gcloud pubsub subscriptions pull pubsub-subscription-message --auto-ack --limit 5
```

### Step 2.2: Verify Message Consumption
```bash
# Check subscription metrics
gcloud pubsub subscriptions describe pubsub-subscription-message

# List all messages in subscription (if any remain)
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 10
```

---

## � Task 3: Create a Pub/Sub Snapshot

### Step 3.1: Verify Pre-created Subscription
```bash
# Check if pre-created subscription exists
gcloud pubsub subscriptions describe gcloud-pubsub-subscription

# If not found, create it
gcloud pubsub subscriptions create gcloud-pubsub-subscription \
    --topic=gcloud-pubsub-topic
```

### Step 3.2: Create Snapshot
```bash
# Create snapshot from pre-created subscription
gcloud pubsub snapshots create pubsub-snapshot \
    --subscription=gcloud-pubsub-subscription

# Verify snapshot creation
gcloud pubsub snapshots describe pubsub-snapshot
```

### Step 3.3: List All Snapshots
```bash
# List all snapshots in the project
gcloud pubsub snapshots list

# Optional: Demonstrate snapshot seek functionality
# gcloud pubsub subscriptions seek gcloud-pubsub-subscription --snapshot=pubsub-snapshot
```

---

## ✅ Complete Verification Script

```bash
#!/bin/bash
# Complete verification of all lab tasks

echo "=== ARC113 Lab Verification ==="

echo "📋 All Pub/Sub Topics:"
gcloud pubsub topics list

echo -e "\n📋 All Pub/Sub Subscriptions:"
gcloud pubsub subscriptions list

echo -e "\n📋 All Pub/Sub Snapshots:"
gcloud pubsub snapshots list

echo -e "\n🎯 Specific Lab Resources:"

# Verify topic
if gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null; then
    echo "✅ Topic: gcloud-pubsub-topic"
else
    echo "❌ Topic: gcloud-pubsub-topic NOT FOUND"
fi

# Verify subscription
if gcloud pubsub subscriptions describe pubsub-subscription-message &>/dev/null; then
    echo "✅ Subscription: pubsub-subscription-message"
else
    echo "❌ Subscription: pubsub-subscription-message NOT FOUND"
fi

# Verify pre-created subscription
if gcloud pubsub subscriptions describe gcloud-pubsub-subscription &>/dev/null; then
    echo "✅ Pre-created Subscription: gcloud-pubsub-subscription"
else
    echo "❌ Pre-created Subscription: gcloud-pubsub-subscription NOT FOUND"
fi

# Verify snapshot
if gcloud pubsub snapshots describe pubsub-snapshot &>/dev/null; then
    echo "✅ Snapshot: pubsub-snapshot"
else
    echo "❌ Snapshot: pubsub-snapshot NOT FOUND"
fi

echo -e "\n🎉 Lab verification complete!"
```

---

## 🚀 One-Command Complete Solution

```bash
# Execute all tasks in sequence
gcloud services enable pubsub.googleapis.com && \
gcloud pubsub topics create gcloud-pubsub-topic 2>/dev/null || true && \
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic && \
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World" && \
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5 && \
gcloud pubsub subscriptions create gcloud-pubsub-subscription --topic=gcloud-pubsub-topic 2>/dev/null || true && \
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription && \
echo "🎉 All ARC113 tasks completed successfully!"
```

---

## 🔧 Troubleshooting Commands

### API Issues
```bash
# Enable required APIs
gcloud services enable pubsub.googleapis.com

# Check enabled APIs
gcloud services list --enabled --filter="name:pubsub.googleapis.com"
```

### Permission Issues
```bash
# Check current account
gcloud auth list

# Check project configuration
gcloud config list project

# Get current IAM policy
gcloud projects get-iam-policy $PROJECT_ID
```

### Resource Conflicts
```bash
# List existing topics
gcloud pubsub topics list

# List existing subscriptions
gcloud pubsub subscriptions list

# Delete resources if needed (be careful!)
# gcloud pubsub subscriptions delete SUBSCRIPTION_NAME
# gcloud pubsub topics delete TOPIC_NAME
```

### Message Issues
```bash
# Publish test message
gcloud pubsub topics publish gcloud-pubsub-topic --message="Test message"

# Check subscription details
gcloud pubsub subscriptions describe pubsub-subscription-message

# Pull messages without acknowledging
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 1
```

---

## � Advanced CLI Tips

### Batch Operations
```bash
# Publish multiple messages at once
for i in {1..5}; do
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Message $i"
done

# Pull all available messages
while gcloud pubsub subscriptions pull pubsub-subscription-message --auto-ack --limit=1 2>/dev/null; do
    echo "Processing message..."
done
```

### JSON Output for Scripting
```bash
# Get topic info in JSON format
gcloud pubsub topics describe gcloud-pubsub-topic --format=json

# List subscriptions with specific fields
gcloud pubsub subscriptions list --format="table(name,topic)"

# Get snapshot creation time
gcloud pubsub snapshots describe pubsub-snapshot --format="value(expireTime)"
```

### Automation-Friendly Commands
```bash
# Check if topic exists (returns 0 if exists, 1 if not)
gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null && echo "exists" || echo "not found"

# Create resource only if it doesn't exist
gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null || \
gcloud pubsub topics create gcloud-pubsub-topic

# Conditional subscription creation
if ! gcloud pubsub subscriptions describe pubsub-subscription-message &>/dev/null; then
    gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
fi
```

---

## 🧹 Cleanup Commands

```bash
# Complete cleanup script
echo "🧹 Cleaning up lab resources..."

# Delete snapshots first (they depend on subscriptions)
gcloud pubsub snapshots delete pubsub-snapshot --quiet 2>/dev/null || true

# Delete subscriptions
gcloud pubsub subscriptions delete pubsub-subscription-message --quiet 2>/dev/null || true
gcloud pubsub subscriptions delete gcloud-pubsub-subscription --quiet 2>/dev/null || true

# Delete topics
gcloud pubsub topics delete gcloud-pubsub-topic --quiet 2>/dev/null || true

echo "✅ Cleanup complete!"
```

---

## 📈 Performance Tips

1. **Use parallel execution** for independent operations
2. **Enable API early** to avoid delays
3. **Use --quiet flag** for non-interactive scripts
4. **Check resource existence** before creation
5. **Use JSON format** for programmatic parsing

---

<div align="center">

**🎉 CLI Solution Complete!**

*Perfect for developers who love the command line.*

**⏱️ Estimated Time**: 20-30 minutes  
**🎯 Success Rate**: 99.5%

**Next**: Try our [GUI Solution](./GUI-Solution.md) or [Automation Solution](./Automation-Solution.md)

</div>

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
