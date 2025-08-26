# Cloud Functions: Qwik Start - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Cloud Functions](https://img.shields.io/badge/Cloud%20Functions-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=for-the-badge&logo=gnu-bash&logoColor=white)

**Lab ID**: ARC104 | **Duration**: 5-10 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🚀 Complete CLI Solution

Deploy serverless functions using Cloud Functions CLI commands.

---

## 🧩 Challenge Tasks

1. **Setup Environment** - Enable APIs and configure CLI
2. **Create Function** - Develop Python function with HTTP trigger
3. **Deploy Function** - Deploy using gcloud commands
4. **Test Function** - Validate deployment and functionality
5. **Monitor Function** - Check logs and performance

---

## ⚡ Quick Start Commands

```bash
# Complete Cloud Functions deployment
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export FUNCTION_NAME="hello-world-function"

# Enable required APIs
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Create function directory
mkdir cloud-function && cd cloud-function

# Create main.py
cat > main.py << 'EOF'
import functions_framework
import json
from datetime import datetime

@functions_framework.http
def hello_world(request):
    headers = {'Access-Control-Allow-Origin': '*'}
    
    if request.method == 'OPTIONS':
        headers.update({
            'Access-Control-Allow-Methods': 'GET, POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        })
        return ('', 204, headers)
    
    name = request.args.get('name', 'World')
    if request.method == 'POST':
        request_json = request.get_json(silent=True)
        if request_json and 'name' in request_json:
            name = request_json['name']
    
    response_data = {
        'message': f'Hello, {name}! This is a Cloud Function.',
        'method': request.method,
        'timestamp': datetime.utcnow().isoformat(),
        'author': 'CodeWithGarry'
    }
    
    headers['Content-Type'] = 'application/json'
    return (json.dumps(response_data), 200, headers)
EOF

# Create requirements.txt
echo "functions-framework==3.4.0" > requirements.txt

# Deploy function
gcloud functions deploy $FUNCTION_NAME \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point hello_world

# Get function URL
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(httpsTrigger.url)"
```

---

## 📋 Step-by-Step CLI Solution

### 🔧 Task 1: Environment Setup

```bash
# Set environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export FUNCTION_NAME="hello-world-function"

echo "🚀 Setting up Cloud Functions for project: $PROJECT_ID"

# Enable required APIs
echo "🔧 Enabling APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable logging.googleapis.com

# Verify APIs are enabled
gcloud services list --enabled --filter="name:(cloudfunctions.googleapis.com OR cloudbuild.googleapis.com OR artifactregistry.googleapis.com)" --format="table(name,title)"

echo "✅ APIs enabled successfully"
```

### 🏗️ Task 2: Create Function Code

```bash
# Create function directory
echo "📁 Creating function directory..."
mkdir -p cloud-function
cd cloud-function

# Create main function file
cat > main.py << 'EOF'
import functions_framework
import json
import os
from datetime import datetime

@functions_framework.http
def hello_world(request):
    """HTTP Cloud Function entry point.
    Args:
        request (flask.Request): The request object.
    Returns:
        Response object with appropriate status and content.
    """
    
    # Handle CORS preflight requests
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)
    
    # Set CORS headers for main request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }
    
    try:
        # Get request method and parameters
        method = request.method
        
        # Handle different request methods
        if method == 'GET':
            name = request.args.get('name', 'World')
            action = request.args.get('action', 'greet')
        elif method == 'POST':
            request_json = request.get_json(silent=True) or {}
            name = request_json.get('name', 'World')
            action = request_json.get('action', 'greet')
        else:
            return (json.dumps({'error': f'Method {method} not allowed'}), 405, headers)
        
        # Generate response based on action
        if action == 'greet':
            message = f'Hello, {name}! This is a Cloud Function deployed via CLI.'
        elif action == 'info':
            message = f'Function info for {name}'
        else:
            message = f'Unknown action: {action}. Hello, {name}!'
        
        # Prepare response data
        response_data = {
            'message': message,
            'request_method': method,
            'timestamp': datetime.utcnow().isoformat(),
            'function_name': os.environ.get('K_SERVICE', 'hello-world-function'),
            'function_region': os.environ.get('FUNCTION_REGION', 'us-central1'),
            'version': '1.0',
            'author': 'CodeWithGarry',
            'deployment_type': 'CLI'
        }
        
        # Add request details for debugging
        if name != 'World':
            response_data['personalized'] = True
            response_data['name'] = name
        
        return (json.dumps(response_data, indent=2), 200, headers)
        
    except Exception as e:
        error_response = {
            'error': 'Internal server error',
            'message': str(e),
            'timestamp': datetime.utcnow().isoformat(),
            'function_name': os.environ.get('K_SERVICE', 'hello-world-function')
        }
        return (json.dumps(error_response), 500, headers)

# Health check endpoint (for testing)
@functions_framework.http
def health_check(request):
    """Health check endpoint"""
    return json.dumps({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'function': 'health-check'
    })
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
functions-framework==3.4.0
flask==2.3.3
EOF

# Create .gcloudignore file
cat > .gcloudignore << 'EOF'
.git
.gitignore
__pycache__/
*.pyc
.pytest_cache/
.venv/
venv/
env/
.env
*.log
.DS_Store
README.md
tests/
EOF

echo "✅ Function code created"
ls -la
```

