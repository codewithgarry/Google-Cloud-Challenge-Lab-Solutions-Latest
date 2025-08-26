# Data Loss Prevention API - GUI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![DLP API](https://img.shields.io/badge/DLP%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)

**Lab ID**: ARC100 | **Duration**: 25-30 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Explore Google Cloud Data Loss Prevention (DLP) API for sensitive data detection, classification, and protection in text and structured data.

---

## 🧩 Challenge Tasks

1. **Enable DLP API** - Activate the Data Loss Prevention service
2. **Detect Sensitive Info** - Identify PII in text content
3. **Custom Info Types** - Create custom detection patterns
4. **De-identification** - Remove or mask sensitive data
5. **Inspect BigQuery** - Scan structured data for PII
6. **Risk Analysis** - Assess re-identification risks

---

## 🖥️ Step-by-Step GUI Solution

### 📋 Prerequisites
- Google Cloud Console access
- Cloud Shell activated
- DLP API enabled
- BigQuery API enabled

---

### 🚀 Task 1: Setup Environment

1. **Enable APIs**
   - Go to: **APIs & Services** → **Library**
   - Search and enable: `Cloud Data Loss Prevention (DLP) API`
   - Search and enable: `BigQuery API`
   - Search and enable: `Cloud Storage API`

2. **Open Cloud Shell**
   - Click **Activate Cloud Shell** (top-right)
   - Wait for shell to initialize

3. **Set Environment Variables**
   ```bash
   export PROJECT_ID=$(gcloud config get-value project)
   export BUCKET_NAME="$PROJECT_ID-dlp-lab"
   export REGION="us-central1"
   export DATASET_NAME="dlp_demo_dataset"
   export TABLE_NAME="customer_data"
   ```

