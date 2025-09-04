# ARC125: Use APIs to Work with Cloud Storage: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Storage](https://img.shields.io/badge/Storage%20APIs-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC125 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll use various APIs to interact with Google Cloud Storage programmatically, including REST APIs, client libraries, and JSON API.

## 📋 Challenge Tasks

### Task 1: REST API Operations

Use REST API to perform basic storage operations.

### Task 2: Python Client Library

Implement storage operations using Python client library.

### Task 3: JSON API Integration

Work with the JSON API for advanced operations.

### Task 4: Signed URLs and Authentication

Implement secure access patterns.

### Task 5: Batch Operations

Perform bulk operations efficiently.

---

## 🚀 Solution Method 1: REST API

### Step 1: Setup and Authentication

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-api-demo
export SERVICE_ACCOUNT_NAME=storage-api-sa

# Create bucket
gsutil mb -l us-central1 gs://$BUCKET_NAME

# Create service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Service account for Storage API demo" \
    --display-name="Storage API Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create storage-api-key.json \
    --iam-account=$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com

# Get access token
export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
```

### Step 2: REST API Operations

```bash
# Create a test file
echo "Hello from REST API!" > test-file.txt

# Upload file using REST API
curl -X POST \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: text/plain" \
    --data-binary @test-file.txt \
    "https://storage.googleapis.com/upload/storage/v1/b/$BUCKET_NAME/o?uploadType=media&name=rest-api-upload.txt"

# List objects using REST API
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o"

# Get object metadata
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/rest-api-upload.txt"

# Download file using REST API
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/rest-api-upload.txt?alt=media" \
    -o downloaded-via-rest.txt

# Update object metadata
curl -X PATCH \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"metadata": {"source": "rest-api", "environment": "demo"}}' \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/rest-api-upload.txt"

# Delete object
curl -X DELETE \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o/rest-api-upload.txt"
```

---

## 🚀 Solution Method 2: Python Client Library

### Step 1: Setup Python Environment

```bash
# Create Python script directory
mkdir ~/storage-api-demo
cd ~/storage-api-demo

# Create requirements file
cat > requirements.txt << 'EOF'
google-cloud-storage==2.10.0
google-auth==2.23.0
google-auth-oauthlib==1.1.0
requests==2.31.0
pillow==10.0.0
EOF

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Python Client Library Implementation

