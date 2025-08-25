# Get Started with Looker: Challenge Lab - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Looker](https://img.shields.io/badge/Looker-FF6B6B?style=for-the-badge&logo=google&logoColor=white)
![Automation](https://img.shields.io/badge/Method-Automation-EA4335?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC107 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Script

```bash
#!/bin/bash

# =============================================================================
# Looker Challenge Lab - Complete Automation
# =============================================================================

set -e

# Configuration - Update with your lab values
INSTANCE_NAME="your-looker-instance"
REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project)

echo "🚀 Starting Looker Challenge Lab Automation"
echo "Instance: $INSTANCE_NAME"
echo "Region: $REGION"
echo "Project: $PROJECT_ID"

# Task 1: Create Looker Instance
echo "📋 Task 1: Creating Looker Instance..."

if gcloud looker instances describe $INSTANCE_NAME --region=$REGION &>/dev/null; then
    echo "⚠️ Instance '$INSTANCE_NAME' already exists"
else
    gcloud looker instances create $INSTANCE_NAME \
        --region=$REGION \
        --edition=LOOKER_CORE_STANDARD \
        --consumer-network=default \
        --enable-public-ip
    echo "✅ Instance creation initiated"
fi

# Task 2: Wait for Instance to be Ready
echo "📋 Task 2: Waiting for instance to be ready..."

MAX_WAIT=1200  # 20 minutes
WAIT_TIME=0

while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    STATE=$(gcloud looker instances describe $INSTANCE_NAME \
        --region=$REGION \
        --format="value(state)" 2>/dev/null)
    
    if [ "$STATE" = "ACTIVE" ]; then
        echo "✅ Instance is ready!"
        break
    else
        echo "Current state: $STATE (waiting...)"
        sleep 30
        WAIT_TIME=$((WAIT_TIME + 30))
    fi
done

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    echo "❌ Instance creation timed out"
    exit 1
fi

# Task 3: Get Instance Details
echo "📋 Task 3: Getting instance details..."

LOOKER_URL=$(gcloud looker instances describe $INSTANCE_NAME \
    --region=$REGION \
    --format="value(lookerUri)")

echo "✅ Instance URL: $LOOKER_URL"

# Task 4: Create LookML Project Structure
echo "📋 Task 4: Creating LookML project files..."

mkdir -p looker-automation/{views,models,dashboards}
cd looker-automation

# Create comprehensive view file
cat > views/ecommerce_analysis.view.lkml << 'EOF'
view: ecommerce_analysis {
  sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items` ;;
  
  # Primary Key
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    description: "Unique identifier for order items"
  }
  
  # Foreign Keys
  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    description: "Associated order ID"
  }
  
  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    description: "Customer user ID"
  }
  
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
    description: "Product identifier"
  }
  
  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
    description: "Inventory item identifier"
  }
  
  # Date Dimensions
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
    description: "When the order item was created"
  }
  
  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
    description: "When the order item was shipped"
  }
  
  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
    description: "When the order item was delivered"
  }
  
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
    description: "When the order item was returned"
  }
  
  # Price Dimensions
  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    description: "Sale price of the item"
  }
  
  # Status Dimension
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
    description: "Current status of the order item"
  }
  
  # Calculated Dimensions
  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
    description: "Whether the item was returned"
  }
  
  dimension: days_to_ship {
    type: number
    sql: DATE_DIFF(${shipped_date}, ${created_date}, DAY) ;;
    description: "Days between order and shipment"
  }
  
  dimension: days_to_deliver {
    type: number
    sql: DATE_DIFF(${delivered_date}, ${shipped_date}, DAY) ;;
    description: "Days between shipment and delivery"
  }
  
  # Measures
  measure: count {
    type: count
    drill_fields: [detail*]
    description: "Count of order items"
  }
  
  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    description: "Total sales revenue"
  }
  
  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
    description: "Average sale price"
  }
  
  measure: median_sale_price {
    type: median
    sql: ${sale_price} ;;
    value_format_name: usd
    description: "Median sale price"
  }
  
  measure: return_rate {
    type: number
    sql: ${returned_items} / ${count} ;;
    value_format_name: percent_2
    description: "Return rate percentage"
  }
  
  measure: returned_items {
    type: count
    filters: [is_returned: "yes"]
    description: "Count of returned items"
  }
  
  measure: average_days_to_ship {
    type: average
    sql: ${days_to_ship} ;;
    value_format_name: decimal_1
    description: "Average days to ship"
  }
  
  measure: average_days_to_deliver {
    type: average
    sql: ${days_to_deliver} ;;
    value_format_name: decimal_1
    description: "Average days to deliver"
  }
  
  # Drill Fields
  set: detail {
    fields: [
      id,
      order_id,
      user_id,
      product_id,
      created_time,
      sale_price,
      status
    ]
  }
}
EOF

