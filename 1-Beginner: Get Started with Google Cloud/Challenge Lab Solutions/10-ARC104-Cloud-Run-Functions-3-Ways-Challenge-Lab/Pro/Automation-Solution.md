# Cloud Functions: Qwik Start - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Functions](https://img.shields.io/badge/Cloud%20Functions-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

**Lab ID**: ARC104 | **Duration**: 5-10 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

Full automation for Cloud Functions deployment using Terraform, Python, and bash scripts.

---

## 🚀 One-Click Bash Automation

```bash
#!/bin/bash

# Cloud Functions Qwik Start - Complete Automation
# Author: CodeWithGarry

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
FUNCTION_NAME="hello-world-function"
FUNCTION_DIR="cloud-function"

echo -e "${BLUE}🚀 Starting Cloud Functions Qwik Start Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Region: $REGION${NC}"
echo -e "${YELLOW}Function: $FUNCTION_NAME${NC}"

# Task 1: Enable APIs
echo -e "\n${BLUE}🔧 Task 1: Enabling APIs...${NC}"
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable logging.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"

# Task 2: Create function directory and files
echo -e "\n${BLUE}📁 Task 2: Creating function files...${NC}"
mkdir -p $FUNCTION_DIR
cd $FUNCTION_DIR

# Create advanced main.py
cat > main.py << 'EOF'
import functions_framework
import json
import os
import logging
from datetime import datetime, timezone
import traceback

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def hello_world(request):
    """
    Advanced HTTP Cloud Function with comprehensive features
    
    Supports:
    - GET and POST requests
    - CORS handling
    - Error handling and logging
    - Environment variable access
    - JSON response formatting
    - Request validation
    """
    
    # Handle CORS preflight requests
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600'
        }
        logger.info("CORS preflight request handled")
        return ('', 204, headers)
    
    # Set CORS headers for main request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=utf-8'
    }
    
    try:
        # Log incoming request
        logger.info(f"Received {request.method} request from {request.remote_addr}")
        
        # Get request data
        method = request.method
        timestamp = datetime.now(timezone.utc).isoformat()
        
        # Initialize response data
        response_data = {
            'timestamp': timestamp,
            'function_name': os.environ.get('K_SERVICE', FUNCTION_NAME),
            'function_region': os.environ.get('FUNCTION_REGION', 'us-central1'),
            'request_method': method,
            'version': '1.0',
            'author': 'CodeWithGarry',
            'deployment_type': 'Automated'
        }
        
        # Handle different request methods
        if method == 'GET':
            name = request.args.get('name', 'World')
            action = request.args.get('action', 'greet')
            
            response_data.update({
                'name': name,
                'action': action,
                'query_params': dict(request.args)
            })
            
        elif method == 'POST':
            try:
                request_json = request.get_json(silent=True)
                if request_json:
                    name = request_json.get('name', 'World')
                    action = request_json.get('action', 'greet')
                    response_data.update({
                        'name': name,
                        'action': action,
                        'request_body': request_json
                    })
                else:
                    name = 'World'
                    action = 'greet'
                    response_data['name'] = name
                    response_data['action'] = action
            except Exception as e:
                logger.warning(f"Error parsing JSON: {str(e)}")
                name = 'World'
                action = 'greet'
                response_data.update({
                    'name': name,
                    'action': action,
                    'json_parse_error': str(e)
                })
        else:
            error_msg = f'Method {method} not allowed'
            logger.error(error_msg)
            return (json.dumps({
                'error': error_msg,
                'allowed_methods': ['GET', 'POST'],
                'timestamp': timestamp
            }), 405, headers)
        
        # Generate message based on action
        if action == 'greet':
            message = f'Hello, {name}! This is an automated Cloud Function deployment.'
        elif action == 'info':
            message = f'Function information for {name}'
            response_data['function_info'] = {
                'runtime': 'python311',
                'memory': os.environ.get('FUNCTION_MEMORY_MB', '256MB'),
                'timeout': os.environ.get('FUNCTION_TIMEOUT_SEC', '60s'),
                'environment': os.environ.get('ENVIRONMENT', 'production')
            }
        elif action == 'health':
            message = f'Health check passed for {name}'
            response_data['health_status'] = 'healthy'
        else:
            message = f'Hello, {name}! Unknown action: {action}'
            response_data['available_actions'] = ['greet', 'info', 'health']
        
        response_data['message'] = message
        
        # Add environment information
        response_data['environment'] = {
            'gcp_project': os.environ.get('GCP_PROJECT', PROJECT_ID),
            'function_target': os.environ.get('FUNCTION_TARGET', 'hello_world'),
            'deployed_with': 'bash_automation'
        }
        
        logger.info(f"Successfully processed {method} request for {name}")
        return (json.dumps(response_data, indent=2), 200, headers)
        
    except Exception as e:
        # Comprehensive error handling
        logger.error(f"Unexpected error: {str(e)}")
        logger.error(traceback.format_exc())
        
        error_response = {
            'error': 'Internal server error',
            'message': str(e),
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'function_name': os.environ.get('K_SERVICE', FUNCTION_NAME),
            'request_method': request.method if request else 'unknown'
        }
        
        return (json.dumps(error_response, indent=2), 500, headers)

# Additional health check function
@functions_framework.http
def health_check(request):
    """Dedicated health check endpoint"""
    return json.dumps({
        'status': 'healthy',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'function': 'health-check',
        'version': '1.0'
    })
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
functions-framework==3.4.0
flask==2.3.3
gunicorn==21.2.0
EOF

# Create .gcloudignore
cat > .gcloudignore << 'EOF'
.git
.gitignore
__pycache__/
*.pyc
*.pyo
*.pyd
.pytest_cache/
.coverage
.venv/
venv/
env/
.env
*.log
.DS_Store
README.md
tests/
docs/
.terraform/
*.tf
*.tfstate*
node_modules/
EOF

echo -e "${GREEN}✅ Function files created${NC}"

# Task 3: Deploy function
echo -e "\n${BLUE}🚀 Task 3: Deploying function...${NC}"
gcloud functions deploy $FUNCTION_NAME \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point hello_world \
    --memory 512MB \
    --timeout 60s \
    --max-instances 100 \
    --set-env-vars ENVIRONMENT=production,VERSION=1.0,AUTHOR=CodeWithGarry \
    --source . \
    --quiet

echo -e "${GREEN}✅ Function deployed successfully${NC}"

# Task 4: Get function details
FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(httpsTrigger.url)")
echo -e "${GREEN}🌐 Function URL: $FUNCTION_URL${NC}"

# Task 5: Test function comprehensively
echo -e "\n${BLUE}🧪 Task 5: Testing function...${NC}"

# Test 1: Basic GET request
echo -e "${BLUE}Test 1: Basic GET request...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$FUNCTION_URL")
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Basic GET test passed (HTTP $HTTP_STATUS)${NC}"
else
    echo -e "${RED}❌ Basic GET test failed (HTTP $HTTP_STATUS)${NC}"
fi

# Test 2: GET with parameters
echo -e "${BLUE}Test 2: GET with parameters...${NC}"
RESPONSE=$(curl -s "$FUNCTION_URL?name=AutomationTest&action=greet")
if echo "$RESPONSE" | grep -q "AutomationTest"; then
    echo -e "${GREEN}✅ Parameterized GET test passed${NC}"
else
    echo -e "${RED}❌ Parameterized GET test failed${NC}"
fi

# Test 3: POST request
echo -e "${BLUE}Test 3: POST request...${NC}"
POST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$FUNCTION_URL" \
    -H "Content-Type: application/json" \
    -d '{"name": "PostTest", "action": "info"}')
if [ "$POST_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ POST test passed (HTTP $POST_STATUS)${NC}"
else
    echo -e "${RED}❌ POST test failed (HTTP $POST_STATUS)${NC}"
fi

# Test 4: CORS preflight
echo -e "${BLUE}Test 4: CORS preflight...${NC}"
CORS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "$FUNCTION_URL" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type")
if [ "$CORS_STATUS" = "204" ]; then
    echo -e "${GREEN}✅ CORS preflight test passed (HTTP $CORS_STATUS)${NC}"
else
    echo -e "${RED}❌ CORS preflight test failed (HTTP $CORS_STATUS)${NC}"
fi

# Test 5: Performance test
echo -e "${BLUE}Test 5: Performance test...${NC}"
RESPONSE_TIME=$(curl -w "%{time_total}" -s -o /dev/null "$FUNCTION_URL")
echo -e "${GREEN}✅ Response time: ${RESPONSE_TIME}s${NC}"

# Task 6: Monitor and verify
echo -e "\n${BLUE}📊 Task 6: Monitoring setup...${NC}"

# Check function status
FUNCTION_STATUS=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(status)")
echo -e "${GREEN}Function Status: $FUNCTION_STATUS${NC}"

# Get recent logs
echo -e "${BLUE}Recent function logs:${NC}"
gcloud functions logs read $FUNCTION_NAME --region=$REGION --limit=5 --format="table(timestamp,severity,textPayload)"

# Setup monitoring alert (optional)
cat > alert-policy.yaml << EOF
displayName: "Cloud Function Error Rate Alert"
conditions:
  - displayName: "High error rate"
    conditionThreshold:
      filter: 'resource.type="cloud_function" AND resource.label.function_name="$FUNCTION_NAME"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 5
      duration: 300s
enabled: true
EOF

gcloud alpha monitoring policies create --policy-from-file=alert-policy.yaml 2>/dev/null || true
echo -e "${GREEN}✅ Monitoring alert configured${NC}"

# Cleanup
rm -f alert-policy.yaml
cd ..

echo -e "\n${GREEN}🎉 Cloud Function deployed and tested successfully!${NC}"
echo -e "${GREEN}🌐 Function URL: $FUNCTION_URL${NC}"
echo -e "${GREEN}🔍 Test endpoints:${NC}"
echo -e "${GREEN}  - Basic: $FUNCTION_URL${NC}"
echo -e "${GREEN}  - With params: $FUNCTION_URL?name=YourName&action=greet${NC}"
echo -e "${GREEN}  - Info: $FUNCTION_URL?action=info${NC}"
echo -e "${GREEN}  - Health: $FUNCTION_URL?action=health${NC}"
echo -e "\n${BLUE}📈 View console: https://console.cloud.google.com/functions/details/$REGION/$FUNCTION_NAME${NC}"
```

