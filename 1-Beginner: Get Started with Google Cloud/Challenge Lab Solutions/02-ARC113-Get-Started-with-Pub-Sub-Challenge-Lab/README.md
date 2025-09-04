# ARC113: Get Started with Pub/Sub - Challenge Lab Solution

## 🚀 Quick Setup & Execution

### Option 1: Instant 2-Minute Solution
```bash
curl -L https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/raw/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/2-minutes-solution.md | bash
```

### Option 2: Automated Challenge Lab Runner
```bash
curl -L https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/raw/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/arc113-challenge-lab-runner.sh | bash
```

### Option 3: Download and Execute Locally
```bash
wget https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/raw/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/arc113-challenge-lab-runner.sh
chmod +x arc113-challenge-lab-runner.sh
./arc113-challenge-lab-runner.sh
```

## 📋 Lab Overview

**Challenge Lab:** ARC113 - Get Started with Pub/Sub  
**Duration:** 30 minutes  
**Level:** Beginner  
**Credits:** 1  

### Lab Objectives
- Create a topic in Pub/Sub
- Create a subscription to the topic
- Publish a message to the topic
- View the message
- Create a snapshot from the subscription

## 🔧 Solution Features

- **Automatic Detection:** Detects lab parameters automatically
- **Error Handling:** Comprehensive error checking
- **Multiple Formats:** Supports various lab variations
- **Progress Tracking:** Real-time execution status
- **Verification:** Automatic solution verification

## 📁 File Structure

```
02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/
├── README.md                           # This file
├── 2-minutes-solution.md              # Quick solution guide
├── Challenge-lab-specific-solution.md  # Detailed solution steps
├── arc113-challenge-lab-runner.sh     # Main automated runner
└── Pro/
    ├── Automation-Solution.md          # Automation approach
    ├── CLI-Solution.md                 # Command line solution
    ├── GUI-Solution.md                 # Console GUI solution
    └── solid/
        ├── README.md                   # Advanced solutions guide
        ├── ENHANCEMENT_SUMMARY.md      # Solution enhancements
        ├── SUBSCRIPTION_SYSTEM.md      # Subscription details
        ├── arc113-challenge-lab-runner.sh
        ├── test-system.sh              # Testing framework
        ├── fix-verification.sh         # Verification fixes
        ├── sci-fi-1/                   # Task 1 solutions
        ├── sci-fi-2/                   # Task 2 solutions
        └── sci-fi-3/                   # Task 3 solutions
```

## 🎯 Quick Commands

### Manual Execution
```bash
# Set variables (update with your lab values)
export TOPIC_NAME="your-topic-name"
export SUBSCRIPTION_NAME="your-subscription-name"
export MESSAGE="your-message"

# Create topic
gcloud pubsub topics create $TOPIC_NAME

# Create subscription
gcloud pubsub subscriptions create $SUBSCRIPTION_NAME --topic=$TOPIC_NAME

# Publish message
gcloud pubsub topics publish $TOPIC_NAME --message="$MESSAGE"

# Pull message
gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack

# Create snapshot
gcloud pubsub snapshots create snapshot-1 --subscription=$SUBSCRIPTION_NAME
```

## 🔍 Lab Variations

This solution handles all common ARC113 variations:
- Different topic names
- Various subscription names
- Multiple message formats
- Schema-based topics
- Different snapshot requirements

## ⚡ Troubleshooting

### Common Issues:
1. **Permission denied:** Ensure you're authenticated with `gcloud auth login`
2. **Project not set:** Run `gcloud config set project YOUR_PROJECT_ID`
3. **API not enabled:** Enable Pub/Sub API if needed
4. **Resource already exists:** Script handles existing resources gracefully

### Quick Fixes:
```bash
# Enable Pub/Sub API
gcloud services enable pubsub.googleapis.com

# Check current project
gcloud config get-value project

# List existing topics
gcloud pubsub topics list

# List existing subscriptions
gcloud pubsub subscriptions list
```

## 📚 Additional Resources

- [Google Cloud Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Pub/Sub Quickstart](https://cloud.google.com/pubsub/docs/quickstart-cli)
- [Challenge Lab Best Practices](../../README.md)

## 🤝 Support

- **Issues:** [GitHub Issues](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/issues)
- **Discussions:** [GitHub Discussions](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/discussions)
- **Updates:** [Release Notes](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/releases)

---

**Note:** This solution is designed for educational purposes. Always understand the commands before executing them in production environments.