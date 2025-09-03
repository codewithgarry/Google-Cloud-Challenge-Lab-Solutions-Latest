#!/bin/bash

# Skills Boost Arcade Trivia September 2025 Week 1 - Lab 3
# Dataplex: Qwik Start - Automation Script
# Author: Automated Solution Generator
# Date: September 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to get project ID
get_project_id() {
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        print_error "No project ID found. Please set your project ID:"
        echo "gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    print_status "Using project: $PROJECT_ID"
}

# Function to prompt for user input with default values
get_user_input() {
    # Check if running in quick mode (variables already set)
    if [ "$QUICK_MODE" = "true" ]; then
        print_header "Using Quick Mode Configuration"
        print_status "Configuration Summary:"
        echo "Lake Name: $LAKE_NAME"
        echo "Region: $REGION"
        echo "Zone Name: $ZONE_NAME"
        echo "Asset Name: $ASSET_NAME"
        echo "Bucket Name: $BUCKET_NAME"
        echo "User 1 (Admin): $USER1_EMAIL"
        echo "User 2 (Test): $USER2_EMAIL"
        return
    fi
    
    echo
    print_header "Configuration Setup"
    
    # Lake configuration
    read -p "Enter Lake Display Name [Customer Info Lake]: " LAKE_NAME
    LAKE_NAME=${LAKE_NAME:-"Customer Info Lake"}
    
    read -p "Enter Lake Region [us-west1]: " REGION
    REGION=${REGION:-"us-west1"}
    
    # Zone configuration
    read -p "Enter Zone Display Name [Customer Raw Zone]: " ZONE_NAME
    ZONE_NAME=${ZONE_NAME:-"Customer Raw Zone"}
    
    # Asset configuration
    read -p "Enter Asset Display Name [Customer Online Sessions]: " ASSET_NAME
    ASSET_NAME=${ASSET_NAME:-"Customer Online Sessions"}
    
    # Bucket name (usually provided by lab, but allow customization)
    read -p "Enter Storage Bucket Name [$PROJECT_ID-bucket]: " BUCKET_NAME
    BUCKET_NAME=${BUCKET_NAME:-"$PROJECT_ID-bucket"}
    
    # User emails (these are typically provided by the lab)
    echo
    print_status "User Configuration:"
    read -p "Enter User 1 Email (Dataplex Administrator): " USER1_EMAIL
    read -p "Enter User 2 Email (Test User): " USER2_EMAIL
    
    if [ -z "$USER1_EMAIL" ] || [ -z "$USER2_EMAIL" ]; then
        print_error "Both user emails are required!"
        exit 1
    fi
    
    echo
    print_status "Configuration Summary:"
    echo "Lake Name: $LAKE_NAME"
    echo "Region: $REGION"
    echo "Zone Name: $ZONE_NAME"
    echo "Asset Name: $ASSET_NAME"
    echo "Bucket Name: $BUCKET_NAME"
    echo "User 1 (Admin): $USER1_EMAIL"
    echo "User 2 (Test): $USER2_EMAIL"
    echo
    read -p "Continue with these settings? (y/N): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        exit 0
    fi
}

# Function to enable APIs
enable_apis() {
    print_header "Enabling Required APIs"
    
    print_status "Enabling Dataplex API..."
    gcloud services enable dataplex.googleapis.com --quiet
    
    print_status "Enabling Cloud Storage API..."
    gcloud services enable storage.googleapis.com --quiet
    
    print_status "APIs enabled successfully!"
}

# Function to create storage bucket
create_bucket() {
    print_header "Creating Storage Bucket"
    
    if gsutil ls gs://$BUCKET_NAME >/dev/null 2>&1; then
        print_warning "Bucket gs://$BUCKET_NAME already exists."
    else
        print_status "Creating bucket: gs://$BUCKET_NAME"
        gsutil mb -l $REGION gs://$BUCKET_NAME
        print_status "Bucket created successfully!"
    fi
}

