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
echo "💡 Press ENTER to use default values (recommended for quick completion)"
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

# Zone input with default
read -p "🎯 Enter the ZONE [default: us-east4-a]: " ZONE
ZONE=${ZONE:-us-east4-a}

# Storage class selection
echo ""
echo "📦 Select storage class:"
echo "1) Standard (frequently accessed data) - Default"
echo "2) Nearline (accessed less than once a month)"
echo "3) Coldline (accessed less than once a quarter)"
echo "4) Archive (accessed less than once a year)"
read -p "Enter your choice (1-4) [Press ENTER for Standard]: " STORAGE_CLASS_CHOICE
STORAGE_CLASS_CHOICE=${STORAGE_CLASS_CHOICE:-1}

case $STORAGE_CLASS_CHOICE in
    1)
        STORAGE_CLASS="STANDARD"
        ;;
    2)
        STORAGE_CLASS="NEARLINE"
        ;;
    3)
        STORAGE_CLASS="COLDLINE"
        ;;
    4)
        STORAGE_CLASS="ARCHIVE"
        ;;
    *)
        STORAGE_CLASS="STANDARD"
        ;;
esac

# Location type input
echo ""
echo "📍 Select location type:"
echo "1) Multi-region (US) - Default for best availability"
echo "2) Dual-region"  
echo "3) Single region"
read -p "Enter your choice (1-3) [Press ENTER for Multi-region]: " LOCATION_TYPE
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

# Access control options
echo ""
echo "🔐 Select access control:"
echo "1) Uniform (Recommended - Default in new buckets)"
echo "2) Fine-grained (Object-level permissions)"
read -p "Enter your choice (1-2) [Press ENTER for Uniform]: " ACCESS_CONTROL_CHOICE
ACCESS_CONTROL_CHOICE=${ACCESS_CONTROL_CHOICE:-1}

case $ACCESS_CONTROL_CHOICE in
    1)
        ACCESS_CONTROL="--uniform-bucket-level-access"
        ACCESS_DESC="Uniform bucket-level access"
        ;;
    2)
        ACCESS_CONTROL=""
        ACCESS_DESC="Fine-grained access control"
        ;;
    *)
        ACCESS_CONTROL="--uniform-bucket-level-access"
        ACCESS_DESC="Uniform bucket-level access [default]"
        ;;
esac

# Public access prevention
echo ""
echo "🛡️  Public access prevention (Recommended for security):"
read -p "Prevent public access? (Y/n) [Press ENTER for Yes]: " PREVENT_PUBLIC
PREVENT_PUBLIC=${PREVENT_PUBLIC:-Y}

if [[ "$PREVENT_PUBLIC" =~ ^[Yy]$ || -z "$PREVENT_PUBLIC" ]]; then
    ENABLE_PAP="yes"
    PUBLIC_DESC="Public access prevention: Enforced"
else
    ENABLE_PAP="no"
    PUBLIC_DESC="Public access prevention: Disabled"
fi

# Versioning option
echo ""
read -p "🔄 Enable object versioning? (y/N) [Press ENTER for No]: " ENABLE_VERSIONING
ENABLE_VERSIONING=${ENABLE_VERSIONING:-N}

# Labels/tags
echo ""
read -p "🏷️  Add custom labels? (y/N) [Press ENTER for No]: " ADD_LABELS
if [[ "$ADD_LABELS" =~ ^[Yy]$ ]]; then
    read -p "Enter labels (format: key1=value1,key2=value2): " CUSTOM_LABELS
    if [[ -n "$CUSTOM_LABELS" ]]; then
        LABELS="--labels=$CUSTOM_LABELS"
    else
        LABELS=""
    fi
else
    LABELS=""
fi

