# Get Started with Pub/Sub: Challenge Lab - Quick Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Quick Solution](https://img.shields.io/badge/Quick-Solution-success?style=for-the-badge)

**Lab ID**: ARC113 | **Duration**: 45-60 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚠️ IMPORTANT: Lab Variations

This challenge lab has **3 different forms**. Check your lab interface for specific task names and values!

### 🔍 **Identify Your Lab Form First:**

**Form 1**: Basic Pub/Sub + Cloud Scheduler  
**Form 2**: Schema-based Pub/Sub + Cloud Functions  
**Form 3**: Message Management + Snapshots  

---

## 🚀 Universal Setup (All Forms)

```bash
# Set up environment variables (adjust values based on your lab)
export PROJECT_ID=$(gcloud config get-value project)
export REGION=$(gcloud config get-value compute/region)

# Enable required APIs
gcloud services enable pubsub.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable cloudfunctions.googleapis.com

echo "✅ Environment setup complete!"
```

---

## 📋 **FORM 1: Basic Pub/Sub + Cloud Scheduler**

### Task 1: Set up Cloud Pub/Sub

```bash
# Replace with your lab's topic name
TOPIC_NAME="[YOUR_TOPIC_NAME]"
SUBSCRIPTION_NAME="[YOUR_SUBSCRIPTION_NAME]"

# Create Pub/Sub topic
gcloud pubsub topics create $TOPIC_NAME
echo "✅ Topic created: $TOPIC_NAME"

# Create subscription
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME
echo "✅ Subscription created: $SUBSCRIPTION_NAME"

# Verify topic creation
gcloud pubsub topics list
```

### Task 2: Create a Cloud Scheduler job

```bash
# Replace with your lab's scheduler job name
JOB_NAME="[YOUR_JOB_NAME]"

# Create Cloud Scheduler job that publishes to Pub/Sub topic
gcloud scheduler jobs create pubsub $JOB_NAME \
    --schedule="*/2 * * * *" \
    --topic=$TOPIC_NAME \
    --message-body="Hello from Cloud Scheduler!" \
    --time-zone="UTC"

echo "✅ Cloud Scheduler job created: $JOB_NAME"

# Run the job immediately for testing
gcloud scheduler jobs run $JOB_NAME
```

### Task 3: Verify the results in Cloud Pub/Sub

```bash
# Pull messages from subscription to verify
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=5

# Check job status
gcloud scheduler jobs describe $JOB_NAME

echo "✅ Form 1 completed successfully!"
```

---

## 📋 **FORM 2: Schema-based Pub/Sub + Cloud Functions**

### Task 1: Create Pub/Sub schema

```bash
# Replace with your lab's schema name
SCHEMA_NAME="[YOUR_SCHEMA_NAME]"

# Create schema definition file
cat > schema.json << 'EOF'
{
  "type": "record",
  "name": "MessageRecord",
  "fields": [
    {"name": "message", "type": "string"},
    {"name": "timestamp", "type": "long"},
    {"name": "source", "type": "string"}
  ]
}
EOF

# Create the schema
gcloud pubsub schemas create $SCHEMA_NAME \
    --type=AVRO \
    --definition-file=schema.json

echo "✅ Schema created: $SCHEMA_NAME"

# Verify schema creation
gcloud pubsub schemas list
```

### Task 2: Create Pub/Sub topic using schema

```bash
# Replace with your lab's topic name
SCHEMA_TOPIC_NAME="[YOUR_SCHEMA_TOPIC_NAME]"

# Create topic with schema
gcloud pubsub topics create $SCHEMA_TOPIC_NAME \
    --schema=$SCHEMA_NAME \
    --message-encoding=JSON

echo "✅ Schema-based topic created: $SCHEMA_TOPIC_NAME"

# Create subscription for the schema topic
gcloud pubsub subscriptions create ${SCHEMA_TOPIC_NAME}-sub \
    --topic=$SCHEMA_TOPIC_NAME
```

### Task 3: Create a trigger cloud function with Pub/Sub topic

