#!/bin/bash

# =============================================================================
# ARC113: Get Started with Pub/Sub Challenge Lab - Automated Solution Runner
# =============================================================================
# 
# 🎯 Purpose: Automatically detect and solve all forms of ARC113 challenge lab
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 📺 YouTube: https://youtube.com/@codewithgarry
# 
# =============================================================================

# Color codes for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to print section headers
print_header() {
    echo ""
    print_color $BLUE "=================================================================="
    print_color $WHITE "  $1"
    print_color $BLUE "=================================================================="
    echo ""
}

# Function to print step information
print_step() {
    print_color $CYAN "🔹 $1"
}

# Function to print success messages
print_success() {
    print_color $GREEN "✅ $1"
}

# Function to print warning messages
print_warning() {
    print_color $YELLOW "⚠️  $1"
}

# Function to print error messages
print_error() {
    print_color $RED "❌ $1"
}

# =============================================================================
# MAIN SCRIPT EXECUTION
# =============================================================================

clear
print_header "ARC113: Get Started with Pub/Sub Challenge Lab"
print_color $PURPLE "🚀 Automated Solution Runner by CodeWithGarry"
print_color $CYAN "📺 Subscribe: https://youtube.com/@codewithgarry"
echo ""

print_step "Checking Google Cloud CLI configuration..."

# Check if gcloud is installed and configured
if ! command -v gcloud &> /dev/null; then
    print_error "Google Cloud CLI not found. Please install gcloud first."
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    print_error "No active Google Cloud project found."
    print_warning "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_success "Project ID: $PROJECT_ID"

# =============================================================================
# LAB FORM DETECTION
# =============================================================================

print_header "🤖 Intelligent Form Detection"

print_step "Choose detection method:"
echo ""
print_color $CYAN "1) 🤖 AI Auto-Detection (Recommended)"
print_color $CYAN "2) 📋 Manual Selection"
echo ""
read -p "Enter your choice (1 or 2): " detection_choice

case $detection_choice in
    1)
        print_success "Selected: AI Auto-Detection"
        print_step "Downloading intelligent auto-detector..."
        
        AUTO_DETECTOR_URL="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/Pro/solid/intelligent-auto-detector.sh"
        
        if curl -LO "$AUTO_DETECTOR_URL"; then
            chmod +x intelligent-auto-detector.sh
            print_success "🤖 Executing AI-powered detection and solution..."
            
            if ./intelligent-auto-detector.sh; then
                print_success "🎉 AI auto-detection completed successfully!"
                rm -f intelligent-auto-detector.sh
                exit 0
            else
                print_warning "AI detection failed, falling back to manual selection..."
                rm -f intelligent-auto-detector.sh
            fi
        else
            print_warning "Failed to download AI detector, using manual selection..."
        fi
        ;;
    2)
        print_success "Selected: Manual Selection"
        ;;
    *)
        print_error "Invalid choice. Using manual selection as fallback."
        ;;
esac

print_step "This lab has 3 different forms with different tasks:"
echo ""
print_color $YELLOW "Form 1: Publish message → View message → Create snapshot"
print_color $YELLOW "Form 2: Create schema → Create topic with schema → Create Cloud Function"  
print_color $YELLOW "Form 3: Set up Pub/Sub → Create Scheduler job → Verify results"
echo ""

# Ask user to select form
print_color $WHITE "Which form are you working on?"
print_color $CYAN "1) Form 1 (Message publishing and snapshots)"
print_color $CYAN "2) Form 2 (Schemas and Cloud Functions)"
print_color $CYAN "3) Form 3 (Scheduler integration)"
echo ""
read -p "Enter your choice (1, 2, or 3): " FORM_CHOICE

case $FORM_CHOICE in
    1)
        FORM_TYPE="form_1"
        print_success "Selected Form 1: Message Publishing and Snapshots"
        ;;
    2)
        FORM_TYPE="form_2"
        print_success "Selected Form 2: Schemas and Cloud Functions"
        ;;
    3)
        FORM_TYPE="form_3"
        print_success "Selected Form 3: Scheduler Integration"
        ;;
    *)
        print_error "Invalid choice. Please run the script again and select 1, 2, or 3."
        exit 1
        ;;
esac

# =============================================================================
# REGION SETUP (for Forms 2 and 3)
# =============================================================================