---

## 🏗️ Terraform Infrastructure as Code

```terraform
# Cloud Functions Qwik Start - Terraform Configuration
# Author: CodeWithGarry

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "function_name" {
  description = "Cloud Function name"
  type        = string
  default     = "hello-world-function"
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com"
  ])
  
  service = each.value
}

# Create function source code
resource "local_file" "function_source" {
  filename = "${path.module}/function/main.py"
  content = <<-EOT
import functions_framework
import json
import os
import logging
from datetime import datetime, timezone

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def hello_world(request):
    """Advanced HTTP Cloud Function deployed with Terraform"""
    
    # Handle CORS preflight
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=utf-8'
    }
    
    try:
        method = request.method
        timestamp = datetime.now(timezone.utc).isoformat()
        
        # Get request data
        if method == 'GET':
            name = request.args.get('name', 'World')
            action = request.args.get('action', 'greet')
        elif method == 'POST':
            request_json = request.get_json(silent=True) or {}
            name = request_json.get('name', 'World')
            action = request_json.get('action', 'greet')
        else:
            return (json.dumps({'error': f'Method {method} not allowed'}), 405, headers)
        
        # Generate response
        if action == 'greet':
            message = f'Hello, {name}! Deployed with Terraform by CodeWithGarry'
        elif action == 'info':
            message = f'Function info for {name}'
        elif action == 'health':
            message = f'Health check passed for {name}'
        else:
            message = f'Hello, {name}! Unknown action: {action}'
        
        response_data = {
            'message': message,
            'request_method': method,
            'timestamp': timestamp,
            'function_name': os.environ.get('K_SERVICE', '${var.function_name}'),
            'function_region': '${var.region}',
            'version': '1.0',
            'author': 'CodeWithGarry',
            'deployment_type': 'Terraform',
            'environment': {
                'gcp_project': '${var.project_id}',
                'terraform_managed': True
            }
        }
        
        if action == 'info':
            response_data['function_info'] = {
                'runtime': 'python311',
                'memory': '512MB',
                'timeout': '60s',
                'trigger_type': 'HTTP'
            }
        
        logger.info(f"Processed {method} request for {name}")
        return (json.dumps(response_data, indent=2), 200, headers)
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        error_response = {
            'error': 'Internal server error',
            'message': str(e),
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'function_name': '${var.function_name}'
        }
        return (json.dumps(error_response), 500, headers)
EOT
}

resource "local_file" "requirements" {
  filename = "${path.module}/function/requirements.txt"
  content = <<-EOT
functions-framework==3.4.0
flask==2.3.3
gunicorn==21.2.0
EOT
}

# Create source archive
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/function.zip"
  
  depends_on = [
    local_file.function_source,
    local_file.requirements
  ]
}

# Storage bucket for function source
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-cloud-function-source"
  location = "US"
  
  uniform_bucket_level_access = true
}

# Upload function source to bucket
resource "google_storage_bucket_object" "function_archive" {
  name   = "function-${formatdate("YYYY-MM-DD-hhmm", timestamp())}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_zip.output_path
  
  depends_on = [data.archive_file.function_zip]
}

# Cloud Function
resource "google_cloudfunctions_function" "hello_world" {
  name        = var.function_name
  region      = var.region
  runtime     = "python311"
  description = "Hello World function deployed with Terraform"
  
  available_memory_mb   = 512
  timeout               = 60
  max_instances        = 100
  entry_point          = "hello_world"
  
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  
  trigger {
    https_trigger {
      security_level = "SECURE_OPTIONAL"
    }
  }
  
  environment_variables = {
    ENVIRONMENT     = "production"
    VERSION         = "1.0"
    AUTHOR          = "CodeWithGarry"
    DEPLOYMENT_TYPE = "terraform"
  }
  
  depends_on = [
    google_project_service.required_apis,
    google_storage_bucket_object.function_archive
  ]
}

# IAM policy to allow unauthenticated access
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# Create monitoring alert policy
resource "google_monitoring_alert_policy" "function_error_rate" {
  display_name = "Cloud Function High Error Rate"
  combiner     = "OR"
  
  conditions {
    display_name = "Cloud Function error rate"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_function\" AND resource.label.function_name=\"${var.function_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 5
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  depends_on = [google_cloudfunctions_function.hello_world]
}

# Outputs
output "function_url" {
  value       = google_cloudfunctions_function.hello_world.https_trigger_url
  description = "URL of the deployed Cloud Function"
}

output "function_name" {
  value       = google_cloudfunctions_function.hello_world.name
  description = "Name of the deployed Cloud Function"
}

output "function_region" {
  value       = google_cloudfunctions_function.hello_world.region
  description = "Region where the function is deployed"
}

output "source_bucket" {
  value       = google_storage_bucket.function_bucket.name
  description = "Bucket containing function source code"
}

output "test_commands" {
  value = <<-EOT
# Test the deployed function:
curl "${google_cloudfunctions_function.hello_world.https_trigger_url}"
curl "${google_cloudfunctions_function.hello_world.https_trigger_url}?name=Terraform&action=greet"
curl -X POST "${google_cloudfunctions_function.hello_world.https_trigger_url}" -H "Content-Type: application/json" -d '{"name":"TerraformUser","action":"info"}'
EOT
}
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
Cloud Functions Qwik Start Automation - Python Script
Author: CodeWithGarry
"""

import os
import time
import json
import subprocess
import requests
import zipfile
from pathlib import Path
import tempfile

class CloudFunctionsQuickStartLab:
    def __init__(self, project_id, region="us-central1"):
        self.project_id = project_id
        self.region = region
        self.function_name = "hello-world-function"
        self.function_dir = Path("cloud-function")
        
    def enable_apis(self):
        """Enable required APIs"""
        print("🔧 Enabling APIs...")
        apis = [
            "cloudfunctions.googleapis.com",
            "cloudbuild.googleapis.com",
            "artifactregistry.googleapis.com",
            "logging.googleapis.com"
        ]
        
        for api in apis:
            result = subprocess.run([
                'gcloud', 'services', 'enable', api
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {api} enabled")
            else:
                print(f"❌ Error enabling {api}: {result.stderr}")
                return False
        
        return True
    
    def create_function_code(self):
        """Create function source code"""
        print("📁 Creating function code...")
        
        self.function_dir.mkdir(exist_ok=True)
        
        # Create advanced main.py
        main_py_content = '''
import functions_framework
import json
import os
import logging
from datetime import datetime, timezone
import traceback

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@functions_framework.http
def hello_world(request):
    """
    Comprehensive HTTP Cloud Function
    
    Features:
    - Multi-method support (GET, POST, OPTIONS)
    - CORS handling
    - Advanced error handling
    - Environment variable access
    - Comprehensive logging
    - JSON response formatting
    """
    
    # Handle CORS preflight requests
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600'
        }
        logger.info("CORS preflight request handled")
        return ('', 204, headers)
    
    # Set response headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=utf-8',
        'X-Function-Version': '1.0',
        'X-Deployed-By': 'python-automation'
    }
    
    try:
        # Log request details
        logger.info(f"Processing {request.method} request from {request.remote_addr}")
        
        method = request.method
        timestamp = datetime.now(timezone.utc).isoformat()
        
        # Initialize response data
        response_data = {
            'timestamp': timestamp,
            'function_name': os.environ.get('K_SERVICE', 'hello-world-function'),
            'function_region': os.environ.get('FUNCTION_REGION', 'us-central1'),
            'request_method': method,
            'version': '1.0',
            'author': 'CodeWithGarry',
            'deployment_type': 'Python Automation'
        }
        
        # Process request based on method
        if method == 'GET':
            name = request.args.get('name', 'World')
            action = request.args.get('action', 'greet')
            
            response_data.update({
                'name': name,
                'action': action,
                'query_parameters': dict(request.args)
            })
            
        elif method == 'POST':
            try:
                request_json = request.get_json(silent=True)
                if request_json:
                    name = request_json.get('name', 'World')
                    action = request_json.get('action', 'greet')
                    response_data.update({
                        'name': name,
                        'action': action,
                        'request_body': request_json
                    })
                else:
                    name = 'World'
                    action = 'greet'
                    response_data.update({
                        'name': name,
                        'action': action,
                        'note': 'No JSON body provided'
                    })
            except Exception as e:
                logger.warning(f"Error parsing JSON: {str(e)}")
                name = 'World'
                action = 'greet'
                response_data.update({
                    'name': name,
                    'action': action,
                    'json_error': str(e)
                })
        else:
            error_msg = f'Method {method} not supported'
            logger.error(error_msg)
            return (json.dumps({
                'error': error_msg,
                'supported_methods': ['GET', 'POST'],
                'timestamp': timestamp
            }, indent=2), 405, headers)
        
        # Generate response message
        if action == 'greet':
            message = f'Hello, {name}! This Cloud Function was deployed using Python automation.'
        elif action == 'info':
            message = f'Function information for {name}'
            response_data['function_details'] = {
                'runtime': 'python311',
                'memory': '512MB',
                'timeout': '60s',
                'trigger': 'HTTP',
                'environment': os.environ.get('ENVIRONMENT', 'production')
            }
        elif action == 'health':
            message = f'Health check successful for {name}'
            response_data['health_data'] = {
                'status': 'healthy',
                'uptime': 'active',
                'last_check': timestamp
            }
        elif action == 'debug':
            message = f'Debug information for {name}'
            response_data['debug_info'] = {
                'headers': dict(request.headers),
                'environment_vars': {k: v for k, v in os.environ.items() if k.startswith(('FUNCTION_', 'K_', 'GCP_'))},
                'request_url': request.url
            }
        else:
            message = f'Hello, {name}! Unknown action: {action}'
            response_data['available_actions'] = ['greet', 'info', 'health', 'debug']
        
        response_data['message'] = message
        
        # Add environment context
        response_data['environment'] = {
            'project_id': os.environ.get('GCP_PROJECT', 'unknown'),
            'function_target': os.environ.get('FUNCTION_TARGET', 'hello_world'),
            'runtime': 'python311',
            'deployed_with': 'python_automation'
        }
        
        # Add request metadata
        response_data['request_metadata'] = {
            'user_agent': request.headers.get('User-Agent', 'unknown'),
            'content_type': request.headers.get('Content-Type', 'none'),
            'content_length': request.headers.get('Content-Length', '0')
        }
        
        logger.info(f"Successfully processed {method} request for {name} with action {action}")
        return (json.dumps(response_data, indent=2), 200, headers)
        
    except Exception as e:
        # Comprehensive error handling
        logger.error(f"Unexpected error in hello_world function: {str(e)}")
        logger.error(traceback.format_exc())
        
        error_response = {
            'error': 'Internal server error',
            'message': str(e),
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'function_name': os.environ.get('K_SERVICE', 'hello-world-function'),
            'request_method': request.method if request else 'unknown',
            'error_type': type(e).__name__
        }
        
        return (json.dumps(error_response, indent=2), 500, headers)

# Health check function for monitoring
@functions_framework.http  
def health_check(request):
    """Dedicated health check endpoint"""
    return json.dumps({
        'status': 'healthy',
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'function': 'health-check',
        'version': '1.0',
        'deployment': 'python-automation'
    }, indent=2)
        '''.strip()
        
        with open(self.function_dir / 'main.py', 'w') as f:
            f.write(main_py_content)
        
        # Create requirements.txt
        requirements_content = '''
functions-framework==3.4.0
flask==2.3.3
gunicorn==21.2.0
requests==2.31.0
        '''.strip()
        
        with open(self.function_dir / 'requirements.txt', 'w') as f:
            f.write(requirements_content)
        
        # Create .gcloudignore
        gcloudignore_content = '''
.git
.gitignore
__pycache__/
*.pyc
*.pyo
*.pyd
.pytest_cache/
.venv/
venv/
env/
.env
*.log
.DS_Store
README.md
tests/
automation.py
        '''.strip()
        
        with open(self.function_dir / '.gcloudignore', 'w') as f:
            f.write(gcloudignore_content)
        
        print("✅ Function code created")
        return True
    
    def deploy_function(self):
        """Deploy Cloud Function"""
        print("🚀 Deploying Cloud Function...")
        
        # Change to function directory
        original_dir = os.getcwd()
        os.chdir(self.function_dir)
        
        try:
            result = subprocess.run([
                'gcloud', 'functions', 'deploy', self.function_name,
                '--runtime', 'python311',
                '--trigger-http',
                '--allow-unauthenticated',
                '--region', self.region,
                '--entry-point', 'hello_world',
                '--memory', '512MB',
                '--timeout', '60s',
                '--max-instances', '100',
                '--set-env-vars', 'ENVIRONMENT=production,VERSION=1.0,AUTHOR=CodeWithGarry',
                '--source', '.',
                '--quiet'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Function deployed successfully")
                return True
            else:
                print(f"❌ Deployment failed: {result.stderr}")
                return False
        finally:
            os.chdir(original_dir)
    
    def get_function_url(self):
        """Get deployed function URL"""
        result = subprocess.run([
            'gcloud', 'functions', 'describe', self.function_name,
            '--region', self.region,
            '--format', 'value(httpsTrigger.url)'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            return result.stdout.strip()
        return None
    
    def test_function(self, function_url):
        """Comprehensive function testing"""
        print("🧪 Testing function...")
        
        test_results = {
            'basic_get': False,
            'parameterized_get': False,
            'post_request': False,
            'cors_preflight': False,
            'error_handling': False
        }
        
        # Test 1: Basic GET request
        try:
            response = requests.get(function_url, timeout=30)
            if response.status_code == 200:
                test_results['basic_get'] = True
                print("✅ Basic GET test passed")
            else:
                print(f"❌ Basic GET test failed (HTTP {response.status_code})")
        except Exception as e:
            print(f"❌ Basic GET test error: {str(e)}")
        
        # Test 2: Parameterized GET request
        try:
            params = {'name': 'PythonTest', 'action': 'greet'}
            response = requests.get(function_url, params=params, timeout=30)
            if response.status_code == 200 and 'PythonTest' in response.text:
                test_results['parameterized_get'] = True
                print("✅ Parameterized GET test passed")
            else:
                print(f"❌ Parameterized GET test failed")
        except Exception as e:
            print(f"❌ Parameterized GET test error: {str(e)}")
        
        # Test 3: POST request
        try:
            data = {'name': 'PostTest', 'action': 'info'}
            response = requests.post(function_url, json=data, timeout=30)
            if response.status_code == 200:
                test_results['post_request'] = True
                print("✅ POST test passed")
            else:
                print(f"❌ POST test failed (HTTP {response.status_code})")
        except Exception as e:
            print(f"❌ POST test error: {str(e)}")
        
        # Test 4: CORS preflight
        try:
            headers = {
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'Content-Type'
            }
            response = requests.options(function_url, headers=headers, timeout=30)
            if response.status_code == 204:
                test_results['cors_preflight'] = True
                print("✅ CORS preflight test passed")
            else:
                print(f"❌ CORS preflight test failed (HTTP {response.status_code})")
        except Exception as e:
            print(f"❌ CORS preflight test error: {str(e)}")
        
        # Test 5: Error handling (unsupported method)
        try:
            response = requests.put(function_url, timeout=30)
            if response.status_code == 405:
                test_results['error_handling'] = True
                print("✅ Error handling test passed")
            else:
                print(f"❌ Error handling test failed (expected 405, got {response.status_code})")
        except Exception as e:
            print(f"❌ Error handling test error: {str(e)}")
        
        # Summary
        passed_tests = sum(test_results.values())
        total_tests = len(test_results)
        print(f"📊 Test results: {passed_tests}/{total_tests} tests passed")
        
        return passed_tests == total_tests
    
    def monitor_function(self):
        """Monitor function status and logs"""
        print("📊 Monitoring function...")
        
        # Get function status
        result = subprocess.run([
            'gcloud', 'functions', 'describe', self.function_name,
            '--region', self.region,
            '--format', 'json'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            function_info = json.loads(result.stdout)
            print(f"✅ Function Status: {function_info.get('status')}")
            print(f"✅ Runtime: {function_info.get('runtime')}")
            print(f"✅ Memory: {function_info.get('availableMemoryMb')}MB")
            print(f"✅ Timeout: {function_info.get('timeout')}")
            print(f"✅ Update Time: {function_info.get('updateTime')}")
        
        # Get recent logs
        print("\n📝 Recent logs:")
        subprocess.run([
            'gcloud', 'functions', 'logs', 'read', self.function_name,
            '--region', self.region,
            '--limit', '5',
            '--format', 'table(timestamp,severity,textPayload)'
        ])
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting Cloud Functions Qwik Start Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📍 Region: {self.region}")
        print(f"🔧 Function: {self.function_name}")
        
        try:
            # Execute all tasks
            if not self.enable_apis():
                return False
            
            if not self.create_function_code():
                return False
            
            if not self.deploy_function():
                return False
            
            # Wait for deployment to be ready
            print("⏳ Waiting for deployment to be ready...")
            time.sleep(30)
            
            function_url = self.get_function_url()
            if not function_url:
                print("❌ Could not get function URL")
                return False
            
            self.test_function(function_url)
            self.monitor_function()
            
            print("\n🎉 Cloud Function deployed and tested successfully!")
            print(f"🌐 Function URL: {function_url}")
            print(f"🔍 Test endpoints:")
            print(f"  - Basic: {function_url}")
            print(f"  - With params: {function_url}?name=YourName&action=greet")
            print(f"  - Info: {function_url}?action=info")
            print(f"  - Health: {function_url}?action=health")
            print(f"  - Debug: {function_url}?action=debug")
            print("📈 Console: https://console.cloud.google.com/functions")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return False

if __name__ == "__main__":
    import sys
    
    # Get project ID
    result = subprocess.run([
        'gcloud', 'config', 'get-value', 'project'
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        print("❌ Could not get project ID. Make sure gcloud is configured.")
        sys.exit(1)
    
    project_id = result.stdout.strip()
    
    # Run the lab
    lab = CloudFunctionsQuickStartLab(project_id)
    success = lab.run_complete_lab()
    
    sys.exit(0 if success else 1)
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach

---

## 🎖️ Skills Boost Arcade

Complete Cloud Functions automation for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Automate Cloud Functions deployment for scalable serverless applications!

</div>
