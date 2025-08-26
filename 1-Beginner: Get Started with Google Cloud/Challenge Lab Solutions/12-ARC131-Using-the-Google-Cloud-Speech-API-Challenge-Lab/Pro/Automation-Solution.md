# Google Cloud Speech API: Qwik Start - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Speech API](https://img.shields.io/badge/Speech%20API-FF6F00?style=for-the-badge&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)

**Lab ID**: ARC132 | **Duration**: 10-15 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🤖 Complete Automation Solution

Full automation for Speech-to-Text API using Terraform, Python, and bash scripts.

---

## 🚀 One-Click Bash Automation

```bash
#!/bin/bash

# Google Cloud Speech API Qwik Start - Complete Automation
# Author: CodeWithGarry

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
BUCKET_NAME="$PROJECT_ID-speech-samples"
SAMPLE_AUDIO_DIR="speech-samples"

echo -e "${BLUE}🚀 Starting Speech API Qwik Start Automation${NC}"
echo -e "${YELLOW}Project: $PROJECT_ID${NC}"
echo -e "${YELLOW}Region: $REGION${NC}"
echo -e "${YELLOW}Bucket: $BUCKET_NAME${NC}"

# Task 1: Enable APIs
echo -e "\n${BLUE}🔧 Task 1: Enabling APIs...${NC}"
gcloud services enable speech.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"

# Task 2: Create storage bucket
echo -e "\n${BLUE}📦 Task 2: Creating storage bucket...${NC}"
gsutil mb -l $REGION gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already exists"
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME
echo -e "${GREEN}✅ Storage bucket configured${NC}"

# Task 3: Download and upload sample audio files
echo -e "\n${BLUE}🎵 Task 3: Preparing audio samples...${NC}"
mkdir -p $SAMPLE_AUDIO_DIR
cd $SAMPLE_AUDIO_DIR

# Download various audio samples
echo -e "${BLUE}Downloading sample audio files...${NC}"
wget -q https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac -O brooklyn.flac
wget -q https://cloud.google.com/speech-to-text/docs/samples/hello.wav -O hello.wav

# Create a simple text-to-speech sample for testing (if espeak is available)
if command -v espeak &> /dev/null; then
    echo "Creating synthetic speech sample..."
    espeak "Hello from CodeWithGarry automation script" -w test-automation.wav 2>/dev/null || true
fi

# Upload all audio files
echo -e "${BLUE}Uploading audio files to bucket...${NC}"
gsutil -m cp *.flac *.wav gs://$BUCKET_NAME/ 2>/dev/null || true
gsutil -m acl ch -u AllUsers:R gs://$BUCKET_NAME/*.flac 2>/dev/null || true
gsutil -m acl ch -u AllUsers:R gs://$BUCKET_NAME/*.wav 2>/dev/null || true

cd ..
echo -e "${GREEN}✅ Audio samples prepared and uploaded${NC}"

# Task 4: Test basic speech recognition
echo -e "\n${BLUE}🗣️ Task 4: Testing basic speech recognition...${NC}"

# Create request for FLAC file
cat > basic_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true,
    "enableWordConfidence": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Execute basic transcription
echo -e "${BLUE}Transcribing brooklyn.flac...${NC}"
BASIC_RESULT=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @basic_request.json)

if echo "$BASIC_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    TRANSCRIPT=$(echo "$BASIC_RESULT" | jq -r '.results[].alternatives[].transcript')
    CONFIDENCE=$(echo "$BASIC_RESULT" | jq -r '.results[].alternatives[].confidence // "N/A"')
    echo -e "${GREEN}✅ Transcription: $TRANSCRIPT${NC}"
    echo -e "${GREEN}📊 Confidence: $CONFIDENCE${NC}"
else
    echo -e "${RED}❌ Basic transcription failed${NC}"
fi

# Task 5: Test advanced features
echo -e "\n${BLUE}🚀 Task 5: Testing advanced features...${NC}"

# Create advanced request with multiple features
cat > advanced_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true,
    "enableWordConfidence": true,
    "enableAutomaticPunctuation": true,
    "enableSpokenPunctuation": false,
    "maxAlternatives": 3,
    "profanityFilter": false,
    "speechContexts": [
      {
        "phrases": ["Brooklyn", "New York", "borough", "CodeWithGarry"]
      }
    ]
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Execute advanced transcription
echo -e "${BLUE}Testing advanced features...${NC}"
ADVANCED_RESULT=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @advanced_request.json)

if echo "$ADVANCED_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Advanced transcription successful${NC}"
    echo -e "${BLUE}Alternative transcriptions:${NC}"
    echo "$ADVANCED_RESULT" | jq -r '.results[].alternatives[]? | "- \(.transcript) (Confidence: \(.confidence // "N/A"))"' | head -3
else
    echo -e "${RED}❌ Advanced transcription failed${NC}"
fi

# Task 6: Test WAV format
echo -e "\n${BLUE}🎧 Task 6: Testing WAV format...${NC}"

cat > wav_request.json << EOF
{
  "config": {
    "encoding": "LINEAR16",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "enableWordTimeOffsets": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/hello.wav"
  }
}
EOF

# Execute WAV transcription
WAV_RESULT=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @wav_request.json)

if echo "$WAV_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    WAV_TRANSCRIPT=$(echo "$WAV_RESULT" | jq -r '.results[].alternatives[].transcript')
    echo -e "${GREEN}✅ WAV transcription: $WAV_TRANSCRIPT${NC}"
else
    echo -e "${YELLOW}⚠️ WAV transcription may have failed (expected for some samples)${NC}"
fi

# Task 7: Test multilingual capabilities
echo -e "\n${BLUE}🌍 Task 7: Testing multilingual capabilities...${NC}"

cat > multilang_request.json << EOF
{
  "config": {
    "encoding": "FLAC",
    "sampleRateHertz": 16000,
    "languageCode": "en-US",
    "alternativeLanguageCodes": ["es-ES", "fr-FR", "de-DE"],
    "enableWordTimeOffsets": true
  },
  "audio": {
    "uri": "gs://$BUCKET_NAME/brooklyn.flac"
  }
}
EOF

# Execute multilingual transcription
MULTILANG_RESULT=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @multilang_request.json)

if echo "$MULTILANG_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    DETECTED_LANG=$(echo "$MULTILANG_RESULT" | jq -r '.results[].languageCode // "en-US"')
    echo -e "${GREEN}✅ Detected language: $DETECTED_LANG${NC}"
else
    echo -e "${YELLOW}⚠️ Multilingual detection test completed${NC}"
fi

# Task 8: Performance and monitoring test
echo -e "\n${BLUE}📊 Task 8: Performance testing...${NC}"

# Test response time
START_TIME=$(date +%s.%N)
PERF_RESULT=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d @basic_request.json)
END_TIME=$(date +%s.%N)
RESPONSE_TIME=$(echo "$END_TIME - $START_TIME" | bc)

echo -e "${GREEN}⏱️ API response time: ${RESPONSE_TIME} seconds${NC}"

# Test batch processing simulation
echo -e "${BLUE}Testing batch processing...${NC}"
BATCH_COUNT=0
SUCCESSFUL_REQUESTS=0

for i in {1..3}; do
    BATCH_COUNT=$((BATCH_COUNT + 1))
    BATCH_RESULT=$(curl -s -X POST \
      -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
      -H "Content-Type: application/json" \
      "https://speech.googleapis.com/v1/speech:recognize" \
      -d @basic_request.json)
    
    if echo "$BATCH_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
        SUCCESSFUL_REQUESTS=$((SUCCESSFUL_REQUESTS + 1))
    fi
    sleep 1
done

echo -e "${GREEN}✅ Batch test: $SUCCESSFUL_REQUESTS/$BATCH_COUNT requests successful${NC}"

# Task 9: Generate comprehensive report
echo -e "\n${BLUE}📋 Task 9: Generating test report...${NC}"

cat > speech_api_test_report.md << EOF
# Speech API Test Report
Generated: $(date)
Project: $PROJECT_ID

## Test Results Summary

### Basic Transcription
- Status: $(if echo "$BASIC_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- Transcript: $(echo "$BASIC_RESULT" | jq -r '.results[].alternatives[].transcript // "N/A"')
- Confidence: $(echo "$BASIC_RESULT" | jq -r '.results[].alternatives[].confidence // "N/A"')

### Advanced Features
- Status: $(if echo "$ADVANCED_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- Multiple alternatives: $(echo "$ADVANCED_RESULT" | jq -r '.results[].alternatives | length')
- Punctuation enabled: Yes

### Format Testing
- FLAC: ✅ Tested
- WAV: $(if echo "$WAV_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then echo "✅ SUCCESS"; else echo "⚠️ LIMITED"; fi)

### Performance
- API Response Time: ${RESPONSE_TIME} seconds
- Batch Success Rate: $SUCCESSFUL_REQUESTS/$BATCH_COUNT

### Detected Languages
- Primary: $DETECTED_LANG

## Recommendations
1. Use FLAC format for best results
2. Enable word confidence for quality assessment
3. Implement proper error handling for production use
4. Consider using speech contexts for domain-specific vocabulary

---
Generated by CodeWithGarry Automation Script
EOF

echo -e "${GREEN}✅ Test report generated: speech_api_test_report.md${NC}"

# Task 10: Cleanup and final verification
echo -e "\n${BLUE}🧹 Task 10: Cleanup and verification...${NC}"

# Verify all components
echo -e "${BLUE}Final verification:${NC}"

# Check API status
if gcloud services list --enabled --filter="name:speech.googleapis.com" --format="value(name)" | grep -q speech; then
    echo -e "${GREEN}✅ Speech API enabled${NC}"
else
    echo -e "${RED}❌ Speech API not enabled${NC}"
fi

# Check bucket
if gsutil ls -b gs://$BUCKET_NAME &>/dev/null; then
    OBJECT_COUNT=$(gsutil ls gs://$BUCKET_NAME/ | wc -l)
    echo -e "${GREEN}✅ Storage bucket exists with $OBJECT_COUNT objects${NC}"
else
    echo -e "${RED}❌ Storage bucket not found${NC}"
fi

# Check successful transcriptions
TOTAL_TESTS=3
SUCCESSFUL_TESTS=0

if echo "$BASIC_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
fi

if echo "$ADVANCED_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
fi

if echo "$WAV_RESULT" | jq -e '.results[].alternatives[].transcript' > /dev/null 2>&1; then
    SUCCESSFUL_TESTS=$((SUCCESSFUL_TESTS + 1))
fi

echo -e "${GREEN}📊 Transcription success rate: $SUCCESSFUL_TESTS/$TOTAL_TESTS${NC}"

# Cleanup temporary files
rm -f *_request.json
rm -rf $SAMPLE_AUDIO_DIR

echo -e "\n${GREEN}🎉 Speech API automation completed successfully!${NC}"
echo -e "${GREEN}📊 Test Report: speech_api_test_report.md${NC}"
echo -e "${GREEN}🗂️ Storage Bucket: gs://$BUCKET_NAME${NC}"
echo -e "${GREEN}🔍 Console: https://console.cloud.google.com/speech${NC}"
echo -e "\n${BLUE}📝 View test report:${NC}"
echo -e "${BLUE}cat speech_api_test_report.md${NC}"
```

