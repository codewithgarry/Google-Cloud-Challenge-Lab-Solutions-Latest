# ARC107: Get Started with Looker: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll create a Looker instance, connect it to BigQuery, create data models, and build visualizations for business intelligence and analytics.

## 📋 Challenge Tasks

### Task 1: Create Looker Instance

**Requirements:**
- **Instance Name**: `looker-instance`
- **Region**: `us-central1`
- **Edition**: Looker Core

### Task 2: Connect to BigQuery

Set up connection to BigQuery datasets.

### Task 3: Create LookML Project

Build data models using LookML.

### Task 4: Create Dashboards

Build interactive dashboards and reports.

### Task 5: Share and Schedule Reports

Configure sharing and automated reporting.

---

## 🚀 Quick Solution Steps

### Step 1: Enable Required APIs

```bash
# Enable Looker API
gcloud services enable looker.googleapis.com

# Enable BigQuery API
gcloud services enable bigquery.googleapis.com

# Enable Cloud Resource Manager API
gcloud services enable cloudresourcemanager.googleapis.com

# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1
```

### Step 2: Create Sample BigQuery Dataset

```bash
# Create BigQuery dataset
bq mk --location=US sales_data

# Create sample tables
bq mk --table sales_data.customers \
  customer_id:INTEGER,name:STRING,email:STRING,city:STRING,state:STRING,country:STRING,signup_date:DATE

bq mk --table sales_data.products \
  product_id:INTEGER,product_name:STRING,category:STRING,price:FLOAT,supplier:STRING

bq mk --table sales_data.orders \
  order_id:INTEGER,customer_id:INTEGER,order_date:DATE,total_amount:FLOAT,status:STRING

bq mk --table sales_data.order_items \
  order_item_id:INTEGER,order_id:INTEGER,product_id:INTEGER,quantity:INTEGER,unit_price:FLOAT

# Load sample data
cat > customers.csv << 'EOF'
customer_id,name,email,city,state,country,signup_date
1,John Doe,john@example.com,New York,NY,USA,2023-01-15
2,Jane Smith,jane@example.com,Los Angeles,CA,USA,2023-02-20
3,Bob Johnson,bob@example.com,Chicago,IL,USA,2023-03-10
4,Alice Brown,alice@example.com,Houston,TX,USA,2023-04-05
5,Charlie Wilson,charlie@example.com,Phoenix,AZ,USA,2023-05-12
EOF

cat > products.csv << 'EOF'
product_id,product_name,category,price,supplier
101,Laptop Pro,Electronics,1299.99,TechCorp
102,Wireless Mouse,Electronics,29.99,TechCorp
103,Office Chair,Furniture,199.99,FurniCo
104,Desk Lamp,Furniture,49.99,FurniCo
105,Coffee Mug,Kitchen,12.99,HomeGoods
EOF

cat > orders.csv << 'EOF'
order_id,customer_id,order_date,total_amount,status
1001,1,2023-06-01,1329.98,completed
1002,2,2023-06-02,199.99,completed
1003,3,2023-06-03,62.98,completed
1004,1,2023-06-04,49.99,completed
1005,4,2023-06-05,1299.99,pending
EOF

cat > order_items.csv << 'EOF'
order_item_id,order_id,product_id,quantity,unit_price
1,1001,101,1,1299.99
2,1001,102,1,29.99
3,1002,103,1,199.99
4,1003,104,1,49.99
5,1003,105,1,12.99
6,1004,104,1,49.99
7,1005,101,1,1299.99
EOF

# Load data into BigQuery
bq load --source_format=CSV --skip_leading_rows=1 sales_data.customers customers.csv
bq load --source_format=CSV --skip_leading_rows=1 sales_data.products products.csv
bq load --source_format=CSV --skip_leading_rows=1 sales_data.orders orders.csv
bq load --source_format=CSV --skip_leading_rows=1 sales_data.order_items order_items.csv
```

### Step 3: Create Looker Instance

```bash
# Create Looker instance
gcloud looker instances create looker-instance \
    --location=$REGION \
    --platform-edition=LOOKER_CORE_STANDARD \
    --consumer-network=projects/$PROJECT_ID/global/networks/default

# Wait for instance to be ready (this can take 15-20 minutes)
gcloud looker instances describe looker-instance --location=$REGION

# Get Looker instance URL
export LOOKER_URL=$(gcloud looker instances describe looker-instance \
    --location=$REGION \
    --format='value(lookerUri)')

echo "Looker Instance URL: $LOOKER_URL"
```

### Step 4: Create Service Account for BigQuery Connection

```bash
# Create service account for Looker
gcloud iam service-accounts create looker-bigquery-sa \
    --description="Service account for Looker BigQuery connection" \
    --display-name="Looker BigQuery Service Account"

# Grant BigQuery permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:looker-bigquery-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataViewer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:looker-bigquery-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"

# Create and download service account key
gcloud iam service-accounts keys create looker-sa-key.json \
    --iam-account=looker-bigquery-sa@$PROJECT_ID.iam.gserviceaccount.com

echo "Service account key created: looker-sa-key.json"
```

---

## 🎯 LookML Project Setup

### Step 1: Create LookML Files

Once your Looker instance is ready, you'll need to create LookML files. Here are the templates:

#### Connection File (connection.view.lkml)
```sql
connection: "bigquery_connection" {
  label: "BigQuery Sales Data"
  sql_dialect: sql_standard_2017
  database: "PROJECT_ID"
  project: "PROJECT_ID"
  
  connection_pool_timeout: 300
  query_timezone: "America/New_York"
  
  case_sensitive: no
  datagroup_trigger: "sales_data_default"
}
```

