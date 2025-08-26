# Getting Started with API Gateway: Challenge Lab - Complete Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-34A853?style=for-the-badge&logo=google&logoColor=white)
![Cloud Run](https://img.shields.io/badge/Cloud%20Run-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Pub/Sub](https://img.shields.io/badge/Pub%2FSub-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 **Lab Tasks Overview**

**Task 1**: Create a Cloud Run function (2nd gen) called `gcfunction`  
**Task 2**: Create an API Gateway to proxy requests to the backend  
**Task 3**: Create a Pub/Sub Topic and Publish Messages via API Backend  

---

## 🚀 **Complete Solution**

### ⚡ **Quick Setup Commands**

```bash
# Set project and region
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1

# Enable required APIs (wait 2-3 minutes for propagation)
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable apigateway.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable servicemanagement.googleapis.com
gcloud services enable pubsub.googleapis.com

echo "✅ APIs enabled. Waiting for propagation..."
sleep 180  # Wait 3 minutes for API propagation
```

---

## 📋 **Task 1: Create a Cloud Run Function**

### **Method 1: Cloud Console (Recommended)**

1. **Go to Cloud Functions** → **CREATE FUNCTION**
2. **Configuration**:
   - **Function name**: `gcfunction`
   - **Region**: `us-central1`
   - **Trigger Type**: `HTTPS`
   - **Authentication**: ✅ **Allow unauthenticated invocations**
3. **Click NEXT**
4. **Runtime**: `Node.js 22`
5. **Entry point**: `helloHttp`
6. **Source code**:

```javascript
// index.js
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.status(200).send('Hello World!');
});
```

```json
// package.json
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
```

7. **Click DEPLOY** and wait for completion

### **Method 2: Cloud Shell**

```bash
# Create function directory
mkdir gcfunction && cd gcfunction

# Create index.js
cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.status(200).send('Hello World!');
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

# Deploy the function
gcloud functions deploy gcfunction \
    --gen2 \
    --runtime=nodejs22 \
    --region=us-central1 \
    --source=. \
    --entry-point=helloHttp \
    --trigger=http \
    --allow-unauthenticated

echo "✅ Task 1 completed: Cloud Run function deployed"

# Get the function URL (save this for Task 2)
FUNCTION_URL=$(gcloud functions describe gcfunction --region=us-central1 --gen2 --format="value(serviceConfig.uri)")
echo "Function URL: $FUNCTION_URL"
```

---

## 📋 **Task 2: Create an API Gateway**

### **Step 1: Create OpenAPI Specification**

```bash
# Get your function URL if not already saved
FUNCTION_URL=$(gcloud functions describe gcfunction --region=us-central1 --gen2 --format="value(serviceConfig.uri)")

# Create OpenAPI spec file with your actual function URL
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
  address: $FUNCTION_URL
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

echo "✅ OpenAPI specification created with URL: $FUNCTION_URL"
```

### **Step 2: Deploy API Gateway**

#### **Console Method (Recommended)**:

1. **Go to API Gateway** → **CREATE GATEWAY**
2. **Upload an API spec**: Select `openapispec.yaml`
3. **Gateway details**:
   - **Display Name**: `gcfunction API`
   - **API ID**: `gcfunction-api`
   - **Location**: `us-central1`
4. **Service Account**: `Compute Engine default service account`
5. **Click CREATE GATEWAY**

⏰ **Wait ~10 minutes for gateway creation** (monitor via notifications bell icon)

#### **CLI Method**:

```bash
# Create API config
gcloud api-gateway api-configs create gcfunction-api \
    --api=gcfunction-api \
    --openapi-spec=openapispec.yaml \
    --project=$PROJECT_ID

# Create API
gcloud api-gateway apis create gcfunction-api \
    --project=$PROJECT_ID

# Create gateway (this takes ~10 minutes)
gcloud api-gateway gateways create gcfunction-api \
    --api=gcfunction-api \
    --api-config=gcfunction-api \
    --location=us-central1 \
    --project=$PROJECT_ID

echo "✅ Task 2 completed: API Gateway deployed"
```

---

## 📋 **Task 3: Create Pub/Sub Topic and Publish Messages**

### **Step 1: Create Pub/Sub Topic**

```bash
# Create Pub/Sub topic with default subscription
gcloud pubsub topics create demo-topic

# Verify topic creation
gcloud pubsub topics list | grep demo-topic
echo "✅ Pub/Sub topic 'demo-topic' created"
```

### **Step 2: Update Cloud Run Function**

#### **Console Method**:

1. **Go to Cloud Functions** → **gcfunction** → **EDIT**
2. **Update package.json**:

```json
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0",
    "@google-cloud/pubsub": "^3.4.1"
  }
}
```

3. **Update index.js**:

```javascript
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const topic = pubsub.topic('demo-topic');
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  // Send a message to the topic
  topic.publishMessage({data: Buffer.from('Hello from Cloud Run functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
});
```

4. **Click DEPLOY**

#### **CLI Method**:

```bash
cd gcfunction

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
const {PubSub} = require('@google-cloud/pubsub');
const pubsub = new PubSub();
const topic = pubsub.topic('demo-topic');
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  // Send a message to the topic
  topic.publishMessage({data: Buffer.from('Hello from Cloud Run functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
});
EOF

# Redeploy the function
gcloud functions deploy gcfunction \
    --gen2 \
    --runtime=nodejs22 \
    --region=us-central1 \
    --source=. \
    --entry-point=helloHttp \
    --trigger=http \
    --allow-unauthenticated

echo "✅ Function updated with Pub/Sub integration"
```

### **Step 3: Test the Complete Workflow**

```bash
# Get API Gateway URL
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=us-central1 --format="value(defaultHostname)")

# Test the API Gateway endpoint
curl "https://$GATEWAY_URL/gcfunction"

# Should return: "Message sent to Topic demo-topic!"

echo "✅ Task 3 completed: Messages published via API Gateway"
```

---

## ✅ **Verification Commands**

```bash
# Check Cloud Run function
gcloud functions describe gcfunction --region=us-central1 --gen2

# Check API Gateway
gcloud api-gateway gateways list --location=us-central1

# Check Pub/Sub topic
gcloud pubsub topics list | grep demo-topic

# Check messages in subscription (wait 5 minutes after API call)
gcloud pubsub subscriptions pull demo-topic-sub --limit=5 --auto-ack

# Test complete workflow
GATEWAY_URL=$(gcloud api-gateway gateways describe gcfunction-api --location=us-central1 --format="value(defaultHostname)")
curl "https://$GATEWAY_URL/gcfunction"
```

---

## 🎯 **One-Click Complete Script**

```bash
#!/bin/bash
# Complete API Gateway Challenge Lab Solution

set -e
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1

echo "🚀 Starting API Gateway Challenge Lab..."

# Enable APIs
echo "📡 Enabling APIs..."
gcloud services enable cloudfunctions.googleapis.com run.googleapis.com apigateway.googleapis.com servicecontrol.googleapis.com servicemanagement.googleapis.com pubsub.googleapis.com
sleep 180

# Task 1: Create Cloud Run Function
echo "📋 Task 1: Creating Cloud Run function..."
mkdir -p gcfunction && cd gcfunction

cat > index.js << 'EOF'
const functions = require('@google-cloud/functions-framework');

functions.http('helloHttp', (req, res) => {
  res.status(200).send('Hello World!');
});
EOF

cat > package.json << 'EOF'
{
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

gcloud functions deploy gcfunction --gen2 --runtime=nodejs22 --region=us-central1 --source=. --entry-point=helloHttp --trigger=http --allow-unauthenticated

FUNCTION_URL=$(gcloud functions describe gcfunction --region=us-central1 --gen2 --format="value(serviceConfig.uri)")
echo "✅ Task 1 completed: Function URL: $FUNCTION_URL"

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
  address: $FUNCTION_URL
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
gcloud api-gateway gateways create gcfunction-api --api=gcfunction-api --api-config=gcfunction-api --location=us-central1 --project=$PROJECT_ID

echo "✅ Task 2 completed: API Gateway created (wait ~10 min for full deployment)"

# Task 3: Create Pub/Sub and update function
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

functions.http('helloHttp', (req, res) => {
  topic.publishMessage({data: Buffer.from('Hello from Cloud Run functions!')});
  res.status(200).send("Message sent to Topic demo-topic!");
});
EOF

gcloud functions deploy gcfunction --gen2 --runtime=nodejs22 --region=us-central1 --source=. --entry-point=helloHttp --trigger=http --allow-unauthenticated

echo "✅ Task 3 completed: Function updated with Pub/Sub integration"

echo "🎉 API Gateway Challenge Lab completed successfully!"
echo "⏰ Wait ~10 minutes for API Gateway to be fully operational"
echo "🧪 Test with: curl 'https://GATEWAY_URL/gcfunction'"
```

---

## ⚠️ **Important Notes**

1. **⏰ API Gateway takes ~10 minutes** to fully deploy
2. **📡 APIs need 3-5 minutes** to propagate after enabling
3. **📬 Pub/Sub messages take ~5 minutes** to appear in subscriptions
4. **🔗 Function URL** must be correctly inserted in OpenAPI spec
5. **📋 Monitor notifications** (bell icon) for deployment status

---

## 🔧 **Troubleshooting**

**Issue**: Function deployment fails  
**Solution**: Wait for APIs to propagate, then retry

**Issue**: API Gateway creation stuck  
**Solution**: Check notifications, it takes ~10 minutes

**Issue**: OpenAPI spec error  
**Solution**: Ensure function URL is correct in `x-google-backend.address`

**Issue**: No messages in Pub/Sub  
**Solution**: Wait 5 minutes, check default subscription exists

---

<div align="center">

**🎉 Congratulations! You've completed the API Gateway Challenge Lab!**

*Solution provided by [CodeWithGarry](https://github.com/codewithgarry) - Your trusted Google Cloud learning partner*

**Next Lab**: [Dataplex Challenge Lab](../04-ARC117-Get-Started-with-Dataplex-Challenge-Lab/)

</div>
  res.status(200).send('Hello World!');
};
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "hello-world",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

# Deploy function
gcloud functions deploy FUNCTION_NAME \
    --runtime nodejs18 \
    --trigger-http \
    --allow-unauthenticated \
    --entry-point helloWorld
```

---

### Task 2: Create API Config

#### Create OpenAPI Specification
```bash
# Get the Cloud Function URL
FUNCTION_URL=$(gcloud functions describe FUNCTION_NAME --format="value(httpsTrigger.url)")

# Create OpenAPI spec
cat > openapi.yaml << EOF
swagger: '2.0'
info:
  title: API Gateway Config
  description: Sample API
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Hello endpoint
      operationId: hello
      x-google-backend:
        address: $FUNCTION_URL
      responses:
        '200':
          description: Success
          schema:
            type: string
EOF

# Create API config
gcloud api-gateway api-configs create CONFIG_NAME \
    --api=API_NAME \
    --openapi-spec=openapi.yaml
```

---

### Task 3: Create and Deploy API Gateway

#### Step 1: Create API
```bash
gcloud api-gateway apis create API_NAME
```

#### Step 2: Create Gateway
```bash
gcloud api-gateway gateways create GATEWAY_NAME \
    --api=API_NAME \
    --api-config=CONFIG_NAME \
    --location=us-central1
```

---

## ✅ Verification

1. **Test Cloud Function**: Visit the function's trigger URL
2. **Test API Gateway**: Get gateway URL and test endpoint:
```bash
# Get gateway URL
GATEWAY_URL=$(gcloud api-gateway gateways describe GATEWAY_NAME \
    --location=us-central1 --format="value(defaultHostname)")

# Test the API
curl https://$GATEWAY_URL/hello
```

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>
