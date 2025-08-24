# Getting Started with API Gateway: Challenge Lab - Complete Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Cloud Run](https://img.shields.io/badge/Cloud%20Run-4CAF50?style=for-the-badge&logo=google&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FFC107?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Credits**: 1 | **Level**: Introductory

</div>

---

## 👨‍💻 Author Profile

<div align="center">

### **CodeWithGarry** 
*Google Cloud Solutions Architect & DevOps Engineer*

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

**🎯 Mission**: Helping developers master Google Cloud technologies through practical challenge lab solutions

</div>

---

## 📋 Challenge Overview

**Scenario**: You're a junior data analyst helping a development team expose backend services as APIs using Google Cloud API Gateway.

**Objective**: Build a complete serverless API solution with Cloud Run functions, API Gateway, and Pub/Sub integration.

**Architecture**:
```
API Gateway → Cloud Run Function → Pub/Sub Topic
```

---

## 🚀 Pre-requisites Setup

```bash
# Set your project variables
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
REGION="us-central1"  # Replace with your lab region

echo "Project ID: $PROJECT_ID"
echo "Project Number: $PROJECT_NUMBER"
echo "Region: $REGION"

# Enable required APIs
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable apigateway.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable run.googleapis.com
```

---

## 📝 Task Solutions

### 🎯 Task 1: Create a Cloud Run Function

#### **Method 1: Using gcloud CLI (Recommended)**

```bash
# Create function directory
mkdir gcfunction-source
cd gcfunction-source

# Create package.json
cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

# Create index.js
cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.status(200).send('Hello World!');
});
EOF

# Deploy the Cloud Run function
gcloud functions deploy gcfunction \
  --gen2 \
  --runtime=nodejs22 \
  --region=$REGION \
  --source=. \
  --entry-point=helloHttp \
  --trigger=http \
  --allow-unauthenticated

# Get function URL
FUNCTION_URL=$(gcloud functions describe gcfunction --region=$REGION --gen2 --format="value(serviceConfig.uri)")
echo "Function URL: $FUNCTION_URL"
```

#### **Method 2: Using Google Cloud Console**

1. **Navigation**: **☰ Menu** → **Cloud Functions**
2. Click **🆕 CREATE FUNCTION**
3. **Configuration**:
   - **Function name**: `gcfunction`
   - **Region**: `us-central1` (or your lab region)
   - **Trigger type**: HTTP
   - **Authentication**: ✅ Allow unauthenticated invocations
4. **Runtime**: Node.js 22
5. **Source code**: Inline editor
6. **Entry point**: `helloHttp`
7. **Code**:
   ```javascript
   const functions = require('@google-cloud/functions-framework');

   functions.http('helloHttp', (req, res) => {
     res.status(200).send('Hello World!');
   });
   ```
8. Click **DEPLOY**

---

### 🎯 Task 2: Create an API Gateway

#### **Step 1: Create OpenAPI Specification File**

```bash
# Create the OpenAPI spec file
cat > openapispec.yaml << EOF
swagger: '2.0'
info:
  title: gcfunction API
  description: Sample API on API Gateway with a Google Cloud Run functions backend
  version: 1.0.0
schemes:
- https
produces:
- application/json
x-google-backend:
  address: https://gcfunction-$PROJECT_NUMBER.$REGION.run.app
paths:
  /gcfunction:
    get:
      summary: gcfunction
      operationId: gcfunction
      responses:
       '200':
          description: A successful response
          schema:
            type: string
EOF

echo "✅ OpenAPI specification created"
```

#### **Step 2: Deploy API Gateway using gcloud**

```bash
# Create API configuration
gcloud api-gateway api-configs create gcfunction-api \
  --api=gcfunction-api \
  --openapi-spec=openapispec.yaml \
  --project=$PROJECT_ID

# Create the API
gcloud api-gateway apis create gcfunction-api \
  --project=$PROJECT_ID

# Create the gateway
gcloud api-gateway gateways create gcfunction-api \
  --api=gcfunction-api \
  --api-config=gcfunction-api \
  --location=$REGION \
  --project=$PROJECT_ID

# Get gateway URL
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=$REGION --format="value(defaultHostname)")
echo "API Gateway URL: https://$GATEWAY_URL"
```

#### **Method 2: Using Google Cloud Console**

