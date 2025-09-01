# 🚀 Cloud Shell Quick Start Guide

## Skills Boost Arcade Trivia September 2025 Week 1 - Lab 3
### Dataplex: Qwik Start

---

## 🎯 One-Command Solution (Recommended)

Copy and paste this **single command** in Google Cloud Shell:

```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/cloud-shell-runner.sh | bash
```

**That's it!** ✨ The script will:
- ✅ Auto-detect your Cloud Shell environment
- ✅ Set up your project automatically  
- ✅ Guide you through user email setup
- ✅ Complete all 5 lab tasks
- ✅ Provide verification links

---

## 🔄 Alternative: Clone and Run

If you prefer to clone the repository first:

```bash
# Clone the repo
git clone https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest.git

# Navigate to lab directory
cd "Google-Cloud-Challenge-Lab-Solutions-Latest/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3"

# Run the Cloud Shell optimized script
chmod +x cloud-shell-runner.sh && ./cloud-shell-runner.sh
```

---

## 📋 What You'll Need

### From Your Lab Instructions:
1. **User 1 Email** (Dataplex Administrator) - Usually like: `student-01-xxxxxx@qwiklabs.net`
2. **User 2 Email** (Test User) - Usually like: `student-02-xxxxxx@qwiklabs.net`  
3. **Project ID** (Auto-detected in Cloud Shell)

### The Script Will Handle:
- ✅ API enablement (Dataplex, Cloud Storage)
- ✅ Lake creation with custom name
- ✅ Zone creation (Raw zone type)
- ✅ Asset creation (Cloud Storage bucket)
- ✅ IAM role assignments (Reader → Writer)
- ✅ File upload testing
- ✅ All verification steps

---

## ⏱️ Expected Timeline

- **Total Time:** ~10-15 minutes
- **Interactive Setup:** 2-3 minutes
- **Automation:** 7-10 minutes  
- **Verification:** 2-3 minutes

---

## 🎨 What You'll See

The script provides a beautiful interface with:
- 🎯 Clear progress indicators
- ✅ Success confirmations
- ⚠️  Important warnings
- 🔗 Direct console links
- 📝 Next steps guidance

---

## 🔧 Advanced Options

### If You Want Manual Control:
```bash
# Download individual components
curl -O https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/dataplex-automation.sh

# Make executable and run with custom config
chmod +x dataplex-automation.sh
./dataplex-automation.sh
```

### Environment Variables (Optional):
```bash
export LAKE_NAME="My Custom Lake"
export REGION="us-central1"  
export ZONE_NAME="My Custom Zone"
export USER1_EMAIL="your-admin@qwiklabs.net"
export USER2_EMAIL="your-test@qwiklabs.net"
export QUICK_MODE=true
./dataplex-automation.sh
```

---

## 🎯 Post-Automation Verification

After the script completes, verify in Google Cloud Console:

1. **Dataplex Console**: https://console.cloud.google.com/dataplex
   - Check lake, zone, and asset creation
   
2. **Cloud Storage**: https://console.cloud.google.com/storage  
   - Verify bucket and test.csv file
   
3. **IAM**: https://console.cloud.google.com/iam-admin/iam
   - Confirm User 2 has Dataplex Data Writer role

---

## 🆘 Troubleshooting

### If Script Fails:
```bash
# Check authentication
gcloud auth list

# Verify project  
gcloud config get-value project

# Check APIs
gcloud services list --enabled --filter="dataplex"
```

### If Permissions Issue:
- Double-check user emails from lab instructions
- Wait a few minutes for IAM propagation
- Refresh Google Cloud Console

---

## 🧹 Cleanup (After Lab Completion)

The script provides cleanup commands, or run:
```bash
# Quick cleanup (replace with your actual resource names)
gcloud dataplex assets delete customer-online-sessions --location=us-west1 --lake=customer-info-lake --zone=customer-raw-zone --quiet
gcloud dataplex zones delete customer-raw-zone --location=us-west1 --lake=customer-info-lake --quiet  
gcloud dataplex lakes delete customer-info-lake --location=us-west1 --quiet
gsutil rm -r gs://YOUR_PROJECT_ID-dataplex-bucket
```

---

## 🎉 Ready to Start?

Just copy this command into your **Google Cloud Shell** and press Enter:

```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/cloud-shell-runner.sh | bash
```

**Happy Learning! 🚀**
