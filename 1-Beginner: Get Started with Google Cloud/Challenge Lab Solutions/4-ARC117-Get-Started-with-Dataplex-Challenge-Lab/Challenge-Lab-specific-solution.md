# ARC117: Get Started with Dataplex: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Dataplex](https://img.shields.io/badge/Dataplex-FF6B6B?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC117 | **Duration**: 1 hour | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll use Google Cloud Dataplex to create a data lake, organize data assets, and perform data discovery and management tasks.

## 📋 Challenge Tasks

### Task 1: Create a Dataplex Lake

**Requirements:**
- **Lake Name**: `customer-data-lake`
- **Region**: `us-central1`
- **Description**: Lake for customer analytics data

### Task 2: Create Raw Data Zone

Create a zone for raw, unprocessed data.

### Task 3: Create Curated Data Zone

Create a zone for processed, curated data.

### Task 4: Add Assets to Zones

Attach Cloud Storage buckets as assets to your zones.

### Task 5: Run Data Discovery

Use Dataplex to discover and profile your data assets.

---

## 🚀 Quick Solution Steps

### Step 1: Enable Required APIs

```bash
# Enable Dataplex API
gcloud services enable dataplex.googleapis.com

# Enable Data Catalog API
gcloud services enable datacatalog.googleapis.com

# Enable Cloud Storage API
gcloud services enable storage.googleapis.com
```

### Step 2: Create Storage Buckets

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1

# Create buckets for raw and curated data
gsutil mb -l $REGION gs://$PROJECT_ID-raw-data
gsutil mb -l $REGION gs://$PROJECT_ID-curated-data

# Upload sample data files
echo "customer_id,name,email,age
1,John Doe,john@example.com,30
2,Jane Smith,jane@example.com,25
3,Bob Johnson,bob@example.com,35" > customers.csv

gsutil cp customers.csv gs://$PROJECT_ID-raw-data/

echo "product_id,product_name,category,price
1,Laptop,Electronics,999.99
2,Phone,Electronics,699.99
3,Book,Education,29.99" > products.csv

gsutil cp products.csv gs://$PROJECT_ID-curated-data/
```

### Step 3: Create Dataplex Lake

```bash
# Create the lake
gcloud dataplex lakes create customer-data-lake \
    --location=$REGION \
    --description="Lake for customer analytics data"
```

### Step 4: Create Raw Data Zone

```bash
# Create raw zone
gcloud dataplex zones create raw-zone \
    --location=$REGION \
    --lake=customer-data-lake \
    --type=RAW \
    --description="Zone for raw, unprocessed data" \
    --resource-location-type=SINGLE_REGION
```

### Step 5: Create Curated Data Zone

```bash
# Create curated zone  
gcloud dataplex zones create curated-zone \
    --location=$REGION \
    --lake=customer-data-lake \
    --type=CURATED \
    --description="Zone for processed, curated data" \
    --resource-location-type=SINGLE_REGION
```

### Step 6: Add Storage Assets

```bash
# Add raw data bucket as asset
gcloud dataplex assets create raw-customer-data \
    --location=$REGION \
    --lake=customer-data-lake \
    --zone=raw-zone \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID-raw-data \
    --description="Raw customer data storage"

# Add curated data bucket as asset
gcloud dataplex assets create curated-customer-data \
    --location=$REGION \
    --lake=customer-data-lake \
    --zone=curated-zone \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$PROJECT_ID/buckets/$PROJECT_ID-curated-data \
    --description="Curated customer data storage"
```

### Step 7: Create Data Discovery Job

```bash
# Create data scan for discovery
gcloud dataplex data-scans create discovery-scan \
    --location=$REGION \
    --data-source-resource=projects/$PROJECT_ID/locations/$REGION/lakes/customer-data-lake/zones/raw-zone/assets/raw-customer-data \
    --description="Discovery scan for raw customer data"