echo ""
echo "=================================================================="
echo "📝 CONFIGURATION SUMMARY"
echo "=================================================================="
echo "Bucket Name: $BUCKET_NAME"
echo "Region: $REGION"
echo "Zone: $ZONE"
echo "Storage Class: $STORAGE_CLASS"
echo "Location: $LOCATION ($LOCATION_DESC)"
echo "Access Control: $ACCESS_DESC"
echo "Public Access: $PUBLIC_DESC"
echo "Versioning: $(if [[ "$ENABLE_VERSIONING" =~ ^[Yy]$ ]]; then echo "Enabled"; else echo "Disabled"; fi)"
if [[ -n "$LABELS" ]]; then
    echo "Labels: $CUSTOM_LABELS"
fi
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

# Step 1: Create the basic bucket with location and storage class
print_status "Step 1: Creating bucket with basic configuration..."
if gsutil mb -l "$LOCATION" -c "$STORAGE_CLASS" "gs://$BUCKET_NAME"; then
    echo ""
    print_status "✅ SUCCESS! Bucket '$BUCKET_NAME' created successfully!"
    
    # Step 2: Configure uniform bucket-level access if selected
    if [[ -n "$ACCESS_CONTROL" ]]; then
        print_status "Step 2: Setting uniform bucket-level access..."
        if gsutil uniformbucketlevelaccess set on "gs://$BUCKET_NAME" 2>/dev/null; then
            print_status "✅ Uniform bucket-level access enabled!"
        else
            print_warning "⚠️  Failed to set uniform bucket-level access (may already be set)"
        fi
    fi
    
    # Step 3: Configure public access prevention if selected
    if [[ "$ENABLE_PAP" == "yes" ]]; then
        print_status "Step 3: Enabling public access prevention..."
        if gsutil pap set enforced "gs://$BUCKET_NAME" 2>/dev/null; then
            print_status "✅ Public access prevention enabled!"
        else
            print_warning "⚠️  Failed to set public access prevention (may not be supported in this region)"
        fi
    fi
    
    # Step 4: Enable versioning if selected
    if [[ "$ENABLE_VERSIONING" =~ ^[Yy]$ ]]; then
        print_status "Step 4: Enabling object versioning..."
        if gsutil versioning set on "gs://$BUCKET_NAME" 2>/dev/null; then
            print_status "✅ Object versioning enabled!"
        else
            print_warning "⚠️  Failed to enable versioning"
        fi
    fi
    
    # Step 5: Add labels if provided
    if [[ -n "$LABELS" ]]; then
        print_status "Step 5: Adding custom labels..."
        if gsutil label ch $LABELS "gs://$BUCKET_NAME" 2>/dev/null; then
            print_status "✅ Custom labels added!"
        else
            print_warning "⚠️  Failed to add custom labels"
        fi
    fi
    
    # Verify bucket creation
    print_status "Final step: Verifying bucket creation..."
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
    echo "Storage Class: $STORAGE_CLASS"
    echo "Location: $LOCATION ($LOCATION_DESC)"
    echo "Access Control: $ACCESS_DESC"
    echo "Public Access: $PUBLIC_DESC"
    echo "Versioning: $(if [[ "$ENABLE_VERSIONING" =~ ^[Yy]$ ]]; then echo "Enabled"; else echo "Disabled"; fi)"
    echo "Project: $PROJECT_ID"
    echo "URL: https://console.cloud.google.com/storage/browser/$BUCKET_NAME"
    echo "=================================================================="
    
    # Create completion marker
    echo "TASK1_COMPLETED=$(date)" > /tmp/arc120_task1_completed
    
else
    print_error "❌ Failed to create bucket '$BUCKET_NAME'"
    echo ""
    echo "Possible reasons:"
    echo "- Bucket name already exists globally"
    echo "- Insufficient permissions"
    echo "- Invalid bucket name format"
    echo "- Quota exceeded"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Try a different bucket name (must be globally unique)"
    echo "2. Check your project permissions"
    echo "3. Verify your project has billing enabled"
    echo ""
    print_warning "Please try again with a different bucket name."
    exit 1
fi

echo ""
print_status "🏁 Task 1 script execution completed!"
echo ""