```bash
# Replace with your lab's function name
FUNCTION_NAME="[YOUR_FUNCTION_NAME]"

# Create function source code
mkdir -p /tmp/pubsub-function
cd /tmp/pubsub-function

cat > main.py << 'EOF'
import base64
import json
import logging

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic."""
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    
    logging.info(f'This Function was triggered by messageId {context.eventId} published at {context.timestamp}')
    logging.info(f'Message: {pubsub_message}')
    
    try:
        message_json = json.loads(pubsub_message)
        logging.info(f'Processed message: {message_json}')
    except json.JSONDecodeError:
        logging.info(f'Message is not JSON: {pubsub_message}')
    
    return 'OK'
EOF

cat > requirements.txt << 'EOF'
functions-framework==3.*
EOF

# Deploy the function
gcloud functions deploy $FUNCTION_NAME \
    --runtime python39 \
    --trigger-topic $SCHEMA_TOPIC_NAME \
    --entry-point hello_pubsub \
    --region $REGION

echo "✅ Cloud Function created: $FUNCTION_NAME"

# Test the function by publishing a message
gcloud pubsub topics publish $SCHEMA_TOPIC_NAME \
    --message='{"message": "Hello from schema topic!", "timestamp": 1234567890, "source": "test"}'

echo "✅ Form 2 completed successfully!"
```

---

## 📋 **FORM 3: Message Management + Snapshots**

### Task 1: Publish a message to the topic

```bash
# Use existing topic or create new one
MESSAGE_TOPIC="[YOUR_MESSAGE_TOPIC_NAME]"
MESSAGE_SUBSCRIPTION="[YOUR_MESSAGE_SUBSCRIPTION_NAME]"

# Create topic if it doesn't exist
gcloud pubsub topics create $MESSAGE_TOPIC 2>/dev/null || echo "Topic already exists"

# Create subscription if it doesn't exist
gcloud pubsub subscriptions create $MESSAGE_SUBSCRIPTION --topic=$MESSAGE_TOPIC 2>/dev/null || echo "Subscription already exists"

# Publish multiple messages
gcloud pubsub topics publish $MESSAGE_TOPIC --message="First message from CodeWithGarry"
gcloud pubsub topics publish $MESSAGE_TOPIC --message="Second message with timestamp: $(date)"
gcloud pubsub topics publish $MESSAGE_TOPIC --message="Third message with JSON data" --attribute="type=json,source=test"

echo "✅ Messages published to topic: $MESSAGE_TOPIC"
```

### Task 2: View the message

```bash
# Pull messages without acknowledging (peek)
echo "📥 Pulling messages from subscription:"
gcloud pubsub subscriptions pull $MESSAGE_SUBSCRIPTION --limit=5

# Pull and acknowledge messages
echo "📥 Pulling and acknowledging messages:"
gcloud pubsub subscriptions pull $MESSAGE_SUBSCRIPTION --auto-ack --limit=3

echo "✅ Messages viewed and processed"
```

### Task 3: Create a Pub/Sub Snapshot for Pub/Sub topic

```bash
# Replace with your lab's snapshot name
SNAPSHOT_NAME="[YOUR_SNAPSHOT_NAME]"

# Create snapshot
gcloud pubsub snapshots create $SNAPSHOT_NAME \
    --subscription=$MESSAGE_SUBSCRIPTION

echo "✅ Snapshot created: $SNAPSHOT_NAME"

# Verify snapshot creation
gcloud pubsub snapshots list

# Optional: Seek to snapshot (restores subscription to snapshot state)
# gcloud pubsub subscriptions seek $MESSAGE_SUBSCRIPTION --snapshot=$SNAPSHOT_NAME

echo "✅ Form 3 completed successfully!"
```

---

## 🔧 **Universal Verification Commands**

```bash
# Check all topics
echo "📋 All Pub/Sub Topics:"
gcloud pubsub topics list

# Check all subscriptions
echo "📋 All Pub/Sub Subscriptions:"
gcloud pubsub subscriptions list

# Check all schemas (if created)
echo "📋 All Pub/Sub Schemas:"
gcloud pubsub schemas list

# Check all snapshots (if created)
echo "📋 All Pub/Sub Snapshots:"
gcloud pubsub snapshots list

# Check Cloud Scheduler jobs (if created)
echo "📋 All Cloud Scheduler Jobs:"
gcloud scheduler jobs list

# Check Cloud Functions (if created)
echo "📋 All Cloud Functions:"
gcloud functions list
```

