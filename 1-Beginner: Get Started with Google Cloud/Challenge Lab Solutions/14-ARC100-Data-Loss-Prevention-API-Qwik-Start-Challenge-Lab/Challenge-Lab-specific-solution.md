# ARC100: Data Loss Prevention API: Qwik Start: Challenge Lab

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![DLP API](https://img.shields.io/badge/DLP%20API-FF6B35?style=for-the-badge&logo=google&logoColor=white)

**Lab ID**: ARC100 | **Duration**: 45 minutes | **Level**: Introductory

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🎯 Challenge Overview

In this challenge lab, you'll explore the Google Cloud Data Loss Prevention (DLP) API to identify, classify, and protect sensitive data across your organization's content.

## 📋 Challenge Tasks

### Task 1: DLP API Setup and Configuration

Enable the DLP API and configure authentication.

### Task 2: Sensitive Data Detection

Detect and classify sensitive information in text content.

### Task 3: Data De-identification

Implement data masking and redaction techniques.

### Task 4: Custom InfoType Detection

Create custom patterns for organization-specific sensitive data.

### Task 5: Batch Processing and Cloud Storage Integration

Process large datasets and integrate with Cloud Storage.

---

## 🚀 Solution Method 1: DLP API Setup and Basic Detection

### Step 1: Environment Setup

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export BUCKET_NAME=${PROJECT_ID}-dlp-demo
export REGION=us-central1

# Enable required APIs
gcloud services enable dlp.googleapis.com
gcloud services enable storage.googleapis.com

# Create service account
gcloud iam service-accounts create dlp-api-sa \
    --description="Service account for DLP API demo" \
    --display-name="DLP API Service Account"

# Grant permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dlp-api-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/dlp.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:dlp-api-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Create and download key
gcloud iam service-accounts keys create dlp-api-key.json \
    --iam-account=dlp-api-sa@$PROJECT_ID.iam.gserviceaccount.com

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=dlp-api-key.json

# Create bucket for storing test data
gsutil mb -l $REGION gs://$BUCKET_NAME
```

### Step 2: Create Sample Data for Testing

```bash
# Create directory for DLP testing
mkdir ~/dlp-demo
cd ~/dlp-demo

# Create sample data files with sensitive information
cat > customer_data.txt << 'EOF'
Customer Information:
Name: John Smith
Email: john.smith@email.com
Phone: (555) 123-4567
SSN: 123-45-6789
Credit Card: 4532-1234-5678-9012
Address: 123 Main St, Anytown, CA 90210

Customer #2:
Name: Jane Doe
Email: jane.doe@company.org
Phone: +1-800-555-0199
SSN: 987-65-4321
Credit Card: 5555-4444-3333-2222
Address: 456 Oak Ave, Somewhere, NY 10001
EOF

cat > employee_records.csv << 'EOF'
employee_id,name,email,phone,ssn,salary,department
E001,Alice Johnson,alice.johnson@company.com,(555) 234-5678,111-22-3333,75000,Engineering
E002,Bob Wilson,bob.wilson@company.com,(555) 345-6789,444-55-6666,82000,Marketing
E003,Carol Davis,carol.davis@company.com,(555) 456-7890,777-88-9999,68000,HR
E004,David Brown,david.brown@company.com,(555) 567-8901,000-11-2222,91000,Finance
EOF

cat > medical_records.json << 'EOF'
{
  "patients": [
    {
      "patient_id": "P12345",
      "name": "Michael Johnson",
      "dob": "1985-03-15",
      "ssn": "123-45-6789",
      "phone": "(555) 987-6543",
      "email": "michael.j@email.com",
      "medical_record_number": "MRN-789123",
      "diagnoses": ["Hypertension", "Type 2 Diabetes"],
      "medications": ["Metformin", "Lisinopril"]
    },
    {
      "patient_id": "P67890",
      "name": "Sarah Williams",
      "dob": "1992-07-22",
      "ssn": "987-65-4321",
      "phone": "(555) 876-5432",
      "email": "sarah.w@email.com",
      "medical_record_number": "MRN-456789",
      "diagnoses": ["Asthma"],
      "medications": ["Albuterol"]
    }
  ]
}
EOF

cat > financial_data.txt << 'EOF'
Investment Portfolio Report
Account Number: 1234567890
Routing Number: 021000021
SWIFT Code: CHASUS33
IBAN: US12CHASE00000001234567890

Transactions:
- Credit Card Payment: 4111-1111-1111-1111 ($2,500.00)
- Wire Transfer to: DE89370400440532013000 ($15,000.00)
- ACH Deposit from: 987654321 ($3,200.00)

Contact: portfolio.manager@bank.com
Phone: 1-800-555-BANK
EOF

cat > web_logs.txt << 'EOF'
192.168.1.100 - - [25/Aug/2023:10:15:32 +0000] "GET /api/user/john.smith@email.com HTTP/1.1" 200 1234
10.0.0.50 - - [25/Aug/2023:10:16:45 +0000] "POST /login HTTP/1.1" 200 567 "username=jdoe&ssn=123-45-6789"
172.16.0.25 - - [25/Aug/2023:10:17:22 +0000] "GET /profile/555-123-4567 HTTP/1.1" 200 890
203.0.113.15 - - [25/Aug/2023:10:18:11 +0000] "PUT /api/payment/4532123456789012 HTTP/1.1" 201 445
EOF

# Upload sample files to Cloud Storage
gsutil cp *.txt *.csv *.json gs://$BUCKET_NAME/sample-data/

echo "Sample data files created and uploaded to Cloud Storage"
```

---

## 🚀 Solution Method 2: Comprehensive DLP Analysis

### Step 1: Basic Sensitive Data Detection

```bash
# Create comprehensive DLP analysis script
cat > dlp_analysis.py << 'EOF'
from google.cloud import dlp_v2
import json
import os
from typing import Dict, List, Any
from google.cloud import storage

class DLPAnalyzer:
    def __init__(self, project_id: str):
        self.project_id = project_id
        self.dlp_client = dlp_v2.DlpServiceClient()
        self.storage_client = storage.Client()
        self.parent = f"projects/{project_id}"
    
    def inspect_text_content(self, text_content: str, info_types: List[str] = None) -> Dict[str, Any]:
        """Inspect text content for sensitive information"""
        
        # Default info types if none specified
        if info_types is None:
            info_types = [
                "EMAIL_ADDRESS", "PHONE_NUMBER", "US_SSN", "CREDIT_CARD_NUMBER",
                "PERSON_NAME", "US_PASSPORT", "US_DRIVER_LICENSE", "IP_ADDRESS",
                "DATE_OF_BIRTH", "US_BANK_ROUTING_MICR", "IBAN_CODE", "SWIFT_CODE"
            ]
        
        # Configure inspection
        info_types_config = [{"name": info_type} for info_type in info_types]
        
        inspect_config = {
            "info_types": info_types_config,
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            "include_quote": True,
        }
        
        # Create inspection item
        item = {"value": text_content}
        
        # Perform inspection
        response = self.dlp_client.inspect_content(
            request={
                "parent": self.parent,
                "inspect_config": inspect_config,
                "item": item,
            }
        )
        
        # Process results
        findings = []
        for finding in response.result.findings:
            finding_data = {
                "info_type": finding.info_type.name,
                "likelihood": finding.likelihood.name,
                "quote": finding.quote,
                "location": {
                    "byte_range": {
                        "start": finding.location.byte_range.start,
                        "end": finding.location.byte_range.end
                    }
                }
            }
            findings.append(finding_data)
        
        return {
            "findings": findings,
            "total_findings": len(findings),
            "findings_by_type": self._group_findings_by_type(findings)
        }
    
    def _group_findings_by_type(self, findings: List[Dict]) -> Dict[str, int]:
        """Group findings by info type"""
        counts = {}
        for finding in findings:
            info_type = finding["info_type"]
            counts[info_type] = counts.get(info_type, 0) + 1
        return counts
    
    def deidentify_text(self, text_content: str, transformation_type: str = "REDACT") -> Dict[str, Any]:
        """De-identify sensitive information in text"""
        
        # Configure info types to detect
        info_types = [
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"},
            {"name": "US_SSN"},
            {"name": "CREDIT_CARD_NUMBER"},
            {"name": "PERSON_NAME"}
        ]
        
        inspect_config = {
            "info_types": info_types,
            "min_likelihood": dlp_v2.Likelihood.LIKELY,
        }
        
        # Configure transformation
        if transformation_type == "REDACT":
            transformation = {
                "primitive_transformation": {
                    "replace_config": {
                        "new_value": {"string_value": "[REDACTED]"}
                    }
                }
            }
        elif transformation_type == "MASK":
            transformation = {
                "primitive_transformation": {
                    "character_mask_config": {
                        "masking_character": "*",
                        "number_to_mask": 0  # Mask all characters
                    }
                }
            }
        elif transformation_type == "REPLACE":
            transformation = {
                "primitive_transformation": {
                    "replace_config": {
                        "new_value": {"string_value": "[SENSITIVE_DATA]"}
                    }
                }
            }
        else:  # DATE_SHIFT
            transformation = {
                "primitive_transformation": {
                    "date_shift_config": {
                        "upper_bound_days": 30,
                        "lower_bound_days": -30
                    }
                }
            }
        
        # Configure de-identification
        deidentify_config = {
            "info_type_transformations": {
                "transformations": [
                    {
                        "info_types": info_types,
                        **transformation
                    }
                ]
            }
        }
        
        # Create inspection item
        item = {"value": text_content}
        
        # Perform de-identification
        response = self.dlp_client.deidentify_content(
            request={
                "parent": self.parent,
                "deidentify_config": deidentify_config,
                "inspect_config": inspect_config,
                "item": item,
            }
        )
        
        return {
            "original_text": text_content,
            "deidentified_text": response.item.value,
            "transformation_type": transformation_type
        }
    
    def create_custom_info_type(self, info_type_name: str, patterns: List[str]) -> str:
        """Create custom info type with regex patterns"""
        
        # Create regex patterns
        regex_patterns = [{"pattern": pattern} for pattern in patterns]
        
        # Configure custom info type
        custom_info_type = {
            "info_type": {"name": info_type_name},
            "regex": {
                "pattern": "|".join(patterns),
                "group_indexes": [0]
            },
            "likelihood": dlp_v2.Likelihood.LIKELY
        }
        
        # Create the custom info type
        stored_info_type_config = {
            "display_name": f"Custom {info_type_name}",
            "description": f"Custom info type for {info_type_name} detection",
            "large_custom_dictionary": {
                "output_path": {
                    "path": f"gs://{self.project_id}-dlp-demo/custom-dictionaries/{info_type_name.lower()}.txt"
                }
            }
        }
        
        return info_type_name
    
    def inspect_cloud_storage_file(self, bucket_name: str, file_name: str) -> Dict[str, Any]:
        """Inspect a file in Cloud Storage for sensitive data"""
        
        # Configure Cloud Storage location
        storage_config = {
            "cloud_storage_options": {
                "file_set": {
                    "url": f"gs://{bucket_name}/{file_name}"
                }
            }
        }
        
        # Configure inspection
        inspect_config = {
            "info_types": [
                {"name": "EMAIL_ADDRESS"},
                {"name": "PHONE_NUMBER"},
                {"name": "US_SSN"},
                {"name": "CREDIT_CARD_NUMBER"},
                {"name": "PERSON_NAME"},
                {"name": "IP_ADDRESS"}
            ],
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            "include_quote": True,
        }
        
        # Configure inspection job
        inspect_job_config = {
            "inspect_config": inspect_config,
            "storage_config": storage_config,
        }
        
        # Start inspection job
        operation = self.dlp_client.create_dlp_job(
            request={
                "parent": self.parent,
                "inspect_job": inspect_job_config,
            }
        )
        
        # Wait for job completion
        print(f"Inspection job started: {operation.name}")
        
        # Poll for job completion
        import time
        while True:
            job = self.dlp_client.get_dlp_job(request={"name": operation.name})
            
            if job.state == dlp_v2.DlpJob.JobState.DONE:
                break
            elif job.state == dlp_v2.DlpJob.JobState.FAILED:
                raise Exception(f"Job failed: {job.errors}")
            
            print("Waiting for job to complete...")
            time.sleep(10)
        
        # Get results
        return {
            "job_name": operation.name,
            "file_inspected": f"gs://{bucket_name}/{file_name}",
            "findings_count": len(job.inspect_details.result.info_type_stats),
            "info_type_stats": [
                {
                    "info_type": stat.info_type.name,
                    "count": stat.count
                }
                for stat in job.inspect_details.result.info_type_stats
            ]
        }
    
    def create_dlp_template(self, template_id: str, display_name: str, description: str) -> str:
        """Create a DLP inspection template"""
        
        inspect_config = {
            "info_types": [
                {"name": "EMAIL_ADDRESS"},
                {"name": "PHONE_NUMBER"},
                {"name": "US_SSN"},
                {"name": "CREDIT_CARD_NUMBER"},
                {"name": "PERSON_NAME"}
            ],
            "min_likelihood": dlp_v2.Likelihood.LIKELY,
            "include_quote": True,
            "rule_set": [
                {
                    "info_types": [{"name": "PERSON_NAME"}],
                    "rules": [
                        {
                            "exclusion_rule": {
                                "matching_type": dlp_v2.MatchingType.MATCHING_TYPE_FULL_MATCH,
                                "dictionary": {
                                    "word_list": {
                                        "words": ["John Doe", "Jane Smith", "Test User"]
                                    }
                                }
                            }
                        }
                    ]
                }
            ]
        }
        
        inspect_template = {
            "display_name": display_name,
            "description": description,
            "inspect_config": inspect_config,
        }
        
        response = self.dlp_client.create_inspect_template(
            request={
                "parent": self.parent,
                "template_id": template_id,
                "inspect_template": inspect_template,
            }
        )
        
        return response.name
    
    def risk_analysis(self, dataset_config: Dict[str, Any]) -> Dict[str, Any]:
        """Perform risk analysis on a dataset"""
        
        # Configure privacy metric
        privacy_metric = {
            "categorical_stats_config": {
                "field": {"name": "email"}
            }
        }
        
        # Configure risk analysis job
        risk_job_config = {
            "privacy_metric": privacy_metric,
            "source_table": dataset_config,
        }
        
        # Start risk analysis job
        operation = self.dlp_client.create_dlp_job(
            request={
                "parent": self.parent,
                "risk_job": risk_job_config,
            }
        )
        
        return {"job_name": operation.name}

def demonstrate_dlp_capabilities():
    """Demonstrate comprehensive DLP capabilities"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    analyzer = DLPAnalyzer(project_id)
    
    # Load sample text files
    sample_files = [
        'customer_data.txt',
        'employee_records.csv',
        'medical_records.json',
        'financial_data.txt',
        'web_logs.txt'
    ]
    
    results = {
        'inspection_results': {},
        'deidentification_results': {},
        'cloud_storage_results': {},
        'template_created': None
    }
    
    print("=== DLP Comprehensive Analysis ===")
    
    # Inspect each file
    for file_name in sample_files:
        try:
            with open(file_name, 'r', encoding='utf-8') as f:
                content = f.read()
            
            print(f"\nInspecting {file_name}...")
            
            # Inspect content
            inspection_result = analyzer.inspect_text_content(content)
            results['inspection_results'][file_name] = inspection_result
            
            print(f"  Found {inspection_result['total_findings']} sensitive data items")
            for info_type, count in inspection_result['findings_by_type'].items():
                print(f"    {info_type}: {count}")
            
            # De-identify content (for first 3 files only to save time)
            if file_name in sample_files[:3]:
                print(f"  De-identifying {file_name}...")
                deidentified = analyzer.deidentify_text(content, "REDACT")
                results['deidentification_results'][file_name] = deidentified
                print(f"    Original length: {len(content)} characters")
                print(f"    De-identified length: {len(deidentified['deidentified_text'])} characters")
        
        except FileNotFoundError:
            print(f"Warning: {file_name} not found, skipping...")
        except Exception as e:
            print(f"Error processing {file_name}: {e}")
    
    # Cloud Storage inspection (for one file)
    try:
        print("\nInspecting Cloud Storage file...")
        bucket_name = f"{project_id}-dlp-demo"
        gcs_result = analyzer.inspect_cloud_storage_file(bucket_name, "sample-data/customer_data.txt")
        results['cloud_storage_results'] = gcs_result
        print(f"Cloud Storage inspection completed: {gcs_result['findings_count']} finding types")
    except Exception as e:
        print(f"Cloud Storage inspection failed: {e}")
        results['cloud_storage_results'] = {'error': str(e)}
    
    # Create inspection template
    try:
        print("\nCreating DLP inspection template...")
        template_name = analyzer.create_dlp_template(
            "basic_pii_template",
            "Basic PII Detection Template",
            "Template for detecting common PII types"
        )
        results['template_created'] = template_name
        print(f"Template created: {template_name}")
    except Exception as e:
        print(f"Template creation failed: {e}")
        results['template_created'] = {'error': str(e)}
    
    # Save results
    with open('dlp_analysis_results.json', 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    print("\nDLP analysis results saved to: dlp_analysis_results.json")
    
    # Print summary
    total_findings = sum(
        result['total_findings'] 
        for result in results['inspection_results'].values()
    )
    print(f"\nSummary: {total_findings} total sensitive data items found across all files")

if __name__ == "__main__":
    demonstrate_dlp_capabilities()
EOF

# Install required dependencies
pip install google-cloud-dlp google-cloud-storage

# Run DLP analysis
python dlp_analysis.py
```

---

## 🚀 Solution Method 3: Advanced DLP Features

### Step 1: Custom InfoTypes and Advanced Transformations

```bash
# Create advanced DLP features script
cat > advanced_dlp_features.py << 'EOF'
from google.cloud import dlp_v2
import json
import re
from typing import Dict, List, Any

class AdvancedDLPFeatures:
    def __init__(self, project_id: str):
        self.project_id = project_id
        self.dlp_client = dlp_v2.DlpServiceClient()
        self.parent = f"projects/{project_id}"
    
    def create_custom_employee_id_detector(self) -> str:
        """Create custom info type for employee IDs"""
        
        # Define custom regex patterns for employee IDs
        employee_patterns = [
            r"EMP-\d{4}",
            r"E\d{4}",
            r"EMPLOYEE_\d{3,5}"
        ]
        
        # Create stored info type
        stored_info_type = {
            "display_name": "Custom Employee ID",
            "description": "Custom info type for detecting employee identification numbers",
            "regex": {
                "pattern": "|".join(employee_patterns),
                "group_indexes": [0]
            }
        }
        
        response = self.dlp_client.create_stored_info_type(
            request={
                "parent": self.parent,
                "stored_info_type_id": "employee_id_detector",
                "config": stored_info_type,
            }
        )
        
        return response.name
    
    def create_custom_product_code_detector(self) -> str:
        """Create custom info type for product codes"""
        
        stored_info_type = {
            "display_name": "Product Code Detector",
            "description": "Custom detector for product codes",
            "regex": {
                "pattern": r"PROD-[A-Z]{2}-\d{4}",
                "group_indexes": [0]
            }
        }
        
        response = self.dlp_client.create_stored_info_type(
            request={
                "parent": self.parent,
                "stored_info_type_id": "product_code_detector",
                "config": stored_info_type,
            }
        )
        
        return response.name
    
    def advanced_deidentification_techniques(self, text_content: str) -> Dict[str, Any]:
        """Demonstrate various de-identification techniques"""
        
        techniques = {}
        
        # 1. Redaction
        techniques['redaction'] = self._apply_transformation(
            text_content, 
            "REDACT",
            {"new_value": {"string_value": "[REDACTED]"}}
        )
        
        # 2. Character masking
        techniques['character_masking'] = self._apply_transformation(
            text_content,
            "MASK",
            {
                "character_mask_config": {
                    "masking_character": "*",
                    "number_to_mask": 4,
                    "reverse_order": False,
                    "characters_to_ignore": [{"characters_to_skip": "-"}]
                }
            }
        )
        
        # 3. Crypto-based tokenization
        techniques['crypto_tokenization'] = self._apply_transformation(
            text_content,
            "CRYPTO_REPLACE_FFX_FPE",
            {
                "crypto_replace_ffx_fpe_config": {
                    "crypto_key": {
                        "transient": {
                            "name": "sample-key"
                        }
                    },
                    "alphabet": "NUMERIC"
                }
            }
        )
        
        # 4. Bucketing (for numeric data)
        techniques['bucketing'] = self._apply_transformation(
            text_content,
            "BUCKETING",
            {
                "bucketing_config": {
                    "buckets": [
                        {
                            "min": {"integer_value": 0},
                            "max": {"integer_value": 25},
                            "replacement_value": {"string_value": "0-25"}
                        },
                        {
                            "min": {"integer_value": 26},
                            "max": {"integer_value": 65},
                            "replacement_value": {"string_value": "26-65"}
                        },
                        {
                            "min": {"integer_value": 66},
                            "replacement_value": {"string_value": "66+"}
                        }
                    ]
                }
            }
        )
        
        return techniques
    
    def _apply_transformation(self, text_content: str, transform_type: str, transform_config: Dict) -> Dict[str, Any]:
        """Apply specific transformation to text"""
        
        try:
            # Configure info types
            info_types = [
                {"name": "EMAIL_ADDRESS"},
                {"name": "PHONE_NUMBER"},
                {"name": "US_SSN"},
                {"name": "CREDIT_CARD_NUMBER"}
            ]
            
            inspect_config = {
                "info_types": info_types,
                "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            }
            
            # Configure transformation
            if transform_type == "REDACT":
                transformation = {
                    "primitive_transformation": {
                        "replace_config": transform_config
                    }
                }
            elif transform_type == "MASK":
                transformation = {
                    "primitive_transformation": transform_config
                }
            elif transform_type == "CRYPTO_REPLACE_FFX_FPE":
                transformation = {
                    "primitive_transformation": transform_config
                }
            elif transform_type == "BUCKETING":
                transformation = {
                    "primitive_transformation": transform_config
                }
            else:
                transformation = {
                    "primitive_transformation": {
                        "replace_config": {"new_value": {"string_value": f"[{transform_type}]"}}
                    }
                }
            
            deidentify_config = {
                "info_type_transformations": {
                    "transformations": [
                        {
                            "info_types": info_types,
                            **transformation
                        }
                    ]
                }
            }
            
            item = {"value": text_content}
            
            response = self.dlp_client.deidentify_content(
                request={
                    "parent": self.parent,
                    "deidentify_config": deidentify_config,
                    "inspect_config": inspect_config,
                    "item": item,
                }
            )
            
            return {
                "original": text_content,
                "transformed": response.item.value,
                "technique": transform_type,
                "success": True
            }
            
        except Exception as e:
            return {
                "original": text_content,
                "error": str(e),
                "technique": transform_type,
                "success": False
            }
    
    def create_inspection_template_with_rules(self) -> str:
        """Create advanced inspection template with custom rules"""
        
        # Define hotword rules
        hotword_rule = {
            "hotword_regex": {"pattern": r"(?i)(medical|health|patient)"},
            "proximity": {"window_before": 50, "window_after": 50},
            "likelihood_adjustment": {
                "fixed_likelihood": dlp_v2.Likelihood.VERY_LIKELY
            }
        }
        
        # Define exclusion rules
        exclusion_rule = {
            "exclusion_rule": {
                "matching_type": dlp_v2.MatchingType.MATCHING_TYPE_PARTIAL_MATCH,
                "dictionary": {
                    "word_list": {
                        "words": ["example.com", "test.org", "demo.net"]
                    }
                }
            }
        }
        
        inspect_config = {
            "info_types": [
                {"name": "EMAIL_ADDRESS"},
                {"name": "PHONE_NUMBER"},
                {"name": "PERSON_NAME"},
                {"name": "US_SSN"}
            ],
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            "include_quote": True,
            "rule_set": [
                {
                    "info_types": [{"name": "EMAIL_ADDRESS"}],
                    "rules": [exclusion_rule]
                },
                {
                    "info_types": [{"name": "PERSON_NAME"}],
                    "rules": [{"hotword_rule": hotword_rule}]
                }
            ]
        }
        
        inspect_template = {
            "display_name": "Advanced PII Detection with Rules",
            "description": "Template with hotword and exclusion rules",
            "inspect_config": inspect_config,
        }
        
        response = self.dlp_client.create_inspect_template(
            request={
                "parent": self.parent,
                "template_id": "advanced_pii_template",
                "inspect_template": inspect_template,
            }
        )
        
        return response.name
    
    def create_deidentification_template(self) -> str:
        """Create de-identification template with multiple transformations"""
        
        deidentify_config = {
            "info_type_transformations": {
                "transformations": [
                    {
                        "info_types": [{"name": "EMAIL_ADDRESS"}],
                        "primitive_transformation": {
                            "character_mask_config": {
                                "masking_character": "*",
                                "number_to_mask": 5,
                                "reverse_order": False
                            }
                        }
                    },
                    {
                        "info_types": [{"name": "PHONE_NUMBER"}],
                        "primitive_transformation": {
                            "replace_config": {
                                "new_value": {"string_value": "[PHONE_REDACTED]"}
                            }
                        }
                    },
                    {
                        "info_types": [{"name": "US_SSN"}],
                        "primitive_transformation": {
                            "character_mask_config": {
                                "masking_character": "X",
                                "number_to_mask": 5,
                                "reverse_order": True,
                                "characters_to_ignore": [{"characters_to_skip": "-"}]
                            }
                        }
                    }
                ]
            }
        }
        
        deidentify_template = {
            "display_name": "Multi-technique De-identification",
            "description": "Template using multiple de-identification techniques",
            "deidentify_config": deidentify_config,
        }
        
        response = self.dlp_client.create_deidentify_template(
            request={
                "parent": self.parent,
                "template_id": "multi_deidentify_template",
                "deidentify_template": deidentify_template,
            }
        )
        
        return response.name
    
    def analyze_with_custom_info_types(self, text_content: str) -> Dict[str, Any]:
        """Analyze text using both built-in and custom info types"""
        
        # Include both built-in and custom info types
        info_types = [
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"},
            {"name": "US_SSN"},
            {"name": f"projects/{self.project_id}/storedInfoTypes/employee_id_detector"},
            {"name": f"projects/{self.project_id}/storedInfoTypes/product_code_detector"}
        ]
        
        inspect_config = {
            "info_types": info_types,
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            "include_quote": True,
        }
        
        item = {"value": text_content}
        
        response = self.dlp_client.inspect_content(
            request={
                "parent": self.parent,
                "inspect_config": inspect_config,
                "item": item,
            }
        )
        
        findings = []
        for finding in response.result.findings:
            findings.append({
                "info_type": finding.info_type.name,
                "likelihood": finding.likelihood.name,
                "quote": finding.quote,
                "is_custom": "storedInfoTypes" in finding.info_type.name
            })
        
        return {
            "findings": findings,
            "custom_findings": [f for f in findings if f["is_custom"]],
            "built_in_findings": [f for f in findings if not f["is_custom"]]
        }
    
    def risk_analysis_demo(self) -> Dict[str, Any]:
        """Demonstrate risk analysis capabilities"""
        
        # Create sample dataset for risk analysis
        sample_data = [
            {"email": "john@company.com", "age": 30, "department": "IT"},
            {"email": "jane@company.com", "age": 25, "department": "HR"},
            {"email": "bob@company.com", "age": 35, "department": "IT"},
            {"email": "alice@company.com", "age": 28, "department": "Finance"}
        ]
        
        # For this demo, we'll simulate risk analysis
        # In practice, you'd use actual BigQuery tables
        
        risk_metrics = {
            "email_uniqueness": len(set(item["email"] for item in sample_data)),
            "age_distribution": {},
            "department_distribution": {}
        }
        
        # Calculate distributions
        for item in sample_data:
            dept = item["department"]
            age_range = f"{(item['age'] // 10) * 10}s"
            
            risk_metrics["department_distribution"][dept] = risk_metrics["department_distribution"].get(dept, 0) + 1
            risk_metrics["age_distribution"][age_range] = risk_metrics["age_distribution"].get(age_range, 0) + 1
        
        return {
            "dataset_size": len(sample_data),
            "risk_metrics": risk_metrics,
            "privacy_assessment": "Medium risk - limited dataset with quasi-identifiers"
        }

def demonstrate_advanced_dlp():
    """Demonstrate advanced DLP features"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    advanced_dlp = AdvancedDLPFeatures(project_id)
    
    results = {
        "custom_info_types": {},
        "transformation_techniques": {},
        "templates_created": {},
        "risk_analysis": {}
    }
    
    print("=== Advanced DLP Features Demo ===")
    
    # Create custom info types
    try:
        print("\n1. Creating custom info types...")
        employee_detector = advanced_dlp.create_custom_employee_id_detector()
        product_detector = advanced_dlp.create_custom_product_code_detector()
        
        results["custom_info_types"] = {
            "employee_id_detector": employee_detector,
            "product_code_detector": product_detector
        }
        print("✓ Custom info types created successfully")
    except Exception as e:
        print(f"✗ Error creating custom info types: {e}")
        results["custom_info_types"] = {"error": str(e)}
    
    # Test advanced transformations
    try:
        print("\n2. Testing advanced transformation techniques...")
        test_text = """
        Employee John Smith (EMP-1234) contacted customer jane.doe@email.com 
        regarding product PROD-AB-5678. Phone: (555) 123-4567, SSN: 123-45-6789.
        Credit Card: 4532-1234-5678-9012.
        """
        
        transformations = advanced_dlp.advanced_deidentification_techniques(test_text)
        results["transformation_techniques"] = transformations
        
        for technique, result in transformations.items():
            if result.get("success"):
                print(f"✓ {technique} transformation successful")
            else:
                print(f"✗ {technique} transformation failed: {result.get('error', 'Unknown error')}")
    
    except Exception as e:
        print(f"✗ Error testing transformations: {e}")
        results["transformation_techniques"] = {"error": str(e)}
    
    # Create advanced templates
    try:
        print("\n3. Creating advanced templates...")
        
        inspect_template = advanced_dlp.create_inspection_template_with_rules()
        deidentify_template = advanced_dlp.create_deidentification_template()
        
        results["templates_created"] = {
            "inspection_template": inspect_template,
            "deidentification_template": deidentify_template
        }
        print("✓ Advanced templates created successfully")
    
    except Exception as e:
        print(f"✗ Error creating templates: {e}")
        results["templates_created"] = {"error": str(e)}
    
    # Test custom info type analysis
    try:
        print("\n4. Testing analysis with custom info types...")
        test_text_custom = """
        Employee records: 
        EMP-1234: John Smith, john.smith@company.com
        E0567: Jane Doe, jane.doe@company.com
        Products sold: PROD-AB-1234, PROD-CD-5678
        Phone numbers: (555) 123-4567, (555) 987-6543
        """
        
        custom_analysis = advanced_dlp.analyze_with_custom_info_types(test_text_custom)
        results["custom_analysis"] = custom_analysis
        
        print(f"✓ Found {len(custom_analysis['custom_findings'])} custom info type matches")
        print(f"✓ Found {len(custom_analysis['built_in_findings'])} built-in info type matches")
    
    except Exception as e:
        print(f"✗ Error in custom analysis: {e}")
        results["custom_analysis"] = {"error": str(e)}
    
    # Risk analysis demo
    try:
        print("\n5. Demonstrating risk analysis...")
        risk_analysis = advanced_dlp.risk_analysis_demo()
        results["risk_analysis"] = risk_analysis
        print("✓ Risk analysis completed")
    
    except Exception as e:
        print(f"✗ Risk analysis failed: {e}")
        results["risk_analysis"] = {"error": str(e)}
    
    # Save results
    with open('advanced_dlp_results.json', 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    print("\nAdvanced DLP results saved to: advanced_dlp_results.json")
    
    # Print summary
    print(f"\n=== Summary ===")
    print(f"Custom info types: {'✓' if 'error' not in results['custom_info_types'] else '✗'}")
    print(f"Transformation techniques: {'✓' if 'error' not in results['transformation_techniques'] else '✗'}")
    print(f"Template creation: {'✓' if 'error' not in results['templates_created'] else '✗'}")
    print(f"Risk analysis: {'✓' if 'error' not in results['risk_analysis'] else '✗'}")

if __name__ == "__main__":
    demonstrate_advanced_dlp()
EOF

# Run advanced DLP features
python advanced_dlp_features.py
```

---

## ✅ Validation

### Comprehensive DLP Testing

```bash
# Create comprehensive validation script
cat > validate_dlp_setup.py << 'EOF'
from google.cloud import dlp_v2
import json
import os

def validate_dlp_api_access():
    """Validate DLP API access and basic functionality"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    client = dlp_v2.DlpServiceClient()
    parent = f"projects/{project_id}"
    
    try:
        # Test basic inspection
        item = {"value": "My email is test@example.com and my phone is (555) 123-4567"}
        inspect_config = {
            "info_types": [{"name": "EMAIL_ADDRESS"}, {"name": "PHONE_NUMBER"}],
            "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
        }
        
        response = client.inspect_content(
            request={
                "parent": parent,
                "inspect_config": inspect_config,
                "item": item,
            }
        )
        
        findings_count = len(response.result.findings)
        print(f"✓ DLP API access validated - found {findings_count} sensitive items")
        
        # Test template listing
        templates = client.list_inspect_templates(request={"parent": parent})
        template_count = len(list(templates))
        print(f"✓ Template access validated - {template_count} templates found")
        
        # Test stored info types listing
        stored_info_types = client.list_stored_info_types(request={"parent": parent})
        stored_count = len(list(stored_info_types))
        print(f"✓ Stored info types access validated - {stored_count} custom types found")
        
        return True
        
    except Exception as e:
        print(f"✗ DLP API validation failed: {e}")
        return False

def test_all_info_types():
    """Test detection of various info types"""
    
    project_id = os.environ.get('GOOGLE_CLOUD_PROJECT')
    client = dlp_v2.DlpServiceClient()
    parent = f"projects/{project_id}"
    
    test_data = {
        "EMAIL_ADDRESS": "Contact us at support@company.com",
        "PHONE_NUMBER": "Call us at (555) 123-4567",
        "US_SSN": "My SSN is 123-45-6789",
        "CREDIT_CARD_NUMBER": "Credit card: 4532-1234-5678-9012",
        "IP_ADDRESS": "Server IP: 192.168.1.100",
        "PERSON_NAME": "Please contact John Smith",
        "US_PASSPORT": "Passport number: 123456789"
    }
    
    results = {}
    
    for info_type, test_text in test_data.items():
        try:
            inspect_config = {
                "info_types": [{"name": info_type}],
                "min_likelihood": dlp_v2.Likelihood.POSSIBLE,
            }
            
            item = {"value": test_text}
            
            response = client.inspect_content(
                request={
                    "parent": parent,
                    "inspect_config": inspect_config,
                    "item": item,
                }
            )
            
            found = len(response.result.findings) > 0
            results[info_type] = "✓" if found else "✗"
            print(f"{results[info_type]} {info_type}: {'detected' if found else 'not detected'}")
            
        except Exception as e:
            results[info_type] = f"Error: {e}"
            print(f"✗ {info_type}: Error - {e}")
    
    return results

def validate_file_processing():
    """Validate file processing capabilities"""
    
    test_files = [
        'customer_data.txt',
        'employee_records.csv',
        'medical_records.json'
    ]
    
    validation_results = {}
    
    for file_name in test_files:
        try:
            if os.path.exists(file_name):
                with open(file_name, 'r') as f:
                    content = f.read()
                
                # Basic validation - check if file can be read and contains expected data
                has_content = len(content) > 0
                has_likely_pii = any(pattern in content.lower() for pattern in 
                                   ['@', 'phone', 'ssn', 'credit', 'email'])
                
                validation_results[file_name] = {
                    "exists": True,
                    "has_content": has_content,
                    "likely_contains_pii": has_likely_pii,
                    "size_bytes": len(content)
                }
                
                status = "✓" if has_content and has_likely_pii else "⚠"
                print(f"{status} {file_name}: {len(content)} bytes, PII likely: {has_likely_pii}")
            
            else:
                validation_results[file_name] = {"exists": False}
                print(f"✗ {file_name}: File not found")
        
        except Exception as e:
            validation_results[file_name] = {"error": str(e)}
            print(f"✗ {file_name}: Error - {e}")
    
    return validation_results

def main():
    """Run comprehensive DLP validation"""
    
    print("=== DLP API Comprehensive Validation ===")
    
    validation_report = {
        "api_access": False,
        "info_type_detection": {},
        "file_processing": {},
        "overall_status": "unknown"
    }
    
    # Test API access
    print("\n1. Testing API Access...")
    validation_report["api_access"] = validate_dlp_api_access()
    
    # Test info type detection
    print("\n2. Testing Info Type Detection...")
    validation_report["info_type_detection"] = test_all_info_types()
    
    # Test file processing
    print("\n3. Testing File Processing...")
    validation_report["file_processing"] = validate_file_processing()
    
    # Determine overall status
    api_ok = validation_report["api_access"]
    info_types_ok = len([r for r in validation_report["info_type_detection"].values() if r == "✓"]) > 5
    files_ok = len([r for r in validation_report["file_processing"].values() if r.get("exists", False)]) > 0
    
    if api_ok and info_types_ok and files_ok:
        validation_report["overall_status"] = "success"
        print("\n✓ All validations passed successfully!")
    elif api_ok:
        validation_report["overall_status"] = "partial"
        print("\n⚠ Partial success - API working but some components may need attention")
    else:
        validation_report["overall_status"] = "failure"
        print("\n✗ Validation failed - please check configuration")
    
    # Save validation report
    with open('dlp_validation_report.json', 'w') as f:
        json.dump(validation_report, f, indent=2)
    
    print("Validation report saved to: dlp_validation_report.json")

if __name__ == "__main__":
    main()
EOF

# Run comprehensive validation
echo "=== Running DLP Validation ==="

# Check environment
echo "Project ID: $PROJECT_ID"
echo "Bucket: $BUCKET_NAME"

# Run Python validation
python validate_dlp_setup.py

# Check generated files
echo -e "\nGenerated Files:"
ls -la *.json 2>/dev/null | grep -E "(dlp|analysis)" || echo "No DLP analysis files found"

# Check Cloud Storage setup
echo -e "\nCloud Storage Status:"
gsutil ls gs://$BUCKET_NAME/ || echo "Bucket access issue"

echo "=== Validation Complete ==="
```

---

## 🔧 Troubleshooting

**Issue**: DLP API quota exceeded
- Check current quota usage in console
- Implement request batching
- Consider quota increase request

**Issue**: Custom info types not working
- Verify regex pattern syntax
- Check stored info type creation
- Test patterns independently

**Issue**: De-identification not preserving format
- Adjust transformation settings
- Use format-preserving encryption
- Implement custom transformations

---

## 📚 Key Learning Points

- **Sensitive Data Detection**: Identifying PII, PHI, and financial data
- **Custom Info Types**: Creating organization-specific detectors
- **De-identification Techniques**: Redaction, masking, tokenization
- **Risk Analysis**: Assessing privacy risks in datasets
- **Template Management**: Reusable inspection and de-identification configs
- **Cloud Integration**: Processing files in Cloud Storage

---

## 🏆 Challenge Complete!

You've successfully mastered Google Cloud Data Loss Prevention API with:
- ✅ Comprehensive sensitive data detection across multiple data types
- ✅ Advanced de-identification techniques (redaction, masking, tokenization)
- ✅ Custom info type creation for organization-specific patterns
- ✅ Template-based configuration for reusable policies
- ✅ Cloud Storage integration for batch processing
- ✅ Risk analysis and privacy assessment capabilities

<div align="center">

**🎉 Congratulations! You've completed ARC100!**

**🎊 You've finished all 14 Google Cloud Challenge Labs! 🎊**

[![Back to Overview](https://img.shields.io/badge/Back%20to-Challenge%20Labs%20Overview-blue?style=for-the-badge)](../../README.md)

</div>
