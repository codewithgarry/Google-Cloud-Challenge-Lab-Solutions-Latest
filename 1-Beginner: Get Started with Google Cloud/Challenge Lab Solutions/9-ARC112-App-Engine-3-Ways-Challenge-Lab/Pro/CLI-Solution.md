# App Engine: Qwik Start - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![App Engine](https://img.shields.io/badge/App%20Engine-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=for-the-badge&logo=gnu-bash&logoColor=white)

**Lab ID**: ARC112 | **Duration**: 5-10 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🚀 Complete CLI Solution

Deploy Python application to App Engine using command-line tools.

---

## 🧩 Challenge Tasks

1. **Setup Environment** - Configure gcloud CLI and enable APIs
2. **Create Application** - Develop Python Flask application
3. **Deploy to App Engine** - Deploy using gcloud commands
4. **Test and Verify** - Validate deployment and functionality
5. **Monitor Application** - Check logs and performance

---

## ⚡ Quick Start Commands

```bash
# Complete deployment in one go
export PROJECT_ID=$(gcloud config get-value project)

# Enable required APIs
gcloud services enable appengine.googleapis.com

# Create app (if not exists)
gcloud app create --region=us-central

# Create application files
mkdir hello-app && cd hello-app

# Create main.py
cat > main.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return '<h1>Hello World from App Engine!</h1>'

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.3
EOF

# Create app.yaml
cat > app.yaml << 'EOF'
runtime: python39

env_variables:
  ENVIRONMENT: production

automatic_scaling:
  min_instances: 0
  max_instances: 10
  target_cpu_utilization: 0.6
EOF

# Deploy application
gcloud app deploy --quiet

# Get application URL
gcloud app browse --no-launch-browser
```

---

## 📋 Step-by-Step CLI Solution

### 🔧 Task 1: Environment Setup

```bash
# Set project configuration
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central"

echo "🚀 Setting up App Engine for project: $PROJECT_ID"

# Enable App Engine API
echo "🔧 Enabling App Engine API..."
gcloud services enable appengine.googleapis.com

# Verify API is enabled
gcloud services list --enabled --filter="name:appengine.googleapis.com" --format="value(name)"

echo "✅ App Engine API enabled"
```

### 🏗️ Task 2: Initialize App Engine

```bash
# Create App Engine application
echo "🏗️ Initializing App Engine application..."

# Check if app already exists
if gcloud app describe --format="value(id)" 2>/dev/null; then
    echo "✅ App Engine application already exists"
else
    gcloud app create --region=$REGION
    echo "✅ App Engine application created in $REGION"
fi

# Get app details
gcloud app describe --format="table(id,locationId,servingStatus)"
```

### 🎨 Task 3: Create Application Code

```bash
# Create project directory
echo "🎨 Creating application files..."
mkdir -p hello-app
cd hello-app

# Create main application file
cat > main.py << 'EOF'
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    return '<h1>Hello World from App Engine!</h1><p>Deployed with CLI by CodeWithGarry</p>'

@app.route('/health')
def health():
    """Health check endpoint."""
    return {'status': 'healthy', 'version': '1.0'}

if __name__ == '__main__':
    # Used when running locally only
    app.run(host='127.0.0.1', port=8080, debug=True)
EOF

# Create requirements file
cat > requirements.txt << 'EOF'
Flask==2.3.3
Werkzeug==2.3.7
EOF

# Create App Engine configuration
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
EOF

# Create .gcloudignore file
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
EOF

echo "✅ Application files created"
ls -la
```

### 🚀 Task 4: Deploy Application

```bash
# Deploy to App Engine
echo "🚀 Deploying application to App Engine..."

# Deploy with automatic confirmation
gcloud app deploy app.yaml \
    --version=v1 \
    --promote \
    --stop-previous-version \
    --quiet

# Check deployment status
echo "✅ Deployment completed"

# Get application URL
APP_URL=$(gcloud app browse --no-launch-browser --format="value(url)")
echo "🌐 Application URL: $APP_URL"
```

### 🧪 Task 5: Test Application

```bash
# Test application endpoints
echo "🧪 Testing application..."

# Get app URL
APP_URL=$(gcloud app describe --format="value(defaultHostname)")
APP_URL="https://$APP_URL"

# Test main endpoint
echo "Testing main endpoint..."
curl -s "$APP_URL" | head -1

# Test health endpoint
echo "Testing health endpoint..."
curl -s "$APP_URL/health" | python3 -m json.tool

# Check response time
echo "Checking response time..."
curl -w "Response time: %{time_total}s\n" -s -o /dev/null "$APP_URL"

echo "✅ Application tests completed"
```

### 📊 Task 6: Monitor and Manage

```bash
# View application information
echo "📊 Application monitoring..."

# Get app details
echo "Application details:"
gcloud app describe --format="table(id,locationId,servingStatus,defaultHostname)"

# List versions
echo "Application versions:"
gcloud app versions list --format="table(id,service,version,traffic_split,last_deployed)"

# View recent logs
echo "Recent application logs:"
gcloud app logs tail --num-logs=10

# Check instances
echo "Active instances:"
gcloud app instances list --format="table(service,version,id,qps,latency,memory_usage)"

# Get traffic allocation
echo "Traffic allocation:"
gcloud app services list --format="table(id,versions[].id,versions[].traffic_split)"
```

### 🔧 Task 7: Application Management

