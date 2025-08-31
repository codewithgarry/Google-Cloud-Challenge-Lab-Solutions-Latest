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
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_tutorial() {
    echo -e "${BLUE}[TUTORIAL]${NC} $1"
}

print_tip() {
    echo -e "${CYAN}[TIP]${NC} $1"
}

# Function to verify YouTube channel subscription
verify_channel_subscription() {
    clear
    echo "=================================================================="
    echo "📺 CODEWITHGARRY YOUTUBE CHANNEL"
    echo "=================================================================="
    echo ""
    echo "      ████████████████████████████████████████████████████████"
    echo "      █                                                      █"
    echo "      █    🎬 CodeWithGarry - Google Cloud Solutions          █"
    echo "      █                                                      █"
    echo "      █    📚 Challenge Labs | Step-by-Step Tutorials        █"
    echo "      █    🚀 Free Google Cloud Content                      █"
    echo "      █                                                      █"
    echo "      █         👤 @CodeWithGarry                            █"
    echo "      █         🔔 SUBSCRIBE for more solutions              █"
    echo "      █                                                      █"
    echo "      ████████████████████████████████████████████████████████"
    echo ""
    echo "🔗 Channel: https://www.youtube.com/@CodeWithGarry"
    echo ""
    echo "=================================================================="
    
    while true; do
        echo ""
        echo "Have you subscribed to CodeWithGarry YouTube channel?"
        echo "📺 https://www.youtube.com/@CodeWithGarry"
        echo ""
        read -p "Confirm subscription (yes/subscribed): " subscription_response
        
        # Convert to lowercase and check
        subscription_lower=$(echo "$subscription_response" | tr '[:upper:]' '[:lower:]')
        
        if [[ "$subscription_lower" =~ (yes|subscribed) ]]; then
            print_status "✅ Thank you for subscribing to CodeWithGarry!"
            break
        else
            print_error "❌ Please subscribe to continue!"
            echo ""
            echo "🔗 https://www.youtube.com/@CodeWithGarry"
            echo ""
            read -p "Press ENTER after subscribing..."
        fi
    done
    
    echo ""
    read -p "Press ENTER to continue with Task 1..."
    clear
}

# Function to show Cloud Storage tutorial
show_storage_tutorial() {
    echo ""
    echo "=================================================================="
    echo "📚 QUICK TUTORIAL: GOOGLE CLOUD STORAGE"
    echo "=================================================================="
    print_tutorial "What is Cloud Storage?"
    echo "   • Object storage service for storing files, images, videos, etc."
    echo "   • Think of it like a massive hard drive in the cloud"
    echo "   • Files are stored in 'buckets' (containers)"
    echo ""
    print_tutorial "Storage Classes (Performance vs Cost):"
    echo "   • Standard: Fast access, higher cost (daily use files)"
    echo "   • Nearline: Monthly access, medium cost (backups)"
    echo "   • Coldline: Quarterly access, low cost (archives)"
    echo "   • Archive: Yearly access, lowest cost (long-term storage)"
    echo ""
    print_tutorial "Key Concepts:"
    echo "   • Bucket: Container that holds your objects/files"
    echo "   • Object: Individual file (photo, video, document)"
    echo "   • Region: Geographic location where data is stored"
    echo "   • Uniform Access: Same permissions for all objects in bucket"
    echo ""
    print_tip "Use cases: Website assets, data backups, content distribution"
    echo "=================================================================="
    echo ""
    read -p "Press ENTER to continue with bucket creation..."
    echo ""
}

# Function to confirm or go back
confirm_or_back() {
    local prompt="$1"
    while true; do
        echo ""
        echo "Options:"
        echo "  y/Y - Yes, continue"
        echo "  n/N - No, cancel"
        echo "  b/B - Go back to previous step"
        echo ""
        read -p "$prompt (y/n/b): " choice
        case $choice in
            [Yy]* ) return 0;;
            [Nn]* ) 
                print_warning "Operation cancelled by user."
                exit 0;;
            [Bb]* ) return 1;;
            * ) print_error "Please answer y (yes), n (no), or b (back).";;
        esac
    done
}

