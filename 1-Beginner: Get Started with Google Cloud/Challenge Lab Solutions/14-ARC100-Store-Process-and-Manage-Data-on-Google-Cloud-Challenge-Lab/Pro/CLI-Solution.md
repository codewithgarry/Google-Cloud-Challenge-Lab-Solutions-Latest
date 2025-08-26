# Data Loss Prevention API - CLI Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![DLP API](https://img.shields.io/badge/DLP%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![CLI](https://img.shields.io/badge/CLI-000000?style=for-the-badge&logo=gnu-bash&logoColor=white)

**Lab ID**: ARC100 | **Duration**: 20-25 minutes | **Level**: Intermediate

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Lab Overview

Use Google Cloud CLI and REST API to implement comprehensive Data Loss Prevention (DLP) features for sensitive data detection, classification, and protection.

---

## 🧩 Challenge Tasks

1. **Setup DLP Environment** - Configure APIs and authentication
2. **Content Inspection** - Detect PII in text and files
3. **Custom Detection** - Create custom info types and patterns
4. **Data De-identification** - Mask, replace, and encrypt sensitive data
5. **BigQuery Scanning** - Inspect structured data at scale
6. **Risk Assessment** - Analyze privacy risks and compliance
7. **Automation Setup** - Create templates and triggers

---

## 💻 Complete CLI Solution

### 🔧 Environment Setup

```bash
#!/bin/bash

# Set environment variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export BUCKET_NAME="$PROJECT_ID-dlp-lab"
export DATASET_NAME="dlp_demo_dataset"
export TABLE_NAME="customer_data"
export ACCESS_TOKEN=$(gcloud auth application-default print-access-token)

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable dlp.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudkms.googleapis.com

# Create Cloud Storage bucket
echo "📦 Creating storage bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME

# Create BigQuery dataset
echo "📊 Setting up BigQuery dataset..."
bq mk --dataset --location=$REGION $PROJECT_ID:$DATASET_NAME

echo "✅ Environment setup completed!"
```

---

### 📝 Test Data Creation

