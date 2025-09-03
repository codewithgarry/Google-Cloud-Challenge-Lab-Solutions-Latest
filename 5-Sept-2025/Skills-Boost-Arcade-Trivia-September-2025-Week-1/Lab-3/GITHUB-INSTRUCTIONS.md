# GitHub Integration Instructions

## Quick Command for Cloud Shell

Copy and paste this command in Google Cloud Shell:

```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/cloud-shell-runner.sh | bash
```

## Alternative Methods

### Method 1: Clone Repository (Recommended)
```bash
# In Google Cloud Shell
git clone https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest.git
cd "Google-Cloud-Challenge-Lab-Solutions-Latest/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3"
./cloud-shell-runner.sh
```

### Method 2: Direct Download
```bash
# Download the main script
curl -O https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/cloud-shell-runner.sh

# Make executable and run
chmod +x cloud-shell-runner.sh
./cloud-shell-runner.sh
```

### Method 3: Individual File Download
```bash
# Download all files individually
curl -O https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/dataplex-automation.sh
curl -O https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/test.csv

# Make executable and run
chmod +x dataplex-automation.sh
./dataplex-automation.sh
```

## What Each Script Does

### cloud-shell-runner.sh (Recommended)
- **Full automation** with beautiful UI
- **Interactive setup** with smart defaults
- **Project and user management**
- **Error handling** and validation
- **Post-completion guidance**

### dataplex-automation.sh
- **Core automation** script
- **All 5 lab tasks** automated
- **Configurable** via environment variables
- **Can run standalone** or via runner

### quick-setup.sh
- **Environment setup** and prerequisite checking
- **Mode selection** (interactive vs quick)
- **Safety checks** and validation

## Lab Timeline

This automation typically completes in **10-15 minutes**:

1. **Setup & Configuration** (2-3 minutes)
   - Project setup
   - User configuration
   - API enablement

2. **Resource Creation** (5-7 minutes)
   - Dataplex lake creation
   - Zone and asset setup
   - Cloud Storage bucket

3. **Permission Management** (2-3 minutes)
   - IAM role assignments
   - Permission propagation delays

4. **Testing & Verification** (1-2 minutes)
   - File upload test
   - Configuration verification

## Troubleshooting

### Common Issues and Solutions

1. **Permission Denied**
   ```bash
   # Ensure you're authenticated
   gcloud auth login
   
   # Set correct project
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **API Not Enabled**
   ```bash
   # Enable required APIs manually
   gcloud services enable dataplex.googleapis.com
   gcloud services enable storage.googleapis.com
   ```

3. **Region Issues**
   ```bash
   # Use supported regions
   # Recommended: us-west1, us-central1, us-east1
   ```

4. **User Email Issues**
   ```bash
   # Check your lab instructions for correct user emails
   # Format is usually: student-XX-XXXXXXXXX@qwiklabs.net
   ```

## Manual Verification Steps

After running the automation:

### 1. Dataplex Console
- Navigate to: https://console.cloud.google.com/dataplex
- Verify lake, zone, and asset creation
- Check asset is properly attached to zone

### 2. Cloud Storage Console
- Navigate to: https://console.cloud.google.com/storage
- Verify bucket exists with uploaded test.csv

### 3. IAM Console
- Navigate to: https://console.cloud.google.com/iam-admin/iam
- Verify User 2 has Dataplex Data Writer role

### 4. Test User Permissions
- Switch to User 2 account
- Try uploading files to the bucket
- Verify access levels work correctly

## Cleanup Commands

After completing the lab:

```bash
# Set variables (replace with your actual values)
LAKE_ID="customer-info-lake"
ZONE_ID="customer-raw-zone"
ASSET_ID="customer-online-sessions"
REGION="us-west1"
BUCKET_NAME="your-project-id-dataplex-bucket"

# Delete resources
gcloud dataplex assets delete $ASSET_ID --location=$REGION --lake=$LAKE_ID --zone=$ZONE_ID --quiet
gcloud dataplex zones delete $ZONE_ID --location=$REGION --lake=$LAKE_ID --quiet
gcloud dataplex lakes delete $LAKE_ID --location=$REGION --quiet
gsutil rm -r gs://$BUCKET_NAME
```

## Support

If you encounter issues:

1. **Check the script output** for specific error messages
2. **Verify prerequisites** (authentication, project setup)
3. **Review lab instructions** for user emails and project details
4. **Use Google Cloud Console** to manually verify resource creation

---

**Happy Learning! 🚀**