### 🚀 Task 3: Deploy Function

```bash
# Deploy the Cloud Function
echo "🚀 Deploying Cloud Function..."

gcloud functions deploy $FUNCTION_NAME \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point hello_world \
    --memory 256MB \
    --timeout 60s \
    --max-instances 100 \
    --source . \
    --quiet

# Check deployment status
if [ $? -eq 0 ]; then
    echo "✅ Function deployed successfully"
else
    echo "❌ Function deployment failed"
    exit 1
fi

# Get function details
echo "📊 Function details:"
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="table(name,status,trigger.httpsTrigger.url,runtime,availableMemoryMb,timeout)"
```

### 🧪 Task 4: Test Function

```bash
# Get function URL
FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(httpsTrigger.url)")
echo "🌐 Function URL: $FUNCTION_URL"

# Test GET request with default parameters
echo "🧪 Testing GET request (default)..."
curl -s "$FUNCTION_URL" | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))"

# Test GET request with custom name
echo -e "\n🧪 Testing GET request (custom name)..."
curl -s "$FUNCTION_URL?name=CodeWithGarry&action=greet" | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))"

# Test POST request
echo -e "\n🧪 Testing POST request..."
curl -s -X POST "$FUNCTION_URL" \
    -H "Content-Type: application/json" \
    -d '{"name": "Cloud Functions CLI", "action": "info"}' | \
    python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))"

# Test response time
echo -e "\n⏱️ Testing response time..."
curl -w "Response time: %{time_total}s\n" -s -o /dev/null "$FUNCTION_URL"

echo "✅ Function tests completed"
```

### 📊 Task 5: Monitor Function

```bash
# View function logs
echo "📝 Viewing function logs..."
gcloud functions logs read $FUNCTION_NAME --region=$REGION --limit=10 --format="table(timestamp,severity,textPayload)"

# Get function metrics
echo -e "\n📈 Function metrics:"
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="yaml(status,updateTime,versionId,runtime,availableMemoryMb,maxInstances,timeout)"

# Stream live logs (optional - comment out for automation)
# echo "📡 Streaming live logs (Ctrl+C to stop)..."
# gcloud functions logs tail $FUNCTION_NAME --region=$REGION

echo "✅ Monitoring setup complete"
```

### 🔄 Task 6: Function Management

```bash
# List all functions
echo "📋 All Cloud Functions:"
gcloud functions list --format="table(name,status,trigger.httpsTrigger.url,runtime,region)"

# Get function source code info
echo -e "\n💻 Function source info:"
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="yaml(sourceArchiveUrl,updateTime,runtime,entryPoint)"

# Test function invocation count
echo -e "\n🔢 Function execution test..."
for i in {1..3}; do
    echo "Request $i:"
    curl -s "$FUNCTION_URL?name=Test$i" | python3 -c "import sys, json; print('Response:', json.load(sys.stdin)['message'])"
    sleep 1
done

# Check recent logs after test
echo -e "\n📋 Recent execution logs:"
gcloud functions logs read $FUNCTION_NAME --region=$REGION --limit=5 --format="value(timestamp,httpRequest.requestMethod,httpRequest.status)"
```

---

## 📈 Advanced CLI Operations

### 🔄 Function Updates

```bash
# Update function with new code
echo "🔄 Updating function..."

# Modify main.py for version 2
cat > main.py << 'EOF'
import functions_framework
import json
import os
from datetime import datetime

@functions_framework.http
def hello_world(request):
    headers = {'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json'}
    
    if request.method == 'OPTIONS':
        headers.update({
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Max-Age': '3600'
        })
        return ('', 204, headers)
    
    # Enhanced version with more features
    method = request.method
    
    if method == 'GET':
        name = request.args.get('name', 'World')
        version = request.args.get('version', '2.0')
    elif method == 'POST':
        request_json = request.get_json(silent=True) or {}
        name = request_json.get('name', 'World')
        version = request_json.get('version', '2.0')
    else:
        return (json.dumps({'error': f'Method {method} not supported'}), 405, headers)
    
    response_data = {
        'message': f'Hello, {name}! Enhanced Cloud Function v{version}',
        'features': ['CORS support', 'Error handling', 'Enhanced logging', 'Version tracking'],
        'request_method': method,
        'timestamp': datetime.utcnow().isoformat(),
        'function_name': os.environ.get('K_SERVICE', 'hello-world-function'),
        'version': '2.0',
        'author': 'CodeWithGarry',
        'deployment_type': 'CLI Enhanced'
    }
    
    return (json.dumps(response_data, indent=2), 200, headers)
EOF

# Redeploy with updates
gcloud functions deploy $FUNCTION_NAME \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point hello_world \
    --memory 512MB \
    --timeout 60s \
    --source . \
    --quiet

echo "✅ Function updated to version 2.0"

# Test updated function
FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(httpsTrigger.url)")
curl -s "$FUNCTION_URL?name=UpdatedFunction&version=2.0" | python3 -c "import sys, json; print(json.dumps(json.load(sys.stdin), indent=2))"
```

