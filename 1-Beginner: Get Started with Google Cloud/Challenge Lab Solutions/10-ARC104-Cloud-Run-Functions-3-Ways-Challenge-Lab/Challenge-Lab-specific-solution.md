# ARC104: Cloud Run Functions: 3 Ways: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Functions](https://img.shields.io/badge/Cloud%20Functions-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC104 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

Deploy serverless functions using Google Cloud Functions in three different ways: HTTP trigger, Pub/Sub trigger, and Cloud Storage trigger.

## 📋 Challenge Tasks

### Task 1: HTTP-Triggered Function

Create a function that responds to HTTP requests.

### Task 2: Pub/Sub-Triggered Function

Create a function triggered by Pub/Sub messages.

### Task 3: Storage-Triggered Function  

Create a function triggered by Cloud Storage events.

---

## 🚀 Solution Method 1: HTTP-Triggered Function

### Step 1: Create HTTP Function

```bash
# Create project directory
mkdir ~/cloud-functions-demo
cd ~/cloud-functions-demo

# Create main function file
cat > main.py << 'EOF'
import functions_framework
from flask import jsonify
import json
from datetime import datetime

@functions_framework.http
def hello_http(request):
    """HTTP-triggered function"""
    
    # Handle CORS
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST',
            'Access-Control-Allow-Headers': 'Content-Type',
        }
        return ('', 204, headers)
    
    # Set CORS headers for main request
    headers = {'Access-Control-Allow-Origin': '*'}
    
    try:
        # Get request data
        request_json = request.get_json(silent=True)
        request_args = request.args
        
        name = request_json.get('name') if request_json else request_args.get('name', 'World')
        
        response_data = {
            'message': f'Hello {name}!',
            'timestamp': datetime.now().isoformat(),
            'method': request.method,
            'function_type': 'HTTP-triggered',
            'source': 'Cloud Functions Gen 2'
        }
        
        return (jsonify(response_data), 200, headers)
        
    except Exception as e:
        error_response = {
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }
        return (jsonify(error_response), 500, headers)
EOF

# Create requirements file
cat > requirements.txt << 'EOF'
functions-framework==3.5.0
flask==2.3.3
EOF
```

### Step 2: Deploy HTTP Function

```bash
# Deploy the function
gcloud functions deploy hello-http \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=hello_http \
    --trigger-http \
    --allow-unauthenticated

# Get the function URL
export HTTP_FUNCTION_URL=$(gcloud functions describe hello-http \
    --region=us-central1 \
    --format='value(serviceConfig.uri)')

echo "HTTP Function URL: $HTTP_FUNCTION_URL"

# Test the function
curl -X POST "$HTTP_FUNCTION_URL" \
    -H "Content-Type: application/json" \
    -d '{"name": "CodeWithGarry"}'
```

---

## 🚀 Solution Method 2: Pub/Sub-Triggered Function

### Step 1: Create Pub/Sub Topic and Subscription

```bash
# Create Pub/Sub topic
gcloud pubsub topics create function-trigger-topic

# Create subscription for testing
gcloud pubsub subscriptions create function-trigger-sub \
    --topic=function-trigger-topic
```

### Step 2: Create Pub/Sub Function

```bash
# Create pubsub function file
cat > pubsub_function.py << 'EOF'
import base64
import json
import functions_framework
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.cloud_event
def process_pubsub_message(cloud_event):
    """Pub/Sub triggered function"""
    
    try:
        # Decode the Pub/Sub message
        pubsub_message = base64.b64decode(cloud_event.data["message"]["data"]).decode('utf-8')
        
        logger.info(f"Received message: {pubsub_message}")
        
        # Parse JSON if possible
        try:
            message_data = json.loads(pubsub_message)
        except json.JSONDecodeError:
            message_data = {"raw_message": pubsub_message}
        
        # Process the message
        processed_data = {
            "original_message": message_data,
            "processed_at": datetime.now().isoformat(),
            "function_type": "Pub/Sub-triggered",
            "message_id": cloud_event.data["message"]["messageId"],
            "publish_time": cloud_event.data["message"]["publishTime"]
        }
        
        logger.info(f"Processed data: {json.dumps(processed_data, indent=2)}")
        
        # In a real scenario, you might:
        # - Store data in a database
        # - Send to another service
        # - Transform and forward to another topic
        
        return "Message processed successfully"
        
    except Exception as e:
        logger.error(f"Error processing message: {str(e)}")
        raise e
EOF
```