# Create model file
cat > models/ecommerce_analytics.model.lkml << 'EOF'
connection: "bigquery-connection"

include: "/views/*.view.lkml"

datagroup: ecommerce_analytics_default_datagroup {
  sql_trigger: SELECT MAX(created_at) FROM `bigquery-public-data.thelook_ecommerce.order_items` ;;
  max_cache_age: "1 hour"
}

persist_with: ecommerce_analytics_default_datagroup

explore: ecommerce_analysis {
  from: ecommerce_analysis
  description: "Comprehensive ecommerce order item analysis"
  
  # Add suggested queries
  query: total_sales_overview {
    description: "Total sales and order count overview"
    dimensions: [ecommerce_analysis.created_month]
    measures: [ecommerce_analysis.total_sales, ecommerce_analysis.count]
    sort: [ecommerce_analysis.created_month desc]
    limit: 12
  }
  
  query: return_analysis {
    description: "Analysis of returned items"
    dimensions: [ecommerce_analysis.created_month, ecommerce_analysis.is_returned]
    measures: [ecommerce_analysis.count, ecommerce_analysis.return_rate]
    filters: [ecommerce_analysis.created_date: "2022-01-01 to 2023-12-31"]
  }
  
  query: shipping_performance {
    description: "Shipping and delivery performance metrics"
    dimensions: [ecommerce_analysis.created_month]
    measures: [
      ecommerce_analysis.average_days_to_ship,
      ecommerce_analysis.average_days_to_deliver
    ]
    sort: [ecommerce_analysis.created_month desc]
    limit: 12
  }
}
EOF

# Create dashboard file
cat > dashboards/ecommerce_executive_dashboard.dashboard.lookml << 'EOF'
- dashboard: ecommerce_executive_dashboard
  title: E-commerce Executive Dashboard
  layout: responsive
  tile_size: 100
  description: "Key metrics and insights for e-commerce performance"
  
  refresh: 1 hour
  
  filters:
  - name: date_filter
    title: Date Range
    type: field_filter
    default_value: "30 days"
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
    model: ecommerce_analytics
    explore: ecommerce_analysis
    listens_to_filters: []
    field: ecommerce_analysis.created_date
  
  elements:
  - title: Total Revenue
    name: total_revenue
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: single_value
    fields: [ecommerce_analysis.total_sales]
    limit: 500
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 0
    col: 0
    width: 6
    height: 4
    
  - title: Total Orders
    name: total_orders
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: single_value
    fields: [ecommerce_analysis.count]
    limit: 500
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 0
    col: 6
    width: 6
    height: 4
    
  - title: Average Order Value
    name: average_order_value
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: single_value
    fields: [ecommerce_analysis.average_sale_price]
    limit: 500
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 0
    col: 12
    width: 6
    height: 4
    
  - title: Return Rate
    name: return_rate
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: single_value
    fields: [ecommerce_analysis.return_rate]
    limit: 500
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 0
    col: 18
    width: 6
    height: 4
    
  - title: Sales Trend
    name: sales_trend
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: looker_line
    fields: [ecommerce_analysis.created_month, ecommerce_analysis.total_sales]
    sorts: [ecommerce_analysis.created_month desc]
    limit: 12
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 4
    col: 0
    width: 12
    height: 8
    
  - title: Order Status Distribution
    name: order_status_distribution
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: looker_pie
    fields: [ecommerce_analysis.status, ecommerce_analysis.count]
    sorts: [ecommerce_analysis.count desc]
    limit: 500
    value_labels: legend
    label_type: labPer
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 4
    col: 12
    width: 12
    height: 8
    
  - title: Shipping Performance
    name: shipping_performance
    model: ecommerce_analytics
    explore: ecommerce_analysis
    type: looker_column
    fields: [
      ecommerce_analysis.created_month,
      ecommerce_analysis.average_days_to_ship,
      ecommerce_analysis.average_days_to_deliver
    ]
    sorts: [ecommerce_analysis.created_month desc]
    limit: 12
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    listen:
      Date Range: ecommerce_analysis.created_date
    row: 12
    col: 0
    width: 24
    height: 8
EOF

echo "✅ LookML project files created successfully"

