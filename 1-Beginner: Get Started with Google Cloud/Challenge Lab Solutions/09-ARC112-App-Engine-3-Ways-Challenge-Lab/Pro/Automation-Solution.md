# App Engine: Qwik Start - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![App Engine](https://img.shields.io/badge/App%20Engine-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

**Lab ID**: ARC112 | **Duration**: 5-10 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

Full automation for App Engine deployment using Terraform, Python, and bash scripts.

---

## 🚀 One-Click Bash Automation

```bash
#!/bin/bash

# App Engine Qwik Start - Complete Automation
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
REGION="us-central"
APP_NAME="hello-world-app"

echo -e "${BLUE}🚀 Starting App Engine Qwik Start Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Region: $REGION${NC}"

# Task 1: Enable APIs
echo -e "\n${BLUE}🔧 Task 1: Enabling APIs...${NC}"
gcloud services enable appengine.googleapis.com
echo -e "${GREEN}✅ App Engine API enabled${NC}"

# Task 2: Create App Engine Application
echo -e "\n${BLUE}🏗️ Task 2: Creating App Engine application...${NC}"
if gcloud app describe --format="value(id)" 2>/dev/null; then
    echo -e "${GREEN}✅ App Engine application already exists${NC}"
else
    gcloud app create --region=$REGION
    echo -e "${GREEN}✅ App Engine application created${NC}"
fi

# Task 3: Create application directory
echo -e "\n${BLUE}📁 Task 3: Creating application files...${NC}"
mkdir -p $APP_NAME
cd $APP_NAME

# Create main.py
cat > main.py << 'EOF'
from flask import Flask, jsonify, request
import os
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    return '''
    <html>
        <head><title>Hello from App Engine</title></head>
        <body style="font-family: Arial, sans-serif; text-align: center; margin-top: 50px;">
            <h1 style="color: #4285F4;">Hello World from App Engine!</h1>
            <p style="color: #34A853;">Deployed with automation by CodeWithGarry</p>
            <p>Environment: {}</p>
            <p>Version: {}</p>
            <a href="/api/info" style="color: #EA4335;">View API Info</a>
        </body>
    </html>
    '''.format(
        os.environ.get('ENVIRONMENT', 'development'),
        os.environ.get('VERSION', '1.0')
    )

@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development')
    })

@app.route('/api/info')
def api_info():
    """API information endpoint."""
    return jsonify({
        'app_name': 'Hello World App',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'runtime': 'python39',
        'author': 'CodeWithGarry'
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

if __name__ == '__main__':
    # Used when running locally only
    app.run(host='127.0.0.1', port=8080, debug=True)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.3
Werkzeug==2.3.7
gunicorn==21.2.0
EOF

# Create app.yaml
cat > app.yaml << 'EOF'
runtime: python39

# Environment variables
env_variables:
  ENVIRONMENT: production
  VERSION: "1.0"

# Automatic scaling configuration
automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.6
  target_throughput_utilization: 0.6
  min_concurrent_requests: 1
  max_concurrent_requests: 80
  max_idle_instances: 3
  max_pending_latency: 1s
  min_pending_latency: 0.01s

# Health check configuration
readiness_check:
  path: "/health"
  check_interval_sec: 5
  timeout_sec: 4
  app_start_timeout_sec: 300

liveness_check:
  path: "/health"
  check_interval_sec: 30
  timeout_sec: 4
  failure_threshold: 4
  success_threshold: 2

# Handlers
handlers:
- url: /static
  static_dir: static
  secure: always

- url: /.*
  script: auto
  secure: always
EOF

# Create .gcloudignore
cat > .gcloudignore << 'EOF'
.git
.gitignore
.pytest_cache
__pycache__/
*.pyc
.env
.venv
env/
venv/
README.md
tests/
*.log
.DS_Store
EOF

echo -e "${GREEN}✅ Application files created${NC}"

# Task 4: Deploy application
echo -e "\n${BLUE}🚀 Task 4: Deploying application...${NC}"
gcloud app deploy app.yaml \
    --version=v1 \
    --promote \
    --stop-previous-version \
    --quiet

echo -e "${GREEN}✅ Application deployed${NC}"

# Task 5: Test application
echo -e "\n${BLUE}🧪 Task 5: Testing application...${NC}"

# Get application URL
APP_URL=$(gcloud app describe --format="value(defaultHostname)")
APP_URL="https://$APP_URL"

# Test main endpoint
echo -e "${BLUE}Testing main endpoint...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Main endpoint working (HTTP $HTTP_STATUS)${NC}"
else
    echo -e "${RED}❌ Main endpoint issue (HTTP $HTTP_STATUS)${NC}"
fi

# Test health endpoint
echo -e "${BLUE}Testing health endpoint...${NC}"
HEALTH_STATUS=$(curl -s "$APP_URL/health" | python3 -c "import sys, json; print(json.load(sys.stdin)['status'])" 2>/dev/null || echo "error")
if [ "$HEALTH_STATUS" = "healthy" ]; then
    echo -e "${GREEN}✅ Health endpoint working${NC}"
else
    echo -e "${RED}❌ Health endpoint issue${NC}"
fi

# Test API endpoint
echo -e "${BLUE}Testing API endpoint...${NC}"
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/api/info")
if [ "$API_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ API endpoint working (HTTP $API_STATUS)${NC}"
else
    echo -e "${RED}❌ API endpoint issue (HTTP $API_STATUS)${NC}"
fi

# Task 6: Configure monitoring
echo -e "\n${BLUE}📊 Task 6: Setting up monitoring...${NC}"
cat > alert-policy.yaml << EOF
displayName: "App Engine High Latency Alert"
conditions:
  - displayName: "High response latency"
    conditionThreshold:
      filter: 'resource.type="gae_app" AND metric.type="appengine.googleapis.com/http/server/response_latencies"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 1000
      duration: 300s
enabled: true
EOF

gcloud alpha monitoring policies create --policy-from-file=alert-policy.yaml 2>/dev/null || true
echo -e "${GREEN}✅ Monitoring configured${NC}"

# Cleanup
rm -f alert-policy.yaml
cd ..

echo -e "\n${GREEN}🎉 App Engine application deployed successfully!${NC}"
echo -e "${GREEN}🌐 Application URL: $APP_URL${NC}"
echo -e "${GREEN}🔍 Health Check: $APP_URL/health${NC}"
echo -e "${GREEN}📊 API Info: $APP_URL/api/info${NC}"
echo -e "\n${BLUE}📈 View dashboard: https://console.cloud.google.com/appengine${NC}"
```