```bash
# Create comprehensive Python script
cat > storage_operations.py << 'EOF'
from google.cloud import storage
from google.oauth2 import service_account
import json
import os
from datetime import datetime, timedelta
import requests
from PIL import Image
import io

class CloudStorageManager:
    def __init__(self, project_id, bucket_name, credentials_path=None):
        self.project_id = project_id
        self.bucket_name = bucket_name
        
        if credentials_path:
            credentials = service_account.Credentials.from_service_account_file(
                credentials_path)
            self.client = storage.Client(credentials=credentials, project=project_id)
        else:
            self.client = storage.Client(project=project_id)
        
        self.bucket = self.client.bucket(bucket_name)
    
    def upload_file(self, source_file, destination_name, metadata=None):
        """Upload a file to Cloud Storage"""
        try:
            blob = self.bucket.blob(destination_name)
            
            if metadata:
                blob.metadata = metadata
            
            blob.upload_from_filename(source_file)
            print(f"File {source_file} uploaded to {destination_name}")
            return True
        except Exception as e:
            print(f"Error uploading file: {e}")
            return False
    
    def upload_from_string(self, content, destination_name, content_type='text/plain'):
        """Upload content from string"""
        try:
            blob = self.bucket.blob(destination_name)
            blob.upload_from_string(content, content_type=content_type)
            print(f"String content uploaded to {destination_name}")
            return True
        except Exception as e:
            print(f"Error uploading string: {e}")
            return False
    
    def download_file(self, source_name, destination_file):
        """Download a file from Cloud Storage"""
        try:
            blob = self.bucket.blob(source_name)
            blob.download_to_filename(destination_file)
            print(f"File {source_name} downloaded to {destination_file}")
            return True
        except Exception as e:
            print(f"Error downloading file: {e}")
            return False
    
    def download_as_string(self, source_name):
        """Download file content as string"""
        try:
            blob = self.bucket.blob(source_name)
            content = blob.download_as_text()
            print(f"Downloaded {source_name} as string")
            return content
        except Exception as e:
            print(f"Error downloading as string: {e}")
            return None
    
    def list_objects(self, prefix=None):
        """List objects in bucket"""
        try:
            blobs = self.client.list_blobs(self.bucket_name, prefix=prefix)
            objects = []
            for blob in blobs:
                objects.append({
                    'name': blob.name,
                    'size': blob.size,
                    'created': blob.time_created,
                    'updated': blob.updated,
                    'content_type': blob.content_type,
                    'metadata': blob.metadata
                })
            return objects
        except Exception as e:
            print(f"Error listing objects: {e}")
            return []
    
    def get_object_metadata(self, object_name):
        """Get object metadata"""
        try:
            blob = self.bucket.blob(object_name)
            blob.reload()
            return {
                'name': blob.name,
                'size': blob.size,
                'created': blob.time_created,
                'updated': blob.updated,
                'content_type': blob.content_type,
                'metadata': blob.metadata,
                'etag': blob.etag,
                'crc32c': blob.crc32c,
                'md5_hash': blob.md5_hash
            }
        except Exception as e:
            print(f"Error getting metadata: {e}")
            return None
    
    def update_metadata(self, object_name, metadata):
        """Update object metadata"""
        try:
            blob = self.bucket.blob(object_name)
            blob.metadata = metadata
            blob.patch()
            print(f"Metadata updated for {object_name}")
            return True
        except Exception as e:
            print(f"Error updating metadata: {e}")
            return False
    
    def copy_object(self, source_name, destination_name, destination_bucket=None):
        """Copy object within or between buckets"""
        try:
            source_blob = self.bucket.blob(source_name)
            if destination_bucket:
                dest_bucket = self.client.bucket(destination_bucket)
            else:
                dest_bucket = self.bucket
            
            dest_blob = dest_bucket.blob(destination_name)
            dest_blob.upload_from_string(source_blob.download_as_text())
            print(f"Copied {source_name} to {destination_name}")
            return True
        except Exception as e:
            print(f"Error copying object: {e}")
            return False
    
    def delete_object(self, object_name):
        """Delete an object"""
        try:
            blob = self.bucket.blob(object_name)
            blob.delete()
            print(f"Deleted {object_name}")
            return True
        except Exception as e:
            print(f"Error deleting object: {e}")
            return False
    
    def generate_signed_url(self, object_name, expiration_hours=1, method='GET'):
        """Generate signed URL for temporary access"""
        try:
            blob = self.bucket.blob(object_name)
            url = blob.generate_signed_url(
                version="v4",
                expiration=datetime.utcnow() + timedelta(hours=expiration_hours),
                method=method
            )
            print(f"Generated signed URL for {object_name}")
            return url
        except Exception as e:
            print(f"Error generating signed URL: {e}")
            return None
    
    def batch_upload(self, files_list):
        """Upload multiple files in batch"""
        results = []
        for local_file, remote_name in files_list:
            result = self.upload_file(local_file, remote_name)
            results.append((remote_name, result))
        return results
    
    def process_image(self, image_name, operations):
        """Process image using PIL and upload variations"""
        try:
            # Download original image
            blob = self.bucket.blob(image_name)
            image_data = blob.download_as_bytes()
            
            # Open with PIL
            image = Image.open(io.BytesIO(image_data))
            
            processed_images = []
            
            for operation in operations:
                processed_image = image.copy()
                
                if operation['type'] == 'resize':
                    size = operation['size']
                    processed_image = processed_image.resize(size)
                    suffix = f"_resized_{size[0]}x{size[1]}"
                
                elif operation['type'] == 'thumbnail':
                    size = operation['size']
                    processed_image.thumbnail(size)
                    suffix = f"_thumb_{size[0]}x{size[1]}"
                
                elif operation['type'] == 'convert':
                    format = operation['format']
                    suffix = f"_converted.{format.lower()}"
                
                # Save processed image
                output = io.BytesIO()
                format = operation.get('format', 'JPEG')
                processed_image.save(output, format=format)
                output.seek(0)
                
                # Upload processed image
                base_name = image_name.rsplit('.', 1)[0]
                new_name = f"{base_name}{suffix}"
                
                new_blob = self.bucket.blob(new_name)
                new_blob.upload_from_file(output, content_type=f'image/{format.lower()}')
                
                processed_images.append(new_name)
                print(f"Processed and uploaded: {new_name}")
            
            return processed_images
            
        except Exception as e:
            print(f"Error processing image: {e}")
            return []

def main():
    # Configuration
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-api-demo"
    
    # Initialize storage manager
    storage_mgr = CloudStorageManager(project_id, bucket_name)
    
    # Create sample files
    sample_data = {
        'users.json': json.dumps([
            {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
            {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com'}
        ], indent=2),
        'config.txt': 'environment=production\nversion=1.0\ndebug=false',
        'log.csv': 'timestamp,level,message\n2023-01-01,INFO,Application started\n2023-01-01,DEBUG,Processing request'
    }
    
    # Upload sample files
    print("=== Uploading Sample Files ===")
    for filename, content in sample_data.items():
        storage_mgr.upload_from_string(content, f"samples/{filename}")
    
    # List objects
    print("\n=== Listing Objects ===")
    objects = storage_mgr.list_objects(prefix="samples/")
    for obj in objects:
        print(f"  {obj['name']} ({obj['size']} bytes)")
    
    # Get metadata
    print("\n=== Object Metadata ===")
    metadata = storage_mgr.get_object_metadata("samples/users.json")
    if metadata:
        print(json.dumps(metadata, indent=2, default=str))
    
    # Update metadata
    print("\n=== Updating Metadata ===")
    custom_metadata = {
        'source': 'api-demo',
        'processed_by': 'python-client',
        'timestamp': datetime.now().isoformat()
    }
    storage_mgr.update_metadata("samples/users.json", custom_metadata)
    
    # Generate signed URL
    print("\n=== Generating Signed URL ===")
    signed_url = storage_mgr.generate_signed_url("samples/users.json", expiration_hours=2)
    if signed_url:
        print(f"Signed URL: {signed_url}")
    
    # Copy object
    print("\n=== Copying Object ===")
    storage_mgr.copy_object("samples/users.json", "backup/users_backup.json")
    
    # Download content
    print("\n=== Downloading Content ===")
    content = storage_mgr.download_as_string("samples/config.txt")
    if content:
        print(f"Downloaded content:\n{content}")
    
    print("\n=== Storage Operations Complete ===")

if __name__ == "__main__":
    main()
EOF

# Run the Python script
export GOOGLE_CLOUD_PROJECT=$PROJECT_ID
python storage_operations.py
```