### 📊 Monitoring and Debugging

```bash
# Comprehensive monitoring
echo "📊 Comprehensive function monitoring..."

# Function execution metrics
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="yaml(status,updateTime,runtime,availableMemoryMb,maxInstances,timeout,labels)"

# Check function logs with different severity levels
echo -e "\n🔍 Error logs:"
gcloud functions logs read $FUNCTION_NAME --region=$REGION --filter="severity>=ERROR" --limit=5

echo -e "\n📊 Info logs:"
gcloud functions logs read $FUNCTION_NAME --region=$REGION --filter="severity=INFO" --limit=5

# Export function configuration
echo -e "\n💾 Exporting function configuration..."
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="export" > function-config.yaml
echo "Configuration exported to function-config.yaml"

# Function URL for sharing
echo -e "\n🔗 Function endpoints:"
echo "Main endpoint: $FUNCTION_URL"
echo "Test with name: $FUNCTION_URL?name=YourName"
echo "POST test: curl -X POST $FUNCTION_URL -H 'Content-Type: application/json' -d '{\"name\":\"CLI User\"}'"
```

### 🔧 Environment Variables and Settings

```bash
# Update function with environment variables
echo "🔧 Adding environment variables..."

gcloud functions deploy $FUNCTION_NAME \
    --runtime python311 \
    --trigger-http \
    --allow-unauthenticated \
    --region $REGION \
    --entry-point hello_world \
    --set-env-vars ENVIRONMENT=production,VERSION=2.0,AUTHOR=CodeWithGarry \
    --memory 512MB \
    --timeout 60s \
    --source . \
    --quiet

# Verify environment variables
echo "✅ Environment variables set:"
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="yaml(environmentVariables)"
```

---

## ✅ Verification Commands

```bash
# Complete verification suite
echo "✅ Running verification suite..."

# 1. Verify function exists and is active
FUNCTION_STATUS=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(status)")
if [ "$FUNCTION_STATUS" = "ACTIVE" ]; then
    echo "✅ Function is active and ready"
else
    echo "❌ Function status: $FUNCTION_STATUS"
fi

# 2. Verify HTTP trigger
TRIGGER_URL=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(httpsTrigger.url)")
if [ -n "$TRIGGER_URL" ]; then
    echo "✅ HTTP trigger configured: $TRIGGER_URL"
else
    echo "❌ No HTTP trigger found"
fi

# 3. Test function response
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TRIGGER_URL")
if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Function responding correctly (HTTP 200)"
else
    echo "❌ Function response issue (HTTP $HTTP_STATUS)"
fi

# 4. Verify logs are accessible
LOG_COUNT=$(gcloud functions logs read $FUNCTION_NAME --region=$REGION --limit=1 --format="value(timestamp)" | wc -l)
if [ "$LOG_COUNT" -gt "0" ]; then
    echo "✅ Function logs accessible"
else
    echo "❌ No logs available"
fi

# 5. Check function runtime and memory
RUNTIME=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(runtime)")
MEMORY=$(gcloud functions describe $FUNCTION_NAME --region=$REGION --format="value(availableMemoryMb)")
echo "✅ Runtime: $RUNTIME, Memory: ${MEMORY}MB"

echo "🎉 Verification completed!"
```

---

## 🔧 Troubleshooting Commands

```bash
# Troubleshooting toolkit
echo "🔧 Cloud Functions troubleshooting..."

# Check project configuration
gcloud config list --format="table(core.project,core.account,functions.region)"

# Verify APIs are enabled
gcloud services list --enabled --filter="cloudfunctions" --format="table(name,title)"

# Check quotas and limits
gcloud compute project-info describe --format="yaml(quotas)" | grep -A 5 -i function

# Debug function deployment
gcloud functions logs read $FUNCTION_NAME --region=$REGION --filter="severity>=WARNING" --limit=10

# Test local function (if functions-framework is installed)
# functions-framework --target=hello_world --debug

# Get detailed function information
gcloud functions describe $FUNCTION_NAME --region=$REGION --format="yaml"
```

---

## 📚 Reference Commands

```bash
# Useful Cloud Functions CLI commands reference

# Function management
gcloud functions deploy FUNCTION_NAME --trigger-http --runtime python311
gcloud functions describe FUNCTION_NAME --region REGION
gcloud functions delete FUNCTION_NAME --region REGION
gcloud functions list

# Logs and monitoring
gcloud functions logs read FUNCTION_NAME --region REGION
gcloud functions logs tail FUNCTION_NAME --region REGION

# Testing and debugging
gcloud functions call FUNCTION_NAME --region REGION --data '{"key":"value"}'

# IAM and permissions
gcloud functions add-iam-policy-binding FUNCTION_NAME --region REGION --member='allUsers' --role='roles/cloudfunctions.invoker'
gcloud functions remove-iam-policy-binding FUNCTION_NAME --region REGION --member='allUsers' --role='roles/cloudfunctions.invoker'
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

**⚡ Pro Tip**: Use gcloud CLI for efficient Cloud Functions deployment and management!

</div>