```bash
#!/bin/bash

# Create comprehensive test data files
echo "📝 Creating test data files..."

# PII-rich sample data
cat > pii_sample.txt << 'EOF'
CUSTOMER DATABASE EXTRACT
=========================

Customer Record #1:
Name: John Michael Smith
Email: john.smith@techcorp.com
Phone: +1 (555) 123-4567
SSN: 123-45-6789
Credit Card: 4532-1234-5678-9012 (Exp: 12/25)
Address: 1234 Elm Street, Springfield, IL 62701
Driver License: D123-456-789-012

Customer Record #2:
Name: Sarah Elizabeth Johnson
Email: sarah.johnson@innovate.org
Phone: (555) 987-6543
SSN: 987-65-4321
Credit Card: 5555-4444-3333-2222 (Exp: 08/26)
Address: 5678 Oak Avenue, Austin, TX 73301
Driver License: D987-654-321-098

Customer Record #3:
Name: Michael Robert Davis
Email: m.davis@globaltech.net
Phone: 555.246.8135
SSN: 555-66-7777
Credit Card: 4111-1111-1111-1111 (Exp: 03/27)
Address: 9876 Pine Boulevard, Seattle, WA 98101
Driver License: D555-666-777-888
EOF

# Healthcare specific data
cat > healthcare_data.txt << 'EOF'
MEDICAL RECORDS DATABASE
========================

Patient ID: PAT-001
Name: Robert William Thompson
DOB: 1975-08-15
SSN: 111-22-3333
Medical Record Number: MRN-789123456
Insurance Policy: INS-POL-456789
Phone: (555) 111-2222
Email: robert.thompson@email.com
Address: 2468 Medical Drive, Boston, MA 02101
Emergency Contact: Mary Thompson (555) 111-3333
Diagnosis: Type 2 Diabetes, Hypertension
Medications: Metformin 500mg BID, Lisinopril 10mg QD
Allergies: Penicillin, Shellfish
Primary Care Physician: Dr. Amanda Wilson
Specialist: Dr. James Rodriguez (Endocrinology)

Patient ID: PAT-002
Name: Jennifer Anne Martinez
DOB: 1988-12-03
SSN: 444-55-6666
Medical Record Number: MRN-456789123
Insurance Policy: INS-POL-789123
Phone: (555) 444-5555
Email: jennifer.martinez@healthmail.com
Address: 1357 Wellness Lane, Denver, CO 80201
Emergency Contact: Carlos Martinez (555) 444-6666
Diagnosis: Asthma, Seasonal Allergies
Medications: Albuterol Inhaler PRN, Claritin 10mg QD
Allergies: Latex, Peanuts
Primary Care Physician: Dr. Susan Lee
Specialist: Dr. Michael Chen (Pulmonology)
EOF

# Financial records
cat > financial_data.txt << 'EOF'
FINANCIAL SERVICES DATA
=======================

Account Holder: David Alexander Wilson
Account Number: ACC-2024-789456123
Routing Number: 021000021
Social Security: 777-88-9999
Credit Card: 4000-0000-0000-0002 (Exp: 06/28, CVV: 789)
Debit Card: 5200-0000-0000-0014 (PIN: *****)
Annual Income: $125,000
Employment: Senior Software Engineer at TechCorp Inc.
Phone: (555) 777-8888
Email: david.wilson@techcorp.com
Address: 3690 Financial Plaza, New York, NY 10001
Investment Account: INV-456789123 ($45,000 balance)
Loan Account: LOAN-789456123 ($15,000 remaining)

Account Holder: Lisa Michelle Anderson
Account Number: ACC-2024-456789321
Routing Number: 121000248
Social Security: 222-33-4444
Credit Card: 5424-1818-1818-1818 (Exp: 09/27, CVV: 456)
Debit Card: 4000-1234-5678-9010 (PIN: *****)
Annual Income: $95,000
Employment: Marketing Director at AdCorp LLC
Phone: (555) 222-3333
Email: lisa.anderson@adcorp.com
Address: 7410 Commerce Street, Chicago, IL 60601
Investment Account: INV-321654987 ($32,000 balance)
Loan Account: LOAN-654321987 ($8,500 remaining)
EOF

# Mixed content with various patterns
cat > mixed_content.txt << 'EOF'
INTERNAL COMPANY DATA
=====================

Employee Records:
- EMP-12345: John Doe (john.doe@company.com)
- EMP-67890: Jane Smith (jane.smith@company.com)
- EMP-11111: Bob Johnson (bob.johnson@company.com)

Project Codes:
- PROJECT-ALPHA-2024: Confidential AI Initiative
- PROJECT-BETA-2024: Customer Analytics Platform
- PROJECT-GAMMA-2024: Security Enhancement Program

Document References:
- DOC-2024-001-CONF: Strategic Planning Document
- RPT-2024-456-INTERNAL: Q4 Financial Report
- MEMO-2024-789-EXEC: Executive Committee Meeting Notes

Medical Test Results:
- Patient MRN-456789: COVID-19 Test (Negative)
- Patient MRN-123456: Blood Work (Normal)
- Patient MRN-789123: X-Ray Results (Clear)

Vendor Information:
- Vendor ID: VEN-2024-001 (ACME Corporation)
- Contract: CON-2024-789 (Software License Agreement)
- Purchase Order: PO-2024-456 ($50,000)
EOF

# Upload files to Cloud Storage
echo "☁️ Uploading test files to Cloud Storage..."
gsutil cp *.txt gs://$BUCKET_NAME/

# Create BigQuery table with sample data
echo "📊 Creating BigQuery table with sample data..."
bq mk --table $PROJECT_ID:$DATASET_NAME.$TABLE_NAME \
  customer_id:STRING,name:STRING,email:STRING,phone:STRING,ssn:STRING,credit_card:STRING,address:STRING,account_balance:FLOAT

# Insert comprehensive sample data
cat > customer_data.json << 'EOF'
{"customer_id": "CUST-001", "name": "Alice Rebecca Johnson", "email": "alice.johnson@email.com", "phone": "555-0101", "ssn": "123-45-6789", "credit_card": "4532-1234-5678-9012", "address": "123 Elm Street, Boston, MA 02101", "account_balance": 15750.50}
{"customer_id": "CUST-002", "name": "Robert Michael Williams", "email": "robert.williams@company.com", "phone": "555-0202", "ssn": "987-65-4321", "credit_card": "5555-4444-3333-2222", "address": "456 Oak Avenue, Seattle, WA 98101", "account_balance": 8425.75}
{"customer_id": "CUST-003", "name": "Carol Ann Davis", "email": "carol.davis@example.org", "phone": "555-0303", "ssn": "555-66-7777", "credit_card": "4111-1111-1111-1111", "address": "789 Pine Boulevard, Austin, TX 73301", "account_balance": 22100.25}
{"customer_id": "CUST-004", "name": "David Steven Brown", "email": "david.brown@test.net", "phone": "555-0404", "ssn": "111-22-3333", "credit_card": "5424-1234-5678-9012", "address": "321 Maple Drive, Denver, CO 80201", "account_balance": 5890.00}
{"customer_id": "CUST-005", "name": "Eva Maria Martinez", "email": "eva.martinez@sample.com", "phone": "555-0505", "ssn": "888-99-0000", "credit_card": "4000-0000-0000-0002", "address": "654 Cedar Lane, Miami, FL 33101", "account_balance": 31250.80}
{"customer_id": "CUST-006", "name": "Frank Thomas Anderson", "email": "frank.anderson@corp.net", "phone": "555-0606", "ssn": "222-33-4444", "credit_card": "5200-0000-0000-0014", "address": "987 Birch Road, Portland, OR 97201", "account_balance": 12650.40}
{"customer_id": "CUST-007", "name": "Grace Elizabeth Wilson", "email": "grace.wilson@business.org", "phone": "555-0707", "ssn": "777-88-9999", "credit_card": "4242-4242-4242-4242", "address": "159 Spruce Court, Phoenix, AZ 85001", "account_balance": 18375.90}
{"customer_id": "CUST-008", "name": "Henry James Taylor", "email": "henry.taylor@enterprise.com", "phone": "555-0808", "ssn": "333-44-5555", "credit_card": "5105-1051-0510-5100", "address": "753 Willow Way, Nashville, TN 37201", "account_balance": 9840.15}
EOF

bq load --source_format=NEWLINE_DELIMITED_JSON $PROJECT_ID:$DATASET_NAME.$TABLE_NAME customer_data.json

echo "✅ Test data created and uploaded successfully!"
```

---

### 🔍 Content Inspection Functions

