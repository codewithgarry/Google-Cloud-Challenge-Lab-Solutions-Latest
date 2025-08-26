# ARC109: Getting Started with API Gateway Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-34A853?style=for-the-badge&logo=google&logoColor=white)
![Cloud Run](https://img.shields.io/badge/Cloud%20Run-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Lab Overview

**Lab ID**: ARC109  
**Lab Name**: Getting Started with API Gateway Challenge Lab  
**Lab Type**: Challenge Lab  
**Difficulty**: Introductory  
**Duration**: 45 minutes  

## 🎯 Lab Objectives

This challenge lab tests your knowledge and skills in:
- Creating Cloud Run functions (2nd generation)
- Deploying and managing API Gateway
- Integrating backend services with API management
- Working with Pub/Sub topics and message publishing
- Building event-driven serverless architectures

## 📚 Knowledge Prerequisites

Before starting this lab, you should be familiar with:
- Google Cloud Console navigation
- Cloud Run functions and serverless concepts
- API Gateway and OpenAPI specifications
- Pub/Sub messaging system
- Basic Node.js and JavaScript

## 🛠️ Lab Tasks

### Task 1: Create a Cloud Run Function
- Create a Cloud Run function (2nd gen) named `gcfunction`
- Region: `us-central1`
- Runtime: Node.js 22
- Allow unauthenticated invocations
- Return "Hello World!" when invoked

### Task 2: Create an API Gateway
- Deploy API Gateway to proxy requests to the Cloud Run function
- Configure with OpenAPI specification
- Set up proper routing and authentication
- Display Name: `gcfunction API`
- API ID: `gcfunction-api`

### Task 3: Create Pub/Sub Topic and Publish Messages
- Create Pub/Sub topic named `demo-topic`
- Update Cloud Run function to publish messages to the topic
- Enable message publishing via API Gateway
- Verify message delivery to subscription

## 🚀 Available Solutions

Choose your preferred approach:

### 📱 GUI Solution
Perfect for beginners who prefer visual, step-by-step guidance through the Google Cloud Console.
- **File**: [GUI-Solution.md](./Pro/GUI-Solution.md)
- **Best for**: Visual learners, beginners, detailed screenshots
- **Time**: 45 minutes

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
- **Time**: 15-20 minutes

## 📝 Lab Instructions

1. **Read the challenge scenario** to understand the requirements
2. **Choose your approach** from the solutions above
3. **Follow the step-by-step instructions** in your chosen solution file
4. **Verify each task** using the provided validation steps
5. **Test the complete workflow** from API Gateway to Pub/Sub
6. **Clean up resources** to avoid unnecessary charges

## ✅ Success Criteria

Your lab is complete when:
- [ ] Cloud Run function is deployed and accessible
- [ ] API Gateway is configured and proxying requests
- [ ] Pub/Sub topic is created with default subscription
- [ ] Messages are published to topic via API Gateway
- [ ] All tasks show as completed in the lab interface
- [ ] Progress score shows 100%

## 🔧 Troubleshooting

### Common Issues

**Issue 1: Cloud Run function deployment fails**
- **Solution**: Wait for Cloud Run Admin APIs to propagate (5-10 minutes)
- **Command**: `gcloud services list --enabled | grep run`

**Issue 2: API Gateway creation takes too long**
- **Solution**: Gateway creation takes ~10 minutes, monitor via notifications
- **Check**: Bell icon in top navigation for status updates

**Issue 3: OpenAPI spec backend URL incorrect**
- **Solution**: Update the x-google-backend address with correct Cloud Run URL
- **Get URL**: `gcloud run services describe gcfunction --region=us-central1`

**Issue 4: Pub/Sub messages not appearing**
- **Solution**: Messages take ~5 minutes to appear after API invocation
- **Verify**: Check subscription message count in console

**Issue 5: Function code deployment errors**
- **Solution**: Ensure package.json and index.js are properly formatted
- **Check**: Validate JSON syntax and JavaScript code

### Getting Help
- Check the [API Gateway Documentation](https://cloud.google.com/api-gateway/docs)
- Check the [Cloud Run Documentation](https://cloud.google.com/run/docs)
- Visit the [Google Cloud Community](https://cloud.google.com/community)
- Open an [issue](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/issues) in this repository

## 📚 Additional Resources

### Official Documentation
- [API Gateway Documentation](https://cloud.google.com/api-gateway/docs)
- [Cloud Run Functions Documentation](https://cloud.google.com/functions/docs)
- [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs)
- [OpenAPI Specification](https://swagger.io/specification/)

### Learning Paths
- [Google Cloud Fundamentals](https://www.cloudskillsboost.google.com/paths)
- [Serverless Development](https://www.cloudskillsboost.google.com/paths)
- [API Management](https://www.cloudskillsboost.google.com/paths)

### Related Labs
- [Previous Lab: Pub/Sub Basics](../02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab)
- [Next Lab: Dataplex](../04-ARC117-Get-Started-with-Dataplex-Challenge-Lab)

## 🏷️ Tags

`google-cloud` `api-gateway` `cloud-run` `pubsub` `serverless` `nodejs` `openapi` `challenge-lab`

## 📈 Skill Level Progression

After completing this lab, you should be able to:
- ✅ Deploy Cloud Run functions with proper configuration
- ✅ Create and manage API Gateway configurations
- ✅ Design OpenAPI specifications for service integration
- ✅ Implement event-driven architectures with Pub/Sub
- ✅ Build secure, scalable API backends
- ✅ Monitor and troubleshoot serverless applications

---

## 🎉 Congratulations!

You've successfully completed the API Gateway Challenge Lab! 

### Next Steps
1. **Clean up resources** to avoid charges
2. **Try the next lab** in the series
3. **Practice** with your own API projects
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
