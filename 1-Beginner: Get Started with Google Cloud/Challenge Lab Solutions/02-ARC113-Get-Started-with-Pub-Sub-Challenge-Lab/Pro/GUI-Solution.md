# Get Started with Pub/Sub: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![GUI Method](https://img.shields.io/badge/Method-GUI-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC113 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🖱️ GUI Method - Step by Step Instructions

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Topic Name**: (specified in your lab)
- **Subscription Name**: (specified in your lab)
- **Region**: (usually us-central1)

---

## 🚀 Task 1: Create Pub/Sub Topic

### Step-by-Step GUI Instructions:

1. **Navigate to Pub/Sub**
   - In the Google Cloud Console navigation menu
   - Click **☰** → **Pub/Sub** → **Topics**

2. **Create Topic**
   - Click **CREATE TOPIC** button
   - **Topic ID**: Enter the topic name specified in your lab
   - **Add a default subscription**: ✅ Check this option
   - Click **CREATE TOPIC**

3. **Verify Creation**
   - Topic should appear in the topics list
   - Status should show as "Active"

---

## 🚀 Task 2: Create Pub/Sub Subscription

### Step-by-Step GUI Instructions:

1. **Navigate to Subscriptions**
   - Click **Pub/Sub** → **Subscriptions**
   - Or from the topic page, click **CREATE SUBSCRIPTION**

2. **Configure Subscription**
   - **Subscription ID**: Enter the subscription name from your lab
   - **Select a Cloud Pub/Sub topic**: Choose the topic created in Task 1
   - **Delivery Type**: Select **Pull**
   - **Message retention duration**: Leave default (7 days)
   - **Expiration policy**: Leave default (Never expire)

3. **Advanced Settings** (Optional)
   - **Acknowledgment deadline**: 10 seconds (default)
   - **Message ordering**: Disabled (default)
   - **Dead lettering**: Disabled (default)

4. **Create Subscription**
   - Click **CREATE** button
   - Verify subscription appears in the list

---

## 🚀 Task 3: Publish and Pull Messages

### Publish a Message (GUI Method):

1. **Navigate to Topic**
   - Go to **Pub/Sub** → **Topics**
   - Click on your topic name

2. **Publish Message**
   - Click **PUBLISH MESSAGE** button
   - **Message body**: Enter "Hello Cloud Pub/Sub" or your custom message
   - **Attributes** (Optional): Leave empty for basic test
   - Click **PUBLISH**

3. **Verify Publication**
   - You should see a success notification
   - Message count should increase in metrics

### Pull Message (GUI Method):

1. **Navigate to Subscription**
   - Go to **Pub/Sub** → **Subscriptions**
   - Click on your subscription name

2. **Pull Messages**
   - Click **PULL** button in the Messages tab
   - Select **Enable ack messages** if you want to acknowledge automatically
   - Click **PULL**

3. **View Messages**
   - Messages will appear in the table
   - You can see Message ID, Data, Attributes, and Publish time
   - Click **ACK** to acknowledge messages if not auto-enabled

---

## 🔍 Verification Steps

### Check Topic Status:
1. Go to **Pub/Sub** → **Topics**
2. Verify your topic is listed and active
3. Check message count in metrics

### Check Subscription Status:
1. Go to **Pub/Sub** → **Subscriptions**
2. Verify subscription is listed and active
3. Check unacknowledged message count

### Test Message Flow:
1. Publish a test message from topic page
2. Pull message from subscription page
3. Verify message content matches

---

## 📊 Monitoring and Metrics

### View Topic Metrics:
1. Click on your topic name
2. Go to **METRICS** tab
3. Monitor:
   - **Publish requests**
   - **Published messages**
   - **Published bytes**

### View Subscription Metrics:
1. Click on your subscription name
2. Go to **METRICS** tab
3. Monitor:
   - **Pull requests**
   - **Unacknowledged messages**
   - **Oldest unacknowledged message age**

---

## 🎯 Pro Tips for GUI Method

- **Use browser bookmarks** for quick navigation to Pub/Sub sections
- **Keep multiple tabs open** for topics and subscriptions
- **Use browser refresh** if metrics don't update immediately
- **Check notification center** for operation status updates
- **Use search bar** to quickly find your resources

---

## ✅ Completion Checklist

- [ ] Topic created with correct name
- [ ] Subscription created with correct name
- [ ] Message published successfully
- [ ] Message pulled and acknowledged
- [ ] All metrics showing activity

---

## 🔗 Related Resources

- [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Best Practices](https://cloud.google.com/pubsub/docs/best-practices)
- [Monitoring Guide](https://cloud.google.com/pubsub/docs/monitoring)

---

**🎉 Congratulations! You've completed the Pub/Sub Challenge Lab using the GUI method!**

*For other solution methods, check out:*
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