1. **Navigation**: **☰ Menu** → **API Gateway**
2. Click **🆕 CREATE GATEWAY**
3. **API Configuration**:
   - **Display Name**: `gcfunction API`
   - **API ID**: `gcfunction-api`
   - **Upload an OpenAPI Spec**: Select `openapispec.yaml`
4. **Gateway Details**:
   - **Display Name**: `gcfunction API`
   - **Location**: Your lab region
   - **Service Account**: Compute Engine default service account
5. Click **CREATE GATEWAY**

**⏳ Note**: Gateway creation takes ~10 minutes. Wait for completion before proceeding.

---

### 🎯 Task 3: Create Pub/Sub Topic and Update Function

#### **Step 1: Create Pub/Sub Topic**

```bash
# Create Pub/Sub topic with default subscription
gcloud pubsub topics create demo-topic

# Verify topic creation
gcloud pubsub topics list | grep demo-topic
echo "✅ Pub/Sub topic 'demo-topic' created"
```

#### **Step 2: Update Cloud Run Function**

```bash
# Navigate to function source directory
cd gcfunction-source

# Update package.json
cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^3.4.1"
  }
}
EOF

# Update index.js
cat > index.js << 'EOF'
/**
 * Responds to any HTTP request.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const topic = pubsub.topic('demo-topic');
const functions = require('@google-cloud/functions-framework');

exports.helloHttp = functions.http('helloHttp', (req, res) => {

  // Send a message to the topic
  topic.publishMessage({data: Buffer.from('Hello from Cloud Run functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
});
EOF

# Redeploy the function
gcloud functions deploy gcfunction \
  --gen2 \
  --runtime=nodejs22 \
  --region=$REGION \
  --source=. \
  --entry-point=helloHttp \
  --trigger=http \
  --allow-unauthenticated

echo "✅ Function updated and redeployed"
```

#### **Step 3: Test the Complete Solution**

```bash
# Test API Gateway endpoint
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=$REGION --format="value(defaultHostname)")

# Invoke the API
curl https://$GATEWAY_URL/gcfunction

# Check Pub/Sub messages (wait 5 minutes for messages to appear)
gcloud pubsub subscriptions pull demo-topic-sub --auto-ack --limit=5

echo "✅ API Gateway integration test completed"
```

---

## 🔍 Verification Steps

### **Check Cloud Run Function**
```bash
# Verify function deployment
gcloud functions describe gcfunction --region=$REGION --gen2

# Test function directly
FUNCTION_URL=$(gcloud functions describe gcfunction --region=$REGION --gen2 --format="value(serviceConfig.uri)")
curl $FUNCTION_URL
```

### **Check API Gateway**
```bash
# Verify API Gateway status
gcloud api-gateway gateways describe gcfunction-api --location=$REGION

# Get gateway URL
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=$REGION --format="value(defaultHostname)")
echo "API Gateway URL: https://$GATEWAY_URL"
```

### **Check Pub/Sub Topic**
```bash
# Verify topic and subscription
gcloud pubsub topics list | grep demo-topic
gcloud pubsub subscriptions list | grep demo-topic

# Check messages
gcloud pubsub subscriptions pull demo-topic-sub --auto-ack --limit=10
```

---

## 🐛 Troubleshooting Guide

### **Issue 1: Function Deployment Fails**
```bash
# Check enabled APIs
gcloud services list --enabled | grep -E "(cloudfunctions|run)"

# Retry deployment with verbose output
gcloud functions deploy gcfunction --gen2 --runtime=nodejs22 --region=$REGION --verbosity=debug
```

### **Issue 2: API Gateway Creation Timeout**
```bash
# Check gateway status
gcloud api-gateway gateways list --location=$REGION

# Monitor operation status
gcloud api-gateway operations list --location=$REGION
```

### **Issue 3: Pub/Sub Messages Not Appearing**
```bash
# Check topic permissions
gcloud pubsub topics get-iam-policy demo-topic

# Manually test Pub/Sub
gcloud pubsub topics publish demo-topic --message="Test message"
gcloud pubsub subscriptions pull demo-topic-sub --auto-ack
```

---

## 🚀 Complete Automation Script

