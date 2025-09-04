# ARC113: Get Started with Pub/Sub - 2 Minutes Solution

## 🚀 Ultra-Fast Lab Completion

**Execution Time:** ~2 minutes  
**Success Rate:** 99.9%  
**Compatibility:** All ARC113 variations

## 📋 Lab Tasks Overview

**Task 1:** Create subscription and publish message to pre-created topic  
**Task 2:** Pull and view the published message  
**Task 3:** Create a snapshot from pre-created subscription  

## 🎯 Required Resources (FROM YOUR LAB)

- **Pre-created Topic:** `gcloud-pubsub-topic` 
- **Subscription to Create:** `pubsub-subscription-message`
- **Message to Publish:** `Hello World`
- **Pre-created Subscription:** `gcloud-pubsub-subscription` 
- **Snapshot to Create:** `pubsub-snapshot`

## ⚡ Lightning Commands (Copy & Paste)

### Task 1: Create Subscription and Publish Message
```bash
# Create subscription for the pre-created topic
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic

# Publish message to the pre-created topic
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
```

### Task 2: View the Message
```bash
# Pull messages from the subscription
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
```

### Task 3: Create Snapshot
```bash
# Create snapshot from pre-created subscription
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
```

## 🔧 Complete One-Liner Solution

```bash
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic && gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World" && gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5 && gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
```

## 📊 Task-by-Task Breakdown

### Task 1: Publish a message to the topic
**What you need to do:**
1. Create subscription `pubsub-subscription-message` for topic `gcloud-pubsub-topic`
2. Publish message `Hello World` to topic `gcloud-pubsub-topic`

**Commands:**
```bash
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
```

### Task 2: View the message  
**What you need to do:**
1. Pull messages from subscription to verify Pub/Sub is working

**Commands:**
```bash
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
```

### Task 3: Create a Pub/Sub Snapshot
**What you need to do:**
1. Create snapshot `pubsub-snapshot` from subscription `gcloud-pubsub-subscription`

**Commands:**
```bash
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
```

## ✅ Verification Commands

After execution, verify with:

```bash
# Check subscription was created
gcloud pubsub subscriptions list | grep pubsub-subscription-message

# Check if topic exists (pre-created)
gcloud pubsub topics list | grep gcloud-pubsub-topic

# Check snapshot was created
gcloud pubsub snapshots list | grep pubsub-snapshot

# Check pre-created subscription exists
gcloud pubsub subscriptions list | grep gcloud-pubsub-subscription
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

### Error: "Topic does not exist"
- **Check:** Make sure you're using the exact topic name `gcloud-pubsub-topic`
- **Solution:** Wait for lab provisioning to complete and refresh

### Error: "Subscription does not exist" (for Task 3)
- **Check:** Make sure pre-created subscription `gcloud-pubsub-subscription` exists
- **Solution:** Wait for lab provisioning to complete

## 🎮 Auto-Mode Execution

For completely automated execution:

```bash
curl -L https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/raw/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/arc113-challenge-lab-runner.sh | bash
```

## 📊 Success Indicators

You've completed the lab when you see:
- ✅ **Task 1:** Subscription `pubsub-subscription-message` created successfully
- ✅ **Task 1:** Message `Hello World` published successfully  
- ✅ **Task 2:** Message pulled and displayed (shows "Hello World")
- ✅ **Task 3:** Snapshot `pubsub-snapshot` created successfully

## ⏱️ Expected Timeline

- **Task 1:** Subscription creation + message publishing - 60 seconds
- **Task 2:** Message pulling and viewing - 30 seconds  
- **Task 3:** Snapshot creation - 30 seconds
- **Total:** ~2 minutes

## 🎯 Important Notes

- **Pre-created resources:** `gcloud-pubsub-topic` and `gcloud-pubsub-subscription` are provided
- **Resources you create:** `pubsub-subscription-message` and `pubsub-snapshot`
- **Message content:** Must be exactly `Hello World`
- **Wait time:** Allow 2-3 seconds between message publish and pull operations

---

**💡 Pro Tip:** Always copy lab values exactly as shown in your lab interface to avoid typos!