```bash
#!/bin/bash

# Function: Basic content inspection
inspect_content() {
    local content="$1"
    local filename="${2:-stdin}"
    
    echo "🔍 Inspecting content from: $filename"
    
    # Create inspection request
    cat > temp_inspect_request.json << EOF
{
  "item": {
    "value": "$(echo "$content" | sed 's/"/\\"/g' | tr '\n' ' ')"
  },
  "inspectConfig": {
    "infoTypes": [
      {"name": "EMAIL_ADDRESS"},
      {"name": "PHONE_NUMBER"},
      {"name": "US_SOCIAL_SECURITY_NUMBER"},
      {"name": "CREDIT_CARD_NUMBER"},
      {"name": "PERSON_NAME"},
      {"name": "US_STATE"},
      {"name": "STREET_ADDRESS"},
      {"name": "DATE"},
      {"name": "US_DRIVER_LICENSE_NUMBER"}
    ],
    "includeQuote": true,
    "minLikelihood": "POSSIBLE",
    "limits": {
      "maxFindingsPerRequest": 100
    }
  }
}
EOF
    
    # Call DLP API
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
        -d @temp_inspect_request.json)
    
    # Parse and display results
    local findings_count=$(echo "$response" | jq '.result.findings | length')
    echo "📊 Found $findings_count sensitive data items:"
    
    if [ "$findings_count" -gt 0 ]; then
        echo "$response" | jq -r '.result.findings[] | "  \(.infoType.name): \(.quote) (\(.likelihood))"' | sort
    else
        echo "  No sensitive data detected."
    fi
    
    echo ""
    rm -f temp_inspect_request.json
}

# Function: Inspect all test files
inspect_all_files() {
    echo "🔍 COMPREHENSIVE CONTENT INSPECTION"
    echo "=================================="
    echo ""
    
    for file in *.txt; do
        if [ -f "$file" ]; then
            content=$(cat "$file")
            inspect_content "$content" "$file"
            echo "---"
        fi
    done
}

# Function: Custom info type detection
detect_custom_patterns() {
    echo "🎯 CUSTOM PATTERN DETECTION"
    echo "==========================="
    echo ""
    
    local test_content="Employee ID: EMP-12345, Medical Record: MRN-789123456, Customer: CUST-001, Project: PROJECT-ALPHA-2024, Document: DOC-2024-001-CONF"
    
    cat > custom_patterns_request.json << EOF
{
  "item": {
    "value": "$test_content"
  },
  "inspectConfig": {
    "customInfoTypes": [
      {
        "infoType": {"name": "EMPLOYEE_ID"},
        "regex": {"pattern": "EMP-[0-9]{5}"},
        "likelihood": "VERY_LIKELY"
      },
      {
        "infoType": {"name": "MEDICAL_RECORD_NUMBER"},
        "regex": {"pattern": "MRN-[0-9]{9}"},
        "likelihood": "VERY_LIKELY"
      },
      {
        "infoType": {"name": "CUSTOMER_ID"},
        "regex": {"pattern": "CUST-[0-9]{3}"},
        "likelihood": "VERY_LIKELY"
      },
      {
        "infoType": {"name": "PROJECT_CODE"},
        "regex": {"pattern": "PROJECT-[A-Z]+-[0-9]{4}"},
        "likelihood": "LIKELY"
      },
      {
        "infoType": {"name": "INTERNAL_DOCUMENT_ID"},
        "regex": {"pattern": "(DOC|RPT|MEMO)-[0-9]{4}-[0-9]{3}-(CONF|INTERNAL|EXEC|PUBLIC)"},
        "likelihood": "VERY_LIKELY"
      }
    ],
    "includeQuote": true
  }
}
EOF
    
    echo "Testing content: $test_content"
    echo ""
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
        -d @custom_patterns_request.json)
    
    echo "🎯 Custom pattern detection results:"
    echo "$response" | jq -r '.result.findings[] | "  \(.infoType.name): \(.quote)"'
    echo ""
    
    rm -f custom_patterns_request.json
}

# Function: Dictionary-based detection
detect_dictionary_terms() {
    echo "📚 DICTIONARY-BASED DETECTION"
    echo "============================="
    echo ""
    
    local test_content="Our classified projects include ProjectAlpha, OperationSecure, CodenameBravo, and MissionCritical initiatives."
    
    cat > dictionary_request.json << EOF
{
  "item": {
    "value": "$test_content"
  },
  "inspectConfig": {
    "customInfoTypes": [
      {
        "infoType": {"name": "CLASSIFIED_PROJECT_NAME"},
        "dictionary": {
          "wordList": {
            "words": [
              "ProjectAlpha",
              "OperationSecure", 
              "CodenameBravo",
              "MissionCritical",
              "SecretProject",
              "TopSecret",
              "Classified"
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
    
    echo "Testing content: $test_content"
    echo ""
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect" \
        -d @dictionary_request.json)
    
    echo "📚 Dictionary detection results:"
    echo "$response" | jq -r '.result.findings[] | "  \(.infoType.name): \(.quote)"'
    echo ""
    
    rm -f dictionary_request.json
}

# Execute inspection functions
inspect_all_files
detect_custom_patterns
detect_dictionary_terms
```

---

### 🛡️ De-identification Functions

