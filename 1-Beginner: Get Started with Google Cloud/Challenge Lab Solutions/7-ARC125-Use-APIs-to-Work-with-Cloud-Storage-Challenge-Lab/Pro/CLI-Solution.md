# Use APIs to Work with Cloud Storage: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-34A853?style=for-the-badge&logo=google&logoColor=white)
![curl](https://img.shields.io/badge/curl-073551?style=for-the-badge&logo=curl&logoColor=white)

**Lab ID**: ARC125 | **Duration**: 30 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Solution (Cloud Shell & APIs)

This solution uses command-line tools and direct API calls for Cloud Storage management.

---

## ⚠️ IMPORTANT: Set Variables

```bash
# Set your lab-specific values
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME="your-bucket-name-from-lab"
export SERVICE_ACCOUNT_NAME="storage-api-sa"
export API_KEY_NAME="storage-api-key"
```

---

## 🚀 Complete CLI Solution

### Task 1: Enable APIs and create credentials

```bash
# Enable required APIs
gcloud services enable storage.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable serviceusage.googleapis.com

# Create API key
gcloud alpha services api-keys create \
    --display-name="$API_KEY_NAME" \
    --api-target=service=storage.googleapis.com

# Get API key value
export API_KEY=$(gcloud alpha services api-keys get-key-string \
    $(gcloud alpha services api-keys list --filter="displayName:$API_KEY_NAME" --format="value(name)"))

echo "API Key created: $API_KEY"
```

### Task 2: Create Service Account

```bash
# Create service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="Storage API Service Account" \
    --description="For Cloud Storage API access"

# Grant Storage Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create ~/key.json \
    --iam-account="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Activate service account
gcloud auth activate-service-account --key-file=~/key.json
```

### Task 3: Create bucket using API

```bash
# Create bucket using REST API
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d '{
        "name": "'$BUCKET_NAME'",
        "location": "US",
        "storageClass": "STANDARD"
    }' \
    "https://storage.googleapis.com/storage/v1/b?project=$PROJECT_ID"

# Verify bucket creation
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME"
```

### Task 4: Upload objects using API

```bash
# Create test files
echo "Hello from API upload!" > api-test.txt
echo "Second test file" > api-test2.txt

# Upload using simple upload
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: text/plain" \
    -T api-test.txt \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=api-test.txt"

# Upload using multipart upload
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -F "metadata={\"name\":\"api-test2.txt\"};type=application/json;charset=UTF-8" \
    -F "file=@api-test2.txt;type=text/plain" \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=multipart"
```

### Task 5: Manage objects via API

```bash
# List objects
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o"

# Get object metadata
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/api-test.txt"

# Download object
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/api-test.txt?alt=media" \
    -o downloaded-file.txt

# Update object metadata
curl -X PATCH \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d '{
        "metadata": {
            "custom-key": "custom-value"
        }
    }' \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/api-test.txt"
```

### Task 6: Configure bucket settings

```bash
# Update bucket CORS
curl -X PATCH \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d '{
        "cors": [
            {
                "origin": ["*"],
                "method": ["GET", "POST"],
                "responseHeader": ["Content-Type"],
                "maxAgeSeconds": 3600
            }
        ]
    }' \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME"

# Set bucket labels
curl -X PATCH \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d '{
        "labels": {
            "environment": "test",
            "team": "api-demo"
        }
    }' \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME"
```

---

## 📊 Advanced API Operations

### Batch operations
```bash
# Batch request for multiple operations
curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: multipart/mixed; boundary=batch_boundary" \
    -d $'--batch_boundary\r
Content-Type: application/http\r
\r
GET /storage/v1/b/'$BUCKET_NAME'/o/api-test.txt\r
\r
--batch_boundary\r
Content-Type: application/http\r
\r
GET /storage/v1/b/'$BUCKET_NAME'/o/api-test2.txt\r
\r
--batch_boundary--\r' \
    "https://www.googleapis.com/batch/storage/v1"
```

### Signed URLs
```bash
# Generate signed URL (requires gsutil)
gsutil signurl -d 1h ~/key.json gs://$BUCKET_NAME/api-test.txt
```

---

## ✅ Verification Commands

```bash
# Test API access with API key
curl -X GET \
    "https://storage.googleapis.com/storage/v1/b?project=$PROJECT_ID&key=$API_KEY"

# Verify bucket exists
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME"

# Check object count
curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o" | jq '.items | length'

# Test public access
curl -I "https://storage.googleapis.com/$BUCKET_NAME/api-test.txt"
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[Automation Solution](Automation-Solution.md)** - Scripts and programmatic access

---

## 🎖️ Skills Boost Arcade

Master Cloud Storage APIs with this comprehensive CLI approach for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Understanding REST APIs is essential for building cloud-native applications!

</div>
