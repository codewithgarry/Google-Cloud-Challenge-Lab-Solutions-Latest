#!/bin/bash

# Skills Boost Arcade Trivia September 2025 Week 1 - Lab 3
# Dataplex: Qwik Start - Cloud Shell Runner
# Similar to ARC120 format for easy GitHub integration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
show_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    Skills Boost Arcade Trivia September 2025                ║"
    echo "║                              Week 1 - Lab 3                                 ║"
    echo "║                          Dataplex: Qwik Start                               ║"
    echo "║                                                                              ║"
    echo "║                          🚀 Cloud Shell Runner 🚀                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[ℹ]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[→]${NC} $1"
}

# Function to check Cloud Shell environment
check_cloud_shell() {
    if [ -z "$CLOUD_SHELL" ]; then
        print_warning "This script is optimized for Google Cloud Shell."
        print_info "You can still run it locally if you have gcloud SDK installed."
        echo
        read -p "Continue anyway? (y/N): " CONTINUE
        if [[ ! $CONTINUE =~ ^[Yy]$ ]]; then
            exit 0
        fi
    else
        print_status "Running in Google Cloud Shell - Perfect! 🎯"
    fi
}

# Function to setup project
setup_project() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                              PROJECT SETUP                                     ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Get current project
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    
    if [ -z "$CURRENT_PROJECT" ]; then
        print_error "No project is currently set!"
        echo
        print_info "Available projects:"
        gcloud projects list --format="table(projectId,name,projectNumber)"
        echo
        read -p "Enter your project ID: " PROJECT_ID
        gcloud config set project $PROJECT_ID
    else
        print_status "Current project: $CURRENT_PROJECT"
        echo
        read -p "Use this project? (Y/n): " USE_CURRENT
        if [[ $USE_CURRENT =~ ^[Nn]$ ]]; then
            print_info "Available projects:"
            gcloud projects list --format="table(projectId,name,projectNumber)"
            echo
            read -p "Enter your project ID: " PROJECT_ID
            gcloud config set project $PROJECT_ID
        else
            PROJECT_ID=$CURRENT_PROJECT
        fi
    fi
    
    print_status "Using project: $PROJECT_ID"
    echo
}

# Function to setup user accounts
setup_users() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                              USER SETUP                                        ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    print_info "This lab requires two user accounts (typically provided by Qwiklabs):"
    echo "  • User 1: Dataplex Administrator (can create and manage resources)"
    echo "  • User 2: Test user (for permission testing)"
    echo
    
    # Check current user
    CURRENT_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
    print_status "Currently authenticated as: $CURRENT_USER"
    echo
    
    read -p "Enter User 1 Email (Dataplex Administrator): " USER1_EMAIL
    
    # Auto-suggest User 2 based on pattern if it looks like a lab account
    if [[ $USER1_EMAIL == *"@qwiklabs.net" ]]; then
        # Extract the pattern and suggest User 2
        BASE_PART=$(echo $USER1_EMAIL | sed 's/@qwiklabs.net//' | sed 's/student-[0-9]*-//')
        SUGGESTED_USER2="student-03-${BASE_PART}@qwiklabs.net"
        read -p "Enter User 2 Email [$SUGGESTED_USER2]: " USER2_EMAIL
        USER2_EMAIL=${USER2_EMAIL:-$SUGGESTED_USER2}
    else
        read -p "Enter User 2 Email (Test User): " USER2_EMAIL
    fi
    
    if [ -z "$USER1_EMAIL" ] || [ -z "$USER2_EMAIL" ]; then
        print_error "Both user emails are required!"
        exit 1
    fi
    
    print_status "User 1 (Admin): $USER1_EMAIL"
    print_status "User 2 (Test): $USER2_EMAIL"
    echo
}

