# Getting Started with API Gateway: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Method](https://img.shields.io/badge/Method-CLI-FBBC04?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Method - Fast & Efficient

### 📋 Lab Requirements
```bash
# Set variables (replace with your lab values)
export FUNCTION_NAME="your-function-name"
export API_GATEWAY_NAME="your-gateway-name"
export REGION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)
```

---

## 🚀 Task 1: Deploy Cloud Function

```bash
# Create function directory
mkdir api-function && cd api-function

# Create function code
cat > index.js << 'EOF'
exports.helloWorld = (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  res.status(200).send('Hello from API Gateway!');
};
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "api-gateway-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {}
}
EOF

# Deploy function
gcloud functions deploy $FUNCTION_NAME \
    --runtime nodejs18 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point helloWorld

# Get function URL
export FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME \
    --region $REGION \
    --format="value(httpsTrigger.url)")

echo "Function URL: $FUNCTION_URL"
```

---

## 🚀 Task 2: Create API Config

```bash
# Create OpenAPI specification
cat > openapi-spec.yaml << EOF
swagger: '2.0'
info:
  title: Cloud Function API
  description: Sample API on API Gateway
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /hello:
    get:
      summary: Hello World
      operationId: hello
      x-google-backend:
        address: $FUNCTION_URL
      responses:
        '200':
          description: A successful response
          schema:
            type: string
EOF

# Create API
gcloud api-gateway apis create $API_GATEWAY_NAME

# Create API config
gcloud api-gateway api-configs create ${API_GATEWAY_NAME}-config \
    --api=$API_GATEWAY_NAME \
    --openapi-spec=openapi-spec.yaml \
    --backend-auth-service-account=$(gcloud config get-value account)
```

---

## 🚀 Task 3: Create and Deploy API Gateway

```bash
# Create API Gateway
gcloud api-gateway gateways create $API_GATEWAY_NAME \
    --api=$API_GATEWAY_NAME \
    --api-config=${API_GATEWAY_NAME}-config \
    --location=$REGION

# Get gateway URL
export GATEWAY_URL=$(gcloud api-gateway gateways describe $API_GATEWAY_NAME \
    --location=$REGION \
    --format="value(defaultHostname)")

echo "Gateway URL: https://$GATEWAY_URL"

# Test the endpoint
curl -X GET "https://$GATEWAY_URL/hello"
```

---

## 🔍 Verification Commands

```bash
# Check function status
gcloud functions describe $FUNCTION_NAME --region $REGION

# Check API status
gcloud api-gateway apis describe $API_GATEWAY_NAME

# Check gateway status
gcloud api-gateway gateways describe $API_GATEWAY_NAME --location=$REGION

# Test the complete flow
curl -X GET "https://$GATEWAY_URL/hello"
```

---

## 🎯 One-Liner Complete Solution

```bash
# Set your lab values first
export FUNCTION_NAME="your-function-name"
export API_GATEWAY_NAME="your-gateway-name"
export REGION="us-central1"

# Complete solution
mkdir api-function && cd api-function && \
echo 'exports.helloWorld = (req, res) => { res.set("Access-Control-Allow-Origin", "*"); res.status(200).send("Hello from API Gateway!"); };' > index.js && \
echo '{"name":"api-gateway-function","version":"1.0.0","main":"index.js","dependencies":{}}' > package.json && \
gcloud functions deploy $FUNCTION_NAME --runtime nodejs18 --trigger-http --allow-unauthenticated --region $REGION --entry-point helloWorld && \
FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region $REGION --format="value(httpsTrigger.url)") && \
echo "swagger: '2.0'
info:
  title: Cloud Function API
  version: 1.0.0
paths:
  /hello:
    get:
      x-google-backend:
        address: $FUNCTION_URL
      responses:
        '200':
          description: Success" > openapi-spec.yaml && \
gcloud api-gateway apis create $API_GATEWAY_NAME && \
gcloud api-gateway api-configs create ${API_GATEWAY_NAME}-config --api=$API_GATEWAY_NAME --openapi-spec=openapi-spec.yaml && \
gcloud api-gateway gateways create $API_GATEWAY_NAME --api=$API_GATEWAY_NAME --api-config=${API_GATEWAY_NAME}-config --location=$REGION
```

---

**🎉 Congratulations! You've completed the API Gateway Challenge Lab using CLI commands!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