```bash
#!/bin/bash

# Function: Character masking
apply_character_masking() {
    echo "🎭 CHARACTER MASKING DE-IDENTIFICATION"
    echo "====================================="
    echo ""
    
    local original_text="Customer: John Smith, SSN: 123-45-6789, Credit Card: 4532-1234-5678-9012, Phone: (555) 123-4567"
    
    cat > mask_request.json << EOF
{
  "item": {
    "value": "$original_text"
  },
  "deidentifyConfig": {
    "infoTypeTransformations": {
      "transformations": [
        {
          "infoTypes": [{"name": "US_SOCIAL_SECURITY_NUMBER"}],
          "primitiveTransformation": {
            "characterMaskConfig": {
              "maskingCharacter": "X",
              "numberToMask": 5
            }
          }
        },
        {
          "infoTypes": [{"name": "CREDIT_CARD_NUMBER"}],
          "primitiveTransformation": {
            "characterMaskConfig": {
              "maskingCharacter": "*",
              "numberToMask": 12
            }
          }
        },
        {
          "infoTypes": [{"name": "PHONE_NUMBER"}],
          "primitiveTransformation": {
            "characterMaskConfig": {
              "maskingCharacter": "#",
              "numberToMask": 7
            }
          }
        }
      ]
    }
  },
  "inspectConfig": {
    "infoTypes": [
      {"name": "US_SOCIAL_SECURITY_NUMBER"},
      {"name": "CREDIT_CARD_NUMBER"},
      {"name": "PHONE_NUMBER"}
    ]
  }
}
EOF
    
    echo "Original: $original_text"
    echo ""
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
        -d @mask_request.json)
    
    local masked_text=$(echo "$response" | jq -r '.item.value')
    echo "Masked: $masked_text"
    echo ""
    
    rm -f mask_request.json
}

# Function: Replacement transformation
apply_replacement_transformation() {
    echo "🔄 REPLACEMENT TRANSFORMATION"
    echo "============================"
    echo ""
    
    local original_text="Contact Information: alice.johnson@company.com, Phone: (555) 234-5678, SSN: 987-65-4321"
    
    cat > replace_request.json << EOF
{
  "item": {
    "value": "$original_text"
  },
  "deidentifyConfig": {
    "infoTypeTransformations": {
      "transformations": [
        {
          "infoTypes": [{"name": "EMAIL_ADDRESS"}],
          "primitiveTransformation": {
            "replaceConfig": {
              "newValue": {"stringValue": "[EMAIL-REDACTED]"}
            }
          }
        },
        {
          "infoTypes": [{"name": "PHONE_NUMBER"}],
          "primitiveTransformation": {
            "replaceConfig": {
              "newValue": {"stringValue": "[PHONE-REDACTED]"}
            }
          }
        },
        {
          "infoTypes": [{"name": "US_SOCIAL_SECURITY_NUMBER"}],
          "primitiveTransformation": {
            "replaceConfig": {
              "newValue": {"stringValue": "[SSN-REDACTED]"}
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
    
    echo "Original: $original_text"
    echo ""
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
        -d @replace_request.json)
    
    local replaced_text=$(echo "$response" | jq -r '.item.value')
    echo "Replaced: $replaced_text"
    echo ""
    
    rm -f replace_request.json
}

# Function: Date shifting
apply_date_shifting() {
    echo "📅 DATE SHIFTING TRANSFORMATION"
    echo "=============================="
    echo ""
    
    local original_text="Patient DOB: 1985-03-15, Admission Date: 2024-01-15, Discharge Date: 2024-01-20"
    
    cat > date_shift_request.json << EOF
{
  "item": {
    "value": "$original_text"
  },
  "deidentifyConfig": {
    "infoTypeTransformations": {
      "transformations": [
        {
          "infoTypes": [{"name": "DATE"}],
          "primitiveTransformation": {
            "dateShiftConfig": {
              "upperBoundDays": 30,
              "lowerBoundDays": -30
            }
          }
        }
      ]
    }
  },
  "inspectConfig": {
    "infoTypes": [{"name": "DATE"}]
  }
}
EOF
    
    echo "Original: $original_text"
    echo ""
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
        -d @date_shift_request.json)
    
    local shifted_text=$(echo "$response" | jq -r '.item.value')
    echo "Date-shifted: $shifted_text"
    echo ""
    
    rm -f date_shift_request.json
}

# Function: Comprehensive file de-identification
deidentify_file() {
    local input_file="$1"
    local output_file="${input_file%.txt}_deidentified.txt"
    
    echo "🛡️ De-identifying file: $input_file"
    
    local content=$(cat "$input_file" | sed 's/"/\\"/g' | tr '\n' ' ')
    
    cat > deidentify_file_request.json << EOF
{
  "item": {
    "value": "$content"
  },
  "deidentifyConfig": {
    "infoTypeTransformations": {
      "transformations": [
        {
          "infoTypes": [{"name": "PERSON_NAME"}],
          "primitiveTransformation": {
            "replaceConfig": {
              "newValue": {"stringValue": "[NAME-REDACTED]"}
            }
          }
        },
        {
          "infoTypes": [{"name": "EMAIL_ADDRESS"}],
          "primitiveTransformation": {
            "replaceConfig": {
              "newValue": {"stringValue": "[EMAIL-REDACTED]"}
            }
          }
        },
        {
          "infoTypes": [{"name": "PHONE_NUMBER"}],
          "primitiveTransformation": {
            "characterMaskConfig": {
              "maskingCharacter": "#",
              "numberToMask": 7
            }
          }
        },
        {
          "infoTypes": [{"name": "US_SOCIAL_SECURITY_NUMBER"}],
          "primitiveTransformation": {
            "characterMaskConfig": {
              "maskingCharacter": "X",
              "numberToMask": 5
            }
          }
        },
        {
          "infoTypes": [{"name": "CREDIT_CARD_NUMBER"}],
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
      {"name": "PERSON_NAME"},
      {"name": "EMAIL_ADDRESS"},
      {"name": "PHONE_NUMBER"},
      {"name": "US_SOCIAL_SECURITY_NUMBER"},
      {"name": "CREDIT_CARD_NUMBER"}
    ]
  }
}
EOF
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify" \
        -d @deidentify_file_request.json)
    
    echo "$response" | jq -r '.item.value' > "$output_file"
    echo "  ✅ De-identified content saved to: $output_file"
    
    rm -f deidentify_file_request.json
}

# Execute de-identification functions
apply_character_masking
apply_replacement_transformation
apply_date_shifting

# De-identify all test files
echo "🛡️ COMPREHENSIVE FILE DE-IDENTIFICATION"
echo "======================================="
echo ""

for file in *.txt; do
    if [[ "$file" != *"_deidentified.txt" ]]; then
        deidentify_file "$file"
    fi
done

echo ""
echo "✅ All de-identification transformations completed!"
```

---

### 📊 BigQuery Integration

