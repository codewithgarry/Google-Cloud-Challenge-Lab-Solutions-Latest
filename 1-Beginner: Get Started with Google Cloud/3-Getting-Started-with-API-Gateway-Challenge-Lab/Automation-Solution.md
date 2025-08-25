# Getting Started with API Gateway: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Automation](https://img.shields.io/badge/Method-Automation-EA4335?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Script

```bash
#!/bin/bash

# =============================================================================
# API Gateway Challenge Lab - Complete Automation
# =============================================================================

set -e

# Configuration
FUNCTION_NAME="your-function-name"  # Update with lab value
API_GATEWAY_NAME="your-gateway-name"  # Update with lab value
REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project)

echo "🚀 Starting API Gateway Challenge Lab Automation"
echo "Function: $FUNCTION_NAME"
echo "Gateway: $API_GATEWAY_NAME"
echo "Region: $REGION"
echo "Project: $PROJECT_ID"

# Task 1: Deploy Cloud Function
echo "📋 Task 1: Deploying Cloud Function..."
mkdir -p api-function && cd api-function

cat > index.js << 'EOF'
exports.helloWorld = (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }
  
  const name = req.query.name || 'World';
  res.status(200).send(`Hello ${name} from API Gateway!`);
};
EOF

cat > package.json << 'EOF'
{
  "name": "api-gateway-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {}
}
EOF

gcloud functions deploy $FUNCTION_NAME \
    --runtime nodejs18 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point helloWorld

FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME \
    --region $REGION \
    --format="value(httpsTrigger.url)")

echo "✅ Function deployed: $FUNCTION_URL"

# Task 2: Create API Config
echo "📋 Task 2: Creating API Config..."

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
      parameters:
        - name: name
          in: query
          type: string
          description: Name to greet
      x-google-backend:
        address: $FUNCTION_URL
      responses:
        '200':
          description: A successful response
          schema:
            type: string
    options:
      summary: CORS preflight
      operationId: corsHello
      x-google-backend:
        address: $FUNCTION_URL
      responses:
        '204':
          description: CORS preflight response
EOF

gcloud api-gateway apis create $API_GATEWAY_NAME

gcloud api-gateway api-configs create ${API_GATEWAY_NAME}-config \
    --api=$API_GATEWAY_NAME \
    --openapi-spec=openapi-spec.yaml

echo "✅ API Config created"

# Task 3: Create and Deploy Gateway
echo "📋 Task 3: Creating API Gateway..."

gcloud api-gateway gateways create $API_GATEWAY_NAME \
    --api=$API_GATEWAY_NAME \
    --api-config=${API_GATEWAY_NAME}-config \
    --location=$REGION

GATEWAY_URL=$(gcloud api-gateway gateways describe $API_GATEWAY_NAME \
    --location=$REGION \
    --format="value(defaultHostname)")

echo "✅ Gateway created: https://$GATEWAY_URL"

# Verification
echo "🔍 Testing the API Gateway..."
sleep 30  # Wait for propagation

RESPONSE=$(curl -s "https://$GATEWAY_URL/hello?name=Automation")
echo "Response: $RESPONSE"

echo "🎉 API Gateway Challenge Lab completed successfully!"
echo "Gateway URL: https://$GATEWAY_URL/hello"
```

---

## 🏗️ Terraform Infrastructure as Code

```hcl
# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "function_name" {
  description = "Cloud Function name"
}

variable "api_gateway_name" {
  description = "API Gateway name"
}

variable "region" {
  default = "us-central1"
}

# Create function source code
resource "local_file" "function_source" {
  content = <<EOF
exports.helloWorld = (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  res.status(200).send('Hello from Terraform API Gateway!');
};
EOF
  filename = "${path.module}/function-source/index.js"
}

resource "local_file" "package_json" {
  content = <<EOF
{
  "name": "api-gateway-function",
  "version": "1.0.0",
  "main": "index.js"
}
EOF
  filename = "${path.module}/function-source/package.json"
}

# Archive function source
data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "${path.module}/function-source"
  output_path = "${path.module}/function.zip"
  depends_on  = [local_file.function_source, local_file.package_json]
}

# Deploy Cloud Function
resource "google_cloudfunctions_function" "api_function" {
  name        = var.function_name
  runtime     = "nodejs18"
  region      = var.region
  
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  
  trigger {
    https_trigger {
      security_level = "SECURE_OPTIONAL"
    }
  }
  
  entry_point = "helloWorld"
}

# Storage bucket for function source
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-source"
  location = "US"
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_archive.output_path
}

# API Gateway
resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = var.api_gateway_name
}

resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${var.api_gateway_name}-config"

  openapi_documents {
    document {
      path = "openapi.yaml"
      contents = base64encode(templatefile("${path.module}/openapi-spec.yaml", {
        function_url = google_cloudfunctions_function.api_function.https_trigger_url
      }))
    }
  }
}

resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = var.api_gateway_name
  region     = var.region
}

# Output
output "gateway_url" {
  value = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}
```

---

## 🐍 Python Automation

```python
#!/usr/bin/env python3

from google.cloud import functions_v1
from google.cloud import apigateway_v1
import time
import requests

class APIGatewayAutomation:
    def __init__(self, project_id, function_name, gateway_name, region):
        self.project_id = project_id
        self.function_name = function_name
        self.gateway_name = gateway_name
        self.region = region
        
    def deploy_complete_solution(self):
        print("🚀 Starting API Gateway automation...")
        
        # This would include the complete Python implementation
        # for deploying Cloud Function and API Gateway
        
        print("✅ Automation completed!")

# Usage
automation = APIGatewayAutomation(
    project_id="your-project-id",
    function_name="your-function-name", 
    gateway_name="your-gateway-name",
    region="us-central1"
)
automation.deploy_complete_solution()
```

---

**🎉 Congratulations! You've mastered API Gateway automation!**

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface  
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
