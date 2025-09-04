# ARC112: App Engine: 3 Ways: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![App Engine](https://img.shields.io/badge/App%20Engine-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC112 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

Deploy applications to Google App Engine using three different approaches: Standard Environment, Flexible Environment, and using Cloud Build for automated deployments.

## 📋 Challenge Tasks

### Task 1: Deploy Python App to Standard Environment

Deploy a simple Python Flask application to App Engine Standard.

### Task 2: Deploy Node.js App to Flexible Environment  

Deploy a Node.js application to App Engine Flexible Environment.

### Task 3: Implement Automated Deployment

Use Cloud Build to create a CI/CD pipeline for App Engine deployment.

---

## 🚀 Solution Method 1: Standard Environment

### Step 1: Create Python Flask App

```bash
# Create project directory
mkdir ~/app-engine-standard
cd ~/app-engine-standard

# Create main application file
cat > main.py << 'EOF'
from flask import Flask, render_template_string
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return render_template_string('''
    <h1>Hello from App Engine Standard!</h1>
    <p>This app is running on Google App Engine Standard Environment</p>
    <p>Runtime: Python 3.9</p>
    <p>Instance: {{ instance_id }}</p>
    ''', instance_id=os.environ.get('GAE_INSTANCE', 'local'))

@app.route('/health')
def health():
    return {'status': 'healthy', 'environment': 'standard'}

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
EOF

# Create requirements file
cat > requirements.txt << 'EOF'
Flask==2.3.3
gunicorn==21.2.0
EOF

# Create app.yaml for Standard Environment
cat > app.yaml << 'EOF'
runtime: python39

env_variables:
  ENVIRONMENT: "standard"

handlers:
- url: /.*
  script: auto

automatic_scaling:
  min_instances: 1
  max_instances: 10
  target_cpu_utilization: 0.6
EOF
```

### Step 2: Deploy to Standard Environment

```bash
# Deploy application
gcloud app deploy app.yaml --quiet

# Get the deployed URL
export STANDARD_URL=$(gcloud app describe --format='value(defaultHostname)')
echo "Standard Environment URL: https://$STANDARD_URL"

# Test the deployment
curl https://$STANDARD_URL/health
```

---

## 🚀 Solution Method 2: Flexible Environment

### Step 1: Create Node.js Application

```bash
# Create project directory
mkdir ~/app-engine-flexible
cd ~/app-engine-flexible

# Create package.json
cat > package.json << 'EOF'
{
  "name": "app-engine-flexible",
  "version": "1.0.0",
  "description": "Node.js app for App Engine Flexible",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create main server file
cat > server.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from App Engine Flexible!</h1>
    <p>This app is running on Google App Engine Flexible Environment</p>
    <p>Runtime: Node.js</p>
    <p>Port: ${PORT}</p>
  `);
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    environment: 'flexible',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

# Create app.yaml for Flexible Environment
cat > app.yaml << 'EOF'
runtime: nodejs18
env: flex

env_variables:
  ENVIRONMENT: "flexible"

resources:
  cpu: 1
  memory_gb: 0.5
  disk_size_gb: 10

automatic_scaling:
  min_num_instances: 1
  max_num_instances: 5
  cool_down_period_sec: 120
  target_cpu_utilization: 0.6
EOF

# Create Dockerfile (optional for custom configuration)
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8080
CMD ["npm", "start"]
EOF
```

### Step 2: Deploy to Flexible Environment

```bash
# Install dependencies
npm install

# Deploy to flexible environment
gcloud app deploy app.yaml --version=flexible --quiet

# Test the flexible deployment
curl https://$STANDARD_URL/health
```

---

## 🚀 Solution Method 3: Cloud Build CI/CD

### Step 1: Create Cloud Build Configuration

```bash
# Create project directory for CI/CD demo
mkdir ~/app-engine-cicd
cd ~/app-engine-cicd

# Create a simple Python app
cat > main.py << 'EOF'
from flask import Flask, jsonify
import os
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    return f'''
    <h1>CI/CD Demo App</h1>
    <p>Deployed via Cloud Build</p>
    <p>Build Time: {os.environ.get("BUILD_TIME", "Unknown")}</p>
    <p>Git Commit: {os.environ.get("COMMIT_SHA", "Unknown")}</p>
    '''