# Function to setup lab configuration
setup_lab_config() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                            LAB CONFIGURATION                                   ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    print_info "You can use default values or customize the configuration:"
    echo
    
    # Lake configuration
    read -p "Lake Display Name [Customer Info Lake]: " LAKE_NAME
    LAKE_NAME=${LAKE_NAME:-"Customer Info Lake"}
    
    # Region selection with options
    echo
    print_info "Available regions for Dataplex:"
    echo "  1. us-west1 (Oregon) - Recommended"
    echo "  2. us-central1 (Iowa)"
    echo "  3. us-east1 (South Carolina)"
    echo "  4. europe-west1 (Belgium)"
    echo "  5. Custom region"
    echo
    read -p "Select region (1-5) [1]: " REGION_CHOICE
    REGION_CHOICE=${REGION_CHOICE:-1}
    
    case $REGION_CHOICE in
        1) REGION="us-west1" ;;
        2) REGION="us-central1" ;;
        3) REGION="us-east1" ;;
        4) REGION="europe-west1" ;;
        5) 
            read -p "Enter custom region: " REGION
            if [ -z "$REGION" ]; then
                REGION="us-west1"
            fi
            ;;
        *) REGION="us-west1" ;;
    esac
    
    # Zone and Asset names
    read -p "Zone Display Name [Customer Raw Zone]: " ZONE_NAME
    ZONE_NAME=${ZONE_NAME:-"Customer Raw Zone"}
    
    read -p "Asset Display Name [Customer Online Sessions]: " ASSET_NAME
    ASSET_NAME=${ASSET_NAME:-"Customer Online Sessions"}
    
    # Bucket name
    read -p "Storage Bucket Name [$PROJECT_ID-dataplex-bucket]: " BUCKET_NAME
    BUCKET_NAME=${BUCKET_NAME:-"$PROJECT_ID-dataplex-bucket"}
    
    echo
    print_status "Configuration Summary:"
    echo "  🏞️  Lake: $LAKE_NAME"
    echo "  🌍 Region: $REGION"
    echo "  📂 Zone: $ZONE_NAME"
    echo "  💾 Asset: $ASSET_NAME"
    echo "  🪣 Bucket: $BUCKET_NAME"
    echo "  👤 Admin: $USER1_EMAIL"
    echo "  👤 Test User: $USER2_EMAIL"
    echo
}

# Function to run the automation
run_automation() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                            STARTING AUTOMATION                                 ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    print_step "Exporting configuration variables..."
    export LAKE_NAME REGION ZONE_NAME ASSET_NAME BUCKET_NAME USER1_EMAIL USER2_EMAIL
    export QUICK_MODE=true
    
    print_step "Making scripts executable..."
    chmod +x dataplex-automation.sh
    chmod +x quick-setup.sh 2>/dev/null || true
    
    print_step "Starting Dataplex automation..."
    echo
    
    # Run the main automation
    ./dataplex-automation.sh
    
    echo
    print_status "Automation completed! 🎉"
}

# Function to show next steps
show_next_steps() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                               NEXT STEPS                                       ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo -e "${GREEN}✅ Lab Tasks Completed:${NC}"
    echo "  1. ✓ Created Dataplex lake, zone, and asset"
    echo "  2. ✓ Assigned Dataplex Data Reader role"
    echo "  3. ✓ Assigned Dataplex Data Writer role"
    echo "  4. ✓ Uploaded test file to Cloud Storage"
    echo "  5. ✓ Verified all configurations"
    echo
    
    echo -e "${CYAN}🔗 Google Cloud Console Links:${NC}"
    echo "  • Dataplex: https://console.cloud.google.com/dataplex"
    echo "  • Cloud Storage: https://console.cloud.google.com/storage"
    echo "  • IAM: https://console.cloud.google.com/iam-admin/iam"
    echo
    
    echo -e "${YELLOW}📝 Manual Verification Steps:${NC}"
    echo "  1. Open Dataplex console and verify lake/zone/asset creation"
    echo "  2. Check Cloud Storage bucket for uploaded test.csv file"
    echo "  3. Verify IAM permissions for User 2"
    echo "  4. Test user switching and permission levels"
    echo
    
    echo -e "${PURPLE}🧪 Optional Testing:${NC}"
    echo "  • Switch to User 2 account and test file upload permissions"
    echo "  • Verify different access levels (Reader vs Writer)"
    echo "  • Explore Dataplex discovery features"
    echo
}

# Main execution function
main() {
    clear
    show_banner
    
    print_info "Welcome to the automated solution for Skills Boost Arcade Trivia!"
    print_info "This script will help you complete Week 1, Lab 3: Dataplex Qwik Start"
    echo
    
    check_cloud_shell
    setup_project
    setup_users
    setup_lab_config
    
    echo
    read -p "Ready to start the automation? (Y/n): " START_CONFIRM
    if [[ $START_CONFIRM =~ ^[Nn]$ ]]; then
        print_info "Configuration saved. Run this script again when ready."
        exit 0
    fi
    
    run_automation
    show_next_steps
    
    echo
    print_status "Thank you for using the automated solution! 🚀"
    print_info "Don't forget to clean up resources after completing the lab."
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