```bash
# Additional management commands

# View application metrics
echo "🔧 Application management commands:"

# Stop application (if needed)
# gcloud app versions stop v1 --service=default

# Set traffic split (if multiple versions)
# gcloud app services set-traffic default --splits=v1=100

# Open application in browser
echo "Opening application in browser..."
gcloud app browse

# Get logs with filter
echo "Application logs (errors only):"
gcloud app logs read --severity=ERROR --limit=5

# Describe service configuration
echo "Service configuration:"
gcloud app describe --format="yaml(automaticScaling,envVariables)"
```

---

## 📈 Advanced CLI Operations

### 🔄 Scaling Management

```bash
# Update scaling configuration
cat > app-scaled.yaml << 'EOF'
runtime: python39

automatic_scaling:
  min_instances: 1
  max_instances: 20
  target_cpu_utilization: 0.5
  target_throughput_utilization: 0.5
  
  min_concurrent_requests: 1
  max_concurrent_requests: 80
  max_idle_instances: 3
  max_pending_latency: 1s
  min_pending_latency: 0.01s
EOF

# Deploy with new scaling
gcloud app deploy app-scaled.yaml --version=v2 --no-promote --quiet

# Split traffic between versions
gcloud app services set-traffic default --splits=v1=80,v2=20
```

### 📝 Log Analysis

```bash
# Comprehensive log analysis
echo "📝 Log analysis..."

# Get error logs
gcloud app logs read --severity=ERROR --limit=10 --format="table(timestamp,severity,sourceLocation.file,textPayload)"

# Get request logs
gcloud app logs read --filter="resource.type=gae_app" --limit=20 --format="table(timestamp,httpRequest.requestMethod,httpRequest.requestUrl,httpRequest.status)"

# Stream live logs
# gcloud app logs tail --service=default

# Export logs to file
gcloud app logs read --limit=100 --format="value(timestamp,severity,textPayload)" > app-logs.txt
```

### 🚀 Deployment Strategies

```bash
# Blue-green deployment
echo "🚀 Blue-green deployment strategy..."

# Deploy new version without promoting
gcloud app deploy --version=blue --no-promote --quiet

# Test new version
BLUE_URL=$(gcloud app versions describe blue --service=default --format="value(versionUrl)")
curl -s "$BLUE_URL" | head -1

# Switch traffic to new version
gcloud app services set-traffic default --splits=blue=100

# Clean up old version
gcloud app versions delete v1 --service=default --quiet
```

---

## ✅ Verification Commands

```bash
# Complete verification suite
echo "✅ Running verification suite..."

# 1. Verify deployment
if gcloud app describe --format="value(servingStatus)" | grep -q "SERVING"; then
    echo "✅ App Engine application is serving"
else
    echo "❌ App Engine application not serving"
fi

# 2. Verify application response
APP_URL=$(gcloud app describe --format="value(defaultHostname)")
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$APP_URL")
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Application responding correctly (HTTP 200)"
else
    echo "❌ Application not responding correctly (HTTP $HTTP_STATUS)"
fi

# 3. Verify scaling configuration
MIN_INSTANCES=$(gcloud app describe --format="value(automaticScaling.minInstances)")
if [ "$MIN_INSTANCES" -ge "0" ]; then
    echo "✅ Scaling configuration is valid"
else
    echo "❌ Scaling configuration issue"
fi

# 4. Verify logs are accessible
LOG_COUNT=$(gcloud app logs read --limit=1 --format="value(timestamp)" | wc -l)
if [ "$LOG_COUNT" -gt "0" ]; then
    echo "✅ Logs are accessible"
else
    echo "❌ No logs available"
fi

echo "🎉 Verification completed!"
```

---

## 🔧 Troubleshooting Commands

```bash
# Troubleshooting toolkit
echo "🔧 Troubleshooting commands..."

# Check project configuration
gcloud config list --format="table(core.project,core.account,compute.region)"

# Verify APIs
gcloud services list --enabled --filter="appengine" --format="table(name,title)"

# Check quotas
gcloud compute project-info describe --format="table(quotas[].metric,quotas[].limit,quotas[].usage)"

# Debug deployment issues
gcloud app logs read --severity=ERROR --limit=20

# Check instance health
gcloud app instances list --format="table(service,version,id,qps,errors,availability)"

# Test local development
# python3 main.py  # Run locally on port 8080
```

---

## 📚 Reference Commands

```bash
# Useful App Engine CLI commands reference

# Application management
gcloud app create --region=REGION
gcloud app describe
gcloud app deploy [CONFIG_FILE]
gcloud app browse

# Version management
gcloud app versions list
gcloud app versions describe VERSION
gcloud app versions delete VERSION
gcloud app versions migrate VERSION

# Service management
gcloud app services list
gcloud app services set-traffic SERVICE --splits=VERSION=PERCENTAGE
gcloud app services describe SERVICE

# Instance management
gcloud app instances list
gcloud app instances describe INSTANCE
gcloud app instances ssh INSTANCE

# Log management
gcloud app logs tail
gcloud app logs read
gcloud app logs read --severity=ERROR
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Console-based deployment approach
- **[Automation Solution](Automation-Solution.md)** - Terraform and script automation

---

## 🎖️ Skills Boost Arcade

Complete this CLI challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use gcloud CLI for faster App Engine deployments and automation!

</div>