---

## 🚀 Solution Method 3: JSON API Advanced Operations

### Step 1: Batch Operations with JSON API

```bash
# Create batch operations script
cat > batch_operations.py << 'EOF'
import json
import requests
import os
from google.auth.transport.requests import Request
from google.oauth2 import service_account

class StorageBatchOperations:
    def __init__(self, project_id, credentials_path=None):
        self.project_id = project_id
        self.base_url = "https://storage.googleapis.com/batch/storage/v1"
        
        if credentials_path:
            credentials = service_account.Credentials.from_service_account_file(
                credentials_path,
                scopes=['https://www.googleapis.com/auth/cloud-platform']
            )
        else:
            credentials, _ = google.auth.default()
        
        credentials.refresh(Request())
        self.access_token = credentials.token
    
    def create_batch_request(self, operations):
        """Create a batch request for multiple operations"""
        boundary = "batch_boundary_123456789"
        
        batch_body = f"--{boundary}\r\n"
        
        for i, operation in enumerate(operations):
            batch_body += f"Content-Type: application/http\r\n"
            batch_body += f"Content-ID: <item{i}>\r\n\r\n"
            
            method = operation['method']
            url = operation['url']
            headers = operation.get('headers', {})
            body = operation.get('body', '')
            
            batch_body += f"{method} {url} HTTP/1.1\r\n"
            batch_body += f"Authorization: Bearer {self.access_token}\r\n"
            
            for header, value in headers.items():
                batch_body += f"{header}: {value}\r\n"
            
            batch_body += f"\r\n{body}\r\n"
            batch_body += f"--{boundary}\r\n"
        
        batch_body += f"--{boundary}--\r\n"
        
        return batch_body, boundary
    
    def execute_batch(self, operations):
        """Execute batch operations"""
        batch_body, boundary = self.create_batch_request(operations)
        
        headers = {
            'Authorization': f'Bearer {self.access_token}',
            'Content-Type': f'multipart/mixed; boundary={boundary}'
        }
        
        response = requests.post(self.base_url, headers=headers, data=batch_body)
        return response.text

def main():
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-api-demo"
    
    batch_ops = StorageBatchOperations(project_id)
    
    # Define batch operations
    operations = [
        {
            'method': 'GET',
            'url': f'/storage/v1/b/{bucket_name}/o/samples%2Fusers.json'
        },
        {
            'method': 'GET', 
            'url': f'/storage/v1/b/{bucket_name}/o/samples%2Fconfig.txt'
        },
        {
            'method': 'PATCH',
            'url': f'/storage/v1/b/{bucket_name}/o/samples%2Fusers.json',
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'metadata': {
                    'batch_processed': 'true',
                    'batch_timestamp': '2023-01-01T00:00:00Z'
                }
            })
        }
    ]
    
    # Execute batch operations
    result = batch_ops.execute_batch(operations)
    print("Batch operation results:")
    print(result)

if __name__ == "__main__":
    main()
EOF
```

