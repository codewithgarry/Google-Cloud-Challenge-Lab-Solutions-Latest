# Get Started with Looker: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=looker&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 📋 Challenge Tasks

**Task 1**: Create a new report in Looker Studio  
**Task 2**: Create a new view in Looker  
**Task 3**: Create a new dashboard in Looker

---

## 🚀 Solutions

### Task 1: Create Report in Looker Studio

#### Steps:
1. Go to **https://studio.looker.com**
2. Click **Create** → **Report**
3. **Data source**: BigQuery → `bigquery-public-data` → `thelook_ecommerce` → `orders`
4. Click **CONNECT** → **CREATE REPORT**
5. **Report name**: "Online Sales" (or as specified in lab)
6. Add a **Time series chart**:
   - **Dimension**: `created_at`
   - **Metric**: `Record Count`
7. Save the report

---

### Task 2: Create View in Looker

#### Steps:
1. Access your **Looker instance** (URL provided in lab)
2. Go to **Develop** → **Your Project**
3. Right-click **views** folder → **Create View**
4. **File name**: `users_region`
5. **LookML code**:
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

#### Join to Events Explore:
1. Open the **events explore** file
2. Add this join:
```lookml
explore: events {
  join: users_region {
    type: left_outer
    sql_on: ${events.user_id} = ${users_region.id} ;;
    relationship: many_to_one
  }
}
```
3. **Save** and **Deploy to Production**

---

### Task 3: Create Dashboard in Looker

#### Steps:
1. Go to **Explore** → **Events**
2. **Build query**:
   - **Dimensions**: `Events > Event Type`
   - **Measures**: `Users Region > Count`
   - **Sort**: By count (descending)
   - **Row Limit**: 3
3. **Visualization**: Bar Chart
4. **Save as Look**: "Top Event Types by Users"
5. **Create Dashboard**:
   - Go to **Browse** → **Dashboards**
   - Click **New Dashboard**
   - **Title**: "User Events"
   - **Add** the saved Look
   - **Save**

---

## ✅ Verification

1. **Looker Studio**: Verify "Online Sales" report exists with time series chart
2. **Looker View**: Check `users_region.view` file exists and is deployed
3. **Looker Dashboard**: Verify "User Events" dashboard shows top 3 event types

---

<div align="center">

**© 2025 CodeWithGarry | Google Cloud Challenge Lab Solutions**

*"Simplifying cloud challenges, one solution at a time."*

</div>