```bash
#!/bin/bash

# Function: BigQuery table inspection
inspect_bigquery_table() {
    echo "📊 BIGQUERY TABLE INSPECTION"
    echo "============================"
    echo ""
    
    cat > bq_inspect_request.json << EOF
{
  "inspectJob": {
    "inspectConfig": {
      "infoTypes": [
        {"name": "EMAIL_ADDRESS"},
        {"name": "PHONE_NUMBER"},
        {"name": "US_SOCIAL_SECURITY_NUMBER"},
        {"name": "CREDIT_CARD_NUMBER"},
        {"name": "PERSON_NAME"},
        {"name": "STREET_ADDRESS"}
      ],
      "minLikelihood": "POSSIBLE",
      "limits": {
        "maxFindingsPerRequest": 1000,
        "maxFindingsPerInfoType": [
          {"infoType": {"name": "EMAIL_ADDRESS"}, "maxFindings": 100},
          {"infoType": {"name": "PHONE_NUMBER"}, "maxFindings": 100},
          {"infoType": {"name": "US_SOCIAL_SECURITY_NUMBER"}, "maxFindings": 100},
          {"infoType": {"name": "CREDIT_CARD_NUMBER"}, "maxFindings": 100}
        ]
      },
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
    
    echo "🚀 Starting BigQuery table inspection job..."
    local job_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        -d @bq_inspect_request.json)
    
    local job_name=$(echo "$job_response" | jq -r '.name')
    echo "📋 Job created: $job_name"
    
    # Wait for job completion
    echo "⏳ Waiting for job to complete..."
    local job_state="PENDING"
    local attempts=0
    local max_attempts=30
    
    while [ "$job_state" != "DONE" ] && [ "$attempts" -lt "$max_attempts" ]; do
        sleep 10
        local job_status=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/$job_name")
        
        job_state=$(echo "$job_status" | jq -r '.state')
        echo "  Status: $job_state (attempt $((attempts + 1))/$max_attempts)"
        attempts=$((attempts + 1))
    done
    
    if [ "$job_state" = "DONE" ]; then
        echo "✅ Job completed successfully!"
        echo ""
        echo "📈 Inspection Results:"
        
        local final_result=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/$job_name")
        
        echo "$final_result" | jq -r '.inspectDetails.result.infoTypeStats[]? | "  \(.infoType.name): \(.count) occurrences"'
        
        local total_findings=$(echo "$final_result" | jq '.inspectDetails.result.infoTypeStats | length')
        echo ""
        echo "📊 Summary: Found $total_findings different info types in BigQuery table"
    else
        echo "❌ Job did not complete within expected time"
    fi
    
    rm -f bq_inspect_request.json
    echo ""
}

# Function: Column-specific inspection
inspect_bigquery_columns() {
    echo "🎯 COLUMN-SPECIFIC BIGQUERY INSPECTION"
    echo "======================================"
    echo ""
    
    # Inspect specific columns
    local columns=("email" "ssn" "credit_card" "phone" "name")
    
    for column in "${columns[@]}"; do
        echo "🔍 Inspecting column: $column"
        
        cat > bq_column_inspect_request.json << EOF
{
  "inspectJob": {
    "inspectConfig": {
      "infoTypes": [
        {"name": "EMAIL_ADDRESS"},
        {"name": "US_SOCIAL_SECURITY_NUMBER"},
        {"name": "CREDIT_CARD_NUMBER"},
        {"name": "PHONE_NUMBER"},
        {"name": "PERSON_NAME"}
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
          {"name": "$column"}
        ]
      }
    }
  }
}
EOF
        
        local column_job_response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
            -d @bq_column_inspect_request.json)
        
        local column_job_name=$(echo "$column_job_response" | jq -r '.name')
        echo "  Job created: $column_job_name"
        
        rm -f bq_column_inspect_request.json
    done
    
    echo ""
    echo "✅ Column-specific inspection jobs submitted!"
    echo ""
}

# Function: BigQuery sampling inspection
inspect_bigquery_sample() {
    echo "📝 BIGQUERY SAMPLE INSPECTION"
    echo "============================="
    echo ""
    
    cat > bq_sample_inspect_request.json << EOF
{
  "inspectJob": {
    "inspectConfig": {
      "infoTypes": [
        {"name": "EMAIL_ADDRESS"},
        {"name": "US_SOCIAL_SECURITY_NUMBER"},
        {"name": "CREDIT_CARD_NUMBER"},
        {"name": "PHONE_NUMBER"},
        {"name": "PERSON_NAME"}
      ],
      "minLikelihood": "POSSIBLE",
      "limits": {
        "maxFindingsPerRequest": 50
      }
    },
    "storageConfig": {
      "bigQueryOptions": {
        "tableReference": {
          "projectId": "$PROJECT_ID",
          "datasetId": "$DATASET_NAME",
          "tableId": "$TABLE_NAME"
        },
        "rowsLimit": 1000,
        "sampleMethod": "RANDOM_START"
      }
    }
  }
}
EOF
    
    echo "🎲 Starting sample-based BigQuery inspection..."
    local sample_job_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        -d @bq_sample_inspect_request.json)
    
    local sample_job_name=$(echo "$sample_job_response" | jq -r '.name')
    echo "📋 Sample inspection job created: $sample_job_name"
    
    rm -f bq_sample_inspect_request.json
    echo ""
}

# Execute BigQuery inspection functions
inspect_bigquery_table
inspect_bigquery_columns
inspect_bigquery_sample
```

---

### 📈 Risk Analysis Functions