---

## 🔐 Solution Method 4: Advanced Authentication and Security

### Step 1: Signed URLs for Different Operations

```bash
# Create advanced signed URL script
cat > signed_urls_demo.py << 'EOF'
from google.cloud import storage
from datetime import datetime, timedelta
import json

def generate_upload_signed_url(bucket_name, object_name, expiration_hours=1):
    """Generate signed URL for uploading"""
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    
    url = blob.generate_signed_url(
        version="v4",
        expiration=datetime.utcnow() + timedelta(hours=expiration_hours),
        method="PUT",
        content_type="application/octet-stream"
    )
    return url

def generate_download_signed_url(bucket_name, object_name, expiration_hours=1):
    """Generate signed URL for downloading"""
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    
    url = blob.generate_signed_url(
        version="v4",
        expiration=datetime.utcnow() + timedelta(hours=expiration_hours),
        method="GET"
    )
    return url

def test_signed_urls():
    """Test signed URL functionality"""
    import requests
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    bucket_name = f"{project_id}-api-demo"
    
    # Generate upload URL
    upload_url = generate_upload_signed_url(bucket_name, "signed-upload-test.txt")
    print(f"Upload URL: {upload_url}")
    
    # Test upload
    test_content = "This file was uploaded using a signed URL!"
    response = requests.put(
        upload_url, 
        data=test_content,
        headers={'Content-Type': 'text/plain'}
    )
    print(f"Upload response: {response.status_code}")
    
    # Generate download URL
    download_url = generate_download_signed_url(bucket_name, "signed-upload-test.txt")
    print(f"Download URL: {download_url}")
    
    # Test download
    response = requests.get(download_url)
    print(f"Downloaded content: {response.text}")

if __name__ == "__main__":
    test_signed_urls()
EOF

python signed_urls_demo.py
```

---

## ✅ Validation

### Test All API Methods

```bash
# Test REST API
echo "Testing REST API..."
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://storage.googleapis.com/storage/v1/b/$BUCKET_NAME/o"

# Test Python client library
echo "Testing Python client..."
python storage_operations.py

# Test batch operations
echo "Testing batch operations..."
python batch_operations.py

# Test signed URLs
echo "Testing signed URLs..."
python signed_urls_demo.py

# Verify all files exist
echo "Listing all objects:"
gsutil ls -r gs://$BUCKET_NAME/
```

---

## 🔧 Troubleshooting

**Issue**: Authentication failures
- Check service account key permissions
- Verify token expiration
- Ensure correct scopes

**Issue**: Batch operations fail
- Validate batch request format
- Check individual operation syntax
- Review response parsing

**Issue**: Signed URLs not working
- Verify clock synchronization
- Check URL encoding
- Validate expiration times

---

## 📚 Key Learning Points

- **API Varieties**: REST API, JSON API, and client libraries
- **Authentication**: Service accounts and signed URLs
- **Batch Operations**: Efficient bulk operations
- **Error Handling**: Robust error management
- **Security**: Secure access patterns and temporary URLs

---

## 🏆 Challenge Complete!

You've successfully demonstrated Storage API usage through:
- ✅ REST API operations for basic storage tasks
- ✅ Python client library for advanced operations
- ✅ JSON API for batch processing
- ✅ Signed URLs for secure temporary access
- ✅ Authentication and security best practices

<div align="center">

**🎉 Congratulations! You've completed ARC125!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC110%20Data%20Lake-blue?style=for-the-badge)](../8-ARC110-Create-a-Streaming-Data-Lake-on-Cloud-Storage-Challenge-Lab/)

</div>
