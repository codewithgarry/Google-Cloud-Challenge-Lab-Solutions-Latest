#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Task 1
# Create Cloud Storage Bucket
# Author: CodeWithGarry
# Lab ID: ARC120
# =============================================================================

echo "=================================================================="
echo "  🚀 TASK 1: CREATE CLOUD STORAGE BUCKET"
echo "=================================================================="
echo ""

# Color codes for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get user inputs
echo "📋 Please provide the following information from your lab instructions:"
echo ""

# Bucket name input
while true; do
    read -p "🪣 Enter the BUCKET NAME (from your lab instructions): " BUCKET_NAME
    if [[ -n "$BUCKET_NAME" ]]; then
        break
    else
        print_error "Bucket name cannot be empty. Please try again."
    fi
done

# Region input with default
read -p "🌍 Enter the REGION [default: us-east4]: " REGION
REGION=${REGION:-us-east4}

# Location type input
echo ""
echo "📍 Select location type:"
echo "1) Multi-region (US)"
echo "2) Dual-region"  
echo "3) Single region"
read -p "Enter your choice (1-3) [default: 1]: " LOCATION_TYPE
LOCATION_TYPE=${LOCATION_TYPE:-1}

case $LOCATION_TYPE in
    1)
        LOCATION="us"
        LOCATION_DESC="Multi-region (US)"
        ;;
    2)
        LOCATION="us-east4"
        LOCATION_DESC="Dual-region"
        ;;
    3)
        LOCATION="$REGION"
        LOCATION_DESC="Single region ($REGION)"
        ;;
    *)
        LOCATION="us"
        LOCATION_DESC="Multi-region (US) [default]"
        ;;
esac

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "Bucket Name: $BUCKET_NAME"
echo "Location: $LOCATION ($LOCATION_DESC)"
echo "=================================================================="
echo ""

# Confirmation
read -p "❓ Do you want to proceed with this configuration? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_warning "Operation cancelled by user."
    exit 0
fi

echo ""
print_status "Starting bucket creation process..."

# Check if gcloud is installed and authenticated
print_status "Checking gcloud authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    print_error "You are not authenticated with gcloud."
    print_warning "Please run: gcloud auth login"
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
    print_error "No project is set."
    print_warning "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_status "Using project: $PROJECT_ID"

# Create the bucket
print_status "Creating Cloud Storage bucket: $BUCKET_NAME"
echo ""

if gsutil mb -l "$LOCATION" "gs://$BUCKET_NAME"; then
    echo ""
    print_status "✅ SUCCESS! Bucket '$BUCKET_NAME' created successfully!"
    
    # Verify bucket creation
    print_status "Verifying bucket creation..."
    if gsutil ls "gs://$BUCKET_NAME" >/dev/null 2>&1; then
        print_status "✅ Bucket verification successful!"
    else
        print_warning "Bucket created but verification failed."
    fi
    
    # Display bucket info
    echo ""
    echo "=================================================================="
    echo "🎉 TASK 1 COMPLETED SUCCESSFULLY!"
    echo "=================================================================="
    echo "Bucket Name: $BUCKET_NAME"
    echo "Location: $LOCATION ($LOCATION_DESC)"
    echo "Project: $PROJECT_ID"
    echo "URL: https://console.cloud.google.com/storage/browser/$BUCKET_NAME"
    echo "=================================================================="
    
else
    print_error "❌ Failed to create bucket '$BUCKET_NAME'"
    echo ""
    echo "Possible reasons:"
    echo "- Bucket name already exists globally"
    echo "- Insufficient permissions"
    echo "- Invalid bucket name format"
    echo ""
    print_warning "Please check your bucket name and try again."
    exit 1
fi

echo ""
print_status "🏁 Task 1 script execution completed!"
echo ""