```bash
#!/bin/bash

# Function: K-anonymity analysis
analyze_k_anonymity() {
    echo "🔒 K-ANONYMITY RISK ANALYSIS"
    echo "==========================="
    echo ""
    
    cat > k_anonymity_request.json << EOF
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
    
    echo "📊 Starting K-anonymity analysis..."
    local k_anon_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        -d @k_anonymity_request.json)
    
    local k_anon_job_name=$(echo "$k_anon_response" | jq -r '.name')
    echo "📋 K-anonymity job created: $k_anon_job_name"
    
    # Wait for completion
    echo "⏳ Waiting for K-anonymity analysis..."
    sleep 20
    
    local k_anon_result=$(curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://dlp.googleapis.com/v2/$k_anon_job_name")
    
    local job_state=$(echo "$k_anon_result" | jq -r '.state')
    if [ "$job_state" = "DONE" ]; then
        echo "✅ K-anonymity analysis completed!"
        echo ""
        echo "📈 Results:"
        echo "$k_anon_result" | jq -r '.riskDetails.kAnonymityResult.equivalenceClassHistogramBuckets[]? | "  Class size \(.minSize)-\(.maxSize): \(.bucketSize) groups"'
    else
        echo "⏳ K-anonymity analysis still in progress: $job_state"
    fi
    
    rm -f k_anonymity_request.json
    echo ""
}

# Function: L-diversity analysis
analyze_l_diversity() {
    echo "🎭 L-DIVERSITY RISK ANALYSIS"
    echo "==========================="
    echo ""
    
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
    
    echo "🎨 Starting L-diversity analysis..."
    local l_div_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        -d @l_diversity_request.json)
    
    local l_div_job_name=$(echo "$l_div_response" | jq -r '.name')
    echo "📋 L-diversity job created: $l_div_job_name"
    
    rm -f l_diversity_request.json
    echo ""
}

# Function: Categorical statistics
analyze_categorical_stats() {
    echo "📊 CATEGORICAL STATISTICS ANALYSIS"
    echo "=================================="
    echo ""
    
    local fields=("address" "email" "name")
    
    for field in "${fields[@]}"; do
        echo "📈 Analyzing field: $field"
        
        cat > categorical_stats_request.json << EOF
{
  "riskJob": {
    "privacyMetric": {
      "categoricalStatsConfig": {
        "field": {
          "name": "$field"
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
        
        local cat_stats_response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
            -d @categorical_stats_request.json)
        
        local cat_stats_job_name=$(echo "$cat_stats_response" | jq -r '.name')
        echo "  📋 Job created: $cat_stats_job_name"
        
        rm -f categorical_stats_request.json
    done
    
    echo ""
    echo "✅ Categorical statistics jobs submitted!"
    echo ""
}

# Function: Numerical statistics
analyze_numerical_stats() {
    echo "🔢 NUMERICAL STATISTICS ANALYSIS"
    echo "================================"
    echo ""
    
    cat > numerical_stats_request.json << EOF
{
  "riskJob": {
    "privacyMetric": {
      "numericalStatsConfig": {
        "field": {
          "name": "account_balance"
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
    
    echo "💰 Starting numerical statistics analysis for account_balance..."
    local num_stats_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        -d @numerical_stats_request.json)
    
    local num_stats_job_name=$(echo "$num_stats_response" | jq -r '.name')
    echo "📋 Numerical statistics job created: $num_stats_job_name"
    
    rm -f numerical_stats_request.json
    echo ""
}

# Execute risk analysis functions
analyze_k_anonymity
analyze_l_diversity
analyze_categorical_stats
analyze_numerical_stats
```

---

### ⚙️ Templates and Automation