```

---

## 🎯 Alternative GUI Solution

1. **Create Dataplex Lake**:
   - Go to Dataplex in the Google Cloud Console
   - Click "Create Lake"
   - Name: `customer-data-lake`
   - Region: `us-central1`
   - Description: "Lake for customer analytics data"

2. **Create Raw Zone**:
   - In your lake, click "Add Zone"
   - Name: `raw-zone`
   - Type: Raw
   - Description: "Zone for raw, unprocessed data"

3. **Create Curated Zone**:
   - Click "Add Zone" again
   - Name: `curated-zone`
   - Type: Curated
   - Description: "Zone for processed, curated data"

4. **Add Assets**:
   - In each zone, click "Add Asset"
   - Select "Cloud Storage bucket"
   - Choose your respective buckets

5. **Run Discovery**:
   - Go to Data Discovery
   - Create new discovery scan
   - Select your raw data asset

---

## 📊 Sample Data Setup

Create sample datasets to work with:

```bash
# Create sample customer data
cat > customer_data.csv << 'EOF'
customer_id,first_name,last_name,email,phone,registration_date
1,John,Doe,john.doe@email.com,555-0101,2023-01-15
2,Jane,Smith,jane.smith@email.com,555-0102,2023-02-20
3,Bob,Johnson,bob.johnson@email.com,555-0103,2023-03-10
4,Alice,Williams,alice.williams@email.com,555-0104,2023-04-05
5,Charlie,Brown,charlie.brown@email.com,555-0105,2023-05-12
EOF

# Create sample transaction data
cat > transactions.csv << 'EOF'
transaction_id,customer_id,product_id,quantity,price,transaction_date
1001,1,101,2,29.99,2023-06-01
1002,2,102,1,199.99,2023-06-02
1003,3,103,3,15.50,2023-06-03
1004,1,104,1,89.99,2023-06-04
1005,4,101,1,29.99,2023-06-05
EOF

# Upload to raw data bucket
gsutil cp customer_data.csv gs://$PROJECT_ID-raw-data/customers/
gsutil cp transactions.csv gs://$PROJECT_ID-raw-data/transactions/
```

---

## 🔍 Data Discovery and Quality

### Running Data Quality Checks

```bash
# Create data quality scan
gcloud dataplex data-scans create quality-scan \
    --location=$REGION \
    --data-source-resource=projects/$PROJECT_ID/locations/$REGION/lakes/customer-data-lake/zones/raw-zone/assets/raw-customer-data \
    --description="Quality scan for customer data" \
    --data-quality-spec-rules='{
      "rules": [
        {
          "column": "email",
          "non_null_expectation": {}
        },
        {
          "column": "customer_id",
          "uniqueness_expectation": {}
        }
      ]
    }'
```

### Scheduling Scans

```bash
# Schedule discovery scan to run daily
gcloud dataplex data-scans update discovery-scan \
    --location=$REGION \
    --schedule='0 2 * * *' \
    --time-zone='UTC'
```

---

## ✅ Validation

1. **Lake Created**: Verify lake exists in Dataplex console
2. **Zones Created**: Check both raw and curated zones are present
3. **Assets Added**: Confirm storage buckets are attached as assets
4. **Data Discovery**: Verify discovery jobs have run successfully
5. **Data Profile**: Check that data profiling results are available

---

## 🔧 Troubleshooting

**Issue**: Lake creation fails
- Check Dataplex API is enabled
- Verify IAM permissions for Dataplex service
- Ensure region is supported

**Issue**: Assets not appearing
- Check bucket permissions
- Verify bucket exists and has data
- Ensure correct resource naming format

**Issue**: Discovery scan fails
- Check data format compatibility
- Verify asset configuration
- Review scan logs for specific errors

---

## 📚 Key Learning Points

- **Data Lake Architecture**: Understanding zones and assets
- **Data Organization**: Separating raw and curated data
- **Data Discovery**: Automated profiling and cataloging
- **Data Quality**: Implementing quality checks and monitoring
- **Governance**: Managing data assets at scale

---

## 🏆 Challenge Complete!

You've successfully demonstrated Dataplex fundamentals by:
- ✅ Creating a data lake with organized zones
- ✅ Adding storage assets to zones
- ✅ Setting up data discovery and profiling
- ✅ Implementing data quality monitoring

<div align="center">

**🎉 Congratulations! You've completed ARC117!**

[![Next Challenge](https://img.shields.io/badge/Next-ARC107%20Looker-blue?style=for-the-badge)](../5-ARC107-Get-Started-with-Looker-Challenge-Lab/)

</div>
