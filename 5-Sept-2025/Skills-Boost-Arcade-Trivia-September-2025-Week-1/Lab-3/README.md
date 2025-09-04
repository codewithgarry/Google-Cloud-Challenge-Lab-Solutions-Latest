# Skills Boost Arcade Trivia September 2025 Week 1 - Lab 3

## Dataplex: Qwik Start - Automated Solution

This directory contains automated solutions for the **Skills Boost Arcade Trivia September 2025 Week 1** lab focusing on Google Cloud Dataplex.

### Lab Overview

This lab demonstrates how to:
1. Create a lake, zone, and asset in Dataplex
2. Assign Dataplex Data Reader role to another user
3. Test access to Dataplex resources as a Dataplex Data Reader
4. Assign Dataplex Data Writer role to another user
5. Upload new file to Cloud Storage bucket as a Dataplex Data Writer

### Files in this Directory

- `dataplex-automation.sh` - Main automation script that performs all lab tasks
- `test.csv` - Sample CSV file used for testing file uploads
- `README.md` - This documentation file

### Prerequisites

Before running the automation script, ensure you have:

1. **Google Cloud SDK installed** with `gcloud` and `gsutil` commands
2. **Authenticated with Google Cloud** using `gcloud auth login`
3. **Project ID set** using `gcloud config set project YOUR_PROJECT_ID`
4. **Appropriate permissions** to create Dataplex resources and manage IAM
5. **Two user accounts** (typically provided by the lab environment):
   - User 1: Dataplex Administrator
   - User 2: Test user for permission testing

### Quick Start (Recommended for Cloud Shell)

#### Option 1: One-liner execution
```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3/cloud-shell-runner.sh | bash
```

#### Option 2: Clone and run
```bash
# Clone the repository
git clone https://github.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest.git

# Navigate to the lab directory
cd "Google-Cloud-Challenge-Lab-Solutions-Latest/Sept-2025/Skills-Boost-Arcade-Trivia-September-2025-Week-1/Lab-3"

# Run the Cloud Shell optimized script
./cloud-shell-runner.sh
```

#### Option 3: Manual setup
```bash
# Download and run the quick setup
chmod +x quick-setup.sh
./quick-setup.sh
```

### Files in this Directory

- `cloud-shell-runner.sh` - **Recommended** - Cloud Shell optimized runner with full automation
- `dataplex-automation.sh` - Main automation script that performs all lab tasks
- `quick-setup.sh` - Interactive setup script with mode selection
- `run.sh` - One-liner script for quick execution
- `test.csv` - Sample CSV file used for testing file uploads
- `README.md` - This documentation file

### Script Features

#### 🚀 **Automated Tasks**
- ✅ Enable Dataplex API
- ✅ Create Cloud Storage bucket
- ✅ Create Dataplex lake
- ✅ Create Dataplex zone (Raw zone type)
- ✅ Create Dataplex asset (Storage bucket)
- ✅ Assign Dataplex Data Reader role
- ✅ Assign Dataplex Data Writer role
- ✅ Upload test file to verify permissions

#### 🎛️ **Configuration Options**
- **Customizable resource names** - All display names can be customized
- **Region selection** - Choose your preferred region
- **Dynamic bucket naming** - Auto-generates or custom bucket names
- **User email configuration** - Support for any user emails

#### 🛡️ **Safety Features**
- **Existence checks** - Prevents duplicate resource creation
- **Error handling** - Graceful handling of existing resources
- **Permission propagation delays** - Built-in waits for IAM changes
- **Colored output** - Clear status messages and warnings

### Expected Outputs

When running successfully, you should see:

```bash
========================================
Skills Boost Arcade Trivia September 2025 Week 1
========================================
[INFO] Using project: your-project-id
...
[INFO] Lab automation completed successfully!
```

### Manual Verification Steps

After running the script, verify in the Google Cloud Console:

1. **Dataplex Console** (`https://console.cloud.google.com/dataplex`):
   - Check that the lake, zone, and asset were created
   - Verify the asset is attached to the zone
   - Confirm discovery settings are enabled

2. **Storage Console** (`https://console.cloud.google.com/storage`):
   - Verify the bucket exists
   - Check that the test.csv file was uploaded

3. **IAM Console** (`https://console.cloud.google.com/iam-admin/iam`):
   - Confirm User 2 has Dataplex Data Writer role on the asset

### Testing User Permissions

To test the permission model:

1. **Switch to User 2 account** in the Google Cloud Console
2. **Navigate to Cloud Storage** and try to:
   - View the bucket contents (should work with both Reader and Writer roles)
   - Upload files (should only work with Writer role)
3. **Navigate to Dataplex** and verify access levels

### Troubleshooting

#### Common Issues:

1. **Permission Denied Errors:**
   - Ensure you're using the correct user accounts
   - Wait for IAM propagation (script includes delays)
   - Verify project ID is correct

2. **Resource Already Exists:**
   - Script handles this gracefully with warnings
   - Resources will be reused if they already exist

3. **API Not Enabled:**
   - Script automatically enables required APIs
   - Ensure you have permission to enable APIs

4. **Region Issues:**
   - Use regions that support Dataplex (us-west1 is recommended)
   - Ensure all resources are in the same region

#### Getting Help:

If you encounter issues:
1. Check the script output for specific error messages
2. Verify your Google Cloud SDK installation
3. Ensure proper authentication and project setup
4. Review the Google Cloud Console for resource status

### Lab Context

This automation is part of the **September 2025 Skills Boost Arcade Trivia** series:
- **Week:** 1
- **Lab Count:** 3
- **Focus:** Google Cloud Dataplex fundamentals
- **Difficulty:** Beginner to Intermediate

### Security Notes

⚠️ **Important Security Considerations:**
- Use temporary lab accounts as instructed
- Do not use production environments
- Clean up resources after lab completion
- Follow principle of least privilege for permissions

### Cleanup

To clean up resources after the lab:

```bash
# Delete the asset
gcloud dataplex assets delete ASSET_ID --location=REGION --lake=LAKE_ID --zone=ZONE_ID

# Delete the zone
gcloud dataplex zones delete ZONE_ID --location=REGION --lake=LAKE_ID

# Delete the lake
gcloud dataplex lakes delete LAKE_ID --location=REGION

# Delete the bucket
gsutil rm -r gs://BUCKET_NAME
```

---

**Note:** This script is designed for educational purposes as part of Google Cloud Skills Boost labs. Always follow your organization's cloud governance policies when using in production environments.