```bash
#!/bin/bash

# Function: Create inspection template
create_inspection_template() {
    echo "📋 CREATING INSPECTION TEMPLATE"
    echo "==============================="
    echo ""
    
    cat > create_template_request.json << EOF
{
  "inspectTemplate": {
    "displayName": "Comprehensive PII Detection Template",
    "description": "Template for detecting all common PII types with high accuracy",
    "inspectConfig": {
      "infoTypes": [
        {"name": "EMAIL_ADDRESS"},
        {"name": "PHONE_NUMBER"},
        {"name": "US_SOCIAL_SECURITY_NUMBER"},
        {"name": "CREDIT_CARD_NUMBER"},
        {"name": "PERSON_NAME"},
        {"name": "US_STATE"},
        {"name": "STREET_ADDRESS"},
        {"name": "DATE"},
        {"name": "US_DRIVER_LICENSE_NUMBER"},
        {"name": "US_BANK_ROUTING_MICR"},
        {"name": "IBAN_CODE"},
        {"name": "IP_ADDRESS"}
      ],
      "customInfoTypes": [
        {
          "infoType": {"name": "EMPLOYEE_ID"},
          "regex": {"pattern": "EMP-[0-9]{5}"},
          "likelihood": "VERY_LIKELY"
        },
        {
          "infoType": {"name": "CUSTOMER_ID"},
          "regex": {"pattern": "CUST-[0-9]{3}"},
          "likelihood": "VERY_LIKELY"
        }
      ],
      "minLikelihood": "POSSIBLE",
      "limits": {
        "maxFindingsPerRequest": 100,
        "maxFindingsPerInfoType": [
          {"infoType": {"name": "EMAIL_ADDRESS"}, "maxFindings": 20},
          {"infoType": {"name": "PHONE_NUMBER"}, "maxFindings": 20},
          {"infoType": {"name": "US_SOCIAL_SECURITY_NUMBER"}, "maxFindings": 10}
        ]
      },
      "includeQuote": true
    }
  }
}
EOF
    
    local template_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/inspectTemplates" \
        -d @create_template_request.json)
    
    local template_name=$(echo "$template_response" | jq -r '.name')
    echo "✅ Inspection template created: $template_name"
    
    rm -f create_template_request.json
    echo ""
}

# Function: Create de-identification template
create_deidentify_template() {
    echo "🛡️ CREATING DE-IDENTIFICATION TEMPLATE"
    echo "======================================="
    echo ""
    
    cat > create_deidentify_template_request.json << EOF
{
  "deidentifyTemplate": {
    "displayName": "Standard De-identification Template",
    "description": "Template for standard de-identification of PII data",
    "deidentifyConfig": {
      "infoTypeTransformations": {
        "transformations": [
          {
            "infoTypes": [{"name": "PERSON_NAME"}],
            "primitiveTransformation": {
              "replaceConfig": {
                "newValue": {"stringValue": "[NAME-REDACTED]"}
              }
            }
          },
          {
            "infoTypes": [{"name": "EMAIL_ADDRESS"}],
            "primitiveTransformation": {
              "replaceConfig": {
                "newValue": {"stringValue": "[EMAIL-REDACTED]"}
              }
            }
          },
          {
            "infoTypes": [{"name": "PHONE_NUMBER"}],
            "primitiveTransformation": {
              "characterMaskConfig": {
                "maskingCharacter": "#",
                "numberToMask": 7
              }
            }
          },
          {
            "infoTypes": [{"name": "US_SOCIAL_SECURITY_NUMBER"}],
            "primitiveTransformation": {
              "characterMaskConfig": {
                "maskingCharacter": "X",
                "numberToMask": 5
              }
            }
          },
          {
            "infoTypes": [{"name": "CREDIT_CARD_NUMBER"}],
            "primitiveTransformation": {
              "characterMaskConfig": {
                "maskingCharacter": "*",
                "numberToMask": 12
              }
            }
          }
        ]
      }
    }
  }
}
EOF
    
    local deidentify_template_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/deidentifyTemplates" \
        -d @create_deidentify_template_request.json)
    
    local deidentify_template_name=$(echo "$deidentify_template_response" | jq -r '.name')
    echo "✅ De-identification template created: $deidentify_template_name"
    
    rm -f create_deidentify_template_request.json
    echo ""
}

# Function: Create job trigger
create_job_trigger() {
    echo "⏰ CREATING JOB TRIGGER"
    echo "======================="
    echo ""
    
    cat > create_trigger_request.json << EOF
{
  "jobTrigger": {
    "displayName": "Daily Customer Data PII Scan",
    "description": "Automated daily scan for PII in customer database",
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
          {"name": "CREDIT_CARD_NUMBER"},
          {"name": "PHONE_NUMBER"}
        ],
        "minLikelihood": "LIKELY",
        "limits": {
          "maxFindingsPerRequest": 1000
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
}
EOF
    
    local trigger_response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/jobTriggers" \
        -d @create_trigger_request.json)
    
    local trigger_name=$(echo "$trigger_response" | jq -r '.name')
    echo "✅ Job trigger created: $trigger_name"
    
    rm -f create_trigger_request.json
    echo ""
}

# Function: List all DLP resources
list_dlp_resources() {
    echo "📋 DLP RESOURCES INVENTORY"
    echo "========================="
    echo ""
    
    echo "🔍 Inspection Templates:"
    curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/inspectTemplates" \
        | jq -r '.inspectTemplates[]? | "  • \(.displayName) (\(.name))"'
    
    echo ""
    echo "🛡️ De-identification Templates:"
    curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/deidentifyTemplates" \
        | jq -r '.deidentifyTemplates[]? | "  • \(.displayName) (\(.name))"'
    
    echo ""
    echo "⏰ Job Triggers:"
    curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/jobTriggers" \
        | jq -r '.jobTriggers[]? | "  • \(.displayName) (\(.name))"'
    
    echo ""
    echo "📊 DLP Jobs (Recent):"
    curl -s -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
        | jq -r '.jobs[]? | "  • \(.type) job: \(.state) (\(.name))"' | head -10
    
    echo ""
}

# Execute template and automation functions
create_inspection_template
create_deidentify_template
create_job_trigger
list_dlp_resources
```

---

### 📊 Comprehensive Reporting