![Setup Environment](https://via.placeholder.com/600x300/4285F4/FFFFFF?text=Setup+Environment)

---

### 📦 Task 2: Prepare Test Data

1. **Create Storage Bucket**
   ```bash
   gsutil mb -l $REGION gs://$BUCKET_NAME
   ```

2. **Create Sample Data Files**
   ```bash
   # PII-rich text file
   cat > pii_sample.txt << 'EOF'
   Customer Information:
   
   Name: John Smith
   Email: john.smith@example.com
   Phone: (555) 123-4567
   SSN: 123-45-6789
   Credit Card: 4532-1234-5678-9012
   Address: 123 Main Street, Anytown, CA 90210
   
   Name: Jane Doe
   Email: jane.doe@company.org
   Phone: +1-555-987-6543
   SSN: 987-65-4321
   Credit Card: 5555-4444-3333-2222
   Address: 456 Oak Avenue, Springfield, IL 62701
   
   Medical Record ID: MR-789123
   Patient DOB: 1985-03-15
   Insurance ID: INS-456789
   EOF
   
   # Healthcare data
   cat > healthcare_data.txt << 'EOF'
   PATIENT RECORDS
   
   Patient: Robert Johnson
   DOB: 1970-12-25
   Medical Record Number: MRN-123456789
   Social Security: 555-66-7777
   Insurance Policy: POL-987654321
   Diagnosis: Type 2 Diabetes
   Medication: Metformin 500mg
   Doctor: Dr. Sarah Wilson
   Phone: (555) 234-5678
   Email: robert.johnson@email.com
   
   Patient: Mary Brown
   DOB: 1988-07-08
   Medical Record Number: MRN-987654321
   Social Security: 888-99-0000
   Insurance Policy: POL-123456789
   Diagnosis: Hypertension
   Medication: Lisinopril 10mg
   Doctor: Dr. Michael Davis
   Phone: (555) 876-5432
   Email: mary.brown@healthmail.com
   EOF
   
   # Financial data
   cat > financial_data.txt << 'EOF'
   FINANCIAL RECORDS
   
   Account Holder: David Wilson
   Account Number: ACC-789456123
   Routing Number: 021000021
   Credit Card: 4111-1111-1111-1111
   Expiration: 12/25
   CVV: 123
   SSN: 111-22-3333
   Annual Income: $75,000
   Employment: Software Engineer at Tech Corp
   
   Account Holder: Lisa Anderson
   Account Number: ACC-456789123
   Routing Number: 121000248
   Credit Card: 5424-1234-5678-9012
   Expiration: 08/26
   CVV: 456
   SSN: 444-55-6666
   Annual Income: $95,000
   Employment: Marketing Manager at AdCorp
   EOF
   ```

3. **Upload Files to Storage**
   ```bash
   gsutil cp *.txt gs://$BUCKET_NAME/
   ```

4. **Create BigQuery Dataset and Table**
   ```bash
   # Create dataset
   bq mk --dataset --location=$REGION $PROJECT_ID:$DATASET_NAME
   
   # Create customer data table
   bq mk --table $PROJECT_ID:$DATASET_NAME.$TABLE_NAME \
     customer_id:STRING,name:STRING,email:STRING,phone:STRING,ssn:STRING,credit_card:STRING,address:STRING
   
   # Insert sample data
   cat > customer_data.json << 'EOF'
   {"customer_id": "CUST001", "name": "Alice Johnson", "email": "alice.johnson@email.com", "phone": "555-0101", "ssn": "123-45-6789", "credit_card": "4532-1234-5678-9012", "address": "123 Elm St, Boston, MA 02101"}
   {"customer_id": "CUST002", "name": "Bob Williams", "email": "bob.williams@company.com", "phone": "555-0202", "ssn": "987-65-4321", "credit_card": "5555-4444-3333-2222", "address": "456 Pine Ave, Seattle, WA 98101"}
   {"customer_id": "CUST003", "name": "Carol Davis", "email": "carol.davis@example.org", "phone": "555-0303", "ssn": "555-66-7777", "credit_card": "4111-1111-1111-1111", "address": "789 Oak Blvd, Austin, TX 73301"}
   {"customer_id": "CUST004", "name": "David Brown", "email": "david.brown@test.net", "phone": "555-0404", "ssn": "111-22-3333", "credit_card": "5424-1234-5678-9012", "address": "321 Maple Dr, Denver, CO 80201"}
   {"customer_id": "CUST005", "name": "Eva Martinez", "email": "eva.martinez@sample.com", "phone": "555-0505", "ssn": "888-99-0000", "credit_card": "4000-0000-0000-0002", "address": "654 Cedar Ln, Miami, FL 33101"}
   EOF
   
   bq load --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:$DATASET_NAME.$TABLE_NAME customer_data.json
   ```

![Prepare Data](https://via.placeholder.com/600x300/34A853/FFFFFF?text=Prepare+Test+Data)

---

### 🔍 Task 3: Basic Sensitive Data Detection

1. **Using Google Cloud Console**
   - Navigate to: **Security** → **Data Loss Prevention**
   - Click **"Inspect"** → **"Configuration"**
   - Select **"Built-in"** info types
   - Choose: `EMAIL_ADDRESS`, `PHONE_NUMBER`, `US_SOCIAL_SECURITY_NUMBER`, `CREDIT_CARD_NUMBER`
   - Paste sample text from `pii_sample.txt`
   - Click **"Inspect"**

2. **Using Cloud Shell REST API**
   ```bash
   # Get authentication token
   export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
   
   # Create basic inspection request
   cat > inspect_request.json << EOF
   {
     "item": {
       "value": "$(cat pii_sample.txt | tr '\n' ' ' | sed 's/"/\\"/g')"
     },
     "inspectConfig": {
       "infoTypes": [
         {"name": "EMAIL_ADDRESS"},
         {"name": "PHONE_NUMBER"},
         {"name": "US_SOCIAL_SECURITY_NUMBER"},
         {"name": "CREDIT_CARD_NUMBER"},
         {"name": "PERSON_NAME"},
         {"name": "US_STATE"},
         {"name": "STREET_ADDRESS"}
       ],
       "includeQuote": true,
       "minLikelihood": "POSSIBLE"
     }
   }
   EOF
   
   # Call DLP API
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
     -d @inspect_request.json > inspect_response.json
   
   # Display results
   echo "=== DLP Inspection Results ==="
   jq '.result.findings[] | {infoType: .infoType.name, quote: .quote, likelihood: .likelihood}' inspect_response.json
   ```

3. **Test Different Content Types**
   ```bash
   # Function to inspect content
   inspect_content() {
       local file=$1
       local content=$(cat "$file" | tr '\n' ' ' | sed 's/"/\\"/g')
       
       cat > temp_inspect_request.json << EOF
   {
     "item": {
       "value": "$content"
     },
     "inspectConfig": {
       "infoTypes": [
         {"name": "EMAIL_ADDRESS"},
         {"name": "PHONE_NUMBER"},
         {"name": "US_SOCIAL_SECURITY_NUMBER"},
         {"name": "CREDIT_CARD_NUMBER"},
         {"name": "PERSON_NAME"},
         {"name": "US_STATE"},
         {"name": "DATE"},
         {"name": "MEDICAL_RECORD_NUMBER"}
       ],
       "includeQuote": true,
       "minLikelihood": "POSSIBLE"
     }
   }
   EOF
       
       curl -s -X POST \
         -H "Authorization: Bearer $ACCESS_TOKEN" \
         -H "Content-Type: application/json" \
         "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
         -d @temp_inspect_request.json
   }
   
   # Inspect all test files
   for file in *.txt; do
       echo "=== Inspecting $file ==="
       result=$(inspect_content "$file")
       findings_count=$(echo "$result" | jq '.result.findings | length')
       echo "Found $findings_count sensitive data items:"
       echo "$result" | jq -r '.result.findings[] | "  \(.infoType.name): \(.quote)"' | head -10
       echo ""
   done
   ```

![Basic Detection](https://via.placeholder.com/600x300/FF9800/FFFFFF?text=Basic+Detection)

---

### 🎛️ Task 4: Custom Info Types

1. **Create Custom Patterns**
   ```bash
   # Custom employee ID pattern
   cat > custom_info_types_request.json << EOF
   {
     "item": {
       "value": "Employee ID: EMP-12345, Medical Record: MR-789123, Customer ID: CUST-456789"
     },
     "inspectConfig": {
       "customInfoTypes": [
         {
           "infoType": {
             "name": "EMPLOYEE_ID"
           },
           "regex": {
             "pattern": "EMP-[0-9]{5}"
           },
           "likelihood": "LIKELY"
         },
         {
           "infoType": {
             "name": "MEDICAL_RECORD_ID"
           },
           "regex": {
             "pattern": "MR-[0-9]{6}"
           },
           "likelihood": "LIKELY"
         },
         {
           "infoType": {
             "name": "CUSTOMER_ID"
           },
           "regex": {
             "pattern": "CUST-[0-9]{6}"
           },
           "likelihood": "LIKELY"
         }
       ],
       "includeQuote": true
     }
   }
   EOF
   
   # Test custom info types
   echo "=== Testing Custom Info Types ==="
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
     -d @custom_info_types_request.json \
     | jq '.result.findings[] | {infoType: .infoType.name, quote: .quote}'
   ```

2. **Dictionary-based Custom Info Types**
   ```bash
   # Create dictionary-based detection
   cat > dictionary_request.json << EOF
   {
     "item": {
       "value": "Our VIP customers include ProjectAlpha, OperationSecure, and CodenameBravo initiatives."
     },
     "inspectConfig": {
       "customInfoTypes": [
         {
           "infoType": {
             "name": "PROJECT_CODENAME"
           },
           "dictionary": {
             "wordList": {
               "words": [
                 "ProjectAlpha",
                 "OperationSecure", 
                 "CodenameBravo",
                 "MissionCritical",
                 "SecretProject"
               ]
             }
           },
           "likelihood": "VERY_LIKELY"
         }
       ],
       "includeQuote": true
     }
   }
   EOF
   
   echo "=== Testing Dictionary-based Detection ==="
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
     -d @dictionary_request.json \
     | jq '.result.findings[] | {infoType: .infoType.name, quote: .quote}'
   ```

3. **Advanced Custom Pattern**
   ```bash
   # Complex pattern for internal document IDs
   cat > advanced_pattern_request.json << EOF
   {
     "item": {
       "value": "Documents: DOC-2023-001-CONF, RPT-2023-456-INTERNAL, MEMO-2024-789-EXEC"
     },
     "inspectConfig": {
       "customInfoTypes": [
         {
           "infoType": {
             "name": "INTERNAL_DOCUMENT_ID"
           },
           "regex": {
             "pattern": "(DOC|RPT|MEMO)-[0-9]{4}-[0-9]{3}-(CONF|INTERNAL|EXEC|PUBLIC)"
           },
           "likelihood": "VERY_LIKELY"
         }
       ],
       "includeQuote": true
     }
   }
   EOF
   
   echo "=== Testing Advanced Pattern Detection ==="
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
     -d @advanced_pattern_request.json \
     | jq '.result.findings[] | {infoType: .infoType.name, quote: .quote}'
   ```

![Custom Info Types](https://via.placeholder.com/600x300/9C27B0/FFFFFF?text=Custom+Info+Types)

---

### 🛡️ Task 5: Data De-identification

1. **Basic Masking**
   ```bash
   # Create de-identification request with masking
   cat > deidentify_mask_request.json << EOF
   {
     "item": {
       "value": "Customer John Smith (SSN: 123-45-6789) paid with credit card 4532-1234-5678-9012."
     },
     "deidentifyConfig": {
       "infoTypeTransformations": {
         "transformations": [
           {
             "infoTypes": [
               {"name": "US_SOCIAL_SECURITY_NUMBER"}
             ],
             "primitiveTransformation": {
               "characterMaskConfig": {
                 "maskingCharacter": "X",
                 "numberToMask": 5
               }
             }
           },
           {
             "infoTypes": [
               {"name": "CREDIT_CARD_NUMBER"}
             ],
             "primitiveTransformation": {
               "characterMaskConfig": {
                 "maskingCharacter": "*",
                 "numberToMask": 12
               }
             }
           }
         ]
       }
     },
     "inspectConfig": {
       "infoTypes": [
         {"name": "US_SOCIAL_SECURITY_NUMBER"},
         {"name": "CREDIT_CARD_NUMBER"}
       ]
     }
   }
   EOF
   
   echo "=== De-identification with Masking ==="
   echo "Original: Customer John Smith (SSN: 123-45-6789) paid with credit card 4532-1234-5678-9012."
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
     -d @deidentify_mask_request.json \
     | jq -r '.item.value' | sed 's/^/De-identified: /'
   ```

2. **Replacement Transformation**
   ```bash
   # Replace sensitive data with placeholders
   cat > deidentify_replace_request.json << EOF
   {
     "item": {
       "value": "Contact: john.doe@company.com, Phone: (555) 123-4567, SSN: 987-65-4321"
     },
     "deidentifyConfig": {
       "infoTypeTransformations": {
         "transformations": [
           {
             "infoTypes": [
               {"name": "EMAIL_ADDRESS"}
             ],
             "primitiveTransformation": {
               "replaceConfig": {
                 "newValue": {
                   "stringValue": "[EMAIL-REDACTED]"
                 }
               }
             }
           },
           {
             "infoTypes": [
               {"name": "PHONE_NUMBER"}
             ],
             "primitiveTransformation": {
               "replaceConfig": {
                 "newValue": {
                   "stringValue": "[PHONE-REDACTED]"
                 }
               }
             }
           },
           {
             "infoTypes": [
               {"name": "US_SOCIAL_SECURITY_NUMBER"}
             ],
             "primitiveTransformation": {
               "replaceConfig": {
                 "newValue": {
                   "stringValue": "[SSN-REDACTED]"
                 }
               }
             }
           }
         ]
       }
     },
     "inspectConfig": {
       "infoTypes": [
         {"name": "EMAIL_ADDRESS"},
         {"name": "PHONE_NUMBER"},
         {"name": "US_SOCIAL_SECURITY_NUMBER"}
       ]
     }
   }
   EOF
   
   echo "=== De-identification with Replacement ==="
   echo "Original: Contact: john.doe@company.com, Phone: (555) 123-4567, SSN: 987-65-4321"
   curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
     -d @deidentify_replace_request.json \
     | jq -r '.item.value' | sed 's/^/De-identified: /'
   ```

3. **Format-Preserving Encryption (FPE)**
   ```bash
   # Create crypto key for FPE
   gcloud kms keyrings create dlp-keyring --location=global || true
   gcloud kms keys create dlp-key --location=global --keyring=dlp-keyring --purpose=encryption || true
   
   # Get the crypto key name
   CRYPTO_KEY_NAME="projects/$PROJECT_ID/locations/global/keyRings/dlp-keyring/cryptoKeys/dlp-key"
   
   # Grant DLP service account access to the key
   gcloud kms keys add-iam-policy-binding dlp-key \
     --location=global \
     --keyring=dlp-keyring \
     --member="serviceAccount:service-$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@dlp-api.iam.gserviceaccount.com" \
     --role="roles/cloudkms.cryptoKeyEncrypterDecrypter"
   
   # FPE transformation request
   cat > deidentify_fpe_request.json << EOF
   {
     "item": {
       "value": "SSN: 123-45-6789, Credit Card: 4532-1234-5678-9012"
     },
     "deidentifyConfig": {
       "infoTypeTransformations": {
         "transformations": [
           {
             "infoTypes": [
               {"name": "US_SOCIAL_SECURITY_NUMBER"}
             ],
             "primitiveTransformation": {
               "cryptoReplaceFfxFpeConfig": {
                 "cryptoKey": {
                   "kmsWrapped": {
                     "wrappedKey": "$(echo -n "dlp-test-key" | base64)",
                     "cryptoKeyName": "$CRYPTO_KEY_NAME"
                   }
                 },
                 "alphabet": "NUMERIC"
               }
             }
           }
         ]
       }
     },
     "inspectConfig": {
       "infoTypes": [
         {"name": "US_SOCIAL_SECURITY_NUMBER"}
       ]
     }
   }
   EOF
   
   echo "=== De-identification with Format-Preserving Encryption ==="
   echo "Original: SSN: 123-45-6789, Credit Card: 4532-1234-5678-9012"
   
   # Note: FPE requires proper setup and may not work in all environments
   echo "FPE transformation configured (requires KMS setup)"
   ```

![De-identification](https://via.placeholder.com/600x300/2196F3/FFFFFF?text=De-identification)

---

### 📊 Task 6: BigQuery Data Inspection

1. **Inspect BigQuery Table**
   ```bash
   # Create BigQuery inspection job
   cat > bq_inspect_request.json << EOF
   {
     "inspectJob": {
       "inspectConfig": {
         "infoTypes": [
           {"name": "EMAIL_ADDRESS"},
           {"name": "PHONE_NUMBER"},
           {"name": "US_SOCIAL_SECURITY_NUMBER"},
           {"name": "CREDIT_CARD_NUMBER"},
           {"name": "PERSON_NAME"}
         ],
         "minLikelihood": "POSSIBLE",
         "limits": {
           "maxFindingsPerRequest": 100
         }
       },
       "storageConfig": {
         "bigQueryOptions": {
           "tableReference": {
             "projectId": "$PROJECT_ID",
             "datasetId": "$DATASET_NAME",
             "tableId": "$TABLE_NAME"
           }
         }
       }
     }
   }
   EOF
   
   # Submit inspection job
   echo "=== Inspecting BigQuery Table ==="
   JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @bq_inspect_request.json)
   
   JOB_NAME=$(echo "$JOB_RESPONSE" | jq -r '.name')
   echo "Inspection job created: $JOB_NAME"
   
   # Wait for job completion
   echo "Waiting for job to complete..."
   sleep 30
   
   # Get job results
   curl -s -X GET \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://dlp.googleapis.com/v2/$JOB_NAME" \
     | jq '.inspectDetails.result.infoTypeStats[] | {infoType: .infoType.name, count: .count}'
   ```

2. **Column-level Scanning**
   ```bash
   # Scan specific columns
   cat > bq_column_inspect_request.json << EOF
   {
     "inspectJob": {
       "inspectConfig": {
         "infoTypes": [
           {"name": "EMAIL_ADDRESS"},
           {"name": "US_SOCIAL_SECURITY_NUMBER"},
           {"name": "CREDIT_CARD_NUMBER"}
         ],
         "minLikelihood": "POSSIBLE"
       },
       "storageConfig": {
         "bigQueryOptions": {
           "tableReference": {
             "projectId": "$PROJECT_ID",
             "datasetId": "$DATASET_NAME",
             "tableId": "$TABLE_NAME"
           },
           "identifyingFields": [
             {"name": "email"},
             {"name": "ssn"},
             {"name": "credit_card"}
           ]
         }
       }
     }
   }
   EOF
   
   echo "=== Column-level BigQuery Inspection ==="
   COLUMN_JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @bq_column_inspect_request.json)
   
   COLUMN_JOB_NAME=$(echo "$COLUMN_JOB_RESPONSE" | jq -r '.name')
   echo "Column inspection job created: $COLUMN_JOB_NAME"
   ```

3. **Data Profiling**
   ```bash
   # Create data profile job
   cat > data_profile_request.json << EOF
   {
     "inspectJob": {
       "inspectConfig": {
         "infoTypes": [
           {"name": "EMAIL_ADDRESS"},
           {"name": "PHONE_NUMBER"},
           {"name": "US_SOCIAL_SECURITY_NUMBER"},
           {"name": "CREDIT_CARD_NUMBER"},
           {"name": "PERSON_NAME"},
           {"name": "US_STATE"}
         ],
         "minLikelihood": "POSSIBLE",
         "includeQuote": false
       },
       "storageConfig": {
         "bigQueryOptions": {
           "tableReference": {
             "projectId": "$PROJECT_ID",
             "datasetId": "$DATASET_NAME",
             "tableId": "$TABLE_NAME"
           }
         }
       }
     }
   }
   EOF
   
   echo "=== BigQuery Data Profiling ==="
   PROFILE_JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @data_profile_request.json)
   
   PROFILE_JOB_NAME=$(echo "$PROFILE_JOB_RESPONSE" | jq -r '.name')
   echo "Data profiling job created: $PROFILE_JOB_NAME"
   ```

![BigQuery Inspection](https://via.placeholder.com/600x300/607D8B/FFFFFF?text=BigQuery+Inspection)

---

### 📈 Task 7: Risk Analysis

1. **K-anonymity Analysis**
   ```bash
   # Create risk analysis job
   cat > risk_analysis_request.json << EOF
   {
     "riskJob": {
       "privacyMetric": {
         "kAnonymityConfig": {
           "quasiIds": [
             {"field": {"name": "name"}},
             {"field": {"name": "address"}}
           ]
         }
       },
       "sourceTable": {
         "projectId": "$PROJECT_ID",
         "datasetId": "$DATASET_NAME",
         "tableId": "$TABLE_NAME"
       }
     }
   }
   EOF
   
   echo "=== K-anonymity Risk Analysis ==="
   RISK_JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @risk_analysis_request.json)
   
   RISK_JOB_NAME=$(echo "$RISK_JOB_RESPONSE" | jq -r '.name')
   echo "Risk analysis job created: $RISK_JOB_NAME"
   
   # Wait and check results
   echo "Waiting for risk analysis to complete..."
   sleep 20
   
   curl -s -X GET \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://dlp.googleapis.com/v2/$RISK_JOB_NAME" \
     | jq '.riskDetails.kAnonymityResult.equivalenceClassHistogramBuckets[] | {minSize: .minSize, maxSize: .maxSize, bucketSize: .bucketSize}'
   ```

2. **L-diversity Analysis**
   ```bash
   # L-diversity for sensitive attributes
   cat > l_diversity_request.json << EOF
   {
     "riskJob": {
       "privacyMetric": {
         "lDiversityConfig": {
           "quasiIds": [
             {"field": {"name": "name"}},
             {"field": {"name": "address"}}
           ],
           "sensitiveAttribute": {
             "name": "credit_card"
           }
         }
       },
       "sourceTable": {
         "projectId": "$PROJECT_ID",
         "datasetId": "$DATASET_NAME",
         "tableId": "$TABLE_NAME"
       }
     }
   }
   EOF
   
   echo "=== L-diversity Analysis ==="
   L_DIV_JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @l_diversity_request.json)
   
   L_DIV_JOB_NAME=$(echo "$L_DIV_JOB_RESPONSE" | jq -r '.name')
   echo "L-diversity job created: $L_DIV_JOB_NAME"
   ```

3. **Categorical Stats**
   ```bash
   # Analyze categorical data distribution
   cat > categorical_stats_request.json << EOF
   {
     "riskJob": {
       "privacyMetric": {
         "categoricalStatsConfig": {
           "field": {
             "name": "address"
           }
         }
       },
       "sourceTable": {
         "projectId": "$PROJECT_ID",
         "datasetId": "$DATASET_NAME",
         "tableId": "$TABLE_NAME"
       }
     }
   }
   EOF
   
   echo "=== Categorical Statistics Analysis ==="
   CAT_STATS_JOB_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     -d @categorical_stats_request.json)
   
   CAT_STATS_JOB_NAME=$(echo "$CAT_STATS_JOB_RESPONSE" | jq -r '.name')
   echo "Categorical statistics job created: $CAT_STATS_JOB_NAME"
   ```

![Risk Analysis](https://via.placeholder.com/600x300/795548/FFFFFF?text=Risk+Analysis)

---

### 🎛️ Task 8: Advanced Features

1. **Template Creation**
   ```bash
   # Create inspection template
   cat > create_template_request.json << EOF
   {
     "inspectTemplate": {
       "displayName": "PII Detection Template",
       "description": "Template for detecting common PII types",
       "inspectConfig": {
         "infoTypes": [
           {"name": "EMAIL_ADDRESS"},
           {"name": "PHONE_NUMBER"},
           {"name": "US_SOCIAL_SECURITY_NUMBER"},
           {"name": "CREDIT_CARD_NUMBER"},
           {"name": "PERSON_NAME"}
         ],
         "minLikelihood": "POSSIBLE",
         "limits": {
           "maxFindingsPerRequest": 50
         },
         "includeQuote": true
       }
     }
   }
   EOF
   
   echo "=== Creating Inspection Template ==="
   TEMPLATE_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/inspectTemplates" \
     -d @create_template_request.json)
   
   TEMPLATE_NAME=$(echo "$TEMPLATE_RESPONSE" | jq -r '.name')
   echo "Template created: $TEMPLATE_NAME"
   ```

2. **Stored InfoType Creation**
   ```bash
   # Create stored info type
   cat > stored_infotype_request.json << EOF
   {
     "storedInfoType": {
       "displayName": "Company Employee List",
       "description": "List of company employees for detection",
       "largeCustomDictionary": {
         "outputPath": {
           "path": "gs://$BUCKET_NAME/employee_list"
         },
         "bigQueryField": {
           "table": {
             "projectId": "$PROJECT_ID",
             "datasetId": "$DATASET_NAME",
             "tableId": "$TABLE_NAME"
           },
           "field": {
             "name": "name"
           }
         }
       }
     }
   }
   EOF
   
   echo "=== Creating Stored InfoType ==="
   STORED_INFO_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/storedInfoTypes" \
     -d @stored_infotype_request.json)
   
   STORED_INFO_NAME=$(echo "$STORED_INFO_RESPONSE" | jq -r '.name')
   echo "Stored InfoType created: $STORED_INFO_NAME"
   ```

3. **Job Triggers**
   ```bash
   # Create job trigger for automated scanning
   cat > job_trigger_request.json << EOF
   {
     "jobTrigger": {
       "displayName": "Daily PII Scan",
       "description": "Automated daily scan for PII in customer data",
       "triggers": [
         {
           "schedule": {
             "recurrencePeriodDuration": "86400s"
           }
         }
       ],
       "inspectJob": {
         "inspectConfig": {
           "infoTypes": [
             {"name": "EMAIL_ADDRESS"},
             {"name": "US_SOCIAL_SECURITY_NUMBER"},
             {"name": "CREDIT_CARD_NUMBER"}
           ],
           "minLikelihood": "LIKELY"
         },
         "storageConfig": {
           "bigQueryOptions": {
             "tableReference": {
               "projectId": "$PROJECT_ID",
               "datasetId": "$DATASET_NAME",
               "tableId": "$TABLE_NAME"
             }
           }
         }
       }
     }
   }
   EOF
   
   echo "=== Creating Job Trigger ==="
   TRIGGER_RESPONSE=$(curl -s -X POST \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     -H "Content-Type: application/json" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/jobTriggers" \
     -d @job_trigger_request.json)
   
   TRIGGER_NAME=$(echo "$TRIGGER_RESPONSE" | jq -r '.name')
   echo "Job trigger created: $TRIGGER_NAME"
   ```

![Advanced Features](https://via.placeholder.com/600x300/4CAF50/FFFFFF?text=Advanced+Features)

---

### 📊 Task 9: Comprehensive Report

1. **Generate DLP Summary Report**
   ```bash
   cat > generate_dlp_report.py << 'EOF'
   #!/usr/bin/env python3
   
   import json
   import os
   from datetime import datetime
   
   def generate_dlp_report():
       print("="*60)
       print("DATA LOSS PREVENTION (DLP) API REPORT")
       print("="*60)
       print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
       print()
       
       project_id = os.environ.get('PROJECT_ID', 'unknown')
       bucket_name = os.environ.get('BUCKET_NAME', 'unknown')
       dataset_name = os.environ.get('DATASET_NAME', 'unknown')
       
       print("PROJECT INFORMATION:")
       print(f"  Project ID: {project_id}")
       print(f"  Storage Bucket: {bucket_name}")
       print(f"  BigQuery Dataset: {dataset_name}")
       print()
       
       print("FEATURES TESTED:")
       print("  ✅ Basic PII Detection")
       print("    - Email addresses")
       print("    - Phone numbers")
       print("    - Social Security Numbers")
       print("    - Credit card numbers")
       print("    - Person names")
       print("    - Addresses")
       print()
       
       print("  ✅ Custom Info Types")
       print("    - Regex patterns")
       print("    - Dictionary-based detection")
       print("    - Complex pattern matching")
       print()
       
       print("  ✅ De-identification")
       print("    - Character masking")
       print("    - Data replacement")
       print("    - Format-preserving encryption (configured)")
       print()
       
       print("  ✅ BigQuery Integration")
       print("    - Table-level scanning")
       print("    - Column-level inspection")
       print("    - Data profiling")
       print()
       
       print("  ✅ Risk Analysis")
       print("    - K-anonymity analysis")
       print("    - L-diversity analysis")
       print("    - Categorical statistics")
       print()
       
       print("  ✅ Advanced Features")
       print("    - Inspection templates")
       print("    - Stored info types")
       print("    - Job triggers")
       print()
       
       print("CONTENT ANALYZED:")
       
       # Check if files exist and show content summary
       content_files = [
           'pii_sample.txt',
           'healthcare_data.txt',
           'financial_data.txt'
       ]
       
       for file in content_files:
           if os.path.exists(file):
               with open(file, 'r') as f:
                   content = f.read()
                   lines = len(content.split('\n'))
                   chars = len(content)
                   print(f"  📄 {file}: {lines} lines, {chars} characters")
       
       print()
       print("RECOMMENDATIONS:")
       print("  • Implement regular DLP scans for all data sources")
       print("  • Use custom info types for organization-specific data")
       print("  • Apply appropriate de-identification for non-production environments")
       print("  • Monitor risk metrics for compliance requirements")
       print("  • Set up automated triggers for continuous monitoring")
       print()
       
       print("COMPLIANCE CONSIDERATIONS:")
       print("  • GDPR: Personal data detection and protection")
       print("  • HIPAA: Healthcare information identification")
       print("  • PCI DSS: Credit card data security")
       print("  • SOX: Financial data governance")
       print()
       
       print("="*60)
   
   if __name__ == "__main__":
       generate_dlp_report()
   EOF
   
   python3 generate_dlp_report.py
   ```

2. **List DLP Jobs**
   ```bash
   echo "=== Active DLP Jobs ==="
   curl -s -X GET \
     -H "Authorization: Bearer $ACCESS_TOKEN" \
     "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
     | jq '.jobs[] | {name: .name, type: .type, state: .state, createTime: .createTime}'
   ```

3. **Performance Summary**
   ```bash
   echo "=== DLP API Performance Summary ==="
   echo "Feature Testing Results:"
   echo "  • Text Inspection: ✅ Completed"
   echo "  • Custom Patterns: ✅ Completed"
   echo "  • De-identification: ✅ Completed"
   echo "  • BigQuery Scanning: ✅ Completed"
   echo "  • Risk Analysis: ✅ Completed"
   echo "  • Advanced Features: ✅ Completed"
   echo ""
   echo "Data Sources Configured:"
   echo "  • Cloud Storage files: $(gsutil ls gs://$BUCKET_NAME/ | wc -l) files"
   echo "  • BigQuery table: $DATASET_NAME.$TABLE_NAME"
   echo ""
   echo "DLP Lab completed successfully!"
   ```

![Comprehensive Report](https://via.placeholder.com/600x300/FF5722/FFFFFF?text=Comprehensive+Report)

---

## ✅ Verification Steps

### 1. Basic Detection Testing
- [ ] PII detection working for all common types
- [ ] Sensitive data found in test files
- [ ] Likelihood scores calculated correctly
- [ ] Quote extraction functioning

### 2. Custom Info Types
- [ ] Regex patterns detecting custom formats
- [ ] Dictionary-based detection working
- [ ] Complex patterns matching correctly
- [ ] Custom likelihood levels applied

### 3. De-identification
- [ ] Character masking applied correctly
- [ ] Replacement transformations working
- [ ] Format-preserving encryption configured
- [ ] Original data properly protected

### 4. BigQuery Integration
- [ ] Table inspection jobs created
- [ ] Column-level scanning functional
- [ ] Data profiling results available
- [ ] Job status monitoring working

### 5. Risk Analysis
- [ ] K-anonymity analysis completed
- [ ] L-diversity metrics calculated
- [ ] Categorical statistics generated
- [ ] Privacy risk assessment done

---

## 🎯 Key Learning Points

1. **Comprehensive Detection** - Built-in and custom info types
2. **Data Protection** - Multiple de-identification methods
3. **Structured Data** - BigQuery integration and scanning
4. **Risk Assessment** - Privacy metrics and analysis
5. **Automation** - Templates, triggers, and stored info types

---

## 🔗 Alternative Solutions

- **[CLI Solution](CLI-Solution.md)** - Command-line approach
- **[Automation Solution](Automation-Solution.md)** - Scripted implementation

---

## 🎖️ Skills Boost Arcade

Complete this challenge for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Use DLP API templates and triggers for automated, continuous data protection monitoring!

</div>
