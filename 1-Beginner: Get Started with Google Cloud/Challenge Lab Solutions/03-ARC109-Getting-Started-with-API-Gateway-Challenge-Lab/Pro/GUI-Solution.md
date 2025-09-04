# Getting Started with API Gateway: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![API Gateway](https://img.shields.io/badge/API%20Gateway-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![GUI Method](https://img.shields.io/badge/Method-GUI-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC109 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🖱️ GUI Method - Step by Step Instructions

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Function Name**: (specified in your lab)
- **API Gateway Name**: (specified in your lab)
- **Region**: (usually us-central1)

---

## 🚀 Task 1: Deploy Cloud Function

### Step-by-Step GUI Instructions:

1. **Navigate to Cloud Functions**
   - In the Google Cloud Console navigation menu
   - Click **☰** → **Cloud Functions**

2. **Create Function**
   - Click **CREATE FUNCTION**
   - **Function name**: Enter the name specified in your lab
   - **Region**: Select `us-central1` (or as specified)

3. **Configure Trigger**
   - **Trigger**: Select **HTTP**
   - **Authentication**: Select **Allow unauthenticated invocations**
   - Click **SAVE**

4. **Configure Runtime**
   - **Runtime**: Select **Node.js 18** (or latest available)
   - **Memory allocated**: 256 MiB (default)
   - **Timeout**: 60 seconds (default)

5. **Add Source Code**
   - **Source code**: Select **Inline editor**
   - **Entry point**: `helloWorld`
   - Replace the default code with:
   ```javascript
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
   ```

6. **Deploy Function**
   - Click **DEPLOY**
   - Wait for deployment to complete (green checkmark)

7. **Get Function URL**
   - Click on the deployed function name
   - Go to **TRIGGER** tab
   - Copy the **Trigger URL** (you'll need this for API Gateway)

---

## 🚀 Task 2: Create API Config

### Step-by-Step GUI Instructions:

1. **Navigate to API Gateway**
   - Click **☰** → **API Gateway**

2. **Create API**
   - Click **CREATE GATEWAY**
   - **Display name**: Enter the gateway name from your lab
   - **API ID**: Will auto-populate

3. **Create API Config**
   - In the **API Config** section
   - **Display name**: Enter a config name (e.g., "my-api-config")
   - **Upload an OpenAPI Spec**: Select this option

4. **Prepare OpenAPI Specification**
   - Create the OpenAPI spec file with this content:
   ```yaml
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
           address: YOUR_CLOUD_FUNCTION_URL  # Replace with actual URL
         responses:
           '200':
             description: A successful response
             schema:
               type: string
   ```

5. **Upload OpenAPI Spec**
   - Replace `YOUR_CLOUD_FUNCTION_URL` with the Cloud Function URL from Task 1
   - Save the content as `openapi-spec.yaml`
   - Click **BROWSE** and upload the file
   - Or use **Inline** and paste the content

---

## 🚀 Task 3: Create and Deploy API Gateway

### Continue Gateway Creation:

1. **Configure Gateway**
   - **Location**: Select the region specified in your lab
   - **Service Account**: Use the default service account

2. **Deploy Gateway**
   - Click **CREATE GATEWAY**
   - Wait for the gateway to be created (this may take several minutes)

3. **Verify Deployment**
   - Once created, you'll see the gateway in the list
   - Click on the gateway name to view details
   - Note the **Gateway URL** in the details

### Test the API Gateway:

1. **Get Gateway URL**
   - From the gateway details page
   - Copy the **Gateway URL**

2. **Test the Endpoint**
   - Open a new browser tab
   - Navigate to: `GATEWAY_URL/hello`
   - You should see "Hello from API Gateway!" response

---

## 🔍 Verification Steps

### Check Cloud Function:
1. Go to **Cloud Functions**
2. Verify your function is deployed and active
3. Test the function directly using its trigger URL

### Check API Gateway:
1. Go to **API Gateway**
2. Verify your gateway is created and deployed
3. Check the gateway status is "Active"

### Test End-to-End:
1. Use the gateway URL with `/hello` endpoint
2. Verify you get the expected response
3. Check that CORS headers are properly set

---

## 📊 Monitoring and Logs

### View Function Logs:
1. Go to **Cloud Functions**
2. Click on your function name
3. Go to **LOGS** tab to see execution logs

### View Gateway Metrics:
1. Go to **API Gateway**
2. Click on your gateway name
3. Go to **METRICS** tab to see API usage

### Check Error Logs:
1. Go to **Logging** in the console
2. Filter by resource type "Cloud Function" or "API Gateway"
3. Look for any error messages

---

## 🎯 Pro Tips for GUI Method

- **Keep multiple tabs open** for Cloud Functions and API Gateway
- **Use browser bookmarks** for quick navigation
- **Save OpenAPI spec** locally for future reference
- **Test function first** before creating API Gateway
- **Check quotas** if deployment fails

---

## 🔧 Troubleshooting Common Issues

### Function Deployment Issues:
- **Check region** - ensure it matches lab requirements
- **Verify permissions** - ensure you have Cloud Functions Admin role
- **Check quotas** - ensure you haven't exceeded function quotas

### API Gateway Issues:
- **Invalid OpenAPI spec** - validate YAML syntax
- **Wrong function URL** - ensure URL is correct and accessible
- **Permission errors** - check service account permissions

### CORS Issues:
- **Add CORS headers** to function code
- **Handle OPTIONS** requests in function
- **Check browser console** for CORS errors

---

## ✅ Completion Checklist

- [ ] Cloud Function deployed successfully
- [ ] Function URL accessible and returns response
- [ ] OpenAPI specification created with correct function URL
- [ ] API Gateway created and deployed
- [ ] Gateway URL accessible
- [ ] End-to-end test successful (/hello endpoint works)

---

## 🔗 Related Resources

- [Cloud Functions Documentation](https://cloud.google.com/functions/docs)
- [API Gateway Documentation](https://cloud.google.com/api-gateway/docs)
- [OpenAPI Specification](https://swagger.io/specification/)

---

**🎉 Congratulations! You've completed the API Gateway Challenge Lab using the GUI method!**

*For other solution methods, check out:*
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