---

## 🏗️ Terraform Infrastructure as Code

```terraform
# Google Cloud Speech API - Terraform Configuration
# Author: CodeWithGarry

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Speech samples bucket name"
  type        = string
  default     = ""
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "speech.googleapis.com",
    "storage.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  
  service = each.value
}

# Storage bucket for audio samples
resource "google_storage_bucket" "speech_samples" {
  name     = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-speech-samples"
  location = var.region
  
  uniform_bucket_level_access = true
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Make bucket publicly readable
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.speech_samples.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Create sample audio files (placeholder - actual files would be uploaded separately)
resource "google_storage_bucket_object" "sample_config" {
  name    = "config/sample-audio-info.json"
  bucket  = google_storage_bucket.speech_samples.name
  content = jsonencode({
    samples = [
      {
        name        = "brooklyn.flac"
        format      = "FLAC"
        sample_rate = 16000
        language    = "en-US"
        description = "Brooklyn borough pronunciation sample"
      },
      {
        name        = "hello.wav"
        format      = "LINEAR16"
        sample_rate = 16000
        language    = "en-US"
        description = "Simple hello greeting sample"
      }
    ]
    created_by = "CodeWithGarry Terraform"
    created_at = timestamp()
  })
}

# Service account for Speech API operations
resource "google_service_account" "speech_api_sa" {
  account_id   = "speech-api-service"
  display_name = "Speech API Service Account"
  description  = "Service account for Speech API operations"
}

# IAM roles for service account
resource "google_project_iam_member" "speech_api_permissions" {
  for_each = toset([
    "roles/speech.client",
    "roles/storage.objectViewer"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.speech_api_sa.email}"
}

# Create service account key
resource "google_service_account_key" "speech_api_key" {
  service_account_id = google_service_account.speech_api_sa.name
}

# Cloud Function for automated testing (optional)
resource "google_storage_bucket_object" "test_function_source" {
  name    = "functions/speech-test-function.py"
  bucket  = google_storage_bucket.speech_samples.name
  content = <<-EOT
import json
from google.cloud import speech
from google.cloud import storage
import functions_framework

@functions_framework.http
def test_speech_api(request):
    """Test Speech API functionality"""
    
    try:
        # Initialize clients
        speech_client = speech.SpeechClient()
        storage_client = storage.Client()
        
        # Configuration for sample audio
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
            sample_rate_hertz=16000,
            language_code="en-US",
            enable_word_time_offsets=True,
            enable_word_confidence=True,
        )
        
        # Audio source
        audio = speech.RecognitionAudio(
            uri="gs://${google_storage_bucket.speech_samples.name}/brooklyn.flac"
        )
        
        # Perform transcription
        response = speech_client.recognize(config=config, audio=audio)
        
        # Process results
        results = []
        for result in response.results:
            alternative = result.alternatives[0]
            results.append({
                "transcript": alternative.transcript,
                "confidence": alternative.confidence,
                "words": [
                    {
                        "word": word.word,
                        "start_time": word.start_time.total_seconds(),
                        "end_time": word.end_time.total_seconds(),
                        "confidence": getattr(word, 'confidence', None)
                    }
                    for word in alternative.words
                ]
            })
        
        return json.dumps({
            "status": "success",
            "results": results,
            "test_type": "automated_terraform_test",
            "bucket": "${google_storage_bucket.speech_samples.name}"
        }, indent=2)
        
    except Exception as e:
        return json.dumps({
            "status": "error",
            "error": str(e),
            "test_type": "automated_terraform_test"
        }), 500
EOT
}

# Monitoring alert for Speech API errors
resource "google_monitoring_alert_policy" "speech_api_errors" {
  display_name = "Speech API Error Rate Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Speech API error rate"
    
    condition_threshold {
      filter          = "resource.type=\"api\" AND resource.label.service=\"speech.googleapis.com\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 5
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  depends_on = [google_project_service.required_apis]
}

# Outputs
output "speech_samples_bucket" {
  value       = google_storage_bucket.speech_samples.name
  description = "Storage bucket for speech samples"
}

output "speech_samples_url" {
  value       = google_storage_bucket.speech_samples.url
  description = "URL of the speech samples bucket"
}

output "service_account_email" {
  value       = google_service_account.speech_api_sa.email
  description = "Email of the Speech API service account"
}

output "test_commands" {
  value = <<-EOT
# Test Speech API with the created resources:

# 1. Upload sample audio files:
gsutil cp brooklyn.flac gs://${google_storage_bucket.speech_samples.name}/
gsutil cp hello.wav gs://${google_storage_bucket.speech_samples.name}/

# 2. Test transcription:
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://speech.googleapis.com/v1/speech:recognize" \
  -d '{
    "config": {
      "encoding": "FLAC",
      "sampleRateHertz": 16000,
      "languageCode": "en-US"
    },
    "audio": {
      "uri": "gs://${google_storage_bucket.speech_samples.name}/brooklyn.flac"
    }
  }'

# 3. Monitor API usage:
gcloud logging read 'resource.type="api" AND resource.label.service="speech.googleapis.com"' --limit=10
EOT
}

output "bucket_public_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.speech_samples.name}"
  description = "Public URL for the speech samples bucket"
}
```