#### Customer View (customers.view.lkml)
```sql
view: customers {
  sql_table_name: `PROJECT_ID.sales_data.customers` ;;
  
  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }
  
  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }
  
  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }
  
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }
  
  dimension_group: signup {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.signup_date ;;
  }
  
  measure: count {
    type: count
    label: "Number of Customers"
  }
}
```

#### Orders Explore (orders.model.lkml)
```sql
connection: "bigquery_connection"

include: "*.view.lkml"

datagroup: sales_data_default {
  sql_trigger: SELECT MAX(order_date) FROM `PROJECT_ID.sales_data.orders` ;;
  max_cache_age: "1 hour"
}

explore: orders {
  label: "Sales Analysis"
  
  join: customers {
    type: left_outer
    sql_on: ${orders.customer_id} = ${customers.customer_id} ;;
    relationship: many_to_one
  }
  
  join: order_items {
    type: left_outer
    sql_on: ${orders.order_id} = ${order_items.order_id} ;;
    relationship: one_to_many
  }
  
  join: products {
    type: left_outer
    sql_on: ${order_items.product_id} = ${products.product_id} ;;
    relationship: many_to_one
  }
}
```

---

## 📊 Dashboard Creation

### Step 1: Sales Overview Dashboard

Create dashboard with these tiles:

1. **Total Revenue** (Single Value)
```sql
SELECT SUM(total_amount) as total_revenue
FROM `PROJECT_ID.sales_data.orders`
WHERE status = 'completed'
```

2. **Revenue by Month** (Line Chart)
```sql
SELECT 
  EXTRACT(MONTH FROM order_date) as month,
  SUM(total_amount) as monthly_revenue
FROM `PROJECT_ID.sales_data.orders`
WHERE status = 'completed'
GROUP BY month
ORDER BY month
```

3. **Top Products** (Bar Chart)
```sql
SELECT 
  p.product_name,
  SUM(oi.quantity * oi.unit_price) as revenue
FROM `PROJECT_ID.sales_data.order_items` oi
JOIN `PROJECT_ID.sales_data.products` p ON oi.product_id = p.product_id
JOIN `PROJECT_ID.sales_data.orders` o ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10
```

4. **Customer Distribution by State** (Map)
```sql
SELECT 
  state,
  COUNT(*) as customer_count
FROM `PROJECT_ID.sales_data.customers`
GROUP BY state
```

### Step 2: Customer Analytics Dashboard

1. **Customer Acquisition** (Area Chart)
2. **Customer Lifetime Value** (Table)
3. **Geographic Distribution** (Map)
4. **Customer Segmentation** (Pie Chart)

---

## 🔄 Alternative GUI Solution

### Using Looker Studio (Data Studio)

If Looker instance creation takes too long, you can use Looker Studio:

```bash
# Create a view for Looker Studio
bq mk --use_legacy_sql=false --view \
'SELECT 
  o.order_id,
  o.order_date,
  o.total_amount,
  o.status,
  c.name as customer_name,
  c.city,
  c.state,
  p.product_name,
  p.category,
  oi.quantity,
  oi.unit_price
FROM `'$PROJECT_ID'.sales_data.orders` o
JOIN `'$PROJECT_ID'.sales_data.customers` c ON o.customer_id = c.customer_id
JOIN `'$PROJECT_ID'.sales_data.order_items` oi ON o.order_id = oi.order_id
JOIN `'$PROJECT_ID'.sales_data.products` p ON oi.product_id = p.product_id' \
sales_data.sales_summary
```

Then connect to Looker Studio:
1. Go to https://datastudio.google.com
2. Create new report
3. Add BigQuery connector
4. Select your project and `sales_data.sales_summary` view

---

## ✅ Validation

### Verify Looker Instance

```bash
# Check instance status
gcloud looker instances describe looker-instance --location=$REGION

# List all instances
gcloud looker instances list --location=$REGION

# Test BigQuery connection
bq query --use_legacy_sql=false \
'SELECT COUNT(*) as total_orders FROM `'$PROJECT_ID'.sales_data.orders`'
```

### Dashboard Validation

1. **Data Accuracy**: Verify calculations match source data
2. **Visualizations**: Check charts render correctly
3. **Filters**: Test interactive filtering
4. **Performance**: Ensure queries execute quickly

---

## 🔧 Troubleshooting

**Issue**: Looker instance creation fails
- Check quotas and limits
- Verify billing is enabled
- Ensure network configuration

**Issue**: BigQuery connection fails
- Verify service account permissions
- Check firewall rules
- Validate connection parameters

**Issue**: LookML syntax errors
- Check indentation and structure
- Validate SQL syntax
- Review field references

---

## 📚 Key Learning Points

- **Business Intelligence**: Creating actionable insights from data
- **LookML**: Modeling data relationships and calculations
- **Data Visualization**: Choosing appropriate chart types
- **Dashboard Design**: Creating user-friendly interfaces
- **Performance Optimization**: Efficient query design

---

## 🏆 Challenge Complete!

You've successfully demonstrated Looker fundamentals by:
- ✅ Creating a Looker instance
- ✅ Connecting to BigQuery data sources
- ✅ Building LookML data models
- ✅ Creating interactive dashboards
- ✅ Implementing business intelligence workflows

<div align="center">

**🎉 Congratulations! You've completed ARC107!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC111%20Cloud%20Storage-blue?style=for-the-badge)](../6-ARC111-Get-Started-with-Cloud-Storage-Challenge-Lab/)

</div>
