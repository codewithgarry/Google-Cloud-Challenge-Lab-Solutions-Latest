# Get Started with Cloud Storage: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC111 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 GUI Solution (Google Cloud Console)

This solution uses the Google Cloud Console web interface for a beginner-friendly approach.

---

## ⚠️ IMPORTANT: Get Values from Your Lab

**Check your lab instructions for these specific values:**
- **Bucket name**: (usually `PROJECT_ID-bucket`)
- **Location**: (specified in lab)
- **Storage class**: (specified in lab)

---

## 📋 Step-by-Step Console Instructions

### Task 1: Create a Cloud Storage bucket

1. **Navigate to Cloud Storage**
   - In the Google Cloud Console, click on the **Navigation menu** (☰)
   - Go to **Storage** → **Cloud Storage** → **Buckets**

2. **Create the bucket**
   - Click **CREATE BUCKET**
   - **Name your bucket**: Enter the exact bucket name from your lab instructions
   - **Choose where to store your data**:
     - Location type: As specified in lab
     - Select the region/multi-region specified
   - **Choose a default storage class**: As specified in lab
   - **Choose how to control access**: Keep default settings
   - Click **CREATE**

### Task 2: Upload objects to the bucket

1. **Upload files**
   - Click on your bucket name to open it
   - Click **UPLOAD FILES**
   - Select the files specified in your lab instructions
   - Wait for upload to complete

2. **Create folders**
   - Click **CREATE FOLDER**
   - Enter folder name as specified in lab
   - Click **CREATE**

### Task 3: Configure bucket permissions

1. **Set public access**
   - Go to **Permissions** tab
   - Click **ADD PRINCIPAL**
   - New principals: `allUsers`
   - Role: **Storage Object Viewer**
   - Click **SAVE**

2. **Configure lifecycle management**
   - Go to **Lifecycle** tab
   - Click **ADD A RULE**
   - Configure rule as specified in lab
   - Click **CREATE**

---

## ✅ Verification Steps

1. **Verify bucket creation**: Check Cloud Storage console
2. **Test object access**: Access public URLs
3. **Check permissions**: Verify public access works
4. **Validate lifecycle**: Confirm rules are applied

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach for efficiency
- **[Automation Solution](Automation-Solution.md)** - Scripts and Infrastructure as Code

---

## 🎖️ Skills Boost Arcade

This challenge lab is part of the **Skills Boost Arcade** program. Complete this lab to earn arcade points and badges!

---

<div align="center">

**💡 Pro Tip**: Practice bucket management to master Cloud Storage fundamentals!

</div>