### Step 3: Deploy Pub/Sub Function

```bash
# Deploy the Pub/Sub function
gcloud functions deploy process-pubsub \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=process_pubsub_message \
    --trigger-topic=function-trigger-topic

# Test the function by publishing a message
gcloud pubsub topics publish function-trigger-topic \
    --message='{"user_id": 123, "action": "login", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'

# Check function logs
gcloud functions logs read process-pubsub \
    --region=us-central1 \
    --limit=10
```

---

## 🚀 Solution Method 3: Storage-Triggered Function

### Step 1: Create Storage Bucket

```bash
# Create bucket for triggering function
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-function-trigger

gsutil mb -l us-central1 gs://$BUCKET_NAME
```

### Step 2: Create Storage Function

```bash
# Create storage function file
cat > storage_function.py << 'EOF'
import functions_framework
import json
from datetime import datetime
import logging
from google.cloud import storage
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.cloud_event
def process_file_upload(cloud_event):
    """Storage triggered function"""
    
    try:
        # Get event data
        data = cloud_event.data
        
        bucket_name = data['bucket']
        file_name = data['name']
        event_type = data['eventType']
        
        logger.info(f"Event: {event_type} for file: {file_name} in bucket: {bucket_name}")
        
        # Initialize storage client
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        
        # Get file metadata
        blob.reload()
        
        file_info = {
            "file_name": file_name,
            "bucket_name": bucket_name,
            "event_type": event_type,
            "file_size": blob.size,
            "content_type": blob.content_type,
            "created": data.get('timeCreated'),
            "updated": data.get('updated'),
            "processed_at": datetime.now().isoformat()
        }
        
        logger.info(f"File info: {json.dumps(file_info, indent=2)}")
        
        # Example processing based on file type
        if file_name.endswith('.txt'):
            # Process text files
            content = blob.download_as_text()
            word_count = len(content.split())
            file_info['word_count'] = word_count
            logger.info(f"Text file contains {word_count} words")
            
        elif file_name.endswith(('.jpg', '.png', '.gif')):
            # Process image files
            file_info['file_type'] = 'image'
            logger.info("Image file detected")
            # Could integrate with Vision API for analysis
            
        elif file_name.endswith('.json'):
            # Process JSON files
            content = blob.download_as_text()
            try:
                json_data = json.loads(content)
                file_info['json_keys'] = list(json_data.keys()) if isinstance(json_data, dict) else None
                logger.info("JSON file processed")
            except json.JSONDecodeError:
                logger.warning("Invalid JSON file")
        
        # In a real scenario, you might:
        # - Save metadata to a database
        # - Trigger additional processing
        # - Send notifications
        # - Generate thumbnails for images
        
        return f"Successfully processed {event_type} for {file_name}"
        
    except Exception as e:
        logger.error(f"Error processing file event: {str(e)}")
        raise e
EOF

# Create requirements for storage function
cat > requirements_storage.txt << 'EOF'
functions-framework==3.5.0
google-cloud-storage==2.10.0
EOF
```

### Step 3: Deploy Storage Function

```bash
# Deploy the storage function
gcloud functions deploy process-file-upload \
    --gen2 \
    --runtime=python311 \
    --region=us-central1 \
    --source=. \
    --entry-point=process_file_upload \
    --trigger-bucket=$BUCKET_NAME \
    --requirements-file=requirements_storage.txt

# Test the function by uploading files
echo "Hello from Cloud Functions demo!" > test-file.txt
echo '{"message": "Test JSON file", "timestamp": "'$(date -Iseconds)'"}' > test-data.json

gsutil cp test-file.txt gs://$BUCKET_NAME/
gsutil cp test-data.json gs://$BUCKET_NAME/

# Check function logs
gcloud functions logs read process-file-upload \
    --region=us-central1 \
    --limit=10
```

