# ARC113: Get Started with Pub/Sub - Challenge Lab Specific Solution

## 🎯 Lab Overview

**Challenge Lab ID:** ARC113  
**Title:** Get Started with Pub/Sub  
**Duration:** 30 minutes  
**Difficulty:** Beginner  
**Credits:** 1  

## 📋 Lab Tasks Breakdown

### Task 1: Create a Topic
**Objective:** Create a Pub/Sub topic with the specified name  
**Points:** 20  
**Typical Values:**
- `myTopic`
- `test-topic`  
- `topic1`

### Task 2: Create a Subscription
**Objective:** Create a subscription to the topic created in Task 1  
**Points:** 20  
**Typical Values:**
- `mySubscription`
- `test-subscription`
- `subscription1`

### Task 3: Publish a Message
**Objective:** Publish a message to the topic  
**Points:** 20  
**Typical Values:**
- `"Hello World"`
- `"Test message"`
- `"My first message"`

### Task 4: View the Message
**Objective:** Pull and view the published message from subscription  
**Points:** 20  

### Task 5: Create a Snapshot
**Objective:** Create a snapshot from the subscription  
**Points:** 20  
**Typical Names:**
- `snapshot-1`
- `my-snapshot`
- `test-snapshot`

## 🔧 Step-by-Step Solution

### Method 1: Manual Step-by-Step

#### Step 1: Create Topic
```bash
# Replace with your actual topic name from the lab
gcloud pubsub topics create [TOPIC_NAME]
```

#### Step 2: Create Subscription  
```bash
# Replace with your actual subscription name from the lab
gcloud pubsub subscriptions create [SUBSCRIPTION_NAME] --topic=[TOPIC_NAME]
```

#### Step 3: Publish Message
```bash
# Replace with your actual message from the lab
gcloud pubsub topics publish [TOPIC_NAME] --message="[MESSAGE_CONTENT]"
```

#### Step 4: Pull Message
```bash
# Pull and acknowledge the message
gcloud pubsub subscriptions pull [SUBSCRIPTION_NAME] --auto-ack --limit=1
```

#### Step 5: Create Snapshot
```bash
# Create snapshot from subscription
gcloud pubsub snapshots create snapshot-1 --subscription=[SUBSCRIPTION_NAME]
```

### Method 2: Variable-Based Approach

```bash
# Set your lab-specific values
export TOPIC_NAME="your-topic-name"
export SUBSCRIPTION_NAME="your-subscription-name"  
export MESSAGE="your-message-content"

# Execute commands
gcloud pubsub topics create $TOPIC_NAME
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME
gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE"
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack --limit=1
gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
```

## 🎮 Lab Variations & Forms

### Form A (Basic):
```bash
export TOPIC_NAME="myTopic"
export SUBSCRIPTION_NAME="mySubscription"
export MESSAGE="Hello World"
```

### Form B (Test):
```bash
export TOPIC_NAME="test-topic"
export SUBSCRIPTION_NAME="test-subscription"
export MESSAGE="Test message"
```

### Form C (Numbered):
```bash
export TOPIC_NAME="topic1"
export SUBSCRIPTION_NAME="subscription1"  
export MESSAGE="My first message"
```

### Form D (Schema-based):
```bash
export TOPIC_NAME="schema-topic"
export SUBSCRIPTION_NAME="schema-subscription"
export MESSAGE="Schema test message"
```

## 🔍 Verification Steps

After each task, verify completion:

### Verify Topic Creation:
```bash
gcloud pubsub topics list
# Should show your topic in the list
```

### Verify Subscription Creation:
```bash
gcloud pubsub subscriptions list
# Should show your subscription in the list
```

### Verify Message Publishing:
```bash
gcloud pubsub topics list-subscriptions [TOPIC_NAME]
# Should show your subscription attached to the topic
```

### Verify Message Pulling:
```bash
# The pull command itself shows the message content
# You should see your published message
```

### Verify Snapshot Creation:
```bash
gcloud pubsub snapshots list
# Should show snapshot-1 in the list
```

## 🚨 Common Issues & Solutions

### Issue 1: Topic Already Exists
```
ERROR: Topic already exists: projects/[PROJECT]/topics/[TOPIC]
```
**Solution:** Continue with next step, this is normal in retries

### Issue 2: Subscription Already Exists  
```
ERROR: Subscription already exists: projects/[PROJECT]/subscriptions/[SUBSCRIPTION]
```
**Solution:** Continue with next step, this is normal in retries

### Issue 3: No Messages Available
```
Listed 0 items.
```
**Solution:** 
- Ensure message was published successfully
- Try pulling again with higher limit
- Check if subscription is correctly attached to topic

### Issue 4: Permission Denied
```
ERROR: (gcloud.pubsub.topics.create) User does not have permission
```
**Solution:**
```bash
gcloud auth login
gcloud config set project [YOUR_PROJECT_ID]
```

### Issue 5: API Not Enabled
```
ERROR: API [pubsub.googleapis.com] not enabled
```
**Solution:**
```bash
gcloud services enable pubsub.googleapis.com
```

## 📊 Progress Tracking

Track your completion:

- [ ] Task 1: Topic created
- [ ] Task 2: Subscription created  
- [ ] Task 3: Message published
- [ ] Task 4: Message viewed
- [ ] Task 5: Snapshot created

## ⏱️ Time Management

**Recommended Timeline:**
- Setup: 2 minutes
- Task 1: 3 minutes  
- Task 2: 3 minutes
- Task 3: 3 minutes
- Task 4: 3 minutes
- Task 5: 3 minutes
- Verification: 3 minutes
- **Buffer:** 10 minutes

## 🎯 Success Criteria

Lab completion requires:
1. ✅ Topic exists and is accessible
2. ✅ Subscription exists and is linked to topic
3. ✅ Message published successfully  
4. ✅ Message retrieved from subscription
5. ✅ Snapshot created from subscription

## 📚 Additional Commands

### List All Resources:
```bash
echo "=== Topics ==="
gcloud pubsub topics list

echo "=== Subscriptions ==="  
gcloud pubsub subscriptions list

echo "=== Snapshots ==="
gcloud pubsub snapshots list
```

### Cleanup (if needed):
```bash
# Delete snapshot
gcloud pubsub snapshots delete snapshot-1

# Delete subscription
gcloud pubsub subscriptions delete [SUBSCRIPTION_NAME]

# Delete topic  
gcloud pubsub topics delete [TOPIC_NAME]
```

---

**💡 Pro Tips:**
- Always copy values exactly from your lab interface
- Use the Cloud Shell for consistent environment
- Verify each step before proceeding to the next
- Keep the lab timer visible to manage time effectively
