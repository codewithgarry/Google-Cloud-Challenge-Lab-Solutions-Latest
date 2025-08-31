# The Basics of Google Cloud Compute: Challenge Lab - 2 Minutes Solution

<div align="center">

[Lab Link](https://www.cloudskillsboost.google.com/focuses/1734?parent=catalog) | 
[Solution Video](https://youtube.com/@codewithgarry)

**Lab ID**: ARC120 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🚀 Quick 2-Minute Automated Solution

**The fastest way to complete this lab is using our automated script runner!**

### ⚡ One-Command Solution

Open **Google Cloud Shell** and run this single command:

```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/arc120-challenge-lab-runner.sh | bash
```

### 🎯 What This Script Does

The script will automatically:

1. **🪣 Task 1**: Create Cloud Storage bucket with your lab-specific name
2. **💻 Task 2**: Create VM instance with persistent disk attached
3. **🌐 Task 3**: Install and configure NGINX on the VM

### 📋 Script Features

- ✅ **Interactive prompts** for lab-specific values
- ✅ **Error handling** and validation
- ✅ **Step-by-step execution** with confirmation
- ✅ **Colored output** for better readability
- ✅ **Verification** of each completed task
<!-- 
### 🔧 Alternative: Step-by-Step Execution

If you prefer to run tasks individually:

#### Download the Runner Script:
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/arc120-challenge-lab-runner.sh -o arc120-runner.sh
chmod +x arc120-runner.sh
./arc120-runner.sh
```


#### Individual Task Scripts:

**Task 1 - Create Storage Bucket:**
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/sci-fi-1/task1-create-storage-bucket.sh -o task1.sh
chmod +x task1.sh && ./task1.sh
```

**Task 2 - Create VM with Disk:**
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/sci-fi-2/task2-create-vm-with-disk.sh -o task2.sh
chmod +x task2.sh && ./task2.sh
```

**Task 3 - Install NGINX:**
```bash
curl -sL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid/sci-fi-3/task3-install-nginx.sh -o task3.sh
chmod +x task3.sh && ./task3.sh
```
-->

---

## ⚠️ Before You Start

**📖 Check Your Lab Instructions For:**
- **Bucket name** (usually `PROJECT_ID-bucket`)
- **Region** (default: `us-east4`)
- **Zone** (default: `us-east4-a`)
- **VM name** (default: `my-instance`)
- **Disk name** (default: `mydisk`)

---

## 🎯 Expected Results

After running the scripts, you should have:

1. ✅ **Cloud Storage bucket** created with your specified name
2. ✅ **VM instance** `my-instance` running in `us-east4-a`
3. ✅ **Additional disk** `mydisk` (200GB) attached to the VM
4. ✅ **NGINX web server** installed and running
5. ✅ **HTTP traffic** allowed (if selected)

---

## 🔍 Verification Commands

After completion, verify with these commands:

```bash
# Check bucket
gsutil ls

# Check VM instances  
gcloud compute instances list

# Check disks
gcloud compute disks list

# Test NGINX (replace EXTERNAL_IP with your VM's IP)
curl http://EXTERNAL_IP
```

---

## 🆘 Troubleshooting

If you encounter issues:

1. **Authentication Error**: Run `gcloud auth login`
2. **Project Not Set**: Run `gcloud config set project YOUR_PROJECT_ID`
3. **Permission Errors**: Ensure you have Editor/Owner role
4. **Bucket Name Exists**: Try a different bucket name
5. **VM Creation Fails**: Check quota limits in your region

---

## 🏆 Lab Completion

Once all tasks are completed:

1. ✅ Go back to the lab page
2. ✅ Click "Check my progress" for each task
3. ✅ Verify all checkmarks are green
4. ✅ Click "End Lab"

---

## 📚 Manual Solution

If you prefer manual steps, check the detailed solution in:
- [Challenge-lab-specific-solution.md.md](./Challenge-lab-specific-solution.md.md)

---

<div align="center">

**🎉 Congratulations! You've completed ARC120 in 2 minutes!**

**⭐ Don't forget to star our repository if this helped you!**

</div>