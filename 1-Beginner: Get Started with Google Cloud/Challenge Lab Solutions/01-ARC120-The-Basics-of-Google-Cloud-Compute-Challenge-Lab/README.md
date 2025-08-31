# ARC120: The Basics of Google Cloud Compute Challenge Lab

## 📋 Lab Overview

**Lab ID**: ARC120  
**Lab Name**: The Basics of Google Cloud Compute Challenge Lab  
**Lab Type**: Challenge Lab  
**Difficulty**: Beginner  
**Duration**: 45-60 minutes  

## 🎯 Lab Objectives

This challenge lab tests your knowledge and skills in:
- Creating and configuring virtual machine instances
- Working with persistent disks and snapshots
- Configuring firewall rules and network security
- Managing instance templates and instance groups

## 📚 Knowledge Prerequisites

Before starting this lab, you should be familiar with:
- Google Cloud Console navigation
- Basic Compute Engine concepts
- Virtual machine fundamentals
- Basic networking concepts

## 🛠️ Lab Tasks

### Task 1: Create a Virtual Machine Instance
- Create a virtual machine with specific configurations
- Configure machine type, boot disk, and network settings

### Task 2: Create and Attach a Persistent Disk  
- Create a persistent disk
- Attach the disk to the virtual machine
- Format and mount the disk

### Task 3: Create a Snapshot and Instance Template
- Create a snapshot of the persistent disk
- Create an instance template based on the VM
- Set up an instance group using the template

### Task 4: Configure Firewall Rules
- Create firewall rules for HTTP/HTTPS traffic
- Test connectivity and security settings

## 🚀 Available Solutions

Choose your preferred approach:

### ⚡ **2-Minute Automated Solution** (Recommended)
**🎯 [Start Here: 2-minutes-solution.md](./2-minutes-solution.md)**

The fastest way to complete this lab! One command execution in Google Cloud Shell:
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/arc120-challenge-lab-runner.sh | bash
```

### 📖 **Manual Step-by-Step Solution**
**📋 [Detailed Guide: Challenge-lab-specific-solution.md.md](./Challenge-lab-specific-solution.md.md)**

Complete walkthrough with console screenshots and explanations.

### 🔧 **Advanced Solutions**
**📁 [Pro Solutions: Pro/](./Pro/)**
- [Automation Solution](./Pro/Automation-Solution.md)
- [CLI Solution](./Pro/CLI-Solution.md)  
- [GUI Solution](./Pro/GUI-Solution.md)
- [Advanced Scripts](./Pro/solid/) - Individual task automation

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

## 📝 Lab Instructions

1. **Choose your approach** from the solutions above
2. **Read the prerequisites** and ensure you have the necessary setup
3. **Follow the step-by-step instructions** in your chosen solution file
4. **Verify your results** using the provided validation steps
5. **Clean up resources** to avoid unnecessary charges

## ✅ Success Criteria

Your lab is complete when:
- [ ] Virtual machine instance is created and running
- [ ] Persistent disk is attached and properly configured
- [ ] Snapshot is created successfully
- [ ] Instance template and group are configured
- [ ] Firewall rules are properly set up
- [ ] Progress score shows 100%

## 🔧 Troubleshooting

### Common Issues

**Issue 1: Permission Denied**
- **Solution**: Ensure you have Compute Engine Admin or Editor role
- **Command**: `gcloud projects get-iam-policy PROJECT_ID`

**Issue 2: Compute Engine API Not Enabled**
- **Solution**: Enable the Compute Engine API
- **Command**: `gcloud services enable compute.googleapis.com`

**Issue 3: Instance Creation Failed**
- **Solution**: Check quotas and try different machine types or zones
- **Command**: `gcloud compute project-info describe --project=PROJECT_ID`

### Getting Help
- Check the [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- Visit the [Google Cloud Community](https://cloud.google.com/community)
- Open an [issue](https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/issues) in this repository

## 📚 Additional Resources

### Official Documentation
- [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Persistent Disks](https://cloud.google.com/compute/docs/disks)
- [Instance Templates](https://cloud.google.com/compute/docs/instance-templates)
- [Firewall Rules](https://cloud.google.com/vpc/docs/firewalls)

### Learning Paths
- [Google Cloud Fundamentals](https://www.cloudskillsboost.google.com/paths/36)
- [Compute Engine Learning Path](https://www.cloudskillsboost.google.com/paths/16)

### Related Labs
- [Next Lab: Get Started with Pub/Sub](../02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab)

## 🏷️ Tags

`google-cloud` `compute-engine` `challenge-lab` `virtual-machines` `persistent-disks` `beginner`

## 📈 Skill Level Progression

After completing this lab, you should be able to:
- ✅ Create and configure virtual machine instances
- ✅ Manage persistent disks and snapshots
- ✅ Set up instance templates and groups
- ✅ Configure basic firewall rules

---

## 🎉 Congratulations!

You've successfully completed the Basics of Google Cloud Compute Challenge Lab! 

### Next Steps
1. **Clean up resources** to avoid charges
2. **Try the next lab** in the series: [Get Started with Pub/Sub](../02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab)
3. **Practice** with your own compute projects
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
