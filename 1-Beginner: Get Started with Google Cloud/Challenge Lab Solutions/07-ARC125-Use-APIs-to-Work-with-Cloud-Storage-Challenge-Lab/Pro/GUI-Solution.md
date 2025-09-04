# Use APIs to Work with Cloud Storage: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)
![APIs](https://img.shields.io/badge/APIs-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC125 | **Duration**: 60 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 GUI Solution (Google Cloud Console)

This solution uses the Google Cloud Console web interface to work with Cloud Storage APIs.

---

## ⚠️ IMPORTANT: Get Values from Your Lab

**Check your lab instructions for these specific values:**
- **Bucket name**: (usually `PROJECT_ID-storage-api`)
- **Service Account name**: (specified in lab)
- **API Key**: (to be created)

---

## 📋 Step-by-Step Console Instructions

### Task 1: Enable Cloud Storage API

1. **Navigate to APIs & Services**
   - In the Google Cloud Console, click on the **Navigation menu** (☰)
   - Go to **APIs & Services** → **Library**

2. **Enable Cloud Storage API**
   - Search for "Cloud Storage JSON API"
   - Click on **Cloud Storage JSON API**
   - Click **ENABLE**

3. **Enable additional APIs**
   - Also enable **Cloud Storage** (if not already enabled)
   - Enable **Service Usage API**

### Task 2: Create API credentials

1. **Create API Key**
   - Go to **APIs & Services** → **Credentials**
   - Click **CREATE CREDENTIALS** → **API key**
   - Copy the API key (save it securely)
   - Click **RESTRICT KEY**
   - Under **API restrictions**, select "Restrict key"
   - Choose **Cloud Storage JSON API**
   - Click **SAVE**

2. **Create Service Account**
   - Click **CREATE CREDENTIALS** → **Service account**
   - Service account name: Enter name from lab
   - Service account description: "For Cloud Storage API access"
   - Click **CREATE AND CONTINUE**
   - Grant role: **Storage Admin**
   - Click **CONTINUE** and **DONE**

3. **Download Service Account Key**
   - Click on the created service account
   - Go to **Keys** tab
   - Click **ADD KEY** → **Create new key**
   - Choose **JSON** format
   - Click **CREATE** (key will download)

### Task 3: Create Cloud Storage bucket via Console

1. **Create bucket for API testing**
   - Go to **Storage** → **Cloud Storage** → **Buckets**
   - Click **CREATE BUCKET**
   - Name: Use bucket name from lab instructions
   - Location: As specified in lab
   - Storage class: **Standard**
   - Access control: **Uniform**
   - Click **CREATE**

### Task 4: Test API access using Cloud Shell

1. **Open Cloud Shell**
   - Click the **Activate Cloud Shell** button in the top right

2. **Set up authentication**
   ```bash
   # Upload your service account key file to Cloud Shell
   # Then authenticate
   gcloud auth activate-service-account --key-file=path/to/your/key.json
   ```

3. **Test Cloud Storage API**
   ```bash
   # Set variables
   export PROJECT_ID=$(gcloud config get-value project)
   export BUCKET_NAME="your-bucket-name-from-lab"
   export API_KEY="your-api-key"
   
   # Test API with curl
   curl -X GET \
     "https://storage.googleapis.com/storage/v1/b?project=$PROJECT_ID&key=$API_KEY"
   ```

### Task 5: Upload and manage objects via API

1. **Create a test file**
   ```bash
   echo "Hello from Cloud Storage API!" > test-file.txt
   ```

2. **Upload using API**
   ```bash
   curl -X POST \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: text/plain" \
     -T test-file.txt \
     "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=test-file.txt"
   ```

3. **List objects via API**
   ```bash
   curl -X GET \
     -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o"
   ```

### Task 6: Configure bucket metadata

1. **Update bucket metadata via Console**
   - Go back to **Cloud Storage** → **Buckets**
   - Click on your bucket
   - Go to **Configuration** tab
   - Add labels as specified in lab
   - Update storage class if needed

2. **Set CORS configuration**
   - In **Configuration** tab, scroll to **CORS**
   - Click **EDIT**
   - Add CORS rules as specified in lab:
     ```json
     [
       {
         "origin": ["*"],
         "method": ["GET", "POST"],
         "responseHeader": ["Content-Type"],
         "maxAgeSeconds": 3600
       }
     ]
     ```

---

## 📊 Monitoring API Usage

### Task 7: Monitor API calls

1. **View API metrics**
   - Go to **APIs & Services** → **Dashboard**
   - Click on **Cloud Storage JSON API**
   - Review traffic, errors, and latency metrics

2. **Set up API quotas**
   - Go to **APIs & Services** → **Quotas**
   - Search for "Cloud Storage"
   - Review and modify quotas if needed

---

## ✅ Verification Steps

1. **Test API Key**: Verify API calls work with your key
2. **Check Service Account**: Confirm permissions are correct
3. **Validate bucket**: Ensure bucket is accessible via API
4. **Test uploads**: Verify objects can be uploaded via API
5. **Check CORS**: Test cross-origin requests work

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach with curl and gcloud
- **[Automation Solution](Automation-Solution.md)** - Scripts and programmatic access

---

## 🎖️ Skills Boost Arcade

This challenge lab teaches you to work with Google Cloud APIs programmatically, essential for building cloud applications!

---

<div align="center">

**💡 Pro Tip**: Understanding APIs is crucial for building scalable cloud applications!

</div>
