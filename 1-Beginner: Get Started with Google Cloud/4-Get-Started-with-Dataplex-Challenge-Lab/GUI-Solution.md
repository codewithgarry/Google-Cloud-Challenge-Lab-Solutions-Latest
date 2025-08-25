# Get Started with Dataplex: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![GUI Method](https://img.shields.io/badge/Method-GUI-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🖱️ GUI Method - Step by Step Instructions

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Lake Name**: (specified in your lab)
- **Zone Name**: (specified in your lab)
- **Asset Name**: (specified in your lab)
- **Region**: (usually us-central1)

---

## 🚀 Task 1: Create a Dataplex Lake

### Step-by-Step GUI Instructions:

1. **Navigate to Dataplex**
   - In the Google Cloud Console navigation menu
   - Click **☰** → **Dataplex**

2. **Create Lake**
   - Click **CREATE LAKE**
   - **Display name**: Enter the lake name specified in your lab
   - **Lake ID**: Will auto-populate from display name
   - **Region**: Select the region specified in your lab (usually us-central1)

3. **Configure Lake Settings**
   - **Description**: "Challenge lab data lake" (optional)
   - Click **CREATE**

4. **Verify Lake Creation**
   - Lake should appear in the lakes list
   - Status should show as "Active"

---

## 🚀 Task 2: Create a Zone in the Lake

### Step-by-Step GUI Instructions:

1. **Access the Lake**
   - Click on the lake name you just created
   - You'll be taken to the lake details page

2. **Create Zone**
   - Click **ADD ZONE** or **CREATE ZONE**
   - **Zone type**: Select **Raw zone** (for raw data) or **Curated zone** (as specified in lab)
   - **Display name**: Enter the zone name specified in your lab
   - **Zone ID**: Will auto-populate

3. **Configure Zone Settings**
   - **Description**: "Challenge lab zone" (optional)
   - **Location**: Same region as the lake
   - Click **CREATE**

4. **Verify Zone Creation**
   - Zone should appear in the lake's zones list
   - Status should show as "Active"

---

## 🚀 Task 3: Add Assets to the Zone

### Step-by-Step GUI Instructions:

1. **Navigate to Zone**
   - Click on the zone name you just created
   - Go to the **ASSETS** tab

2. **Add Asset**
   - Click **ADD ASSETS** or **ATTACH ASSETS**
   - **Asset type**: Select **Cloud Storage bucket**

3. **Configure Asset**
   - **Display name**: Enter the asset name specified in your lab
   - **Asset ID**: Will auto-populate
   - **Resource path**: 
     - For Cloud Storage: `gs://bucket-name/path/` (use bucket from lab)
     - Select the bucket specified in your lab instructions

4. **Configure Discovery Settings**
   - **Enable discovery**: ✅ Check this option
   - **Discovery schedule**: Use default or as specified
   - **Discovery scope**: Include all files or specific patterns

5. **Attach Asset**
   - Click **ATTACH** or **CREATE**
   - Wait for the asset to be attached and discovery to run

---

## 🚀 Task 4: Run Data Discovery (if required)

### Step-by-Step GUI Instructions:

1. **Access Asset**
   - Click on the asset name in your zone
   - Go to the **DISCOVERY** tab

2. **Trigger Discovery**
   - If not auto-started, click **RUN DISCOVERY**
   - Monitor the discovery job progress

3. **View Discovery Results**
   - Once complete, check the **ENTITIES** tab
   - Verify that data entities were discovered
   - Check the **SCHEMA** information

---

## 🔍 Verification Steps

### Check Lake Status:
1. Go to **Dataplex** main page
2. Verify your lake is listed and active
3. Click on lake name to see details

### Check Zone Status:
1. In your lake details page
2. Verify zone is listed under **ZONES** tab
3. Check zone status is "Active"

### Check Asset Status:
1. In your zone details page
2. Go to **ASSETS** tab
3. Verify asset is attached and active
4. Check discovery status

### Verify Data Discovery:
1. Click on your asset
2. Go to **ENTITIES** tab
3. Verify data entities are discovered
4. Check schema information is populated

---

## 📊 Monitoring and Management

### View Lake Metrics:
1. In lake details page
2. Go to **MONITORING** tab
3. Check:
   - **Storage usage**
   - **Discovery jobs**
   - **Asset health**

### Manage Permissions:
1. Go to **IAM** tab in lake details
2. Add users/service accounts as needed
3. Assign appropriate Dataplex roles

### View Logs:
1. Go to **Logs** section
2. Filter by Dataplex service
3. Check for any errors or warnings

---

## 🎯 Pro Tips for GUI Method

- **Plan your lake structure** before creating zones
- **Use descriptive names** for easier management
- **Set up proper IAM** from the beginning
- **Monitor discovery jobs** to ensure they complete successfully
- **Check quotas** if you encounter issues

---

## ✅ Completion Checklist

- [ ] Dataplex lake created with correct name and region
- [ ] Zone created in the lake with correct type
- [ ] Asset attached to zone with proper configuration
- [ ] Data discovery enabled and running successfully
- [ ] Entities discovered and schema populated
- [ ] All components showing "Active" status

---

## 🔗 Related Resources

- [Dataplex Documentation](https://cloud.google.com/dataplex/docs)
- [Data Lake Best Practices](https://cloud.google.com/dataplex/docs/best-practices)
- [Dataplex Monitoring](https://cloud.google.com/dataplex/docs/monitor)

---

**🎉 Congratulations! You've completed the Dataplex Challenge Lab using the GUI method!**

*For other solution methods, check out:*
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
