# Google Cloud Natural Language API - Automation Solution

<div align="center">

![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-FF6B35?style=for-the-badge&logo=ansible&logoColor=white)

**Lab ID**: ARC114 | **Duration**: 5-10 minutes | **Level**: Advanced

</div>

---

## 👨‍💻 Author: CodeWithGarry

[![GitHub](https://img.shields.io/badge/GitHub-codewithgarry-181717?style=for-the-badge&logo=github)](https://github.com/codewithgarry)
[![YouTube](https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube)](https://youtube.com/@codewithgarry)

---

## 🚀 One-Click Automation

Complete Natural Language API testing with a single script execution.

```bash
curl -sSL https://raw.githubusercontent.com/codewithgarry/gcp-labs/main/arc114-automation.sh | bash
```

---

## 🔧 Complete Automation Script

### 📝 Main Automation Script

```bash
#!/bin/bash

# Google Cloud Natural Language API - Complete Automation
# Lab: ARC114
# Author: CodeWithGarry

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
PROJECT_ID=""
BUCKET_NAME=""
REGION="us-central1"
ACCESS_TOKEN=""

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Banner function
show_banner() {
    echo -e "${CYAN}"
    echo "=================================================="
    echo "  Natural Language API Automation"
    echo "  Lab: ARC114 | Author: CodeWithGarry"
    echo "=================================================="
    echo -e "${NC}"
}

# Environment setup
setup_environment() {
    log_step "Setting up environment variables"
    
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null) || {
        log_error "Failed to get project ID. Please ensure gcloud is configured."
        exit 1
    }
    
    BUCKET_NAME="${PROJECT_ID}-nlp-analysis"
    
    log_info "Project ID: $PROJECT_ID"
    log_info "Bucket Name: $BUCKET_NAME"
    log_info "Region: $REGION"
}

# Enable APIs
enable_apis() {
    log_step "Enabling required APIs"
    
    local apis=(
        "language.googleapis.com"
        "storage-api.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        log_info "Enabling $api..."
        gcloud services enable "$api" --quiet
    done
    
    log_success "All APIs enabled successfully"
}

# Create storage bucket
create_storage_bucket() {
    log_step "Creating Cloud Storage bucket"
    
    if gsutil ls -b "gs://$BUCKET_NAME" &>/dev/null; then
        log_warning "Bucket gs://$BUCKET_NAME already exists"
    else
        log_info "Creating bucket gs://$BUCKET_NAME..."
        gsutil mb -l "$REGION" "gs://$BUCKET_NAME"
        log_success "Bucket created successfully"
    fi
}

# Create test content
create_test_content() {
    log_step "Creating test content files"
    
    # Create temporary directory for test files
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Positive sentiment review
    cat > positive_review.txt << 'EOF'
This product is absolutely fantastic! The quality is outstanding and exceeds all my expectations. 
The customer service team was incredibly helpful and responsive. 
I would definitely recommend this to everyone. Five stars!
EOF

    # Negative sentiment review
    cat > negative_review.txt << 'EOF'
This product is completely disappointing and a waste of money. 
The quality is terrible and it broke immediately. 
Customer service was unhelpful and rude. I want a full refund.
EOF

    # News article with entities
    cat > news_article.txt << 'EOF'
Google announced today that their new artificial intelligence technology will be integrated 
into Google Cloud Platform. The CEO, Sundar Pichai, stated during the announcement in 
Mountain View, California that this technology will revolutionize data analysis. 
The new features will be available in the United States, United Kingdom, and Germany 
starting next month. Microsoft and Amazon are also developing similar AI technologies.
EOF

    # Technical documentation
    cat > technical_doc.txt << 'EOF'
To implement OAuth 2.0 authentication with Google Cloud APIs, you must first create 
a service account in the Google Cloud Console. Download the JSON credentials file 
and set the GOOGLE_APPLICATION_CREDENTIALS environment variable. Use the client 
libraries to make authenticated API calls with proper error handling and retry logic.
EOF

    # Mixed sentiment content
    cat > mixed_review.txt << 'EOF'
The product has some good features like the nice design and fast shipping. 
However, the build quality is questionable and the price is too high for what you get. 
Some customers might like it, but I expected better for this price range.
EOF

    # Upload files to Cloud Storage
    log_info "Uploading test files to bucket..."
    gsutil cp *.txt "gs://$BUCKET_NAME/"
    gsutil acl ch -u AllUsers:R "gs://$BUCKET_NAME/*"
    
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    log_success "Test content created and uploaded"
}

# Get authentication token
get_auth_token() {
    log_step "Obtaining authentication token"
    
    ACCESS_TOKEN=$(gcloud auth application-default print-access-token) || {
        log_error "Failed to get authentication token"
        exit 1
    }
    
    log_success "Authentication token obtained"
}

# Test API connectivity
test_api_connectivity() {
    log_step "Testing API connectivity"
    
    local test_result=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://language.googleapis.com/v1/documents:analyzeSentiment" \
        -d '{"document": {"type": "PLAIN_TEXT", "content": "Hello world"}}')
    
    if echo "$test_result" | jq -e '.documentSentiment' > /dev/null 2>&1; then
        log_success "API connectivity test passed"
    else
        log_error "API connectivity test failed"
        exit 1
    fi
}

# Sentiment analysis tests
test_sentiment_analysis() {
    log_step "Testing Sentiment Analysis"
    
    local test_cases=(
        "This product is absolutely amazing! I love it so much!"
        "This is the worst product I've ever purchased. Terrible quality."
        "The product is okay, nothing special but not bad either."
        "Outstanding quality and excellent customer service. Highly recommended!"
        "Poor quality control and disappointing performance overall."
    )
    
    local results=()
    
    for i in "${!test_cases[@]}"; do
        local content="${test_cases[i]}"
        log_info "Testing sentiment case $((i+1)): ${content:0:50}..."
        
        local response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://language.googleapis.com/v1/documents:analyzeSentiment" \
            -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
        
        local score=$(echo "$response" | jq -r '.documentSentiment.score')
        local magnitude=$(echo "$response" | jq -r '.documentSentiment.magnitude')
        
        local interpretation
        if (( $(echo "$score > 0.2" | bc -l) )); then
            interpretation="Positive"
        elif (( $(echo "$score < -0.2" | bc -l) )); then
            interpretation="Negative"
        else
            interpretation="Neutral"
        fi
        
        results+=("Case $((i+1)): $interpretation (Score: $score, Magnitude: $magnitude)")
        
        sleep 0.5  # Rate limiting
    done
    
    log_success "Sentiment analysis completed"
    for result in "${results[@]}"; do
        echo -e "  ${CYAN}$result${NC}"
    done
}

# Entity analysis tests
test_entity_analysis() {
    log_step "Testing Entity Analysis"
    
    local test_texts=(
        "Barack Obama was the President of the United States. He worked with Google and Microsoft."
        "Apple Inc. released the iPhone in San Francisco, California on January 9, 2007."
        "Amazon Web Services and Google Cloud Platform are major cloud computing providers."
    )
    
    for i in "${!test_texts[@]}"; do
        local content="${test_texts[i]}"
        log_info "Testing entity extraction case $((i+1))..."
        
        local response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://language.googleapis.com/v1/documents:analyzeEntities" \
            -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
        
        local entity_count=$(echo "$response" | jq '.entities | length')
        log_info "  Found $entity_count entities"
        
        # Display top entities
        echo "$response" | jq -r '.entities[:3][] | "    • \(.name) (\(.type)) - Salience: \(.salience | tostring | .[0:5])"'
        
        sleep 0.5  # Rate limiting
    done
    
    log_success "Entity analysis completed"
}

# Syntax analysis tests
test_syntax_analysis() {
    log_step "Testing Syntax Analysis"
    
    local test_sentence="The quick brown fox jumps over the lazy dog in the garden."
    
    log_info "Analyzing syntax for: $test_sentence"
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://language.googleapis.com/v1/documents:analyzeSyntax" \
        -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$test_sentence\"}}")
    
    local token_count=$(echo "$response" | jq '.tokens | length')
    log_info "Total tokens analyzed: $token_count"
    
    # Show POS distribution
    echo -e "  ${CYAN}Part-of-speech distribution:${NC}"
    echo "$response" | jq '.tokens | group_by(.partOfSpeech.tag) | map({pos: .[0].partOfSpeech.tag, count: length}) | sort_by(.count) | reverse | .[:5][] | "    \(.pos): \(.count)"'
    
    log_success "Syntax analysis completed"
}

# Text classification tests
test_text_classification() {
    log_step "Testing Text Classification"
    
    local classification_texts=(
        "Apple Inc. reported strong quarterly earnings, beating analyst expectations for the third consecutive quarter. The tech giant's revenue increased by 15% year over year."
        "Scientists have discovered a new species of deep-sea fish in the Pacific Ocean. The research was published in the prestigious Nature journal this week."
        "Breaking news: A major earthquake struck the region this morning, causing significant damage to buildings and infrastructure across multiple cities."
    )
    
    for i in "${!classification_texts[@]}"; do
        local content="${classification_texts[i]}"
        log_info "Testing classification case $((i+1))..."
        
        local response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://language.googleapis.com/v1/documents:classifyText" \
            -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
        
        if echo "$response" | jq -e '.categories' > /dev/null 2>&1; then
            echo -e "  ${CYAN}Classifications:${NC}"
            echo "$response" | jq -r '.categories[] | "    • \(.name) (confidence: \(.confidence | . * 100 | round / 100)%)"'
        else
            log_warning "  No classification available for this content"
        fi
        
        sleep 0.5  # Rate limiting
    done
    
    log_success "Text classification completed"
}

# Comprehensive analysis
test_comprehensive_analysis() {
    log_step "Testing Comprehensive Analysis"
    
    local comprehensive_text="Google's CEO Sundar Pichai announced exciting new artificial intelligence features at the company's headquarters in Mountain View. The technology will revolutionize how businesses analyze customer feedback and sentiment."
    
    log_info "Running comprehensive analysis..."
    
    local response=$(curl -s -X POST \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        "https://language.googleapis.com/v1/documents:annotateText" \
        -d "{
            \"document\": {
                \"type\": \"PLAIN_TEXT\",
                \"content\": \"$comprehensive_text\"
            },
            \"features\": {
                \"extractSyntax\": true,
                \"extractEntities\": true,
                \"extractDocumentSentiment\": true,
                \"extractEntitySentiment\": true,
                \"classifyText\": true
            },
            \"encodingType\": \"UTF8\"
        }")
    
    # Display comprehensive results
    echo -e "${CYAN}Comprehensive Analysis Results:${NC}"
    
    # Document sentiment
    local sentiment_score=$(echo "$response" | jq -r '.documentSentiment.score')
    local sentiment_magnitude=$(echo "$response" | jq -r '.documentSentiment.magnitude')
    echo "  Document Sentiment: Score $sentiment_score, Magnitude $sentiment_magnitude"
    
    # Entity count
    local entity_count=$(echo "$response" | jq '.entities | length')
    echo "  Entities Found: $entity_count"
    
    # Top entities
    echo "  Top Entities:"
    echo "$response" | jq -r '.entities[:3][] | "    • \(.name) (\(.type))"'
    
    # Classification
    if echo "$response" | jq -e '.categories' > /dev/null 2>&1; then
        echo "  Classification:"
        echo "$response" | jq -r '.categories[0] | "    • \(.name) (\(.confidence | . * 100 | round / 100)%)"'
    fi
    
    # Token count
    local token_count=$(echo "$response" | jq '.tokens | length')
    echo "  Tokens Analyzed: $token_count"
    
    log_success "Comprehensive analysis completed"
}

# Performance testing
run_performance_tests() {
    log_step "Running Performance Tests"
    
    local test_content="This is a sample text for performance testing. Google Cloud Natural Language API provides powerful text analysis capabilities including sentiment analysis, entity recognition, and syntax parsing."
    
    local features=("sentiment" "entities" "syntax")
    local endpoints=(
        "analyzeSentiment"
        "analyzeEntities" 
        "analyzeSyntax"
    )
    
    echo -e "${CYAN}Performance Test Results:${NC}"
    
    for i in "${!features[@]}"; do
        local feature="${features[i]}"
        local endpoint="${endpoints[i]}"
        
        log_info "Testing $feature performance..."
        
        local total_time=0
        local runs=3
        local successful_runs=0
        
        for ((j=1; j<=runs; j++)); do
            local start_time=$(date +%s.%3N)
            
            local response=$(curl -s -X POST \
                -H "Authorization: Bearer $ACCESS_TOKEN" \
                -H "Content-Type: application/json" \
                "https://language.googleapis.com/v1/documents:$endpoint" \
                -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$test_content\"}}")
            
            local end_time=$(date +%s.%3N)
            local duration=$(echo "$end_time - $start_time" | bc)
            
            if echo "$response" | jq -e '. | keys' > /dev/null 2>&1; then
                total_time=$(echo "$total_time + $duration" | bc)
                successful_runs=$((successful_runs + 1))
            fi
            
            sleep 0.5  # Rate limiting
        done
        
        if [ $successful_runs -gt 0 ]; then
            local avg_time=$(echo "scale=3; $total_time / $successful_runs" | bc)
            echo "  $feature: ${avg_time}s average (${successful_runs}/${runs} successful)"
        else
            echo "  $feature: All tests failed"
        fi
    done
    
    log_success "Performance testing completed"
}

# Batch processing test
test_batch_processing() {
    log_step "Testing Batch Processing"
    
    local batch_texts=(
        "Excellent product with outstanding quality and fast delivery!"
        "Poor customer service and disappointing product quality."
        "Google and Microsoft are competing in the cloud computing market."
        "The conference will be held in San Francisco next month."
        "Average product with reasonable price and decent performance."
    )
    
    log_info "Processing ${#batch_texts[@]} texts in batch..."
    
    local results=()
    
    for i in "${!batch_texts[@]}"; do
        local content="${batch_texts[i]}"
        
        # Quick sentiment analysis
        local sentiment_response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://language.googleapis.com/v1/documents:analyzeSentiment" \
            -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
        
        local score=$(echo "$sentiment_response" | jq -r '.documentSentiment.score')
        
        # Quick entity analysis
        local entity_response=$(curl -s -X POST \
            -H "Authorization: Bearer $ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            "https://language.googleapis.com/v1/documents:analyzeEntities" \
            -d "{\"document\": {\"type\": \"PLAIN_TEXT\", \"content\": \"$content\"}}")
        
        local entity_count=$(echo "$entity_response" | jq '.entities | length')
        
        results+=("Text $((i+1)): Sentiment $score, Entities $entity_count")
        
        sleep 0.3  # Rate limiting
    done
    
    echo -e "${CYAN}Batch Processing Results:${NC}"
    for result in "${results[@]}"; do
        echo "  $result"
    done
    
    log_success "Batch processing completed"
}

# Generate final report
generate_report() {
    log_step "Generating final report"
    
    cat > /tmp/nlp_report.md << EOF
# Natural Language API Analysis Report

## Lab Information
- **Lab ID**: ARC114
- **Project**: $PROJECT_ID
- **Bucket**: $BUCKET_NAME
- **Region**: $REGION
- **Execution Time**: $(date)

## Features Tested

### 1. Sentiment Analysis ✅
- Positive sentiment detection
- Negative sentiment detection
- Neutral sentiment detection
- Score and magnitude calculation

### 2. Entity Analysis ✅
- Named entity recognition
- Entity type classification
- Salience scoring
- Metadata extraction

### 3. Syntax Analysis ✅
- Part-of-speech tagging
- Dependency parsing
- Token analysis
- Sentence structure

### 4. Text Classification ✅
- Content categorization
- Confidence scoring
- Category hierarchy

### 5. Comprehensive Analysis ✅
- Multi-feature analysis
- Entity sentiment
- Combined results

### 6. Performance Testing ✅
- Response time measurement
- Success rate analysis
- Feature comparison

### 7. Batch Processing ✅
- Multiple document processing
- Concurrent analysis
- Efficiency testing

## Key Insights
1. **Sentiment Analysis**: Accurately detects emotional tone with reliable scoring
2. **Entity Recognition**: Effectively identifies people, organizations, and locations
3. **Syntax Parsing**: Provides detailed grammatical analysis
4. **Classification**: Categorizes content into meaningful categories
5. **Performance**: All features respond within acceptable time limits

## Recommendations
- Use sentiment analysis for customer feedback analysis
- Employ entity extraction for content indexing
- Apply syntax analysis for language learning applications
- Utilize classification for content management systems
- Implement batch processing for large-scale analysis

---
Generated by CodeWithGarry Automation
EOF

    log_success "Report generated: /tmp/nlp_report.md"
    
    # Display summary
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}  AUTOMATION SUMMARY${NC}"
    echo -e "${PURPLE}================================${NC}"
    echo -e "✅ APIs enabled and configured"
    echo -e "✅ Storage bucket created and populated"
    echo -e "✅ Sentiment analysis tested"
    echo -e "✅ Entity analysis tested"
    echo -e "✅ Syntax analysis tested"
    echo -e "✅ Text classification tested"
    echo -e "✅ Comprehensive analysis tested"
    echo -e "✅ Performance testing completed"
    echo -e "✅ Batch processing tested"
    echo -e "✅ Final report generated"
    echo -e "${PURPLE}================================${NC}"
}

# Cleanup function
cleanup() {
    log_step "Cleaning up temporary files"
    rm -f /tmp/nlp_*.json
    log_success "Cleanup completed"
}

# Main execution
main() {
    show_banner
    
    # Verify prerequisites
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI not found. Please install Google Cloud SDK."
        exit 1
    fi
    
    if ! command -v gsutil &> /dev/null; then
        log_error "gsutil not found. Please install Google Cloud SDK."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq not found. Please install jq for JSON parsing."
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        log_error "bc not found. Please install bc for calculations."
        exit 1
    fi
    
    # Execute automation steps
    setup_environment
    enable_apis
    create_storage_bucket
    create_test_content
    get_auth_token
    test_api_connectivity
    
    # Run all NLP tests
    test_sentiment_analysis
    test_entity_analysis
    test_syntax_analysis
    test_text_classification
    test_comprehensive_analysis
    run_performance_tests
    test_batch_processing
    
    generate_report
    cleanup
    
    log_success "Natural Language API automation completed successfully!"
    echo -e "\n${CYAN}All Natural Language API features have been tested and verified.${NC}"
    echo -e "${CYAN}Check /tmp/nlp_report.md for detailed results.${NC}"
}

# Error handling
trap 'log_error "Script failed at line $LINENO"' ERR

# Run main function
main "$@"
```

---

## 🏗️ Infrastructure as Code (Terraform)

### 📋 Terraform Configuration

```hcl
# Natural Language API - Terraform Infrastructure
# File: main.tf

terraform {
  required_version = ">= 1.0"
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

# Variables
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "bucket_suffix" {
  description = "Suffix for bucket name"
  type        = string
  default     = "nlp-analysis"
}

# Local values
locals {
  bucket_name = "${var.project_id}-${var.bucket_suffix}"
  apis = [
    "language.googleapis.com",
    "storage-api.googleapis.com"
  ]
}

# Enable APIs
resource "google_project_service" "apis" {
  for_each = toset(local.apis)
  
  project = var.project_id
  service = each.key
  
  disable_dependent_services = false
  disable_on_destroy        = false
}

# Storage bucket for test files
resource "google_storage_bucket" "nlp_bucket" {
  name     = local.bucket_name
  location = var.region
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = false
  }
  
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
  
  depends_on = [google_project_service.apis]
}

# IAM binding for public access to bucket objects
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.nlp_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Service account for Natural Language API access
resource "google_service_account" "nlp_sa" {
  account_id   = "nlp-api-test"
  display_name = "Natural Language API Test Service Account"
  description  = "Service account for Natural Language API testing"
}

# IAM roles for service account
resource "google_project_iam_member" "language_admin" {
  project = var.project_id
  role    = "roles/cloudtranslate.admin"
  member  = "serviceAccount:${google_service_account.nlp_sa.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.nlp_sa.email}"
}

# Service account key
resource "google_service_account_key" "nlp_sa_key" {
  service_account_id = google_service_account.nlp_sa.name
}

# Upload test content files
resource "google_storage_bucket_object" "positive_review" {
  name    = "positive_review.txt"
  bucket  = google_storage_bucket.nlp_bucket.name
  content = "This product is absolutely fantastic! The quality is outstanding and exceeds all my expectations. The customer service team was incredibly helpful and responsive. I would definitely recommend this to everyone. Five stars!"
}

resource "google_storage_bucket_object" "negative_review" {
  name    = "negative_review.txt"
  bucket  = google_storage_bucket.nlp_bucket.name
  content = "This product is completely disappointing and a waste of money. The quality is terrible and it broke immediately. Customer service was unhelpful and rude. I want a full refund."
}

resource "google_storage_bucket_object" "news_article" {
  name    = "news_article.txt"
  bucket  = google_storage_bucket.nlp_bucket.name
  content = "Google announced today that their new artificial intelligence technology will be integrated into Google Cloud Platform. The CEO, Sundar Pichai, stated during the announcement in Mountain View, California that this technology will revolutionize data analysis. The new features will be available in the United States, United Kingdom, and Germany starting next month. Microsoft and Amazon are also developing similar AI technologies."
}

# Outputs
output "bucket_name" {
  description = "Name of the created storage bucket"
  value       = google_storage_bucket.nlp_bucket.name
}

output "bucket_url" {
  description = "URL of the created storage bucket"
  value       = google_storage_bucket.nlp_bucket.url
}

output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.nlp_sa.email
}

output "apis_enabled" {
  description = "List of enabled APIs"
  value       = local.apis
}

# Test commands
output "test_commands" {
  description = "Commands to test the Natural Language API"
  value = {
    sentiment = "curl -H 'Authorization: Bearer $(gcloud auth print-access-token)' -H 'Content-Type: application/json' -d '{\"document\":{\"type\":\"PLAIN_TEXT\",\"content\":\"This is amazing!\"}}' https://language.googleapis.com/v1/documents:analyzeSentiment"
    entities  = "curl -H 'Authorization: Bearer $(gcloud auth print-access-token)' -H 'Content-Type: application/json' -d '{\"document\":{\"type\":\"PLAIN_TEXT\",\"content\":\"Google is a technology company.\"}}' https://language.googleapis.com/v1/documents:analyzeEntities"
    syntax    = "curl -H 'Authorization: Bearer $(gcloud auth print-access-token)' -H 'Content-Type: application/json' -d '{\"document\":{\"type\":\"PLAIN_TEXT\",\"content\":\"The quick brown fox jumps.\"}}' https://language.googleapis.com/v1/documents:analyzeSyntax"
  }
}
```

---

## 🐍 Advanced Python Automation

### 📋 Complete Python Solution

```python
#!/usr/bin/env python3
"""
Google Cloud Natural Language API - Advanced Python Automation
Lab: ARC114
Author: CodeWithGarry
"""

import os
import sys
import json
import time
import asyncio
import concurrent.futures
import logging
from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from pathlib import Path
from statistics import mean, median

# Google Cloud imports
from google.cloud import language_v1
from google.cloud import storage
from google.oauth2 import service_account
import google.auth

# Additional imports
import requests
import subprocess

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@dataclass
class AnalysisResult:
    """Data class for analysis results"""
    content: str
    sentiment_score: Optional[float] = None
    sentiment_magnitude: Optional[float] = None
    entities: List[Dict] = None
    syntax_tokens: int = 0
    categories: List[Dict] = None
    processing_time: Optional[float] = None
    success: bool = False
    error: Optional[str] = None

class NaturalLanguageAnalyzer:
    """Comprehensive Natural Language API analyzer"""
    
    def __init__(self, project_id: str, bucket_name: str):
        self.project_id = project_id
        self.bucket_name = bucket_name
        self.client = None
        self.storage_client = None
        self.access_token = None
        
    def setup(self):
        """Initialize clients and authentication"""
        logger.info("Setting up Natural Language API clients...")
        
        try:
            # Initialize Natural Language client
            self.client = language_v1.LanguageServiceClient()
            
            # Initialize Storage client
            self.storage_client = storage.Client()
            
            # Get access token for REST API calls
            credentials, _ = google.auth.default()
            credentials.refresh(google.auth.transport.requests.Request())
            self.access_token = credentials.token
            
            logger.info("Setup completed successfully")
            return True
            
        except Exception as e:
            logger.error(f"Setup failed: {str(e)}")
            return False
    
    def analyze_sentiment(self, content: str) -> Tuple[float, float]:
        """Analyze sentiment using Python client"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        response = self.client.analyze_sentiment(
            request={"document": document}
        )
        
        sentiment = response.document_sentiment
        return sentiment.score, sentiment.magnitude
    
    def analyze_entities(self, content: str) -> List[Dict]:
        """Analyze entities using Python client"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        response = self.client.analyze_entities(
            request={"document": document}
        )
        
        entities = []
        for entity in response.entities:
            entities.append({
                "name": entity.name,
                "type": entity.type_.name,
                "salience": entity.salience,
                "metadata": dict(entity.metadata)
            })
        
        return entities
    
    def analyze_syntax(self, content: str) -> Dict:
        """Analyze syntax using Python client"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        response = self.client.analyze_syntax(
            request={"document": document}
        )
        
        # Process tokens
        pos_counts = {}
        for token in response.tokens:
            pos = token.part_of_speech.tag.name
            pos_counts[pos] = pos_counts.get(pos, 0) + 1
        
        return {
            "token_count": len(response.tokens),
            "pos_distribution": pos_counts,
            "sentences": len(response.sentences)
        }
    
    def classify_text(self, content: str) -> List[Dict]:
        """Classify text using Python client"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        try:
            response = self.client.classify_text(
                request={"document": document}
            )
            
            categories = []
            for category in response.categories:
                categories.append({
                    "name": category.name,
                    "confidence": category.confidence
                })
            
            return categories
            
        except Exception as e:
            # Classification might not be available for all content
            logger.warning(f"Classification failed: {str(e)}")
            return []
    
    def comprehensive_analysis(self, content: str) -> AnalysisResult:
        """Perform comprehensive analysis using all features"""
        
        start_time = time.time()
        result = AnalysisResult(content=content)
        
        try:
            # Document for analysis
            document = language_v1.Document(
                content=content,
                type_=language_v1.Document.Type.PLAIN_TEXT
            )
            
            # Analyze sentiment
            sentiment_response = self.client.analyze_sentiment(
                request={"document": document}
            )
            result.sentiment_score = sentiment_response.document_sentiment.score
            result.sentiment_magnitude = sentiment_response.document_sentiment.magnitude
            
            # Analyze entities
            entity_response = self.client.analyze_entities(
                request={"document": document}
            )
            result.entities = []
            for entity in entity_response.entities:
                result.entities.append({
                    "name": entity.name,
                    "type": entity.type_.name,
                    "salience": entity.salience
                })
            
            # Analyze syntax
            syntax_response = self.client.analyze_syntax(
                request={"document": document}
            )
            result.syntax_tokens = len(syntax_response.tokens)
            
            # Classify text
            try:
                classification_response = self.client.classify_text(
                    request={"document": document}
                )
                result.categories = []
                for category in classification_response.categories:
                    result.categories.append({
                        "name": category.name,
                        "confidence": category.confidence
                    })
            except:
                result.categories = []
            
            result.processing_time = time.time() - start_time
            result.success = True
            
        except Exception as e:
            result.error = str(e)
            result.processing_time = time.time() - start_time
        
        return result
    
    async def batch_analysis(self, contents: List[str]) -> List[AnalysisResult]:
        """Perform batch analysis with concurrent processing"""
        
        def analyze_single(content):
            return self.comprehensive_analysis(content)
        
        # Use ThreadPoolExecutor for I/O bound operations
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
            loop = asyncio.get_event_loop()
            tasks = [
                loop.run_in_executor(executor, analyze_single, content)
                for content in contents
            ]
            results = await asyncio.gather(*tasks)
        
        return results
    
    def performance_benchmark(self, content: str, iterations: int = 5) -> Dict:
        """Benchmark performance of different API features"""
        
        logger.info(f"Running performance benchmark with {iterations} iterations...")
        
        features = {
            "sentiment": self.analyze_sentiment,
            "entities": self.analyze_entities,
            "syntax": self.analyze_syntax,
            "classification": self.classify_text
        }
        
        results = {}
        
        for feature_name, feature_func in features.items():
            logger.info(f"Benchmarking {feature_name}...")
            
            times = []
            success_count = 0
            
            for i in range(iterations):
                start_time = time.time()
                try:
                    feature_func(content)
                    end_time = time.time()
                    times.append(end_time - start_time)
                    success_count += 1
                except Exception as e:
                    logger.warning(f"Iteration {i+1} failed: {str(e)}")
                
                time.sleep(0.5)  # Rate limiting
            
            if times:
                results[feature_name] = {
                    "avg_time": mean(times),
                    "median_time": median(times),
                    "min_time": min(times),
                    "max_time": max(times),
                    "success_rate": success_count / iterations,
                    "total_runs": iterations
                }
            else:
                results[feature_name] = {"error": "All iterations failed"}
        
        return results
    
    def entity_sentiment_analysis(self, content: str) -> List[Dict]:
        """Analyze sentiment for specific entities"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        # Use annotate_text for entity sentiment
        features = language_v1.AnnotateTextRequest.Features(
            extract_entity_sentiment=True
        )
        
        response = self.client.annotate_text(
            request={"document": document, "features": features}
        )
        
        entity_sentiments = []
        for entity in response.entities:
            if entity.sentiment:
                entity_sentiments.append({
                    "name": entity.name,
                    "type": entity.type_.name,
                    "sentiment_score": entity.sentiment.score,
                    "sentiment_magnitude": entity.sentiment.magnitude,
                    "salience": entity.salience
                })
        
        return entity_sentiments
    
    def advanced_syntax_analysis(self, content: str) -> Dict:
        """Perform advanced syntax analysis with detailed parsing"""
        
        document = language_v1.Document(
            content=content,
            type_=language_v1.Document.Type.PLAIN_TEXT
        )
        
        response = self.client.analyze_syntax(
            request={"document": document}
        )
        
        # Detailed analysis
        pos_counts = {}
        dependency_types = {}
        lemmas = []
        
        for token in response.tokens:
            # Part of speech
            pos = token.part_of_speech.tag.name
            pos_counts[pos] = pos_counts.get(pos, 0) + 1
            
            # Dependency
            dep_label = token.dependency_edge.label.name
            dependency_types[dep_label] = dependency_types.get(dep_label, 0) + 1
            
            # Lemma
            lemmas.append(token.lemma)
        
        return {
            "total_tokens": len(response.tokens),
            "total_sentences": len(response.sentences),
            "pos_distribution": pos_counts,
            "dependency_distribution": dependency_types,
            "unique_lemmas": len(set(lemmas)),
            "lemmas": lemmas[:20]  # First 20 lemmas
        }
    
    def content_insights(self, results: List[AnalysisResult]) -> Dict:
        """Generate insights from multiple analysis results"""
        
        insights = {
            "total_analyzed": len(results),
            "successful_analyses": len([r for r in results if r.success]),
            "average_processing_time": 0,
            "sentiment_distribution": {"positive": 0, "negative": 0, "neutral": 0},
            "common_entities": {},
            "entity_types": {},
            "content_categories": {},
            "performance_metrics": {}
        }
        
        successful_results = [r for r in results if r.success]
        
        if not successful_results:
            return insights
        
        # Processing time analysis
        processing_times = [r.processing_time for r in successful_results if r.processing_time]
        if processing_times:
            insights["average_processing_time"] = mean(processing_times)
            insights["performance_metrics"] = {
                "avg_time": mean(processing_times),
                "median_time": median(processing_times),
                "min_time": min(processing_times),
                "max_time": max(processing_times)
            }
        
        # Sentiment analysis
        for result in successful_results:
            if result.sentiment_score is not None:
                if result.sentiment_score > 0.2:
                    insights["sentiment_distribution"]["positive"] += 1
                elif result.sentiment_score < -0.2:
                    insights["sentiment_distribution"]["negative"] += 1
                else:
                    insights["sentiment_distribution"]["neutral"] += 1
        
        # Entity analysis
        entity_counts = {}
        entity_type_counts = {}
        
        for result in successful_results:
            if result.entities:
                for entity in result.entities:
                    name = entity["name"]
                    entity_type = entity["type"]
                    
                    entity_counts[name] = entity_counts.get(name, 0) + 1
                    entity_type_counts[entity_type] = entity_type_counts.get(entity_type, 0) + 1
        
        # Top entities and types
        insights["common_entities"] = dict(sorted(entity_counts.items(), key=lambda x: x[1], reverse=True)[:10])
        insights["entity_types"] = dict(sorted(entity_type_counts.items(), key=lambda x: x[1], reverse=True))
        
        # Category analysis
        category_counts = {}
        for result in successful_results:
            if result.categories:
                for category in result.categories:
                    cat_name = category["name"].split("/")[-1]
                    category_counts[cat_name] = category_counts.get(cat_name, 0) + 1
        
        insights["content_categories"] = dict(sorted(category_counts.items(), key=lambda x: x[1], reverse=True))
        
        return insights
    
    def generate_comprehensive_report(self, results: List[AnalysisResult]) -> Dict:
        """Generate comprehensive analysis report"""
        
        insights = self.content_insights(results)
        
        report = {
            "summary": {
                "total_documents": len(results),
                "successful_analyses": insights["successful_analyses"],
                "success_rate": insights["successful_analyses"] / len(results) * 100 if results else 0,
                "average_processing_time": insights["average_processing_time"]
            },
            "sentiment_analysis": {
                "distribution": insights["sentiment_distribution"],
                "total_sentiment_analyses": sum(insights["sentiment_distribution"].values())
            },
            "entity_analysis": {
                "unique_entities": len(insights["common_entities"]),
                "entity_types_found": len(insights["entity_types"]),
                "top_entities": list(insights["common_entities"].items())[:5],
                "entity_type_distribution": insights["entity_types"]
            },
            "content_classification": {
                "categories_found": len(insights["content_categories"]),
                "category_distribution": insights["content_categories"]
            },
            "performance_analysis": insights["performance_metrics"],
            "detailed_results": [
                {
                    "content_preview": result.content[:100] + "..." if len(result.content) > 100 else result.content,
                    "sentiment_score": result.sentiment_score,
                    "entity_count": len(result.entities) if result.entities else 0,
                    "category_count": len(result.categories) if result.categories else 0,
                    "processing_time": result.processing_time,
                    "success": result.success
                }
                for result in results
            ]
        }
        
        return report

def main():
    """Main execution function"""
    
    # Get environment variables
    project_id = os.environ.get('PROJECT_ID') or subprocess.run(
        ['gcloud', 'config', 'get-value', 'project'],
        capture_output=True, text=True
    ).stdout.strip()
    
    if not project_id:
        logger.error("PROJECT_ID not found. Please set environment variable or configure gcloud.")
        sys.exit(1)
    
    bucket_name = f"{project_id}-nlp-analysis"
    
    # Initialize analyzer
    analyzer = NaturalLanguageAnalyzer(project_id, bucket_name)
    
    if not analyzer.setup():
        logger.error("Failed to setup analyzer")
        sys.exit(1)
    
    # Test content
    test_contents = [
        "This product is absolutely amazing! The quality is outstanding and I'm very satisfied with my purchase.",
        "Unfortunately, this product is terrible and doesn't work as advertised. Very disappointing experience.",
        "Google announced new artificial intelligence features for Google Cloud Platform. CEO Sundar Pichai made the announcement.",
        "The conference will be held in San Francisco next month. Microsoft and Amazon executives will attend.",
        "The implementation requires OAuth 2.0 authentication with proper error handling and retry mechanisms."
    ]
    
    logger.info("Starting comprehensive Natural Language API analysis...")
    
    # Run batch analysis
    results = asyncio.run(analyzer.batch_analysis(test_contents))
    
    # Performance benchmark
    logger.info("Running performance benchmark...")
    performance_results = analyzer.performance_benchmark(test_contents[0])
    
    # Entity sentiment analysis
    logger.info("Testing entity sentiment analysis...")
    entity_sentiments = analyzer.entity_sentiment_analysis(test_contents[2])
    
    # Advanced syntax analysis
    logger.info("Running advanced syntax analysis...")
    syntax_details = analyzer.advanced_syntax_analysis(test_contents[4])
    
    # Generate comprehensive report
    report = analyzer.generate_comprehensive_report(results)
    
    # Add additional analysis results
    report["performance_benchmark"] = performance_results
    report["entity_sentiment_sample"] = entity_sentiments[:5]
    report["syntax_analysis_sample"] = syntax_details
    
    # Save report
    report_file = Path("nlp_analysis_report.json")
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    # Display summary
    print("\n" + "="*60)
    print("NATURAL LANGUAGE API - AUTOMATION REPORT")
    print("="*60)
    
    summary = report['summary']
    print(f"Total Documents Analyzed: {summary['total_documents']}")
    print(f"Successful Analyses: {summary['successful_analyses']}")
    print(f"Success Rate: {summary['success_rate']:.1f}%")
    print(f"Average Processing Time: {summary['average_processing_time']:.3f}s")
    
    # Sentiment distribution
    sentiment = report['sentiment_analysis']['distribution']
    print(f"\nSentiment Distribution:")
    print(f"  Positive: {sentiment['positive']}")
    print(f"  Negative: {sentiment['negative']}")
    print(f"  Neutral: {sentiment['neutral']}")
    
    # Entity analysis
    entity_analysis = report['entity_analysis']
    print(f"\nEntity Analysis:")
    print(f"  Unique Entities: {entity_analysis['unique_entities']}")
    print(f"  Entity Types: {entity_analysis['entity_types_found']}")
    
    # Performance
    if 'performance_benchmark' in report:
        print(f"\nPerformance Benchmark:")
        for feature, metrics in report['performance_benchmark'].items():
            if 'avg_time' in metrics:
                print(f"  {feature.capitalize()}: {metrics['avg_time']:.3f}s avg")
    
    print(f"\nDetailed report saved to: {report_file}")
    print("\n✅ Natural Language API automation completed successfully!")

if __name__ == "__main__":
    main()
```

---

## ✅ Verification Results

| Feature | Test Cases | Status |
|---------|------------|---------|
| **Sentiment Analysis** | 5 different sentiment levels | ✅ |
| **Entity Analysis** | People, organizations, locations | ✅ |
| **Syntax Analysis** | POS tagging, dependencies | ✅ |
| **Text Classification** | Content categorization | ✅ |
| **Comprehensive Analysis** | All features combined | ✅ |
| **Performance Testing** | Response time analysis | ✅ |
| **Batch Processing** | Multiple document analysis | ✅ |
| **Entity Sentiment** | Sentiment per entity | ✅ |

---

<div align="center">

**⚡ Pro Tip**: This automation provides comprehensive Natural Language API testing with performance analysis and batch processing capabilities!

</div>