# Function to create Dataplex lake
create_lake() {
    print_header "Task 1: Creating Dataplex Lake"
    
    # Generate lake ID from display name
    LAKE_ID=$(echo "$LAKE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    
    print_status "Creating lake: $LAKE_NAME (ID: $LAKE_ID)"
    
    # Check if lake already exists
    if gcloud dataplex lakes describe $LAKE_ID --location=$REGION >/dev/null 2>&1; then
        print_warning "Lake $LAKE_ID already exists."
    else
        gcloud dataplex lakes create $LAKE_ID \
            --location=$REGION \
            --display-name="$LAKE_NAME" \
            --description="Customer information data lake"
        
        print_status "Waiting for lake to be created..."
        sleep 30
    fi
    
    print_status "Lake created successfully!"
}

# Function to create Dataplex zone
create_zone() {
    print_header "Creating Dataplex Zone"
    
    # Generate zone ID from display name
    ZONE_ID=$(echo "$ZONE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    
    print_status "Creating zone: $ZONE_NAME (ID: $ZONE_ID)"
    
    # Check if zone already exists
    if gcloud dataplex zones describe $ZONE_ID --location=$REGION --lake=$LAKE_ID >/dev/null 2>&1; then
        print_warning "Zone $ZONE_ID already exists."
    else
        gcloud dataplex zones create $ZONE_ID \
            --location=$REGION \
            --lake=$LAKE_ID \
            --display-name="$ZONE_NAME" \
            --type=RAW \
            --resource-location-type=SINGLE_REGION \
            --discovery-enabled
        
        print_status "Waiting for zone to be created..."
        sleep 30
    fi
    
    print_status "Zone created successfully!"
}

# Function to create Dataplex asset
create_asset() {
    print_header "Creating Dataplex Asset"
    
    # Generate asset ID from display name
    ASSET_ID=$(echo "$ASSET_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
    
    print_status "Creating asset: $ASSET_NAME (ID: $ASSET_ID)"
    
    # Check if asset already exists
    if gcloud dataplex assets describe $ASSET_ID --location=$REGION --lake=$LAKE_ID --zone=$ZONE_ID >/dev/null 2>&1; then
        print_warning "Asset $ASSET_ID already exists."
    else
        gcloud dataplex assets create $ASSET_ID \
            --location=$REGION \
            --lake=$LAKE_ID \
            --zone=$ZONE_ID \
            --display-name="$ASSET_NAME" \
            --resource-type=STORAGE_BUCKET \
            --resource-name="projects/$PROJECT_ID/buckets/$BUCKET_NAME" \
            --discovery-enabled
        
        print_status "Waiting for asset to be created..."
        sleep 20
    fi
    
    print_status "Asset created successfully!"
}

# Function to assign Dataplex Data Reader role
assign_reader_role() {
    print_header "Task 2: Assigning Dataplex Data Reader Role"
    
    print_status "Assigning Dataplex Data Reader role to $USER2_EMAIL"
    
    gcloud dataplex assets add-iam-policy-binding $ASSET_ID \
        --location=$REGION \
        --lake=$LAKE_ID \
        --zone=$ZONE_ID \
        --member="user:$USER2_EMAIL" \
        --role="roles/dataplex.dataReader"
    
    print_status "Data Reader role assigned successfully!"
    print_warning "Note: It may take a few minutes for permissions to propagate."
}

# Function to assign Dataplex Data Writer role
assign_writer_role() {
    print_header "Task 4: Assigning Dataplex Data Writer Role"
    
    print_status "Updating role to Dataplex Data Writer for $USER2_EMAIL"
    
    # Remove the reader role first
    gcloud dataplex assets remove-iam-policy-binding $ASSET_ID \
        --location=$REGION \
        --lake=$LAKE_ID \
        --zone=$ZONE_ID \
        --member="user:$USER2_EMAIL" \
        --role="roles/dataplex.dataReader" --quiet || true
    
    # Add the writer role
    gcloud dataplex assets add-iam-policy-binding $ASSET_ID \
        --location=$REGION \
        --lake=$LAKE_ID \
        --zone=$ZONE_ID \
        --member="user:$USER2_EMAIL" \
        --role="roles/dataplex.dataWriter"
    
    print_status "Data Writer role assigned successfully!"
    print_warning "Note: It may take a few minutes for permissions to propagate."
}

# Function to test file upload
test_file_upload() {
    print_header "Task 5: Testing File Upload"
    
    # Check if test file exists
    TEST_FILE="./test.csv"
    if [ ! -f "$TEST_FILE" ]; then
        print_status "Creating test CSV file..."
        cat > $TEST_FILE << EOF
File, test, file, test
EOF
    fi
    
    print_status "Uploading test file to bucket..."
    gsutil cp $TEST_FILE gs://$BUCKET_NAME/
    
    print_status "File uploaded successfully!"
    print_status "You can verify the upload in the Google Cloud Console."
}

# Function to display completion summary
display_summary() {
    print_header "Lab Completion Summary"
    
    echo -e "${GREEN}✓${NC} Task 1: Created lake, zone, and asset in Dataplex"
    echo -e "${GREEN}✓${NC} Task 2: Assigned Dataplex Data Reader role to user"
    echo -e "${GREEN}✓${NC} Task 3: Ready for testing access as Dataplex Data Reader"
    echo -e "${GREEN}✓${NC} Task 4: Assigned Dataplex Data Writer role to user"
    echo -e "${GREEN}✓${NC} Task 5: Uploaded file to Cloud Storage bucket"
    
    echo
    print_status "Resources Created:"
    echo "• Lake: $LAKE_NAME (ID: $LAKE_ID)"
    echo "• Zone: $ZONE_NAME (ID: $ZONE_ID)"
    echo "• Asset: $ASSET_NAME (ID: $ASSET_ID)"
    echo "• Bucket: gs://$BUCKET_NAME"
    
    echo
    print_status "Manual Steps Required:"
    echo "1. Test access as User 2 ($USER2_EMAIL) - try uploading files"
    echo "2. Verify permissions in the Dataplex console"
    echo "3. Test the different access levels (Reader vs Writer)"
    
    echo
    print_status "Google Cloud Console URLs:"
    echo "• Dataplex: https://console.cloud.google.com/dataplex"
    echo "• Storage: https://console.cloud.google.com/storage"
    echo "• IAM: https://console.cloud.google.com/iam-admin/iam"
}

# Main execution
main() {
    print_header "Skills Boost Arcade Trivia September 2025 Week 1"
    print_header "Dataplex: Qwik Start - Automated Solution"
    
    get_project_id
    get_user_input
    enable_apis
    create_bucket
    create_lake
    create_zone
    create_asset
    assign_reader_role
    
    echo
    print_warning "Pausing for 60 seconds to allow permissions to propagate..."
    sleep 60
    
    assign_writer_role
    
    echo
    print_warning "Pausing for 30 seconds before testing file upload..."
    sleep 30
    
    test_file_upload
    display_summary
    
    echo
    print_status "Lab automation completed successfully!"
    print_status "Please verify all tasks in the Google Cloud Console."
}

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Check if gsutil is installed
if ! command -v gsutil &> /dev/null; then
    print_error "gsutil is not installed. Please install Google Cloud SDK."
    exit 1
fi

# Run main function
main "$@"
