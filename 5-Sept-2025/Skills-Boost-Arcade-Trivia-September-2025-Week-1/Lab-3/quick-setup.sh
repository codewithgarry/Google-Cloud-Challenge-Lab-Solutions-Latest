#!/bin/bash

# Quick Setup Script for Skills Boost Arcade Trivia September 2025 Week 1
# Dataplex: Qwik Start - Lab 3
# This script sets up the environment and runs the automation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install Google Cloud SDK."
        exit 1
    fi
    
    # Check if gsutil is installed
    if ! command -v gsutil &> /dev/null; then
        print_error "gsutil is not installed. Please install Google Cloud SDK."
        exit 1
    fi
    
    # Check if authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null 2>&1; then
        print_error "Not authenticated with Google Cloud. Please run 'gcloud auth login'"
        exit 1
    fi
    
    # Check if project is set
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        print_error "No project ID set. Please run 'gcloud config set project YOUR_PROJECT_ID'"
        exit 1
    fi
    
    print_status "All prerequisites met!"
    print_status "Project: $PROJECT_ID"
}

# Function to setup lab environment
setup_environment() {
    print_header "Setting Up Lab Environment"
    
    # Make the main script executable
    chmod +x dataplex-automation.sh
    
    # Check if test file exists
    if [ ! -f "test.csv" ]; then
        print_warning "Test CSV file not found. Creating one..."
        cat > test.csv << EOF
File, test, file, test
EOF
        print_status "Test CSV file created."
    fi
    
    print_status "Environment setup complete!"
}

# Function to display lab information
display_lab_info() {
    print_header "Lab Information"
    echo "Lab: Skills Boost Arcade Trivia September 2025 Week 1"
    echo "Topic: Dataplex: Qwik Start"
    echo "Tasks: 5 automated tasks"
    echo "Duration: ~10-15 minutes"
    echo
    echo "What this automation does:"
    echo "1. ✅ Create a lake, zone, and asset in Dataplex"
    echo "2. ✅ Assign Dataplex Data Reader role to user"
    echo "3. ✅ Assign Dataplex Data Writer role to user"
    echo "4. ✅ Upload test file to Cloud Storage bucket"
    echo "5. ✅ Verify all configurations"
    echo
}

# Function to run automation with options
run_automation() {
    print_header "Running Lab Automation"
    
    echo "Choose automation mode:"
    echo "1. Interactive Mode (recommended for learning)"
    echo "2. Quick Mode (uses default values)"
    echo
    read -p "Enter your choice (1 or 2): " MODE_CHOICE
    
    case $MODE_CHOICE in
        1)
            print_status "Starting interactive automation..."
            ./dataplex-automation.sh
            ;;
        2)
            print_status "Starting quick automation with defaults..."
            run_quick_automation
            ;;
        *)
            print_error "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
}

# Function to run quick automation with defaults
run_quick_automation() {
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    
    # Default values
    LAKE_NAME="Customer Info Lake"
    REGION="us-west1"
    ZONE_NAME="Customer Raw Zone" 
    ASSET_NAME="Customer Online Sessions"
    BUCKET_NAME="$PROJECT_ID-dataplex-bucket"
    
    # Get user emails from lab environment or prompt
    echo
    print_warning "User emails are required for this lab."
    print_status "These are typically provided in your lab instructions."
    echo
    read -p "Enter User 1 Email (Dataplex Administrator): " USER1_EMAIL
    read -p "Enter User 2 Email (Test User): " USER2_EMAIL
    
    if [ -z "$USER1_EMAIL" ] || [ -z "$USER2_EMAIL" ]; then
        print_error "Both user emails are required!"
        exit 1
    fi
    
    # Export variables for the main script
    export LAKE_NAME REGION ZONE_NAME ASSET_NAME BUCKET_NAME USER1_EMAIL USER2_EMAIL
    export QUICK_MODE=true
    
    # Run the main automation script
    ./dataplex-automation.sh
}

# Main execution
main() {
    clear
    print_header "Skills Boost Arcade Trivia September 2025 Week 1"
    print_header "Dataplex: Qwik Start - Quick Setup"
    
    check_prerequisites
    display_lab_info
    setup_environment
    
    echo
    read -p "Ready to start the lab automation? (y/N): " START_CONFIRM
    if [[ ! $START_CONFIRM =~ ^[Yy]$ ]]; then
        print_status "Setup complete. Run './dataplex-automation.sh' when ready."
        exit 0
    fi
    
    run_automation
    
    echo
    print_status "Lab automation completed!"
    print_status "Please verify all tasks in the Google Cloud Console."
}

# Run main function
main "$@"