---

## 🐍 Python Automation Script

```python
#!/usr/bin/env python3
"""
Google Cloud Speech API Qwik Start Automation - Python Script
Author: CodeWithGarry
"""

import os
import json
import time
import subprocess
import requests
from pathlib import Path
from google.cloud import speech
from google.cloud import storage
from google.oauth2 import service_account

class SpeechAPIQuickStartLab:
    def __init__(self, project_id, region="us-central1"):
        self.project_id = project_id
        self.region = region
        self.bucket_name = f"{project_id}-speech-samples"
        self.sample_dir = Path("speech-samples")
        
        # Initialize clients
        self.speech_client = None
        self.storage_client = None
        
    def enable_apis(self):
        """Enable required APIs"""
        print("🔧 Enabling APIs...")
        apis = [
            "speech.googleapis.com",
            "storage.googleapis.com",
            "cloudresourcemanager.googleapis.com"
        ]
        
        for api in apis:
            result = subprocess.run([
                'gcloud', 'services', 'enable', api
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print(f"✅ {api} enabled")
            else:
                print(f"❌ Error enabling {api}: {result.stderr}")
                return False
        
        return True
    
    def initialize_clients(self):
        """Initialize Google Cloud clients"""
        try:
            self.speech_client = speech.SpeechClient()
            self.storage_client = storage.Client()
            print("✅ Google Cloud clients initialized")
            return True
        except Exception as e:
            print(f"❌ Error initializing clients: {str(e)}")
            return False
    
    def create_storage_bucket(self):
        """Create and configure storage bucket"""
        print("📦 Creating storage bucket...")
        
        try:
            # Create bucket
            bucket = self.storage_client.bucket(self.bucket_name)
            bucket.location = self.region
            bucket = self.storage_client.create_bucket(bucket, location=self.region)
            
            # Make bucket publicly readable
            policy = bucket.get_iam_policy()
            policy.bindings.append({
                "role": "roles/storage.objectViewer",
                "members": {"allUsers"}
            })
            bucket.set_iam_policy(policy)
            
            print(f"✅ Storage bucket created: {self.bucket_name}")
            return True
            
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"✅ Storage bucket already exists: {self.bucket_name}")
                return True
            else:
                print(f"❌ Error creating bucket: {str(e)}")
                return False
    
    def download_sample_audio(self):
        """Download sample audio files"""
        print("📥 Downloading sample audio files...")
        
        self.sample_dir.mkdir(exist_ok=True)
        
        sample_files = [
            {
                "url": "https://cloud.google.com/speech-to-text/docs/samples/brooklyn.flac",
                "filename": "brooklyn.flac",
                "format": "FLAC"
            },
            {
                "url": "https://cloud.google.com/speech-to-text/docs/samples/hello.wav",
                "filename": "hello.wav", 
                "format": "WAV"
            }
        ]
        
        downloaded_files = []
        
        for sample in sample_files:
            file_path = self.sample_dir / sample["filename"]
            
            try:
                response = requests.get(sample["url"], timeout=30)
                response.raise_for_status()
                
                with open(file_path, 'wb') as f:
                    f.write(response.content)
                
                downloaded_files.append({
                    "path": file_path,
                    "filename": sample["filename"],
                    "format": sample["format"]
                })
                
                print(f"✅ Downloaded {sample['filename']}")
                
            except Exception as e:
                print(f"❌ Error downloading {sample['filename']}: {str(e)}")
        
        return downloaded_files
    
    def upload_audio_files(self, audio_files):
        """Upload audio files to storage bucket"""
        print("📤 Uploading audio files to bucket...")
        
        bucket = self.storage_client.bucket(self.bucket_name)
        uploaded_files = []
        
        for audio_file in audio_files:
            try:
                blob_name = audio_file["filename"]
                blob = bucket.blob(blob_name)
                
                with open(audio_file["path"], 'rb') as f:
                    blob.upload_from_file(f)
                
                # Make file publicly readable
                blob.make_public()
                
                uploaded_files.append({
                    "uri": f"gs://{self.bucket_name}/{blob_name}",
                    "format": audio_file["format"],
                    "filename": blob_name
                })
                
                print(f"✅ Uploaded {blob_name}")
                
            except Exception as e:
                print(f"❌ Error uploading {audio_file['filename']}: {str(e)}")
        
        return uploaded_files
    
    def test_speech_recognition(self, audio_files):
        """Test speech recognition with various configurations"""
        print("🗣️ Testing speech recognition...")
        
        test_results = []
        
        for audio_file in audio_files:
            print(f"\n🎵 Testing {audio_file['filename']}...")
            
            try:
                # Configure recognition settings based on format
                if audio_file["format"] == "FLAC":
                    config = speech.RecognitionConfig(
                        encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
                        sample_rate_hertz=16000,
                        language_code="en-US",
                        enable_word_time_offsets=True,
                        enable_word_confidence=True,
                        enable_automatic_punctuation=True,
                        max_alternatives=3
                    )
                elif audio_file["format"] == "WAV":
                    config = speech.RecognitionConfig(
                        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
                        sample_rate_hertz=16000,
                        language_code="en-US",
                        enable_word_time_offsets=True,
                        enable_word_confidence=True
                    )
                else:
                    print(f"⚠️ Unsupported format: {audio_file['format']}")
                    continue
                
                # Create audio object
                audio = speech.RecognitionAudio(uri=audio_file["uri"])
                
                # Perform recognition
                response = self.speech_client.recognize(config=config, audio=audio)
                
                # Process results
                if response.results:
                    for i, result in enumerate(response.results):
                        alternative = result.alternatives[0]
                        
                        test_result = {
                            "filename": audio_file["filename"],
                            "format": audio_file["format"],
                            "transcript": alternative.transcript,
                            "confidence": alternative.confidence,
                            "word_count": len(alternative.words) if hasattr(alternative, 'words') else 0,
                            "alternatives": len(result.alternatives)
                        }
                        
                        test_results.append(test_result)
                        
                        print(f"✅ Transcript: {alternative.transcript}")
                        print(f"📊 Confidence: {alternative.confidence:.2f}")
                        
                        # Show word-level details for first few words
                        if hasattr(alternative, 'words') and alternative.words:
                            print("🔍 Word details (first 5):")
                            for word in alternative.words[:5]:
                                confidence = getattr(word, 'confidence', 'N/A')
                                print(f"  - {word.word}: {confidence}")
                else:
                    print(f"❌ No transcription results for {audio_file['filename']}")
                    test_results.append({
                        "filename": audio_file["filename"],
                        "format": audio_file["format"],
                        "error": "No results"
                    })
                
            except Exception as e:
                print(f"❌ Error processing {audio_file['filename']}: {str(e)}")
                test_results.append({
                    "filename": audio_file["filename"],
                    "format": audio_file["format"],
                    "error": str(e)
                })
        
        return test_results
    
    def test_advanced_features(self, audio_uri):
        """Test advanced Speech API features"""
        print("🚀 Testing advanced Speech API features...")
        
        advanced_tests = []
        
        # Test 1: Multiple language detection
        print("\n🌍 Testing multiple language detection...")
        try:
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
                sample_rate_hertz=16000,
                language_code="en-US",
                alternative_language_codes=["es-ES", "fr-FR", "de-DE"],
                enable_word_time_offsets=True
            )
            
            audio = speech.RecognitionAudio(uri=audio_uri)
            response = self.speech_client.recognize(config=config, audio=audio)
            
            if response.results:
                result = response.results[0]
                detected_language = getattr(result, 'language_code', 'en-US')
                
                advanced_tests.append({
                    "test": "multilingual_detection",
                    "status": "success",
                    "detected_language": detected_language,
                    "transcript": result.alternatives[0].transcript
                })
                
                print(f"✅ Detected language: {detected_language}")
            else:
                advanced_tests.append({
                    "test": "multilingual_detection",
                    "status": "failed",
                    "error": "No results"
                })
                
        except Exception as e:
            print(f"❌ Multilingual test error: {str(e)}")
            advanced_tests.append({
                "test": "multilingual_detection",
                "status": "error",
                "error": str(e)
            })
        
        # Test 2: Speech contexts (phrase hints)
        print("\n🎯 Testing speech contexts...")
        try:
            speech_contexts = [speech.SpeechContext(
                phrases=["Brooklyn", "New York", "borough", "CodeWithGarry"]
            )]
            
            config = speech.RecognitionConfig(
                encoding=speech.RecognitionConfig.AudioEncoding.FLAC,
                sample_rate_hertz=16000,
                language_code="en-US",
                speech_contexts=speech_contexts,
                enable_word_confidence=True
            )
            
            audio = speech.RecognitionAudio(uri=audio_uri)
            response = self.speech_client.recognize(config=config, audio=audio)
            
            if response.results:
                result = response.results[0]
                advanced_tests.append({
                    "test": "speech_contexts",
                    "status": "success",
                    "transcript": result.alternatives[0].transcript,
                    "confidence": result.alternatives[0].confidence
                })
                
                print(f"✅ Context-enhanced transcript: {result.alternatives[0].transcript}")
            else:
                advanced_tests.append({
                    "test": "speech_contexts",
                    "status": "failed",
                    "error": "No results"
                })
                
        except Exception as e:
            print(f"❌ Speech contexts test error: {str(e)}")
            advanced_tests.append({
                "test": "speech_contexts",
                "status": "error",
                "error": str(e)
            })
        
        return advanced_tests
    
    def generate_report(self, test_results, advanced_results):
        """Generate comprehensive test report"""
        print("📋 Generating test report...")
        
        report = {
            "project_id": self.project_id,
            "bucket_name": self.bucket_name,
            "test_timestamp": time.strftime("%Y-%m-%d %H:%M:%S UTC", time.gmtime()),
            "basic_tests": test_results,
            "advanced_tests": advanced_results,
            "summary": {
                "total_files_tested": len(test_results),
                "successful_transcriptions": len([r for r in test_results if "transcript" in r]),
                "average_confidence": 0,
                "advanced_features_tested": len(advanced_results)
            }
        }
        
        # Calculate average confidence
        confidences = [r["confidence"] for r in test_results if "confidence" in r]
        if confidences:
            report["summary"]["average_confidence"] = sum(confidences) / len(confidences)
        
        # Save report
        report_file = "speech_api_test_report.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"✅ Test report saved: {report_file}")
        
        # Print summary
        print("\n📊 Test Summary:")
        print(f"Files tested: {report['summary']['total_files_tested']}")
        print(f"Successful transcriptions: {report['summary']['successful_transcriptions']}")
        print(f"Average confidence: {report['summary']['average_confidence']:.2f}")
        print(f"Advanced features tested: {report['summary']['advanced_features_tested']}")
        
        return report
    
    def cleanup(self):
        """Clean up temporary files"""
        print("🧹 Cleaning up temporary files...")
        
        # Remove sample directory
        if self.sample_dir.exists():
            import shutil
            shutil.rmtree(self.sample_dir)
            print("✅ Sample files cleaned up")
    
    def run_complete_lab(self):
        """Run the complete Speech API lab"""
        print("🚀 Starting Speech API Qwik Start Lab Automation")
        print(f"📋 Project: {self.project_id}")
        print(f"📍 Region: {self.region}")
        print(f"🪣 Bucket: {self.bucket_name}")
        
        try:
            # Execute all tasks
            if not self.enable_apis():
                return False
            
            if not self.initialize_clients():
                return False
            
            if not self.create_storage_bucket():
                return False
            
            audio_files = self.download_sample_audio()
            if not audio_files:
                print("❌ Failed to download audio files")
                return False
            
            uploaded_files = self.upload_audio_files(audio_files)
            if not uploaded_files:
                print("❌ Failed to upload audio files")
                return False
            
            # Test speech recognition
            test_results = self.test_speech_recognition(uploaded_files)
            
            # Test advanced features with first FLAC file
            flac_files = [f for f in uploaded_files if f["format"] == "FLAC"]
            advanced_results = []
            if flac_files:
                advanced_results = self.test_advanced_features(flac_files[0]["uri"])
            
            # Generate report
            report = self.generate_report(test_results, advanced_results)
            
            # Cleanup
            self.cleanup()
            
            print("\n🎉 Speech API lab completed successfully!")
            print(f"🪣 Storage bucket: gs://{self.bucket_name}")
            print(f"📊 Test report: speech_api_test_report.json")
            print("🔍 Console: https://console.cloud.google.com/speech")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            return False

if __name__ == "__main__":
    import sys
    
    # Get project ID
    result = subprocess.run([
        'gcloud', 'config', 'get-value', 'project'
    ], capture_output=True, text=True)
    
    if result.returncode != 0:
        print("❌ Could not get project ID. Make sure gcloud is configured.")
        sys.exit(1)
    
    project_id = result.stdout.strip()
    
    # Run the lab
    lab = SpeechAPIQuickStartLab(project_id)
    success = lab.run_complete_lab()
    
    sys.exit(0 if success else 1)
```

---

## 🔗 Alternative Solutions

- **[GUI Solution](GUI-Solution.md)** - Step-by-step console instructions
- **[CLI Solution](CLI-Solution.md)** - Command-line approach

---

## 🎖️ Skills Boost Arcade

Complete Speech API automation for the **Skills Boost Arcade** program!

---

<div align="center">

**⚡ Pro Tip**: Automate Speech-to-Text workflows for scalable voice processing applications!

</div>
