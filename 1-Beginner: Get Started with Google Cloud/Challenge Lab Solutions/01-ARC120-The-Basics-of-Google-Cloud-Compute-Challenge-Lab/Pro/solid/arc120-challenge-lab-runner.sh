#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Master Script
# Downloads and runs all task scripts
# Author: CodeWithGarry
# Lab ID: ARC120
# =============================================================================

echo "=================================================================="
echo "  🚀 THE BASICS OF GOOGLE CLOUD COMPUTE CHALLENGE LAB"
echo "=================================================================="
echo "  📚 Lab ID: ARC120"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Tasks: 3 (Storage Bucket, VM + Disk, NGINX)"
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# GitHub repository URLs (replace with your actual repository URLs)
REPO_BASE_URL="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/01-ARC120-The-Basics-of-Google-Cloud-Compute-Challenge-Lab/Pro/solid"

# Script URLs
TASK1_URL="$REPO_BASE_URL/sci-fi-1/task1-create-storage-bucket.sh"
TASK2_URL="$REPO_BASE_URL/sci-fi-2/task2-create-vm-with-disk.sh"
TASK3_URL="$REPO_BASE_URL/sci-fi-3/task3-install-nginx.sh"

# Function to download and execute script
download_and_run() {
    local task_num=$1
    local script_url=$2
    local script_name=$3
    local description=$4
    
    print_header "=================================================================="
    print_header "  TASK $task_num: $description"
    print_header "=================================================================="
    
    print_status "Downloading script: $script_name"
    
    if curl -sL "$script_url" -o "$script_name"; then
        print_status "✅ Script downloaded successfully!"
        
        # Make executable
        chmod +x "$script_name"
        print_status "✅ Script made executable!"
        
        echo ""
        read -p "🚀 Do you want to run Task $task_num now? (y/N): " run_now
        
        if [[ "$run_now" =~ ^[Yy]$ ]]; then
            echo ""
            print_status "🏃‍♂️ Running Task $task_num script..."
            echo ""
            
            if ./"$script_name"; then
                print_status "✅ Task $task_num completed successfully!"
            else
                print_error "❌ Task $task_num failed!"
                return 1
            fi
        else
            print_warning "⏭️  Skipping Task $task_num execution."
            print_status "You can run it later with: ./$script_name"
        fi
    else
        print_error "❌ Failed to download script: $script_name"
        return 1
    fi
    
    echo ""
}

# Function to show menu
show_menu() {
    echo ""
    print_header "=================================================================="
    print_header "  📋 CHALLENGE LAB TASK MENU"
    print_header "=================================================================="
    echo ""
    echo "1) 🪣  Task 1: Create Cloud Storage Bucket"
    echo "2) 💻  Task 2: Create VM with Persistent Disk"
    echo "3) 🌐  Task 3: Install NGINX on VM"
    echo "4) 🚀  Run All Tasks Sequentially"
    echo "5) 📥  Download All Scripts Only"
    echo "6) ❌  Exit"
    echo ""
}

# Function to download all scripts
download_all_scripts() {
    print_status "📥 Downloading all scripts..."
    
    # Download Task 1
    print_status "Downloading Task 1 script..."
    curl -sL "$TASK1_URL" -o "task1-create-storage-bucket.sh"
    chmod +x "task1-create-storage-bucket.sh"
    
    # Download Task 2
    print_status "Downloading Task 2 script..."
    curl -sL "$TASK2_URL" -o "task2-create-vm-with-disk.sh"
    chmod +x "task2-create-vm-with-disk.sh"
    
    # Download Task 3
    print_status "Downloading Task 3 script..."
    curl -sL "$TASK3_URL" -o "task3-install-nginx.sh"
    chmod +x "task3-install-nginx.sh"
    
    print_status "✅ All scripts downloaded and made executable!"
    echo ""
    echo "Available scripts:"
    echo "- task1-create-storage-bucket.sh"
    echo "- task2-create-vm-with-disk.sh"
    echo "- task3-install-nginx.sh"
}

# Function to run all tasks
run_all_tasks() {
    print_header "🚀 RUNNING ALL TASKS SEQUENTIALLY"
    echo ""
    
    # Task 1
    if download_and_run "1" "$TASK1_URL" "task1-create-storage-bucket.sh" "CREATE CLOUD STORAGE BUCKET"; then
        echo ""
        read -p "⏭️  Continue to Task 2? (y/N): " continue_task2
        if [[ ! "$continue_task2" =~ ^[Yy]$ ]]; then
            print_warning "Stopping at Task 1."
            return 0
        fi
    else
        print_error "Task 1 failed. Stopping execution."
        return 1
    fi
    
    # Task 2
    if download_and_run "2" "$TASK2_URL" "task2-create-vm-with-disk.sh" "CREATE VM WITH PERSISTENT DISK"; then
        echo ""
        read -p "⏭️  Continue to Task 3? (y/N): " continue_task3
        if [[ ! "$continue_task3" =~ ^[Yy]$ ]]; then
            print_warning "Stopping at Task 2."
            return 0
        fi
    else
        print_error "Task 2 failed. Stopping execution."
        return 1
    fi
    
    # Task 3
    if download_and_run "3" "$TASK3_URL" "task3-install-nginx.sh" "INSTALL NGINX ON VM"; then
        echo ""
        print_header "🎉 ALL TASKS COMPLETED SUCCESSFULLY!"
        print_header "🏆 CHALLENGE LAB ARC120 FINISHED!"
    else
        print_error "Task 3 failed."
        return 1
    fi
}

# Main execution
print_status "🔍 Checking prerequisites..."

# Check if curl is available
if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install curl first."
    exit 1
fi

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install Google Cloud SDK first."
    exit 1
fi

print_status "✅ Prerequisites check passed!"

# Show welcome message
echo ""
print_header "👋 Welcome to the Challenge Lab Automation Script!"
echo ""
echo "This script will help you complete all tasks in ARC120:"
echo "• Task 1: Create Cloud Storage Bucket"
echo "• Task 2: Create VM with Persistent Disk"  
echo "• Task 3: Install NGINX on VM"
echo ""
echo "Each script will:"
echo "✅ Prompt for required lab-specific values"
echo "✅ Validate inputs and configurations"
echo "✅ Execute the task with error handling"
echo "✅ Provide verification and next steps"

# Main menu loop
while true; do
    show_menu
    read -p "Please select an option (1-6): " choice
    
    case $choice in
        1)
            download_and_run "1" "$TASK1_URL" "task1-create-storage-bucket.sh" "CREATE CLOUD STORAGE BUCKET"
            ;;
        2)
            download_and_run "2" "$TASK2_URL" "task2-create-vm-with-disk.sh" "CREATE VM WITH PERSISTENT DISK"
            ;;
        3)
            download_and_run "3" "$TASK3_URL" "task3-install-nginx.sh" "INSTALL NGINX ON VM"
            ;;
        4)
            run_all_tasks
            ;;
        5)
            download_all_scripts
            ;;
        6)
            print_warning "👋 Goodbye! Happy learning!"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please select 1-6."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
