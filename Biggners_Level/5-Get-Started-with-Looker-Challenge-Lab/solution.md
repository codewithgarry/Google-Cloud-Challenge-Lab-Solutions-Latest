# Get Started with Looker: Challenge Lab - Complete Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=looker&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker%20Studio-4CAF50?style=for-the-badge&logo=google&logoColor=white)
![BigQuery](https://img.shields.io/badge/BigQuery-FFC107?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 45 minutes | **Credits**: No cost | **Level**: Introductory

</div>

---

## 👨‍💻 Author Profile

<div align="center">

### **CodeWithGarry** 
*Google Cloud Solutions Architect & Data Analytics Expert*

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

**🎯 Mission**: Empowering data analysts to master business intelligence with Looker and Looker Studio

</div>

---

## 📋 Challenge Overview

**Scenario**: You're a junior data analyst helping the Sales team analyze and visualize online sales data using both Looker Studio and Looker.

**Objective**: Create comprehensive data visualizations and analysis using BigQuery public data, custom views, and interactive dashboards.

**Components**:
```
BigQuery Data → Looker Studio Report
BigQuery Data → Looker Views → Looker Dashboard
```

---

## 🚀 Pre-requisites Setup

### **Access Requirements**
- Google Cloud Console access
- Looker Studio access (studio.looker.com)
- Looker instance access (provided in lab)
- BigQuery public datasets enabled

### **Lab Environment Check**
1. Verify access to your Looker instance URL (provided in lab details)
2. Ensure BigQuery API is enabled in your project
3. Confirm access to `thelook_ecommerce` public dataset

---

## 📝 Task Solutions

### 🎯 Task 1: Create a New Report in Looker Studio

#### **Method 1: Using Looker Studio GUI (Recommended)**

**Step 1: Access Looker Studio**
1. Open a new browser tab and navigate to **https://studio.looker.com**
2. Sign in with your lab Google account
3. Click **🆕 Create** → **Report**

**Step 2: Connect to BigQuery Data Source**
1. In the data source selection screen:
   - Click **BigQuery**
   - Select **Public datasets**
   - Navigate to your lab's specified dataset (e.g., `bigquery-public-data`)
   - Select **`thelook_ecommerce`** → **`orders`** table
   - Click **CONNECT**

**Step 3: Create the Report**
1. **Report Setup**:
   - **Report Name**: Change "Untitled Report" to **"Online Sales"**
   - Accept the default field configuration and click **CREATE REPORT**

**Step 4: Add Time Series Chart**
1. **Insert Chart**:
   - Click **📊 Add a chart**
   - Select **📈 Time series chart**
   - Place the chart on your canvas

2. **Configure Chart**:
   - **Data tab**:
     - **Dimension**: `created_at` (should be auto-selected)
     - **Metric**: `Record Count` or any relevant measure
   - **Style tab**:
     - Choose any theme/colors you prefer
     - Add a meaningful title (e.g., "Orders Over Time")

3. **Save the Report**:
   - Click **File** → **Save** or **Ctrl+S**
   - Confirm the report name is "Online Sales"

---

### 🎯 Task 2: Create a New View in Looker

#### **Method 1: Using Looker GUI (Recommended)**

**Step 1: Access Looker Instance**
1. Navigate to your Looker instance URL (provided in lab)
2. Sign in with your lab credentials
3. Go to **Develop** → **<Your Project>** (usually the project name from lab)

**Step 2: Create New View File**
1. **Navigate to Views**:
   - In the project explorer, find the **views** folder
   - Right-click on **views** folder
   - Select **Create View**

2. **Name the View**:
   - **File name**: `users_region`
   - Click **Create**

**Step 3: Define the View**
1. **Replace the default content** with the following LookML code:

```lookml
view: users_region {
  sql_table_name: `cloud-training-demos.looker_ecomm.users` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  measure: count {
    type: count
    drill_fields: [id, state, country]
  }
}
```

2. **Save the view**:
   - Click **Save Changes**

**Step 4: Join View to Events Explore**
1. **Find the Events Explore**:
   - Navigate to the **explores** folder
   - Open the file that contains the **events** explore

2. **Add the Join**:
   - In the events explore definition, add the following join:

```lookml
explore: events {
  # existing configuration...
  
  join: users_region {
    type: left_outer
    sql_on: ${events.user_id} = ${users_region.id} ;;
    relationship: many_to_one
  }
}
```

3. **Save the explore file**

**Step 5: Deploy to Production**
1. **Validate Changes**:
   - Click **Project** → **Validate LookML**
   - Ensure no errors are present

2. **Deploy to Production**:
   - Click **Deploy** → **Deploy to Production**
   - Add a commit message: "Add users_region view and join to events explore"
   - Click **Deploy to Production**

#### **Method 2: Using LookML via Command Line Interface**

```bash
# Note: This requires Looker CLI setup which is typically not available in challenge labs
# The GUI method above is the recommended approach for challenge labs

# If you had Looker CLI access, you would:
# 1. Clone the LookML project
# 2. Create the view file locally
# 3. Push changes back to the project
# 4. Deploy via git workflow
```

---

### 🎯 Task 3: Create a New Dashboard in Looker

#### **Method 1: Using Looker GUI (Recommended)**

**Step 1: Create a New Look (Chart)**
1. **Navigate to Explore**:
   - Go to **Explore** → **Events** (your explore with the new join)

2. **Build the Query**:
   - **Dimensions**: 
     - Add `Events > Event Type`
   - **Measures**: 
     - Add `Users Region > Count`
   
3. **Configure the Visualization**:
   - **Visualization Type**: Select **Bar Chart**
   - **Sort**: Sort by `Users Region Count` (descending)
   - **Row Limit**: Set to **3** (for top 3 event types)

4. **Customize the Chart**:
   - Click **Edit** → **Plot**
   - **Colors**: Choose your preferred color scheme
   - **Labels**: Customize axis labels and title
   - **Title**: Add a meaningful title like "Top 3 Event Types by User Count"

5. **Save as Look**:
   - Click **⚙️ Settings** → **Save** → **Save as Look**
   - **Title**: "Top Event Types by Users"
   - **Description**: Optional description
   - Click **Save**

**Step 2: Create New Dashboard**
1. **Create Dashboard**:
   - Go to **Browse** → **Dashboards**
   - Click **🆕 New Dashboard**
   - **Title**: "User Events"
   - Click **Create Dashboard**

2. **Add Look to Dashboard**:
   - Click **✏️ Edit Dashboard**
   - Click **Add** → **Look**
   - Search for and select your saved look: "Top Event Types by Users"
   - Position and resize as needed
   - Click **Save Changes**

3. **Final Dashboard Setup**:
   - Add any additional formatting or filters if desired
   - Click **Done Editing**

#### **Method 2: Alternative Dashboard Creation**

If you encounter issues with the explore, you can create a dashboard directly:

1. **Go to Dashboards**:
   - Navigate to **Browse** → **Dashboards**
   - Click **New Dashboard**

2. **Create Dashboard**:
   - **Title**: "User Events"
   - Click **Create Dashboard**

3. **Add Visualization**:
   - Click **Edit Dashboard**
   - Click **Add** → **Query**
   - Select your **Events** explore
   - Build the same query as above
   - Save directly to the dashboard

---

## 🔍 Verification Steps

### **Verify Looker Studio Report**
1. Navigate to https://studio.looker.com
2. Confirm "Online Sales" report exists
3. Verify BigQuery connection to `thelook_ecommerce.orders`
4. Check that time series chart is present and configured

### **Verify Looker View and Join**
1. In Looker, go to **Develop** → **<Your Project>**
2. Confirm `users_region.view` file exists with correct dimensions
3. Check that the Events explore includes the join
4. Verify deployment status shows "Production"

### **Verify Looker Dashboard**
1. Navigate to **Browse** → **Dashboards**
2. Confirm "User Events" dashboard exists
3. Verify the bar chart shows top 3 event types
4. Check that data is displaying correctly

---

## 🐛 Troubleshooting Guide

### **Issue 1: Cannot Access Looker Studio**
```
Solution:
1. Ensure you're using the correct lab Google account
2. Try incognito/private browsing mode
3. Clear browser cache and cookies
4. Verify internet connectivity
```

### **Issue 2: BigQuery Dataset Not Found**
```
Solution:
1. Verify the exact dataset name from lab instructions
2. Check project permissions for BigQuery access
3. Ensure BigQuery API is enabled
4. Try refreshing the data source connection
```

### **Issue 3: Looker View Validation Errors**
```
Solution:
1. Check LookML syntax carefully (spacing, semicolons)
2. Verify table name format: `cloud-training-demos.looker_ecomm.users`
3. Ensure all required fields are properly defined
4. Validate before attempting to deploy
```

### **Issue 4: Join Not Working in Explore**
```
Solution:
1. Verify the join syntax matches the field names exactly
2. Check that both views have the necessary key fields
3. Ensure the explore file is saved and deployed
4. Try refreshing the explore page
```

### **Issue 5: Dashboard Not Displaying Data**
```
Solution:
1. Verify the explore query returns data
2. Check that the join is working correctly
3. Ensure proper permissions on underlying tables
4. Try creating a simpler query first to test connectivity
```

---

## 🚀 Complete Task Automation Guide

While Looker Studio and Looker are primarily GUI-based tools, here are some automation tips:

### **Looker Studio Automation**
```bash
# Looker Studio is primarily GUI-based, but you can:
# 1. Use the Looker Studio API (requires setup)
# 2. Create templates for repeated use
# 3. Use Google Apps Script for custom integrations

# For challenge labs, manual GUI method is recommended
```

### **Looker LookML Automation**
```bash
# If you have git access to LookML project:

# 1. Clone the LookML repository
git clone <your-looker-project-repo>

# 2. Create the view file
cat > views/users_region.view.lkml << 'EOF'
view: users_region {
  sql_table_name: `cloud-training-demos.looker_ecomm.users` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  measure: count {
    type: count
    drill_fields: [id, state, country]
  }
}
EOF

# 3. Update the explore file
# (Manual edit required for join configuration)

# 4. Commit and push changes
git add .
git commit -m "Add users_region view and join"
git push origin main

# 5. Deploy via Looker UI
```

### **Quick Completion Checklist**
```bash
# Challenge Lab Quick Completion Guide:

# Task 1: Looker Studio (5-10 minutes)
# ✅ Go to studio.looker.com
# ✅ Create "Online Sales" report
# ✅ Connect to thelook_ecommerce.orders
# ✅ Add time series chart

# Task 2: Looker View Creation (15-20 minutes)
# ✅ Access Looker instance
# ✅ Create users_region view with specified fields
# ✅ Join to events explore
# ✅ Deploy to production

# Task 3: Looker Dashboard (10-15 minutes)
# ✅ Create bar chart query in events explore
# ✅ Customize visualization
# ✅ Save to "User Events" dashboard
```

---

## 📚 Key Concepts Explained

### **🎨 Looker Studio**
- **Purpose**: Self-service business intelligence and data visualization
- **Data Sources**: Connects to BigQuery, Google Sheets, and 600+ connectors
- **Sharing**: Easy sharing and collaboration features
- **Best Practice**: Use for executive dashboards and external reporting

### **🔍 Looker (Core Platform)**
- **LookML**: Modeling layer that defines business logic
- **Views**: Define table structures and calculations
- **Explores**: Define how views join together for analysis
- **Dashboards**: Collections of visualizations for specific use cases

### **📊 BigQuery Integration**
- **Public Datasets**: Free access to sample data for learning
- **Performance**: Optimized for large-scale analytics
- **Security**: Fine-grained access controls and data governance

---

## ✅ Final Verification Checklist

- [ ] **Looker Studio Report**: "Online Sales" created with BigQuery connection
- [ ] **Time Series Chart**: Added to Looker Studio report with custom styling
- [ ] **Looker View**: `users_region` created with all required dimensions and measures
- [ ] **Explore Join**: `users_region` successfully joined to events explore
- [ ] **Production Deployment**: Changes deployed to production in Looker
- [ ] **Dashboard Creation**: "User Events" dashboard created in Looker
- [ ] **Bar Chart**: Top 3 event types visualization added to dashboard
- [ ] **Data Validation**: All components displaying data correctly

**Lab completion time**: 35-45 minutes

---

<div align="center">

## 🎯 **About This Solution**

This comprehensive Looker challenge lab solution is crafted by **CodeWithGarry** to help you master business intelligence and data visualization on Google Cloud Platform.

### 📞 **Connect with CodeWithGarry**

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/codewithgarry)

### 🌟 **Why Choose Our Solutions?**

✅ **BI Expertise**: Specialized knowledge in Looker and data visualization  
✅ **GUI-First Approach**: Detailed step-by-step visual instructions  
✅ **Real-World Focus**: Business intelligence best practices  
✅ **Complete Coverage**: All aspects of Looker ecosystem  

---

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Transforming data into insights, one visualization at a time."*

**Happy Learning! 🚀📊**

</div>