```bash
#!/bin/bash

# API Gateway Challenge Lab - Complete Automation
set -e

# Variables
PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
REGION="us-central1"  # Update with your lab region

echo "🚀 Starting API Gateway Challenge Lab..."

# Enable APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudfunctions.googleapis.com apigateway.googleapis.com servicecontrol.googleapis.com servicemanagement.googleapis.com pubsub.googleapis.com run.googleapis.com

# Task 1: Create Cloud Run Function
echo "📋 Task 1: Creating Cloud Run function..."
mkdir -p gcfunction-source && cd gcfunction-source

cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.status(200).send('Hello World!');
});
EOF

gcloud functions deploy gcfunction --gen2 --runtime=nodejs22 --region=$REGION --source=. --entry-point=helloHttp --trigger=http --allow-unauthenticated
echo "✅ Task 1 completed"

# Task 2: Create API Gateway
echo "📋 Task 2: Creating API Gateway..."
cat > openapispec.yaml << EOF
swagger: '2.0'
info:
  title: gcfunction API
  description: Sample API on API Gateway with a Google Cloud Run functions backend
  version: 1.0.0
schemes:
- https
produces:
- application/json
x-google-backend:
  address: https://gcfunction-$PROJECT_NUMBER.$REGION.run.app
paths:
  /gcfunction:
    get:
      summary: gcfunction
      operationId: gcfunction
      responses:
       '200':
          description: A successful response
          schema:
            type: string
EOF

gcloud api-gateway apis create gcfunction-api --project=$PROJECT_ID
gcloud api-gateway api-configs create gcfunction-api --api=gcfunction-api --openapi-spec=openapispec.yaml --project=$PROJECT_ID
gcloud api-gateway gateways create gcfunction-api --api=gcfunction-api --api-config=gcfunction-api --location=$REGION --project=$PROJECT_ID

echo "✅ Task 2 completed (Gateway creation in progress - takes ~10 minutes)"

# Task 3: Create Pub/Sub and Update Function
echo "📋 Task 3: Creating Pub/Sub topic and updating function..."
gcloud pubsub topics create demo-topic

cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^3.4.1"
  }
}
EOF

cat > index.js << 'EOF'
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const topic = pubsub.topic('demo-topic');
const functions = require('@google-cloud/functions-framework');

exports.helloHttp = functions.http('helloHttp', (req, res) => {
  topic.publishMessage({data: Buffer.from('Hello from Cloud Run functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
});
EOF

gcloud functions deploy gcfunction --gen2 --runtime=nodejs22 --region=$REGION --source=. --entry-point=helloHttp --trigger=http --allow-unauthenticated

echo "✅ Task 3 completed"

# Final verification
echo "🧪 Final verification..."
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=$REGION --format="value(defaultHostname)" 2>/dev/null || echo "Gateway still creating...")
echo "🌐 API Gateway URL: https://$GATEWAY_URL"

echo "🎉 Challenge Lab completed successfully!"
echo "📝 Note: Wait for API Gateway creation to complete (~10 minutes) before testing"
```

---

## ✅ Final Verification Checklist

- [ ] **Cloud Run Function**: `gcfunction` deployed with Node.js 22
- [ ] **Function Response**: Returns "Hello World!" initially
- [ ] **API Gateway**: `gcfunction-api` created and configured
- [ ] **OpenAPI Spec**: Properly configured with correct backend URL
- [ ] **Pub/Sub Topic**: `demo-topic` created with default subscription
- [ ] **Updated Function**: Publishes messages to Pub/Sub topic
- [ ] **API Integration**: Gateway successfully proxies to function
- [ ] **Message Flow**: Messages appear in Pub/Sub subscription

**Lab completion time**: 35-45 minutes

---

<div align="center">

## 🎯 **About This Solution**

This comprehensive API Gateway challenge lab solution is crafted by **CodeWithGarry** to help you master serverless API development on Google Cloud Platform.

### 📞 **Connect with CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

### 🌟 **Why Choose Our Solutions?**

✅ **Production Ready**: Enterprise-grade configurations  
✅ **Complete Coverage**: All challenge scenarios covered  
✅ **Expert Guidance**: Professional insights and tips  
✅ **Automation Scripts**: One-click deployment solutions  

---

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Building the future of serverless APIs, one challenge lab at a time."*

**Happy Learning! 🚀☁️**

</div>