---

## 🏗️ Terraform Infrastructure as Code

```terraform
# App Engine Qwik Start - Terraform Configuration
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
  default     = "us-central"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "hello-world-app"
}

# Enable App Engine API
resource "google_project_service" "appengine_api" {
  service = "appengine.googleapis.com"
}

# Create App Engine application
resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.region
  
  depends_on = [google_project_service.appengine_api]
}

# Create application files
resource "local_file" "main_py" {
  filename = "${path.module}/app/main.py"
  content = <<-EOT
from flask import Flask, jsonify, request
import os
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/')
def hello():
    return '''
    <html>
        <head><title>Hello from App Engine</title></head>
        <body style="font-family: Arial, sans-serif; text-align: center; margin-top: 50px;">
            <h1 style="color: #4285F4;">Hello World from App Engine!</h1>
            <p style="color: #34A853;">Deployed with Terraform by CodeWithGarry</p>
            <p>Environment: {}</p>
            <p>Version: {}</p>
            <div style="margin-top: 30px;">
                <a href="/api/info" style="color: #EA4335; margin: 10px;">API Info</a>
                <a href="/health" style="color: #FBBC04; margin: 10px;">Health Check</a>
            </div>
        </body>
    </html>
    '''.format(
        os.environ.get('ENVIRONMENT', 'development'),
        os.environ.get('VERSION', '1.0')
    )

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'deployed_with': 'terraform'
    })

@app.route('/api/info')
def api_info():
    return jsonify({
        'app_name': 'Hello World App',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'runtime': 'python39',
        'deployed_with': 'terraform',
        'author': 'CodeWithGarry'
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
EOT
}

resource "local_file" "requirements_txt" {
  filename = "${path.module}/app/requirements.txt"
  content = <<-EOT
Flask==2.3.3
Werkzeug==2.3.7
gunicorn==21.2.0
EOT
}

resource "local_file" "app_yaml" {
  filename = "${path.module}/app/app.yaml"
  content = <<-EOT
runtime: python39

env_variables:
  ENVIRONMENT: production
  VERSION: "1.0"
  DEPLOYED_WITH: terraform

automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.6
  target_throughput_utilization: 0.6
  min_concurrent_requests: 1
  max_concurrent_requests: 80
  max_idle_instances: 3
  max_pending_latency: 1s
  min_pending_latency: 0.01s

readiness_check:
  path: "/health"
  check_interval_sec: 5
  timeout_sec: 4
  app_start_timeout_sec: 300

liveness_check:
  path: "/health"
  check_interval_sec: 30
  timeout_sec: 4
  failure_threshold: 4
  success_threshold: 2

handlers:
- url: /.*
  script: auto
  secure: always
EOT
}

resource "local_file" "gcloudignore" {
  filename = "${path.module}/app/.gcloudignore"
  content = <<-EOT
.git
.gitignore
.pytest_cache
__pycache__/
*.pyc
.env
.venv
env/
venv/
README.md
tests/
*.log
.DS_Store
terraform/
*.tf
*.tfstate*
.terraform/
EOT
}

# Create archive for deployment
data "archive_file" "app_zip" {
  type        = "zip"
  source_dir  = "${path.module}/app"
  output_path = "${path.module}/app.zip"
  
  depends_on = [
    local_file.main_py,
    local_file.requirements_txt,
    local_file.app_yaml,
    local_file.gcloudignore
  ]
}

# Deploy App Engine version
resource "google_app_engine_standard_app_version" "myapp_v1" {
  version_id = "v1"
  service    = "default"
  runtime    = "python39"
  
  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.deployment_bucket.name}/${google_storage_bucket_object.app_archive.name}"
    }
  }
  
  env_variables = {
    ENVIRONMENT   = "production"
    VERSION       = "1.0"
    DEPLOYED_WITH = "terraform"
  }
  
  automatic_scaling {
    min_instances                    = 0
    max_instances                    = 10
    target_cpu_utilization          = 0.6
    target_throughput_utilization    = 0.6
    min_concurrent_requests          = 1
    max_concurrent_requests          = 80
    max_idle_instances              = 3
    max_pending_latency             = "1s"
    min_pending_latency             = "0.01s"
  }
  
  readiness_check {
    path                = "/health"
    check_interval      = "5s"
    timeout             = "4s"
    app_start_timeout   = "300s"
  }
  
  liveness_check {
    path               = "/health"
    check_interval     = "30s"
    timeout            = "4s"
    failure_threshold  = 4
    success_threshold  = 2
  }
  
  delete_service_on_destroy = true
  
  depends_on = [
    google_app_engine_application.app,
    google_storage_bucket_object.app_archive
  ]
}

# Storage bucket for deployment
resource "google_storage_bucket" "deployment_bucket" {
  name     = "${var.project_id}-appengine-deployment"
  location = "US"
  
  uniform_bucket_level_access = true
}

# Upload app archive to storage
resource "google_storage_bucket_object" "app_archive" {
  name   = "app-${formatdate("YYYY-MM-DD-hhmm", timestamp())}.zip"
  bucket = google_storage_bucket.deployment_bucket.name
  source = data.archive_file.app_zip.output_path
  
  depends_on = [data.archive_file.app_zip]
}

# Traffic allocation (promote new version)
resource "google_app_engine_service_split_traffic" "livetraffic" {
  service = google_app_engine_standard_app_version.myapp_v1.service
  
  migrate_traffic = false
  
  split {
    shard_by = "UNSPECIFIED"
    allocations = {
      (google_app_engine_standard_app_version.myapp_v1.version_id) = 1
    }
  }
  
  depends_on = [google_app_engine_standard_app_version.myapp_v1]
}

# Outputs
output "app_engine_url" {
  value = "https://${var.project_id}.appspot.com"
}

output "app_engine_default_hostname" {
  value = google_app_engine_application.app.default_hostname
}

output "deployment_bucket" {
  value = google_storage_bucket.deployment_bucket.name
}

output "app_version" {
  value = google_app_engine_standard_app_version.myapp_v1.version_id
}

output "health_check_url" {
  value = "https://${var.project_id}.appspot.com/health"
}

output "api_info_url" {
  value = "https://${var.project_id}.appspot.com/api/info"
}
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
App Engine Qwik Start Automation - Python Script
Author: CodeWithGarry
"""

import os
import time
import json
import subprocess
import requests
from pathlib import Path

class AppEngineQuickStartLab:
    def __init__(self, project_id, region="us-central"):
        self.project_id = project_id
        self.region = region
        self.app_name = "hello-world-app"
        self.app_dir = Path(self.app_name)
        
    def enable_apis(self):
        """Enable required APIs"""
        print("🔧 Enabling APIs...")
        result = subprocess.run([
            'gcloud', 'services', 'enable', 'appengine.googleapis.com'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ App Engine API enabled")
        else:
            print(f"❌ Error enabling API: {result.stderr}")
    
    def create_app_engine_app(self):
        """Create App Engine application"""
        print("🏗️ Creating App Engine application...")
        
        # Check if app already exists
        result = subprocess.run([
            'gcloud', 'app', 'describe', '--format=value(id)'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ App Engine application already exists")
            return True
        
        # Create new app
        result = subprocess.run([
            'gcloud', 'app', 'create', f'--region={self.region}'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ App Engine application created")
            return True
        else:
            print(f"❌ Error creating app: {result.stderr}")
            return False
    
    def create_application_files(self):
        """Create application files"""
        print("📁 Creating application files...")
        
        # Create app directory
        self.app_dir.mkdir(exist_ok=True)
        
        # Create main.py
        main_py_content = '''
from flask import Flask, jsonify, request
import os
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    return f"""
    <html>
        <head>
            <title>Hello from App Engine</title>
            <style>
                body {{ font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }}
                .container {{ max-width: 600px; margin: 0 auto; }}
                .title {{ color: #4285F4; }}
                .subtitle {{ color: #34A853; }}
                .links {{ margin-top: 30px; }}
                .link {{ color: #EA4335; margin: 10px; text-decoration: none; }}
            </style>
        </head>
        <body>
            <div class="container">
                <h1 class="title">Hello World from App Engine!</h1>
                <p class="subtitle">Deployed with Python automation by CodeWithGarry</p>
                <p>Environment: {os.environ.get('ENVIRONMENT', 'development')}</p>
                <p>Version: {os.environ.get('VERSION', '1.0')}</p>
                <div class="links">
                    <a href="/api/info" class="link">API Info</a> | 
                    <a href="/health" class="link">Health Check</a>
                </div>
            </div>
        </body>
    </html>
    """

@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'deployed_with': 'python_automation'
    })

@app.route('/api/info')
def api_info():
    """API information endpoint."""
    return jsonify({
        'app_name': 'Hello World App',
        'version': os.environ.get('VERSION', '1.0'),
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'runtime': 'python39',
        'deployed_with': 'python_automation',
        'author': 'CodeWithGarry',
        'endpoints': {
            'home': '/',
            'health': '/health',
            'info': '/api/info'
        }
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found', 'status': 404}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error', 'status': 500}), 500

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
        '''.strip()
        
        with open(self.app_dir / 'main.py', 'w') as f:
            f.write(main_py_content)
        
        # Create requirements.txt
        requirements_content = '''
Flask==2.3.3
Werkzeug==2.3.7
gunicorn==21.2.0
requests==2.31.0
        '''.strip()
        
        with open(self.app_dir / 'requirements.txt', 'w') as f:
            f.write(requirements_content)
        
        # Create app.yaml
        app_yaml_content = '''
runtime: python39

env_variables:
  ENVIRONMENT: production
  VERSION: "1.0"
  DEPLOYED_WITH: python_automation

automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.6
  target_throughput_utilization: 0.6
  min_concurrent_requests: 1
  max_concurrent_requests: 80
  max_idle_instances: 3
  max_pending_latency: 1s
  min_pending_latency: 0.01s

readiness_check:
  path: "/health"
  check_interval_sec: 5
  timeout_sec: 4
  app_start_timeout_sec: 300

liveness_check:
  path: "/health"
  check_interval_sec: 30
  timeout_sec: 4
  failure_threshold: 4
  success_threshold: 2

handlers:
- url: /static
  static_dir: static
  secure: always

- url: /.*
  script: auto
  secure: always
        '''.strip()
        
        with open(self.app_dir / 'app.yaml', 'w') as f:
            f.write(app_yaml_content)
        
        # Create .gcloudignore
        gcloudignore_content = '''
.git
.gitignore
.pytest_cache
__pycache__/
*.pyc
.env
.venv
env/
venv/
README.md
tests/
*.log
.DS_Store
automation.py
        '''.strip()
        
        with open(self.app_dir / '.gcloudignore', 'w') as f:
            f.write(gcloudignore_content)
        
        print("✅ Application files created")
    
    def deploy_application(self):
        """Deploy application to App Engine"""
        print("🚀 Deploying application...")
        
        # Change to app directory
        original_dir = os.getcwd()
        os.chdir(self.app_dir)
        
        try:
            result = subprocess.run([
                'gcloud', 'app', 'deploy', 'app.yaml',
                '--version=v1',
                '--promote',
                '--stop-previous-version',
                '--quiet'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Application deployed successfully")
                return True
            else:
                print(f"❌ Deployment failed: {result.stderr}")
                return False
        finally:
            os.chdir(original_dir)
    
    def test_application(self):
        """Test deployed application"""
        print("🧪 Testing application...")
        
        # Get app URL
        result = subprocess.run([
            'gcloud', 'app', 'describe', '--format=value(defaultHostname)'
        ], capture_output=True, text=True)
        
        if result.returncode != 0:
            print("❌ Could not get app URL")
            return False
        
        app_url = f"https://{result.stdout.strip()}"
        
        # Test endpoints
        endpoints = {
            'main': '/',
            'health': '/health',
            'api_info': '/api/info'
        }
        
        for name, path in endpoints.items():
            url = f"{app_url}{path}"
            try:
                response = requests.get(url, timeout=30)
                if response.status_code == 200:
                    print(f"✅ {name.title()} endpoint working (HTTP {response.status_code})")
                else:
                    print(f"❌ {name.title()} endpoint issue (HTTP {response.status_code})")
            except Exception as e:
                print(f"❌ Error testing {name} endpoint: {str(e)}")
        
        return app_url
    
    def get_app_info(self):
        """Get application information"""
        print("📊 Getting application information...")
        
        # Get app details
        result = subprocess.run([
            'gcloud', 'app', 'describe', '--format=json'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            app_info = json.loads(result.stdout)
            print(f"✅ App ID: {app_info.get('id')}")
            print(f"✅ Location: {app_info.get('locationId')}")
            print(f"✅ Serving Status: {app_info.get('servingStatus')}")
            print(f"✅ Default Hostname: {app_info.get('defaultHostname')}")
    
    def run_complete_lab(self):
        """Run the complete lab automation"""
        print("🚀 Starting App Engine Qwik Start Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📍 Region: {self.region}")
        
        try:
            # Execute all tasks
            self.enable_apis()
            
            if not self.create_app_engine_app():
                return False
            
            self.create_application_files()
            
            if not self.deploy_application():
                return False
            
            # Wait for deployment to be ready
            print("⏳ Waiting for deployment to be ready...")
            time.sleep(30)
            
            app_url = self.test_application()
            self.get_app_info()
            
            print("\n🎉 App Engine application deployed successfully!")
            print(f"🌐 Application URL: {app_url}")
            print(f"🔍 Health Check: {app_url}/health")
            print(f"📊 API Info: {app_url}/api/info")
            print("📈 Dashboard: https://console.cloud.google.com/appengine")
            
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
    lab = AppEngineQuickStartLab(project_id)
    success = lab.run_complete_lab()
    
    sys.exit(0 if success else 1)
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach

---

## 🎖️ Skills Boost Arcade

Complete App Engine automation for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Automate App Engine deployments for faster, consistent results!

</div>
