# Get Started with Looker: Challenge Lab - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![GUI Method](https://img.shields.io/badge/Method-GUI-34A853?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🖱️ GUI Method - Step by Step Instructions

### 📋 Lab Requirements
Check your lab instructions for these specific values:
- **Instance Name**: (specified in your lab)
- **Database Connection**: (usually BigQuery)
- **Region**: (usually us-central1)

---

## 🚀 Task 1: Create Looker Instance

### Step-by-Step GUI Instructions:

1. **Navigate to Looker**
   - In the Google Cloud Console navigation menu
   - Click **☰** → **Looker (Google Cloud core)**

2. **Create Instance**
   - Click **CREATE INSTANCE**
   - **Instance ID**: Enter the name specified in your lab
   - **Region**: Select the region specified in your lab (usually us-central1)

3. **Configure Instance Settings**
   - **Edition**: Select **Looker (Google Cloud core)**
   - **Platform edition**: Choose **Standard** (or as specified in lab)
   - **User capacity**: Select appropriate size (usually Small for labs)

4. **Network Configuration**
   - **Public IP**: Enable (unless specified otherwise)
   - **Private IP**: Configure if required by lab
   - **Authorized networks**: Add 0.0.0.0/0 for lab purposes

5. **Create Instance**
   - Review settings
   - Click **CREATE**
   - Wait for instance creation (may take 10-15 minutes)

---

## 🚀 Task 2: Access Looker and Set Up Connection

### Step-by-Step GUI Instructions:

1. **Access Looker Instance**
   - Once created, click on the instance name
   - Click **Visit Instance** to open Looker in new tab
   - Sign in with your Google Cloud credentials

2. **Initial Setup**
   - Complete the welcome setup if prompted
   - Set up admin user credentials if required

3. **Navigate to Admin Panel**
   - Click on your profile icon (top right)
   - Select **Admin** → **Connections**

4. **Create Database Connection**
   - Click **New Connection**
   - **Name**: Enter connection name (e.g., "bigquery-connection")
   - **Database**: Select **Google BigQuery Standard SQL**

5. **Configure BigQuery Connection**
   - **Project Name**: Your Google Cloud project ID
   - **Dataset**: Specify dataset from lab (e.g., "public_datasets")
   - **Authentication**: Select **Service Account** or **OAuth**
   - **Service Account Email**: Use Looker service account
   - Click **Test** to verify connection
   - Click **Save** if test successful

---

## 🚀 Task 3: Create LookML Project

### Step-by-Step GUI Instructions:

1. **Navigate to Develop**
   - Click **Develop** in the top navigation
   - Click **Manage LookML Projects**

2. **Create New Project**
   - Click **New LookML Project**
   - **Project Name**: Enter project name from lab
   - **Starting Point**: Choose **Blank Project**
   - **Connection**: Select the connection created in Task 2
   - Click **Create Project**

3. **Set Up Git Repository (if required)**
   - Click **Configure Git** if prompted
   - **Git Repository**: Create or connect to repository
   - **Production Branch**: Usually "main" or "master"
   - Click **Continue**

---

## 🚀 Task 4: Create Views and Explores

### Step-by-Step GUI Instructions:

1. **Access Development Mode**
   - Click **Toggle Development Mode** (if not already on)
   - You should see "Development Mode" indicator

2. **Create View File**
   - In the project file tree, click **+** next to files
   - Select **Create View**
   - **View Name**: Enter view name from lab (e.g., "sales_data")
   - **From Table**: Select table from BigQuery dataset

3. **Configure View**
   - The LookML code will auto-generate
   - Add dimensions and measures as required:
   ```lookml
   view: sales_data {
     sql_table_name: `project.dataset.table_name` ;;
     
     dimension: id {
       primary_key: yes
       type: number
       sql: ${TABLE}.id ;;
     }
     
     dimension: product_name {
       type: string
       sql: ${TABLE}.product_name ;;
     }
     
     measure: count {
       type: count
       drill_fields: [id, product_name]
     }
   }
   ```
   - Click **Save Changes**

4. **Create Model File**
   - Click **+** next to files
   - Select **Create Model**
   - **Model Name**: Enter model name from lab
   - Configure model to include views:
   ```lookml
   connection: "bigquery-connection"
   
   explore: sales_data {
     from: sales_data
   }
   ```
   - Click **Save Changes**

---

## 🚀 Task 5: Create and Share Dashboard

### Step-by-Step GUI Instructions:

1. **Navigate to Explore**
   - Click **Explore** in top navigation
   - Select your explore from the list

2. **Build Query**
   - **Dimensions**: Select relevant dimensions
   - **Measures**: Select relevant measures
   - **Filters**: Add filters as needed
   - Click **Run** to execute query

3. **Create Visualization**
   - Click **Visualizations** tab
   - Select chart type (bar, line, table, etc.)
   - Customize visualization settings
   - Click **Done**

4. **Save to Dashboard**
   - Click **Save** → **To Dashboard**
   - **Dashboard**: Create new or select existing
   - **Title**: Enter tile title
   - Click **Save to Dashboard**

5. **Share Dashboard**
   - Navigate to **Browse** → **Dashboards**
   - Open your dashboard
   - Click **Share** button
   - Configure sharing settings:
     - **Access**: Set to appropriate level
     - **Schedule Delivery**: Configure if needed
   - Click **Save**

---

## 🔍 Verification Steps

### Check Instance Status:
1. Go to **Looker (Google Cloud core)** in Console
2. Verify instance is "Running"
3. Check instance details and connectivity

### Verify Database Connection:
1. In Looker Admin → Connections
2. Test the BigQuery connection
3. Ensure connection shows "Connected" status

### Test LookML Project:
1. Navigate to Develop → Your Project
2. Validate LookML code (no errors)
3. Test explores work correctly

### Verify Dashboard:
1. Browse to your dashboard
2. Ensure visualizations load properly
3. Test interactivity and filters

---

## 📊 Additional Features to Explore

### Data Modeling:
- Create additional views for related tables
- Set up joins between views
- Add calculated fields and table calculations

### Advanced Visualizations:
- Create custom visualizations
- Set up drill-down paths
- Configure conditional formatting

### User Management:
- Set up user groups and permissions
- Configure content access controls
- Create shared folders for collaboration

---

## 🎯 Pro Tips for GUI Method

- **Use Looker's IDE** for efficient LookML development
- **Test connections** before building complex models
- **Save frequently** during development
- **Use version control** for LookML projects
- **Preview data** before creating final visualizations

---

## ✅ Completion Checklist

- [ ] Looker instance created and running
- [ ] BigQuery connection established and tested
- [ ] LookML project created with proper git setup
- [ ] Views created with dimensions and measures
- [ ] Model file configured with explores
- [ ] Dashboard created with visualizations
- [ ] Content shared with appropriate permissions

---

## 🔗 Related Resources

- [Looker Documentation](https://cloud.google.com/looker/docs)
- [LookML Reference](https://cloud.google.com/looker/docs/lookml-reference)
- [Looker Best Practices](https://cloud.google.com/looker/docs/best-practices)

---

**🎉 Congratulations! You've completed the Looker Challenge Lab using the GUI method!**

*For other solution methods, check out:*
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
