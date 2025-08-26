# ARC109: Getting Started with API Gateway: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll deploy a Cloud Run service and create an API Gateway to manage and secure access to your API endpoints.

## 📋 Challenge Tasks

### Task 1: Deploy a Cloud Run Service

**Requirements:**
- **Service Name**: `hello-api`
- **Region**: `us-central1`
- **Container Image**: `gcr.io/cloudrun/hello`
- **Allow unauthenticated invocations**

### Task 2: Create API Configuration

Create an OpenAPI specification that defines your API endpoints.

### Task 3: Deploy API Gateway

Deploy the API Gateway with your configuration.

### Task 4: Test the API Gateway

Verify that your API Gateway is working correctly.

---

## 🚀 Quick Solution Steps

### Step 1: Deploy Cloud Run Service

```bash
# Deploy the Cloud Run service
gcloud run deploy hello-api \
    --image=gcr.io/cloudrun/hello \
    --region=us-central1 \
    --allow-unauthenticated \
    --platform=managed

# Get the service URL
export SERVICE_URL=$(gcloud run services describe hello-api \
    --region=us-central1 \
    --format='value(status.url)')

echo "Service URL: $SERVICE_URL"
```

### Step 2: Create API Configuration

Create the OpenAPI specification file:

```bash
cat > openapi_spec.yaml << 'EOF'
swagger: '2.0'
info:
  title: Hello API Gateway
  description: Sample API on API Gateway with a Google Cloud Run backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /:
    get:
      summary: Hello World
      operationId: hello
      x-google-backend:
        address: SERVICE_URL_PLACEHOLDER
      responses:
        '200':
          description: A successful response
          schema:
            type: string
EOF

# Replace placeholder with actual service URL
sed -i "s|SERVICE_URL_PLACEHOLDER|$SERVICE_URL|g" openapi_spec.yaml
```

### Step 3: Enable Required APIs

```bash
# Enable API Gateway API
gcloud services enable apigateway.googleapis.com

# Enable Service Management API  
gcloud services enable servicemanagement.googleapis.com

# Enable Service Control API
gcloud services enable servicecontrol.googleapis.com
```

### Step 4: Create API Gateway

```bash
# Create the API
gcloud api-gateway apis create hello-gateway-api

# Create API config
gcloud api-gateway api-configs create hello-gateway-config \
    --api=hello-gateway-api \
    --openapi-spec=openapi_spec.yaml

# Deploy the gateway
gcloud api-gateway gateways create hello-gateway \
    --api=hello-gateway-api \
    --api-config=hello-gateway-config \
    --location=us-central1

# Get the gateway URL
export GATEWAY_URL=$(gcloud api-gateway gateways describe hello-gateway \
    --location=us-central1 \
    --format='value(defaultHostname)')

echo "Gateway URL: https://$GATEWAY_URL"
```

### Step 5: Test the API Gateway

```bash
# Test the API Gateway endpoint
curl https://$GATEWAY_URL

# You should see a "Hello World!" response
```

---

## 🎯 Alternative GUI Solution

1. **Deploy Cloud Run Service**:
   - Go to Cloud Run in the console
   - Click "Create Service"
   - Select "Deploy one revision from an existing container image"
   - Container image URL: `gcr.io/cloudrun/hello`
   - Service name: `hello-api`
   - Region: `us-central1`
   - Authentication: Allow unauthenticated invocations

2. **Create API Gateway**:
   - Go to API Gateway in the console
   - Click "Create Gateway"
   - Gateway name: `hello-gateway`
   - API: Create a new API
   - API ID: `hello-gateway-api`
   - Upload the OpenAPI spec file
   - Select region: `us-central1`

3. **Test the Gateway**:
   - Copy the gateway URL from the console
   - Open in browser or use curl to test

---

## 📄 Complete OpenAPI Specification

```yaml
swagger: '2.0'
info:
  title: Hello API Gateway
  description: Sample API on API Gateway with a Google Cloud Run backend
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /:
    get:
      summary: Hello World
      operationId: hello
      x-google-backend:
        address: YOUR_CLOUD_RUN_SERVICE_URL
      responses:
        '200':
          description: A successful response
          schema:
            type: string
  /hello:
    get:
      summary: Hello with parameter
      operationId: helloParam
      parameters:
        - name: name
          in: query
          type: string
          description: Name to greet
      x-google-backend:
        address: YOUR_CLOUD_RUN_SERVICE_URL
      responses:
        '200':
          description: A successful response
          schema:
            type: string
```

---

## ✅ Validation

1. **Cloud Run Service**: Verify service is deployed and accessible
2. **API Gateway**: Check gateway status is "ACTIVE"
3. **API Response**: Test both direct Cloud Run URL and Gateway URL
4. **Security**: Verify API Gateway provides managed access

---

## 🔧 Troubleshooting

**Issue**: API Gateway creation fails
- Ensure all required APIs are enabled
- Check IAM permissions for API Gateway service account
- Verify OpenAPI spec syntax is correct

**Issue**: Gateway returns 404
- Check the OpenAPI spec backend address
- Ensure Cloud Run service is accessible
- Verify API config is properly deployed

**Issue**: Permission denied errors
- Enable necessary APIs
- Check service account permissions
- Verify Cloud Run allows unauthenticated access

---

## 📚 Key Learning Points

- **Cloud Run**: Deploying containerized applications
- **API Gateway**: Managing and securing API access
- **OpenAPI**: Defining API specifications
- **Service Integration**: Connecting API Gateway to backend services
- **URL Management**: Understanding service URLs and routing

---

## 🏆 Challenge Complete!

You've successfully demonstrated API Gateway fundamentals by:
- ✅ Deploying a Cloud Run service
- ✅ Creating OpenAPI specification
- ✅ Configuring API Gateway
- ✅ Testing the complete API flow

<div align="center">

**🎉 Congratulations! You've completed ARC109!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC117%20Dataplex-blue?style=for-the-badge)](../4-ARC117-Get-Started-with-Dataplex-Challenge-Lab/)

</div>