---

## 🎯 **One-Click Complete Script**

If you want to run all tasks for your specific form, use this template:

```bash
#!/bin/bash
# Complete Pub/Sub Challenge Lab Script
# Replace values with your lab-specific names

set -e  # Exit on any error

# Configuration - REPLACE WITH YOUR LAB VALUES
PROJECT_ID=$(gcloud config get-value project)
REGION=$(gcloud config get-value compute/region)

# Form 1 variables
TOPIC_NAME="my-topic"
SUBSCRIPTION_NAME="my-subscription"
JOB_NAME="my-scheduler-job"

# Form 2 variables  
SCHEMA_NAME="my-schema"
SCHEMA_TOPIC_NAME="my-schema-topic"
FUNCTION_NAME="my-pubsub-function"

# Form 3 variables
MESSAGE_TOPIC="my-message-topic"
MESSAGE_SUBSCRIPTION="my-message-subscription"
SNAPSHOT_NAME="my-snapshot"

echo "🚀 Starting Pub/Sub Challenge Lab automation..."

# Enable APIs
gcloud services enable pubsub.googleapis.com cloudscheduler.googleapis.com cloudfunctions.googleapis.com

# Execute based on your lab form
read -p "Which form are you completing? (1/2/3): " FORM_NUMBER

case $FORM_NUMBER in
    1)
        echo "📋 Executing Form 1: Basic Pub/Sub + Cloud Scheduler"
        # Insert Form 1 commands here
        ;;
    2)
        echo "📋 Executing Form 2: Schema-based Pub/Sub + Cloud Functions"
        # Insert Form 2 commands here
        ;;
    3)
        echo "📋 Executing Form 3: Message Management + Snapshots"
        # Insert Form 3 commands here
        ;;
    *)
        echo "❌ Invalid form number. Please run again and select 1, 2, or 3."
        exit 1
        ;;
esac

echo "🎉 Lab completed successfully!"
```

---

## ⚠️ **Security & Best Practices**

### ✅ **Why This Solution is Better:**

1. **🔒 Security**: No external script downloads
2. **📚 Educational**: Learn each command and concept
3. **🎯 Adaptable**: Works with all lab variations
4. **🛡️ Safe**: All commands are verified and explained
5. **🔍 Transparent**: You can see exactly what each command does

### ❌ **Why External Scripts are Risky:**

1. **🚨 Security Risk**: Unknown code execution
2. **📉 Dependency**: External sources can be unavailable
3. **🎭 Not Educational**: Doesn't help you learn
4. **⚠️ Unpredictable**: Scripts may not match your lab variation

---

## 🔧 **Troubleshooting**

### Common Issues:

**Issue**: API not enabled
```bash
gcloud services enable pubsub.googleapis.com
```

**Issue**: Permission denied
```bash
# Check your IAM roles
gcloud projects get-iam-policy $PROJECT_ID
```

**Issue**: Topic already exists
```bash
# List existing topics
gcloud pubsub topics list
```

**Issue**: No messages in subscription
```bash
# Check if messages are published
gcloud pubsub topics publish TOPIC_NAME --message="test"
```

---

## 🎯 **Pro Tips**

1. **📝 Always check your lab instructions** for exact names and requirements
2. **🔄 Replace placeholder values** with actual lab values
3. **✅ Verify each step** before proceeding to the next
4. **🧹 Clean up resources** after lab completion
5. **📚 Understand each command** rather than just copying

---

<div align="center">

**🎉 Congratulations! You've completed the Pub/Sub Challenge Lab!**

*Solution provided by [CodeWithGarry](https://github.com/codewithgarry) - Your trusted Google Cloud learning partner*

**Next Lab**: [API Gateway Challenge Lab](../03-ARC109-Getting-Started-with-API-Gateway-Challenge-Lab/)

</div>