if [ "$FORM_TYPE" == "form_2" ] || [ "$FORM_TYPE" == "form_3" ]; then
    print_header "Region Configuration"
    
    # Check if LOCATION is already set
    if [ -z "$LOCATION" ]; then
        print_warning "LOCATION environment variable not set."
        print_step "Common regions for labs:"
        print_color $CYAN "  - us-central1"
        print_color $CYAN "  - us-east1"
        print_color $CYAN "  - europe-west1"
        print_color $CYAN "  - asia-southeast1"
        echo ""
        read -p "Enter your lab region (e.g., us-central1): " USER_LOCATION
        
        if [ -z "$USER_LOCATION" ]; then
            print_warning "No region specified. Using default: us-central1"
            export LOCATION="us-central1"
        else
            export LOCATION="$USER_LOCATION"
        fi
    fi
    
    print_success "Using region: $LOCATION"
fi

# =============================================================================
# SOLUTION EXECUTION
# =============================================================================

print_header "Executing Solution for $FORM_TYPE"

print_step "Downloading solution script from repository..."

# Use our internal high-quality scripts
SCRIPT_NAME=""
case $FORM_CHOICE in
    1)
        SCRIPT_NAME="form1-solution.sh"
        ;;
    2)
        SCRIPT_NAME="form2-solution.sh"
        ;;
    3)
        SCRIPT_NAME="form3-solution.sh"
        ;;
esac

SCRIPT_URL="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/Pro/solid/${SCRIPT_NAME}"

print_step "Downloading CodeWithGarry's optimized solution script..."

if curl -LO "$SCRIPT_URL"; then
    print_success "High-quality script downloaded successfully"
else
    print_error "Failed to download script. Please check your internet connection."
    exit 1
fi

print_step "Making script executable..."
chmod +x "$SCRIPT_NAME"

print_step "Executing CodeWithGarry's solution script..."
print_warning "This may take a few minutes. Please wait..."
echo ""

# Execute the script with proper environment
if ./"$SCRIPT_NAME"; then
    print_success "Solution script executed successfully!"
else
    print_error "Script execution failed. Please check the output above for errors."
    exit 1
fi

# Clean up
rm -f "$SCRIPT_NAME"

# =============================================================================
# VERIFICATION AND CLEANUP
# =============================================================================

print_header "Verification and Cleanup"

print_step "Cleaning up downloaded script..."
rm -f "$SCRIPT_NAME"

print_success "Cleanup completed"

# =============================================================================
# COMPLETION MESSAGE
# =============================================================================

print_header "Lab Completion"

print_success "🎉 ARC113 Challenge Lab solution executed successfully!"
echo ""
print_color $WHITE "Next steps:"
print_color $CYAN "1. 📊 Check your lab progress page"
print_color $CYAN "2. ✅ Verify all tasks show green checkmarks"
print_color $CYAN "3. 🏆 Click 'End Lab' to submit your work"
echo ""

if [ "$FORM_TYPE" == "form_1" ]; then
    print_color $YELLOW "Form 1 Tasks Completed:"
    print_color $GREEN "  ✅ Published message to topic"
    print_color $GREEN "  ✅ Viewed message in subscription"
    print_color $GREEN "  ✅ Created Pub/Sub snapshot"
elif [ "$FORM_TYPE" == "form_2" ]; then
    print_color $YELLOW "Form 2 Tasks Completed:"
    print_color $GREEN "  ✅ Created Pub/Sub schema"
    print_color $GREEN "  ✅ Created topic using schema"
    print_color $GREEN "  ✅ Created Cloud Function with Pub/Sub trigger"
elif [ "$FORM_TYPE" == "form_3" ]; then
    print_color $YELLOW "Form 3 Tasks Completed:"
    print_color $GREEN "  ✅ Set up Cloud Pub/Sub"
    print_color $GREEN "  ✅ Created Cloud Scheduler job"
    print_color $GREEN "  ✅ Verified results in Pub/Sub"
fi

echo ""
print_color $PURPLE "🙏 Thank you for using CodeWithGarry's solutions!"
print_color $CYAN "📺 Subscribe: https://youtube.com/@codewithgarry"
print_color $CYAN "⭐ Star us: https://github.com/codewithgarry"
echo ""
print_color $WHITE "Happy learning! 🚀"

# =============================================================================
# END OF SCRIPT
# =============================================================================