@app.route('/api/status')
def status():
    return jsonify({
        'status': 'running',
        'deployment_method': 'cloud_build',
        'timestamp': datetime.now().isoformat(),
        'commit': os.environ.get("COMMIT_SHA", "unknown")
    })

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
EOF

cat > requirements.txt << 'EOF'
Flask==2.3.3
gunicorn==21.2.0
EOF

# Create Cloud Build configuration
cat > cloudbuild.yaml << 'EOF'
steps:
  # Install dependencies
  - name: 'python:3.9'
    entrypoint: 'pip'
    args: ['install', '-r', 'requirements.txt', '--user']
  
  # Run tests (optional)
  - name: 'python:3.9'
    entrypoint: 'python'
    args: ['-m', 'pytest', '-v']
    
  # Deploy to App Engine
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: 'gcloud'
    args: ['app', 'deploy', 'app.yaml', '--quiet']

substitutions:
  _ENVIRONMENT: 'production'

options:
  logging: CLOUD_LOGGING_ONLY
EOF

# Create app.yaml with build information
cat > app.yaml << 'EOF'
runtime: python39

env_variables:
  ENVIRONMENT: "cicd"
  BUILD_TIME: "${BUILD_TIME}"
  COMMIT_SHA: "${COMMIT_SHA}"

handlers:
- url: /.*
  script: auto
EOF

# Create simple test file
cat > test_main.py << 'EOF'
import pytest
from main import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page(client):
    response = client.get('/')
    assert response.status_code == 200
    assert b'CI/CD Demo App' in response.data

def test_status_endpoint(client):
    response = client.get('/api/status')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'running'
EOF
```

### Step 2: Set Up Cloud Build Trigger

```bash
# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Grant App Engine deployment permissions to Cloud Build
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
    --role=roles/appengine.deployer

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
    --role=roles/appengine.serviceAdmin

# Create Cloud Build trigger (manual)
gcloud builds submit --config=cloudbuild.yaml .
```

### Step 3: Automated Git-based Deployment

```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit for CI/CD demo"

# Create Cloud Source Repository (optional)
gcloud source repos create app-engine-demo
git remote add google https://source.developers.google.com/p/$PROJECT_ID/r/app-engine-demo
git push google main

# Create automated trigger
gcloud builds triggers create cloud-source-repositories \
    --repo=app-engine-demo \
    --branch-pattern=".*" \
    --build-config=cloudbuild.yaml \
    --description="Auto-deploy to App Engine"
```

---

## ✅ Validation

### Test All Three Deployments

```bash
# Get App Engine URL
export APP_URL=$(gcloud app describe --format='value(defaultHostname)')

# Test standard environment endpoint
curl https://$APP_URL/

# Test flexible environment (if deployed)
curl https://$APP_URL/health

# Test CI/CD deployment
curl https://$APP_URL/api/status
```

### View Deployment History

```bash
# List all versions
gcloud app versions list

# View application details
gcloud app describe

# Check build history
gcloud builds list --limit=10
```

---

## 🔧 Troubleshooting

**Issue**: Deployment fails
- Check app.yaml syntax
- Verify billing is enabled
- Ensure APIs are enabled

**Issue**: Flexible environment takes too long
- Flexible deployments take 5-10 minutes
- Check resource allocation in app.yaml
- Monitor build logs

**Issue**: Cloud Build permissions
- Verify Cloud Build service account has App Engine permissions
- Check IAM roles are correctly assigned

---

## 📚 Key Learning Points

- **Standard vs Flexible**: Understanding environment differences
- **Configuration Management**: Using app.yaml effectively
- **CI/CD Integration**: Automating deployments with Cloud Build
- **Scaling Options**: Configuring automatic scaling
- **Multi-version Deployment**: Managing different app versions

---

## 🏆 Challenge Complete!

You've successfully demonstrated App Engine deployment using three methods:
- ✅ Standard Environment deployment
- ✅ Flexible Environment deployment  
- ✅ CI/CD pipeline with Cloud Build

<div align="center">

**🎉 Congratulations! You've completed ARC112!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC104%20Cloud%20Functions-blue?style=for-the-badge)](../10-ARC104-Cloud-Run-Functions-3-Ways-Challenge-Lab/)

</div>
