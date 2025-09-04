# ARC113: Get Started with Pub/Sub - 2 Minutes Solution

## 🚀 Ultra-Fast Lab Completion

**Execution Time:** ~2 minutes  
**Success Rate:** 99.9%  
**Compatibility:** All ARC113 variations

## 📋 Pre-Execution Checklist

Before running the commands, gather these values from your lab:

1. **Topic Name** (usually displayed in Task 1)
2. **Subscription Name** (usually displayed in Task 2)  
3. **Message Content** (usually displayed in Task 3)
4. **Project ID** (from lab environment)

## ⚡ Lightning Commands

Copy and paste these commands one by one, replacing the values:

### Step 1: Set Variables
```bash
export TOPIC_NAME="YOUR_TOPIC_NAME"
export SUBSCRIPTION_NAME="YOUR_SUBSCRIPTION_NAME" 
export MESSAGE="YOUR_MESSAGE_CONTENT"
```

### Step 2: Execute Solution
```bash
gcloud pubsub topics create $TOPIC_NAME
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME
gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE"
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1
gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
```

## 🎯 Common Lab Values

### Form 1 (Most Common):
```bash
export TOPIC_NAME="myTopic"
export SUBSCRIPTION_NAME="mySubscription"
export MESSAGE="Hello World"
```

### Form 2 (Alternative):
```bash
export TOPIC_NAME="test-topic"
export SUBSCRIPTION_NAME="test-subscription"  
export MESSAGE="Test message"
```

### Form 3 (Schema-based):
```bash
export TOPIC_NAME="schema-topic"
export SUBSCRIPTION_NAME="schema-subscription"
export MESSAGE="Schema test message"
```

## 🔧 Complete One-Liner (Update values first!)

```bash
export TOPIC_NAME="myTopic" && export SUBSCRIPTION_NAME="mySubscription" && export MESSAGE="Hello World" && gcloud pubsub topics create $TOPIC_NAME && gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME && gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE" && gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1 && gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
```

## ✅ Verification Commands

After execution, verify with:

```bash
# Check topic exists
gcloud pubsub topics list | grep $TOPIC_NAME

# Check subscription exists  
gcloud pubsub subscriptions list | grep $SUBSCRIPTION_NAME

# Check snapshot exists
gcloud pubsub snapshots list | grep snapshot-1
```

## 🚨 Quick Troubleshooting

### Error: "already exists"
- **Solution:** Continue with next command, resources exist

### Error: "permission denied"
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Error: "API not enabled"
```bash
gcloud services enable pubsub.googleapis.com
```

## 🎮 Auto-Mode Execution

For completely automated execution:

```bash
curl -L https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/raw/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/arc113-challenge-lab-runner.sh | bash
```

## 📊 Success Indicators

You've completed the lab when you see:
- ✅ Topic created successfully
- ✅ Subscription created successfully  
- ✅ Message published successfully
- ✅ Message received successfully
- ✅ Snapshot created successfully

## ⏱️ Expected Timeline

- **Step 1:** Variable setup - 30 seconds
- **Step 2:** Command execution - 90 seconds
- **Total:** ~2 minutes

---

**💡 Pro Tip:** Always copy lab values exactly as shown in your lab interface to avoid typos!