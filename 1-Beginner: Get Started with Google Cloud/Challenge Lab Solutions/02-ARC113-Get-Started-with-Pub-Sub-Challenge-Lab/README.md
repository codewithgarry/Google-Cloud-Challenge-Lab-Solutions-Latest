# ARC113: Get Started with Pub/Sub Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Challenge Lab](https://img.shields.io/badge/Challenge%20Lab-Success-28a745?style=for-the-badge)

**Lab ID**: ARC113 | **Duration**: 45-60 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Lab Overview

**Lab ID**: ARC113  
**Lab Name**: Get Started with Pub/Sub Challenge Lab  
**Lab Type**: Challenge Lab  
**Difficulty**: Beginner  
**Duration**: 45-60 minutes  

## 🎯 Lab Objectives

This challenge lab tests your knowledge and skills in:
- Creating and managing Pub/Sub topics
- Setting up subscriptions for message delivery
- Publishing and consuming messages
- Creating Cloud Scheduler jobs for automated messaging
- Working with Pub/Sub schemas and snapshots
- Setting up Cloud Functions with Pub/Sub triggers

## 📚 Knowledge Prerequisites

Before starting this lab, you should be familiar with:
- Google Cloud Console navigation
- Basic Pub/Sub messaging concepts
- Cloud Shell and gcloud command-line tools
- JSON schema structure (for advanced tasks)

## 🛠️ Lab Task Variations

This challenge lab has **3 different forms** with varying tasks:

### 📋 **Form 1**: Basic Pub/Sub with Cloud Scheduler
- **Task 1**: Set up Cloud Pub/Sub
- **Task 2**: Create a Cloud Scheduler job
- **Task 3**: Verify the results in Cloud Pub/Sub

### 📋 **Form 2**: Schema-based Pub/Sub with Cloud Functions
- **Task 1**: Create Pub/Sub schema
- **Task 2**: Create Pub/Sub topic using schema
- **Task 3**: Create a trigger cloud function with Pub/Sub topic

### 📋 **Form 3**: Message Management and Snapshots
- **Task 1**: Publish a message to the topic
- **Task 2**: View the message
- **Task 3**: Create a Pub/Sub Snapshot for Pub/Sub topic

## 🚀 Available Solutions

Choose your preferred approach:

### 📱 GUI Solution
Perfect for beginners who prefer visual, step-by-step guidance through the Google Cloud Console.
- **File**: [GUI-Solution.md](./Pro/GUI-Solution.md)
- **Best for**: Visual learners, beginners, detailed screenshots
- **Time**: 45-60 minutes

### 💻 CLI Solution  
Ideal for developers comfortable with command-line interfaces and automation.
- **File**: [CLI-Solution.md](./Pro/CLI-Solution.md)
- **Best for**: CLI users, faster execution, scripting practice
- **Time**: 20-30 minutes

### 🤖 Automation Solution
Advanced solution using Infrastructure as Code and automation scripts.
- **File**: [Automation-Solution.md](./Pro/Automation-Solution.md)
- **Best for**: DevOps engineers, production deployments, learning IaC
- **Time**: 10-15 minutes

### ⚡ Quick Solution
For rapid completion with essential commands only.
- **File**: [solution.md](./solution.md)
- **Best for**: Quick reference, experienced users
- **Time**: 5-10 minutes

## 📝 Lab Instructions

1. **Identify your lab form** by checking the specific tasks in your lab interface
2. **Choose your approach** from the solutions above
3. **Read the prerequisites** and ensure you have the necessary setup
4. **Follow the step-by-step instructions** in your chosen solution file
5. **Verify your results** using the provided validation steps
6. **Clean up resources** to avoid unnecessary charges

## ✅ Success Criteria

Your lab is complete when:
- [ ] All tasks are marked as complete in the lab interface
- [ ] Pub/Sub topics and subscriptions are properly configured
- [ ] Messages can be published and consumed successfully
- [ ] All additional components (scheduler/functions/schemas) are working
- [ ] Progress score shows 100%

## 🔧 Troubleshooting

### Common Issues

**Issue 1: API Not Enabled**
- **Solution**: Enable the Pub/Sub API
- **Command**: `gcloud services enable pubsub.googleapis.com`

**Issue 2: Permission Denied**
- **Solution**: Ensure you have the required IAM roles
- **Required Roles**: `Pub/Sub Editor`, `Cloud Scheduler Admin` (if needed)

**Issue 3: Topic Already Exists**
- **Solution**: Use unique names or check existing resources
- **Command**: `gcloud pubsub topics list`

**Issue 4: Subscription Not Receiving Messages**
- **Solution**: Check topic-subscription binding and message acknowledgment
- **Command**: `gcloud pubsub subscriptions describe SUBSCRIPTION_NAME`

### Getting Help
- Check the [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- Visit the [Google Cloud Community](https://cloud.google.com/community)
- Open an [issue](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/issues) in this repository

## 📚 Additional Resources

### Official Documentation
- [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [Cloud Scheduler Documentation](https://cloud.google.com/scheduler/docs)
- [Cloud Functions with Pub/Sub](https://cloud.google.com/functions/docs/calling/pubsub)
- [Pub/Sub Schema Documentation](https://cloud.google.com/pubsub/docs/schemas)

### Learning Paths
- [Google Cloud Fundamentals](https://www.cloudskillsboost.google.com/paths)
- [Messaging and Event-Driven Architecture](https://www.cloudskillsboost.google.com/paths)

### Related Labs
- [Previous Lab: Compute Engine Basics](../01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab)
- [Next Lab: API Gateway](../03-ARC109-Getting-Started-with-API-Gateway-Challenge-Lab)

## 🏷️ Tags

`google-cloud` `pubsub` `messaging` `cloud-scheduler` `cloud-functions` `schemas` `snapshots` `beginner` `challenge-lab`

## 📈 Skill Level Progression

After completing this lab, you should be able to:
- ✅ Create and manage Pub/Sub topics and subscriptions
- ✅ Publish and consume messages in cloud messaging systems
- ✅ Set up automated messaging with Cloud Scheduler
- ✅ Work with message schemas for data validation
- ✅ Create and manage message snapshots for recovery
- ✅ Integrate Pub/Sub with Cloud Functions for event-driven architecture

---

## 🎉 Congratulations!

You've successfully completed the Get Started with Pub/Sub Challenge Lab! 

### Next Steps
1. **Clean up resources** to avoid charges
2. **Try the next lab** in the series
3. **Practice** with your own messaging projects
4. **Share** your success with the community

### Share Your Success
- ⭐ Star this repository if it helped you
- 🐦 Tweet about your achievement with #GoogleCloud
- 💼 Add this skill to your LinkedIn profile
- 📝 Write a blog post about your learning journey

---

*Solution provided by [CodeWithGarry](https://github.com/codewithgarry) - Your Google Cloud Learning Partner*

[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)