# Task 5: Create deployment summary
echo "📋 Task 5: Creating deployment summary..."

cat > deployment_summary.md << EOF
# Looker Instance Deployment Summary

## Instance Details
- **Instance Name**: $INSTANCE_NAME
- **Region**: $REGION
- **Project ID**: $PROJECT_ID
- **Instance URL**: $LOOKER_URL
- **Status**: ACTIVE

## Next Steps (Manual Configuration Required)

1. **Access Looker Instance**:
   - Visit: $LOOKER_URL
   - Sign in with your Google Cloud credentials

2. **Configure BigQuery Connection**:
   - Go to Admin → Connections
   - Create new connection named "bigquery-connection"
   - Select "Google BigQuery Standard SQL"
   - Configure authentication

3. **Import LookML Project**:
   - Create new LookML project
   - Import the generated files from this directory:
     - views/ecommerce_analysis.view.lkml
     - models/ecommerce_analytics.model.lkml
     - dashboards/ecommerce_executive_dashboard.dashboard.lookml

4. **Deploy and Test**:
   - Commit changes to LookML project
   - Deploy to production
   - Test explores and dashboards

## Generated Files
- ✅ E-commerce analysis view with comprehensive dimensions and measures
- ✅ Analytics model with explores and datagroups
- ✅ Executive dashboard with key performance indicators
- ✅ Automated deployment scripts

## Features Included
- Sales analytics and trends
- Return rate analysis
- Shipping performance metrics
- Order status tracking
- Executive-level KPI dashboard

EOF

echo "🎉 Looker Challenge Lab automation completed!"
echo ""
echo "============================================================"
echo "📊 DEPLOYMENT SUMMARY"
echo "============================================================"
echo "Instance URL: $LOOKER_URL"
echo "LookML files: $(pwd)"
echo "Status: Ready for manual configuration"
echo "============================================================"
echo ""
echo "📝 Next: Access the Looker URL to complete the setup"
```

---

## 🏗️ Terraform Infrastructure as Code

```hcl
# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "instance_name" {
  description = "Looker instance name"
}

variable "region" {
  default = "us-central1"
}

# Create Looker Instance
resource "google_looker_instance" "looker_instance" {
  name               = var.instance_name
  platform_edition   = "LOOKER_CORE_STANDARD"
  region             = var.region
  
  public_ip_enabled = true
  
  admin_settings {
    allowed_email_domains = ["${var.project_id}.iam.gserviceaccount.com"]
  }
  
  maintenance_window {
    day_of_week = "SUNDAY"
    start_time {
      hours   = 2
      minutes = 0
    }
  }
}

# Output
output "looker_uri" {
  value = google_looker_instance.looker_instance.looker_uri
  description = "The URI of the Looker instance"
}

output "instance_id" {
  value = google_looker_instance.looker_instance.name
  description = "The ID of the Looker instance"
}
```

---

## 🐍 Python Automation

```python
#!/usr/bin/env python3
"""
Google Cloud Looker Challenge Lab - Python Automation
"""

from google.cloud import looker_v1
import time

class LookerAutomation:
    def __init__(self, project_id, instance_name, region):
        self.project_id = project_id
        self.instance_name = instance_name
        self.region = region
        self.client = looker_v1.LookerServiceClient()
        
    def create_instance(self):
        """Create Looker instance"""
        parent = f"projects/{self.project_id}/locations/{self.region}"
        
        instance = looker_v1.Instance(
            platform_edition=looker_v1.Instance.PlatformEdition.LOOKER_CORE_STANDARD,
            public_ip_enabled=True
        )
        
        operation = self.client.create_instance(
            parent=parent,
            instance_id=self.instance_name,
            instance=instance
        )
        
        print(f"⏳ Creating Looker instance {self.instance_name}...")
        result = operation.result(timeout=1200)  # 20 minutes timeout
        print(f"✅ Instance created: {result.looker_uri}")
        return result
        
    def run_automation(self):
        """Run complete automation"""
        print("🚀 Starting Looker Python Automation")
        instance = self.create_instance()
        print("🎉 Automation completed!")
        return instance

# Usage
automation = LookerAutomation("your-project-id", "your-instance-name", "us-central1")
automation.run_automation()
```

---

**🎉 Congratulations! You've mastered Looker automation!**

*Note: Looker requires significant manual configuration for LookML development and dashboard creation after instance creation.*

*For other solution methods, check out:*
- [GUI-Solution.md](./GUI-Solution.md) - Graphical User Interface
- [CLI-Solution.md](./CLI-Solution.md) - Command Line Interface
