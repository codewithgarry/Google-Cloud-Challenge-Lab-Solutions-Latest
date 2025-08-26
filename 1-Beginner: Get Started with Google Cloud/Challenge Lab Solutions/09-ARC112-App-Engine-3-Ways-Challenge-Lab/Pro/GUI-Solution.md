# App Engine: Qwik Start - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![App Engine](https://img.shields.io/badge/App%20Engine-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)

**Lab ID**: ARC112 | **Duration**: 5-10 minutes | **Level**: Beginner

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Deploy a Python application to Google App Engine and understand serverless application deployment.

---

## 🧩 Challenge Tasks

1. **Deploy Python App** - Create and deploy Hello World application
2. **Configure App Engine** - Set up App Engine in your project
3. **Test Application** - Verify deployment and access application
4. **View Logs** - Monitor application logs and performance
5. **Scale Application** - Configure automatic scaling

---

## 🖥️ Step-by-Step GUI Solution

### 📋 Prerequisites
- Google Cloud Console access
- Active Google Cloud project
- App Engine API enabled

---

### 🚀 Task 1: Enable App Engine API

1. **Open APIs & Services**
   - Navigate to: **APIs & Services** → **Library**
   - Search for: `App Engine Admin API`
   - Click **ENABLE**

2. **Verify API Status**
   - Go to: **APIs & Services** → **Enabled APIs**
   - Confirm `App Engine Admin API` is listed

![Enable API](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Enable+App+Engine+API)

---

### 🏗️ Task 2: Initialize App Engine Application

1. **Access App Engine Console**
   - Go to: **Navigation Menu** → **App Engine** → **Dashboard**
   - Click **Create Application**

2. **Select Region**
   - Choose region: **us-central**
   - Click **Create app**

3. **Language Selection**
   - Select: **Python**
   - Environment: **Standard**
   - Click **Next**

![Initialize App Engine](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Initialize+App+Engine)

---

### 🎨 Task 3: Create Application Files

1. **Open Cloud Shell**
   - Click **Activate Cloud Shell** (top-right corner)
   - Wait for shell to initialize

2. **Create Project Directory**
   ```bash
   mkdir hello-app
   cd hello-app
   ```

3. **Create Main Application File**
   - In Cloud Shell Editor, create `main.py`:
   ```python
   from flask import Flask

   app = Flask(__name__)

   @app.route('/')
   def hello():
       return '<h1>Hello World from App Engine!</h1>'

   if __name__ == '__main__':
       app.run(host='127.0.0.1', port=8080, debug=True)
   ```

4. **Create Requirements File**
   - Create `requirements.txt`:
   ```text
   Flask==2.3.3
   ```

5. **Create App Engine Configuration**
   - Create `app.yaml`:
   ```yaml
   runtime: python39
   
   env_variables:
     ENVIRONMENT: production
   
   automatic_scaling:
     min_instances: 0
     max_instances: 10
   ```

![Create Files](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Create+Application+Files)

---

### 🚀 Task 4: Deploy Application

1. **Deploy from Cloud Shell**
   ```bash
   gcloud app deploy
   ```

2. **Deployment Confirmation**
   - Type: `Y` when prompted
   - Wait for deployment to complete (2-3 minutes)

3. **Get Application URL**
   ```bash
   gcloud app browse
   ```

![Deploy App](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Deploy+Application)

---

### 🌐 Task 5: Test Application

1. **Access Application**
   - Click the generated URL or go to:
   - `https://PROJECT_ID.appspot.com`

2. **Verify Response**
   - Should display: "Hello World from App Engine!"
   - Check page loads correctly

3. **Test Multiple Requests**
   - Refresh page several times
   - Verify consistent response

![Test Application](https://via.placeholder.com/600x300/FF9800/FFFFFF?text=Test+Application)

---

### 📊 Task 6: Monitor Application

1. **View App Engine Dashboard**
   - Go to: **App Engine** → **Dashboard**
   - Review deployment status
   - Check traffic metrics

2. **Access Application Logs**
   - Go to: **App Engine** → **Logs**
   - Filter by: **Recent logs**
   - View request logs

3. **Monitor Performance**
   - Go to: **App Engine** → **Instances**
   - Check active instances
   - Review resource usage

![Monitor App](https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=Monitor+Application)

---

### ⚙️ Task 7: Configure Scaling (Optional)

1. **Edit Scaling Configuration**
   - Update `app.yaml`:
   ```yaml
   runtime: python39
   
   automatic_scaling:
     min_instances: 1
     max_instances: 5
     target_cpu_utilization: 0.6
     target_throughput_utilization: 0.6
   ```

2. **Redeploy with New Configuration**
   ```bash
   gcloud app deploy
   ```

3. **Verify Scaling Settings**
   - Go to: **App Engine** → **Versions**
   - Check version details
   - Confirm scaling configuration

![Configure Scaling](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=Configure+Scaling)

---

## ✅ Verification Steps

### 1. Application Deployment
- [ ] App Engine application created
- [ ] Python application deployed successfully
- [ ] Application accessible via URL

### 2. Application Functionality
- [ ] Hello World page displays correctly
- [ ] Application responds to requests
- [ ] Logs show successful requests

### 3. App Engine Features
- [ ] Dashboard shows deployment metrics
- [ ] Logs accessible and readable
- [ ] Scaling configuration active

---

## 🎯 Key Learning Points

1. **Serverless Deployment** - No infrastructure management needed
2. **Automatic Scaling** - Handles traffic spikes automatically
3. **Integrated Monitoring** - Built-in logging and metrics
4. **Simple Configuration** - YAML-based app configuration
5. **Multiple Environments** - Support for staging and production

---

## 🔧 Troubleshooting Guide

### ❌ Common Issues

| Issue | Solution |
|-------|----------|
| API not enabled | Enable App Engine Admin API |
| Region selection error | Choose supported region |
| Deployment timeout | Check network and retry |
| Application not accessible | Verify firewall rules |
| Scaling not working | Check scaling configuration |

### 🔍 Debug Commands
```bash
# Check app status
gcloud app describe

# View recent logs
gcloud app logs tail -s default

# List versions
gcloud app versions list

# Check scaling settings
gcloud app describe --format="value(defaultBucket)"
```

---

## 📚 Additional Resources

- [App Engine Documentation](https://cloud.google.com/appengine/docs)
- [Python Runtime](https://cloud.google.com/appengine/docs/standard/python3)
- [Scaling Configuration](https://cloud.google.com/appengine/docs/standard/python3/config/appref)

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line deployment approach
- **[Automation Solution](Automation-Solution.md)** - Scripted deployment with Terraform

---

## 🎖️ Skills Boost Arcade

Complete this challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use App Engine for quick serverless application deployment!

</div>