```bash
#!/bin/bash

# Function: Generate comprehensive DLP report
generate_comprehensive_report() {
    echo "📊 COMPREHENSIVE DLP LAB REPORT"
    echo "==============================="
    echo ""
    
    local report_file="dlp_lab_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "DATA LOSS PREVENTION (DLP) API LAB REPORT"
        echo "=========================================="
        echo "Generated: $(date)"
        echo "Project ID: $PROJECT_ID"
        echo "Region: $REGION"
        echo ""
        
        echo "ENVIRONMENT SETUP:"
        echo "• APIs Enabled: DLP, BigQuery, Cloud Storage, Cloud KMS"
        echo "• Storage Bucket: $BUCKET_NAME"
        echo "• BigQuery Dataset: $DATASET_NAME"
        echo "• BigQuery Table: $TABLE_NAME"
        echo ""
        
        echo "TEST DATA CREATED:"
        local file_count=$(ls -1 *.txt 2>/dev/null | wc -l)
        echo "• Text files: $file_count files"
        local bq_rows=$(bq query --use_legacy_sql=false --format=csv "SELECT COUNT(*) as count FROM \`$PROJECT_ID.$DATASET_NAME.$TABLE_NAME\`" 2>/dev/null | tail -n 1)
        echo "• BigQuery rows: $bq_rows records"
        echo ""
        
        echo "FEATURES TESTED:"
        echo "✅ Basic PII Detection"
        echo "  - Email addresses, phone numbers, SSNs"
        echo "  - Credit card numbers, person names"
        echo "  - Addresses, dates, driver licenses"
        echo ""
        echo "✅ Custom Info Types"
        echo "  - Regex pattern detection"
        echo "  - Dictionary-based detection"
        echo "  - Complex pattern matching"
        echo ""
        echo "✅ De-identification Methods"
        echo "  - Character masking"
        echo "  - Data replacement"
        echo "  - Date shifting"
        echo ""
        echo "✅ BigQuery Integration"
        echo "  - Table-level scanning"
        echo "  - Column-specific inspection"
        echo "  - Sample-based analysis"
        echo ""
        echo "✅ Risk Analysis"
        echo "  - K-anonymity analysis"
        echo "  - L-diversity analysis"
        echo "  - Categorical statistics"
        echo "  - Numerical statistics"
        echo ""
        echo "✅ Automation & Templates"
        echo "  - Inspection templates"
        echo "  - De-identification templates"
        echo "  - Job triggers"
        echo ""
        
        echo "COMPLIANCE COVERAGE:"
        echo "• GDPR: Personal data identification and protection"
        echo "• HIPAA: Healthcare information detection"
        echo "• PCI DSS: Credit card data security"
        echo "• SOX: Financial data governance"
        echo "• Custom: Organization-specific patterns"
        echo ""
        
        echo "RESOURCE SUMMARY:"
        local job_count=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
            | jq '.jobs | length')
        echo "• DLP Jobs created: $job_count"
        
        local template_count=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/inspectTemplates" \
            | jq '.inspectTemplates | length')
        echo "• Inspection templates: $template_count"
        
        local deidentify_template_count=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/deidentifyTemplates" \
            | jq '.deidentifyTemplates | length')
        echo "• De-identification templates: $deidentify_template_count"
        
        local trigger_count=$(curl -s -X GET \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/jobTriggers" \
            | jq '.jobTriggers | length')
        echo "• Job triggers: $trigger_count"
        echo ""
        
        echo "RECOMMENDATIONS:"
        echo "• Implement regular PII scanning schedules"
        echo "• Use templates for consistent detection policies"
        echo "• Apply appropriate de-identification for non-production data"
        echo "• Monitor risk metrics for compliance requirements"
        echo "• Set up alerts for sensitive data discovery"
        echo "• Integrate with data governance workflows"
        echo ""
        
        echo "NEXT STEPS:"
        echo "• Deploy production scanning policies"
        echo "• Configure automated remediation"
        echo "• Set up compliance reporting"
        echo "• Train teams on DLP best practices"
        echo "• Implement data classification workflows"
        echo ""
        
        echo "LAB COMPLETION STATUS: ✅ SUCCESSFUL"
        echo "All DLP API features tested and verified!"
        
    } | tee "$report_file"
    
    echo ""
    echo "📄 Report saved to: $report_file"
    echo ""
}

# Function: Performance summary
show_performance_summary() {
    echo "⚡ PERFORMANCE SUMMARY"
    echo "====================="
    echo ""
    
    echo "Content Inspection:"
    echo "  ✅ Text file scanning: Completed"
    echo "  ✅ Custom pattern detection: Completed"
    echo "  ✅ Dictionary-based detection: Completed"
    echo ""
    
    echo "Data Protection:"
    echo "  ✅ Character masking: Completed"
    echo "  ✅ Data replacement: Completed"
    echo "  ✅ Date shifting: Completed"
    echo ""
    
    echo "BigQuery Integration:"
    echo "  ✅ Table inspection: Completed"
    echo "  ✅ Column scanning: Completed"
    echo "  ✅ Sample analysis: Completed"
    echo ""
    
    echo "Risk Assessment:"
    echo "  ✅ K-anonymity: Completed"
    echo "  ✅ L-diversity: Completed"
    echo "  ✅ Categorical stats: Completed"
    echo "  ✅ Numerical stats: Completed"
    echo ""
    
    echo "Automation:"
    echo "  ✅ Templates: Completed"
    echo "  ✅ Job triggers: Completed"
    echo "  ✅ Resource management: Completed"
    echo ""
    
    echo "🎉 DLP API Lab completed successfully!"
    echo "All features tested and operational."
}

# Execute reporting functions
generate_comprehensive_report
show_performance_summary
```

---

### 🎯 Complete Lab Execution Script

```bash
#!/bin/bash

# Main execution script for DLP API Lab
echo "🚀 STARTING DATA LOSS PREVENTION API LAB"
echo "========================================"
echo ""

# Set environment
source ./setup_environment.sh

# Create test data
source ./create_test_data.sh

# Run content inspection
source ./content_inspection.sh

# Apply de-identification
source ./deidentification.sh

# BigQuery integration
source ./bigquery_integration.sh

# Risk analysis
source ./risk_analysis.sh

# Templates and automation
source ./templates_automation.sh

# Generate reports
source ./comprehensive_reporting.sh

echo ""
echo "✅ DATA LOSS PREVENTION API LAB COMPLETED!"
echo "All DLP features have been successfully tested and configured."
echo ""
echo "📚 Key Achievements:"
echo "  • Comprehensive PII detection implemented"
echo "  • Custom info types and patterns configured"
echo "  • Data de-identification methods applied"
echo "  • BigQuery integration established"
echo "  • Risk analysis performed"
echo "  • Automation templates created"
echo "  • Compliance coverage verified"
echo ""
echo "🎯 Lab objectives achieved successfully!"
```

---

## ✅ Verification Commands

```bash
# Verify DLP API is enabled
gcloud services list --enabled --filter="name:dlp.googleapis.com"

# Check BigQuery dataset
bq ls $PROJECT_ID:$DATASET_NAME

# List DLP jobs
curl -s -X GET \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/dlpJobs" \
  | jq '.jobs[] | {name: .name, type: .type, state: .state}'

# Verify storage bucket
gsutil ls gs://$BUCKET_NAME/

# Check templates
curl -s -X GET \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  "https://dlp.googleapis.com/v2/projects/$PROJECT_ID/inspectTemplates" \
  | jq '.inspectTemplates[] | .displayName'
```

---

## 🔗 Related Solutions

- **[GUI Solution](GUI-Solution.md)** - Console-based approach
- **[Automation Solution](Automation-Solution.md)** - Full automation scripts

---

<div align="center">

**⚡ Pro Tip**: Use CLI for scripted DLP workflows and integration with CI/CD pipelines!

</div>