---

## 🔄 Advanced Integration Example

### Multi-Function Workflow

```bash
# Create a workflow that chains all three functions
cat > workflow_function.py << 'EOF'
import functions_framework
import json
from google.cloud import pubsub_v1
from google.cloud import storage
import requests
import os

@functions_framework.http
def orchestrate_workflow(request):
    """Orchestrates a workflow using all three function types"""
    
    try:
        # Parse request
        request_json = request.get_json()
        workflow_id = request_json.get('workflow_id', 'default')
        data = request_json.get('data', {})
        
        # Step 1: Save data to storage (triggers storage function)
        storage_client = storage.Client()
        bucket = storage_client.bucket(os.environ.get('BUCKET_NAME'))
        blob = bucket.blob(f'workflows/{workflow_id}.json')
        blob.upload_from_string(json.dumps(data))
        
        # Step 2: Publish message to Pub/Sub (triggers pubsub function)
        publisher = pubsub_v1.PublisherClient()
        topic_path = publisher.topic_path(
            os.environ.get('GOOGLE_CLOUD_PROJECT'), 
            'function-trigger-topic'
        )
        
        message_data = {
            'workflow_id': workflow_id,
            'step': 'pubsub_processing',
            'data': data
        }
        
        publisher.publish(topic_path, json.dumps(message_data).encode('utf-8'))
        
        # Step 3: Return workflow status
        return {
            'workflow_id': workflow_id,
            'status': 'initiated',
            'steps_triggered': ['storage_function', 'pubsub_function'],
            'storage_file': f'workflows/{workflow_id}.json'
        }
        
    except Exception as e:
        return {'error': str(e)}, 500
EOF
```

---

## ✅ Validation

### Test All Functions

```bash
# Test HTTP function
curl -X POST "$HTTP_FUNCTION_URL" \
    -H "Content-Type: application/json" \
    -d '{"name": "Cloud Functions Test"}'

# Test Pub/Sub function
gcloud pubsub topics publish function-trigger-topic \
    --message='{"test": "pubsub trigger", "value": 42}'

# Test Storage function
echo "Storage trigger test" > trigger-test.txt
gsutil cp trigger-test.txt gs://$BUCKET_NAME/

# Check all function logs
gcloud functions logs read --region=us-central1 --limit=20
```

### Monitor Function Performance

```bash
# List all functions
gcloud functions list --regions=us-central1

# Get function details
gcloud functions describe hello-http --region=us-central1
gcloud functions describe process-pubsub --region=us-central1  
gcloud functions describe process-file-upload --region=us-central1

# View metrics in Cloud Console
echo "View metrics at: https://console.cloud.google.com/functions"
```

---

## 🔧 Troubleshooting

**Issue**: Function deployment fails
- Check Python syntax and requirements.txt
- Verify IAM permissions
- Ensure APIs are enabled

**Issue**: Pub/Sub function not triggering
- Check topic exists and function is subscribed
- Verify message format
- Check function logs for errors

**Issue**: Storage function not triggering
- Verify bucket exists and function has access
- Check if file upload was successful
- Review Cloud Storage bucket notifications

---

## 📚 Key Learning Points

- **Serverless Architecture**: Understanding event-driven computing
- **Trigger Types**: HTTP, Pub/Sub, and Storage triggers
- **Function Lifecycle**: Deployment, execution, and monitoring
- **Error Handling**: Implementing robust error handling
- **Integration Patterns**: Chaining functions for workflows

---

## 🏆 Challenge Complete!

You've successfully demonstrated Cloud Functions using three trigger types:
- ✅ HTTP-triggered function for web requests
- ✅ Pub/Sub-triggered function for event processing
- ✅ Storage-triggered function for file processing

<div align="center">

**🎉 Congratulations! You've completed ARC104!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC131%20Speech%20API-blue?style=for-the-badge)](../11-ARC131-Using-the-Google-Cloud-Speech-API-Challenge-Lab/)

</div>