# Main function to collect user inputs with back navigation
collect_user_inputs() {
    # Show tutorial first
    echo "📖 Would you like to see a quick tutorial about Cloud Storage?"
    read -p "Show tutorial? (Y/n): " show_tutorial
    if [[ "$show_tutorial" =~ ^[Yy]$ || -z "$show_tutorial" ]]; then
        show_storage_tutorial
    fi

    while true; do
        # Step 1: Bucket name
        while true; do
            echo "📋 STEP 1: BUCKET CONFIGURATION"
            echo ""
            print_tip "Bucket names must be globally unique across all Google Cloud"
            read -p "🪣 Enter the BUCKET NAME (from your lab instructions): " BUCKET_NAME
            if [[ -n "$BUCKET_NAME" ]]; then
                echo "Selected: $BUCKET_NAME"
                if confirm_or_back "Is this bucket name correct?"; then
                    break
                fi
            else
                print_error "Bucket name cannot be empty. Please try again."
            fi
        done

        # Step 2: Region and Zone
        while true; do
            echo ""
            echo "📋 STEP 2: LOCATION CONFIGURATION"
            echo ""
            print_tutorial "Regions are geographic locations for your resources"
            print_tip "Choose a region close to your users for better performance"
            read -p "🌍 Enter the REGION [default: us-east4]: " REGION
            REGION=${REGION:-us-east4}
            
            read -p "🎯 Enter the ZONE [default: us-east4-a]: " ZONE
            ZONE=${ZONE:-us-east4-a}
            
            echo "Selected: Region=$REGION, Zone=$ZONE"
            if confirm_or_back "Are these location settings correct?"; then
                break
            fi
        done

        # Step 3: Storage class
        while true; do
            echo ""
            echo "📋 STEP 3: STORAGE CLASS SELECTION"
            echo ""
            print_tutorial "Storage classes determine access speed and cost:"
            echo "📦 Select storage class:"
            echo "1) Standard (frequently accessed data) - Default"
            echo "   └ Best for: Active website content, gaming data"
            echo "2) Nearline (accessed less than once a month)"
            echo "   └ Best for: Monthly reports, backup data"
            echo "3) Coldline (accessed less than once a quarter)"
            echo "   └ Best for: Disaster recovery, long-term backups"
            echo "4) Archive (accessed less than once a year)"
            echo "   └ Best for: Legal compliance, historical records"
            read -p "Enter your choice (1-4) [Press ENTER for Standard]: " STORAGE_CLASS_CHOICE
            STORAGE_CLASS_CHOICE=${STORAGE_CLASS_CHOICE:-1}

            case $STORAGE_CLASS_CHOICE in
                1) STORAGE_CLASS="STANDARD"; STORAGE_DESC="Standard (frequent access)" ;;
                2) STORAGE_CLASS="NEARLINE"; STORAGE_DESC="Nearline (monthly access)" ;;
                3) STORAGE_CLASS="COLDLINE"; STORAGE_DESC="Coldline (quarterly access)" ;;
                4) STORAGE_CLASS="ARCHIVE"; STORAGE_DESC="Archive (yearly access)" ;;
                *) STORAGE_CLASS="STANDARD"; STORAGE_DESC="Standard (frequent access) [default]" ;;
            esac
            
            echo "Selected: $STORAGE_DESC"
            if confirm_or_back "Is this storage class correct?"; then
                break
            fi
        done

        # Step 4: Location type
        while true; do
            echo ""
            echo "📋 STEP 4: GEOGRAPHIC DISTRIBUTION"
            echo ""
            print_tutorial "Location types affect availability and performance:"
            echo "📍 Select location type:"
            echo "1) Multi-region (US) - Default for best availability"
            echo "   └ Data stored across multiple US regions (99.95% availability)"
            echo "2) Dual-region"  
            echo "   └ Data stored in two specific regions (99.95% availability)"
            echo "3) Single region"
            echo "   └ Data stored in one region (99.9% availability, lower cost)"
            read -p "Enter your choice (1-3) [Press ENTER for Multi-region]: " LOCATION_TYPE
            LOCATION_TYPE=${LOCATION_TYPE:-1}

            case $LOCATION_TYPE in
                1) LOCATION="us"; LOCATION_DESC="Multi-region (US)" ;;
                2) LOCATION="us-east4"; LOCATION_DESC="Dual-region" ;;
                3) LOCATION="$REGION"; LOCATION_DESC="Single region ($REGION)" ;;
                *) LOCATION="us"; LOCATION_DESC="Multi-region (US) [default]" ;;
            esac
            
            echo "Selected: $LOCATION_DESC"
            if confirm_or_back "Is this location type correct?"; then
                break
            fi
        done

        # Step 5: Access control
        while true; do
            echo ""
            echo "📋 STEP 5: ACCESS CONTROL SETTINGS"
            echo ""
            print_tutorial "Access control determines who can access your objects:"
            echo "🔐 Select access control:"
            echo "1) Uniform (Recommended - Default in new buckets)"
            echo "   └ Same permissions for all objects in bucket (simpler)"
            echo "2) Fine-grained (Object-level permissions)"
            echo "   └ Different permissions per object (more complex)"
            read -p "Enter your choice (1-2) [Press ENTER for Uniform]: " ACCESS_CONTROL_CHOICE
            ACCESS_CONTROL_CHOICE=${ACCESS_CONTROL_CHOICE:-1}

            case $ACCESS_CONTROL_CHOICE in
                1) ACCESS_CONTROL="--uniform-bucket-level-access"; ACCESS_DESC="Uniform bucket-level access" ;;
                2) ACCESS_CONTROL=""; ACCESS_DESC="Fine-grained access control" ;;
                *) ACCESS_CONTROL="--uniform-bucket-level-access"; ACCESS_DESC="Uniform bucket-level access [default]" ;;
            esac
            
            echo "Selected: $ACCESS_DESC"
            if confirm_or_back "Is this access control setting correct?"; then
                break
            fi
        done

        # Step 6: Public access prevention
        while true; do
            echo ""
            echo "� STEP 6: SECURITY SETTINGS"
            echo ""
            print_tutorial "Public access prevention protects your data from accidental exposure"
            print_tip "Always enable this unless you specifically need public access"
            echo "�🛡️  Public access prevention (Recommended for security):"
            read -p "Prevent public access? (Y/n) [Press ENTER for Yes]: " PREVENT_PUBLIC
            PREVENT_PUBLIC=${PREVENT_PUBLIC:-Y}

            if [[ "$PREVENT_PUBLIC" =~ ^[Yy]$ || -z "$PREVENT_PUBLIC" ]]; then
                ENABLE_PAP="yes"
                PUBLIC_DESC="Public access prevention: Enforced"
            else
                ENABLE_PAP="no"
                PUBLIC_DESC="Public access prevention: Disabled"
            fi
            
            echo "Selected: $PUBLIC_DESC"
            if confirm_or_back "Is this security setting correct?"; then
                break
            fi
        done

        # Step 7: Versioning
        while true; do
            echo ""
            echo "📋 STEP 7: VERSIONING SETTINGS"
            echo ""
            print_tutorial "Object versioning keeps multiple versions of the same file"
            print_tip "Useful for protecting against accidental overwrites or deletions"
            read -p "🔄 Enable object versioning? (y/N) [Press ENTER for No]: " ENABLE_VERSIONING
            ENABLE_VERSIONING=${ENABLE_VERSIONING:-N}
            
            if [[ "$ENABLE_VERSIONING" =~ ^[Yy]$ ]]; then
                VERSIONING_DESC="Enabled"
            else
                VERSIONING_DESC="Disabled"
            fi
            
            echo "Selected: Versioning $VERSIONING_DESC"
            if confirm_or_back "Is this versioning setting correct?"; then
                break
            fi
        done

        # Step 8: Labels (optional)
        while true; do
            echo ""
            echo "📋 STEP 8: LABELS (OPTIONAL)"
            echo ""
            print_tutorial "Labels help organize and track resources for billing and management"
            read -p "🏷️  Add custom labels? (y/N) [Press ENTER for No]: " ADD_LABELS
            if [[ "$ADD_LABELS" =~ ^[Yy]$ ]]; then
                read -p "Enter labels (format: key1=value1,key2=value2): " CUSTOM_LABELS
                if [[ -n "$CUSTOM_LABELS" ]]; then
                    LABELS="--labels=$CUSTOM_LABELS"
                    LABELS_DESC="Custom labels: $CUSTOM_LABELS"
                else
                    LABELS=""
                    LABELS_DESC="No labels"
                fi
            else
                LABELS=""
                LABELS_DESC="No labels"
            fi
            
            echo "Selected: $LABELS_DESC"
            if confirm_or_back "Are these label settings correct?"; then
                break
            fi
        done

        # Final confirmation
        echo ""
        echo "=================================================================="
        echo "📝 FINAL CONFIGURATION SUMMARY"
        echo "=================================================================="
        echo "Bucket Name: $BUCKET_NAME"
        echo "Region: $REGION"
        echo "Zone: $ZONE"
        echo "Storage Class: $STORAGE_DESC"
        echo "Location: $LOCATION ($LOCATION_DESC)"
        echo "Access Control: $ACCESS_DESC"
        echo "Public Access: $PUBLIC_DESC"
        echo "Versioning: $VERSIONING_DESC"
        echo "Labels: $LABELS_DESC"
        echo "=================================================================="
        echo ""

        while true; do
            echo "Final options:"
            echo "  c/C - Continue with bucket creation"
            echo "  b/B - Go back and modify settings"
            echo "  q/Q - Quit without creating bucket"
            echo ""
            read -p "What would you like to do? (c/b/q): " final_choice
            case $final_choice in
                [Cc]* ) 
                    print_status "Proceeding with bucket creation..."
                    return 0;;
                [Bb]* ) 
                    print_warning "Going back to modify settings..."
                    break;;
                [Qq]* ) 
                    print_warning "Operation cancelled by user."
                    exit 0;;
                * ) print_error "Please answer c (continue), b (back), or q (quit).";;
            esac
        done
    done
}

# Get user inputs
echo "📋 Please provide the following information from your lab instructions:"
echo ""
echo "💡 Press ENTER to use default values (recommended for quick completion)"
echo "💡 Type 'b' at any confirmation to go back and change previous settings"
echo ""

collect_user_inputs

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
    echo "Storage Class: $STORAGE_DESC"
    echo "Location: $LOCATION ($LOCATION_DESC)"
    echo "Access Control: $ACCESS_DESC"
    echo "Public Access: $PUBLIC_DESC"
    echo "Versioning: $VERSIONING_DESC"
    echo "Labels: $LABELS_DESC"
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
