# Getting Started with API Gateway: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Challenge Tasks

**Task 1**: Deploy a Cloud Function  
**Task 2**: Create an API config  
**Task 3**: Create and deploy an API Gateway

---

## 🚀 Solutions

### Task 1: Deploy Cloud Function

#### Method 1: Google Cloud Console
1. Go to **Cloud Functions**
2. Click **CREATE FUNCTION**
3. **Function name**: Use the name specified in lab
4. **Trigger**: HTTP
5. **Authentication**: Allow unauthenticated invocations
6. **Runtime**: Node.js 18
7. **Source Code**: Use provided code or default Hello World
8. Click **DEPLOY**

#### Method 2: Cloud Shell
```bash
# Create function directory
mkdir cloud-function && cd cloud-function

# Create index.js
cat > index.js << 'EOF'
exports.helloWorld = (req, res) => {
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
