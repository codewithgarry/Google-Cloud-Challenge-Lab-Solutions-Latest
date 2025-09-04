# ⚡ ARC113: Get Started with Pub/Sub Challenge Lab - 2 Minute Solution

<div align="center">

## 🚀 **Speed Solution for Experts** 🚀
*Complete the lab in under 3 minutes*

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Duration](https://img.shields.io/badge/Duration-2--3%20min-red?style=for-the-badge)
![Expert](https://img.shields.io/badge/Level-Expert-purple?style=for-the-badge)

</div>

---

<div align="center">

## 👨‍💻 **By CodeWithGarry**

[![YouTube](https://img.shields.io/badge/YouTube-codewithgarry-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)

</div>

---

## ⚡ **Quick Copy-Paste Commands**

### **🎯 Task 1: Publish a Message to the Topic**

```bash
# Create subscription for the pre-created topic
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic

# Publish "Hello World" message
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
```

### **👀 Task 2: View the Message**

```bash
# Pull messages from subscription (required command)
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
```

### **📸 Task 3: Create a Pub/Sub Snapshot**

```bash
# Create snapshot from pre-created subscription
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
```

---

## 🎯 **One-Command Solution** 

```bash
# Execute all tasks at once
gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic && \
gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World" && \
gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5 && \
gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription && \
echo "✅ All tasks completed!"
```

---

## ✅ **Verification Commands**

```bash
# Quick verification
gcloud pubsub topics list
gcloud pubsub subscriptions list  
gcloud pubsub snapshots list
```

---

## 🔧 **Troubleshooting (If Needed)**

```bash
# If topic doesn't exist
gcloud pubsub topics create gcloud-pubsub-topic

# If pre-created subscription doesn't exist  
gcloud pubsub subscriptions create gcloud-pubsub-subscription --topic=gcloud-pubsub-topic

# If API not enabled
gcloud services enable pubsub.googleapis.com
```

---

<div align="center">

**⏱️ Total Time: 2-3 minutes**  
**🎉 Lab Complete!**

*For detailed explanations, check our [Complete Learning Solution](./Challenge-Lab-Specific-Solution.md)*

</div>
