# Get Started with Looker: Challenge Lab - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![CLI Method](https://img.shields.io/badge/Method-CLI-FBBC04?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## ⚡ CLI Method - Fast & Efficient

### 📋 Lab Requirements
```bash
# Set variables (replace with your lab values)
export INSTANCE_NAME="your-looker-instance"
export REGION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)
```

---

## 🚀 Task 1: Create Looker Instance

```bash
# Create Looker instance
gcloud looker instances create $INSTANCE_NAME \
    --region=$REGION \
    --edition=LOOKER_CORE_STANDARD \
    --consumer-network=default \
    --enable-public-ip

# Check instance status
gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION
```

---

## 🚀 Task 2: Get Instance Details

```bash
# Get instance URL
export LOOKER_URL=$(gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="value(lookerUri)")

echo "Looker Instance URL: $LOOKER_URL"

# Get instance status
gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="value(state)"
```

---

## 🚀 Task 3: Configure Looker (Manual Steps)

**Note**: The following steps require manual interaction with the Looker web interface, as CLI access to Looker's internal configuration is limited.

### Create LookML Project Files

```bash
# Create project directory structure
mkdir -p looker-project/{views,models,dashboards}
cd looker-project

# Create view file
cat > views/sales_data.view.lkml << 'EOF'
view: sales_data {
  sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items` ;;
  
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  
  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }
  
  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }
  
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }
  
  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }
  
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }
  
  measure: count {
    type: count
    drill_fields: [id, order_id, user_id, product_id]
  }
  
  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }
  
  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }
}
EOF

# Create model file
cat > models/ecommerce.model.lkml << 'EOF'
connection: "bigquery-connection"

include: "/views/*.view.lkml"

explore: sales_data {
  from: sales_data
  description: "Sales data analysis"
}
EOF

# Create dashboard file
cat > dashboards/sales_dashboard.dashboard.lookml << 'EOF'
- dashboard: sales_dashboard
  title: Sales Dashboard
  layout: responsive
  tile_size: 100
  
  elements:
  - title: Total Sales
    name: total_sales
    model: ecommerce
    explore: sales_data
    type: single_value
    fields: [sales_data.total_sales]
    limit: 500
    
  - title: Sales by Month
    name: sales_by_month
    model: ecommerce
    explore: sales_data
    type: looker_line
    fields: [sales_data.created_month, sales_data.total_sales]
    sorts: [sales_data.created_month desc]
    limit: 500
EOF

echo "✅ LookML files created successfully"
```

---

## 🔍 Verification Commands

```bash
# Check instance status
gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="table(name,state,lookerUri)"

# List all Looker instances
gcloud looker instances list --region=$REGION

# Get instance configuration
gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="yaml"
```

---

## 🛠️ Advanced CLI Operations

### Update Instance
```bash
# Update instance (if needed)
gcloud looker instances update $INSTANCE_NAME \
    --region=$REGION \
    --enable-public-ip
```

### Restart Instance
```bash
# Restart instance
gcloud looker instances restart $INSTANCE_NAME \
    --region=$REGION
```

### Export Instance Config
```bash
# Export instance configuration
gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="export" > looker-instance-config.yaml
```

---

## 🎯 Complete Setup Script

```bash
#!/bin/bash

# Complete Looker setup script
export INSTANCE_NAME="your-looker-instance"
export REGION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)

echo "🚀 Creating Looker instance..."

# Create instance
gcloud looker instances create $INSTANCE_NAME \
    --region=$REGION \
    --edition=LOOKER_CORE_STANDARD \
    --consumer-network=default \
    --enable-public-ip

# Wait for instance to be ready
echo "⏳ Waiting for instance to be ready..."
while true; do
    STATE=$(gcloud looker instances describe $INSTANCE_NAME \
        --region=$REGION \
        --format="value(state)" 2>/dev/null)
    
    if [ "$STATE" = "ACTIVE" ]; then
        echo "✅ Instance is ready!"
        break
    else
        echo "Current state: $STATE"
        sleep 30
    fi
done

# Get instance URL
LOOKER_URL=$(gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="value(lookerUri)")

echo "🎉 Looker instance created successfully!"
echo "Instance URL: $LOOKER_URL"
echo "Please access the URL to complete the setup in the Looker interface."
```

---

## 🧹 Cleanup Commands

```bash
# Delete Looker instance
gcloud looker instances delete $INSTANCE_NAME \
    --region=$REGION \
    --quiet
```

---

## 📝 Manual Steps Required

**Important**: After creating the instance via CLI, you'll need to:

1. **Access Looker Interface**: Visit the Looker URL
2. **Complete Initial Setup**: Set up admin user
3. **Configure BigQuery Connection**: Add database connection
4. **Upload LookML Files**: Create or import the project files
5. **Create Explores and Dashboards**: Build visualizations

---

## 🔗 API Integration

```bash
# Example API calls (requires authentication setup)
# Get instance via REST API
curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://looker.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/instances/$INSTANCE_NAME"
```

---

**🎉 Congratulations! You've completed the Looker Challenge Lab using CLI commands!**

*Note: Looker configuration primarily requires GUI interaction for LookML development and dashboard creation.*

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [Automation-Solution.md](./Automation-Solution.md) - Infrastructure as Code
