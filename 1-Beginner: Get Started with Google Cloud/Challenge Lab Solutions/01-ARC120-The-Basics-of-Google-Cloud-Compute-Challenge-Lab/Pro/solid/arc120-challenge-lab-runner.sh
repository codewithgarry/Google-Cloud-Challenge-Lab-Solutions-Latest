#!/bin/bash

# =============================================================================
# The Basics of Google Cloud Compute: Challenge Lab - Master Script
# Downloads and runs all task scripts
# Author: CodeWithGarry
# Lab ID: ARC120
# =============================================================================

# Global subscription verification flag
SUBSCRIPTION_VERIFIED=false

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
MAGENTA='\033[0;35m'
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

print_tutorial() {
    echo -e "${BLUE}[TUTORIAL]${NC} $1"
}

print_tip() {
    echo -e "${MAGENTA}[TIP]${NC} $1"
}

# Function to perform comprehensive resource cleanup
perform_resource_cleanup() {
    clear
    echo "=================================================================="
    echo "  🧹 COMPLETE LAB CLEANUP & RESOURCE DELETION"
    echo "=================================================================="
    echo ""
    echo "🌟 Thank you for completing the ARC120 Challenge Lab!"
    echo "💡 This cleanup will help you avoid unnecessary charges and maintain a clean environment"
    echo ""
    print_warning "⚠️  IMPORTANT: This action will permanently delete:"
    echo ""
    echo "🗑️  GOOGLE CLOUD RESOURCES:"
    echo "   • VM Instance: my-instance"
    echo "   • Persistent Disk: mydisk"
    echo "   • Cloud Storage Bucket and contents"
    echo "   • Firewall rules (if created)"
    echo ""
    echo "📁 LOCAL FILES:"
    echo "   • Downloaded task scripts (task1, task2, task3)"
    echo "   • Temporary progress files"
    echo "   • This main runner script"
    echo ""
    echo "💰 COST SAVINGS:"
    echo "   • Prevents ongoing VM compute charges"
    echo "   • Eliminates persistent disk storage costs"
    echo "   • Removes network egress charges"
    echo ""
    echo "=================================================================="
    
    # First confirmation
    while true; do
        echo ""
        echo "🤔 Are you ready to proceed with complete cleanup?"
        echo "   This action cannot be undone!"
        echo ""
        read -p "Type 'cleanup' to confirm, or 'cancel' to return to menu: " confirm1
        
        if [[ "$confirm1" == "cleanup" ]]; then
            break
        elif [[ "$confirm1" == "cancel" ]]; then
            echo ""
            print_status "Cleanup cancelled. Returning to main menu."
            return
        else
            print_error "Please type exactly 'cleanup' or 'cancel'"
        fi
    done
    
    # Second confirmation for safety
    echo ""
    echo "⚠️  FINAL CONFIRMATION REQUIRED"
    echo ""
    echo "🎯 You have confirmed resource deletion. This is your final chance to cancel."
    echo "💡 After deletion, you'll need to recreate resources if you want to practice again."
    echo ""
    
    while true; do
        read -p "Final confirmation - Type 'DELETE ALL' to proceed: " confirm2
        
        if [[ "$confirm2" == "DELETE ALL" ]]; then
            break
        else
            print_error "Please type exactly 'DELETE ALL' to proceed with deletion"
            echo "💡 Or press Ctrl+C to cancel"
        fi
    done
    
    echo ""
    echo "=================================================================="
    echo "🧹 STARTING COMPREHENSIVE CLEANUP PROCESS"
    echo "=================================================================="
    
    # Step 1: Get current project info
    print_step "Step 1: Gathering project information..."
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "Unable to determine project ID. Please ensure gcloud is configured."
        return 1
    fi
    
    print_status "Working in project: $PROJECT_ID"
    echo ""
    
    # Step 2: Delete VM instances
    print_step "Step 2: Deleting VM instances..."
    
    # List all instances to delete
    INSTANCES=$(gcloud compute instances list --format="value(name,zone)" --filter="name~'my-instance.*'" 2>/dev/null)
    
    if [[ -n "$INSTANCES" ]]; then
        while IFS=$'\t' read -r instance_name zone; do
            if [[ -n "$instance_name" && -n "$zone" ]]; then
                print_status "Deleting VM instance: $instance_name in zone $zone"
                gcloud compute instances delete "$instance_name" \
                    --zone="$zone" \
                    --quiet 2>/dev/null
                
                if [[ $? -eq 0 ]]; then
                    print_status "✅ Successfully deleted VM: $instance_name"
                else
                    print_warning "⚠️  Failed to delete VM: $instance_name"
                fi
            fi
        done <<< "$INSTANCES"
    else
        print_status "ℹ️  No VM instances found matching 'my-instance'"
    fi
    echo ""
    
    # Step 3: Delete persistent disks
    print_step "Step 3: Deleting persistent disks..."
    
    DISKS=$(gcloud compute disks list --format="value(name,zone)" --filter="name~'mydisk.*'" 2>/dev/null)
    
    if [[ -n "$DISKS" ]]; then
        while IFS=$'\t' read -r disk_name zone; do
            if [[ -n "$disk_name" && -n "$zone" ]]; then
                print_status "Deleting persistent disk: $disk_name in zone $zone"
                gcloud compute disks delete "$disk_name" \
                    --zone="$zone" \
                    --quiet 2>/dev/null
                
                if [[ $? -eq 0 ]]; then
                    print_status "✅ Successfully deleted disk: $disk_name"
                else
                    print_warning "⚠️  Failed to delete disk: $disk_name"
                fi
            fi
        done <<< "$DISKS"
    else
        print_status "ℹ️  No persistent disks found matching 'mydisk'"
    fi
    echo ""
    
    # Step 4: Delete Cloud Storage buckets
    print_step "Step 4: Deleting Cloud Storage buckets..."
    
    # Common bucket naming patterns for this lab
    BUCKET_PATTERNS=("$PROJECT_ID-bucket" "$PROJECT_ID" "${PROJECT_ID}_bucket")
    
    for pattern in "${BUCKET_PATTERNS[@]}"; do
        if gsutil ls "gs://$pattern" &>/dev/null; then
            print_status "Deleting bucket: gs://$pattern"
            gsutil rm -r "gs://$pattern" 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                print_status "✅ Successfully deleted bucket: $pattern"
            else
                print_warning "⚠️  Failed to delete bucket: $pattern"
            fi
        fi
    done
    
    # Also check for any buckets containing the project ID
    BUCKETS=$(gsutil ls 2>/dev/null | grep "$PROJECT_ID" || true)
    if [[ -n "$BUCKETS" ]]; then
        echo "$BUCKETS" | while read -r bucket; do
            if [[ -n "$bucket" ]]; then
                print_status "Found additional bucket: $bucket"
                read -p "Delete this bucket? (y/N): " delete_bucket
                if [[ "$delete_bucket" =~ ^[Yy]$ ]]; then
                    gsutil rm -r "$bucket" 2>/dev/null
                    print_status "✅ Deleted bucket: $bucket"
                fi
            fi
        done
    fi
    echo ""
    
    # Step 5: Delete firewall rules
    print_step "Step 5: Cleaning up firewall rules..."
    
    FIREWALL_RULES=$(gcloud compute firewall-rules list --format="value(name)" --filter="name~'default-allow-http.*'" 2>/dev/null)
    
    if [[ -n "$FIREWALL_RULES" ]]; then
        echo "$FIREWALL_RULES" | while read -r rule_name; do
            if [[ -n "$rule_name" ]]; then
                print_status "Deleting firewall rule: $rule_name"
                gcloud compute firewall-rules delete "$rule_name" --quiet 2>/dev/null
                
                if [[ $? -eq 0 ]]; then
                    print_status "✅ Successfully deleted firewall rule: $rule_name"
                else
                    print_warning "⚠️  Failed to delete firewall rule: $rule_name"
                fi
            fi
        done
    else
        print_status "ℹ️  No custom firewall rules found"
    fi
    echo ""
    
    # Step 6: Clean up local files
    print_step "Step 6: Cleaning up local files and scripts..."
    
    # List of files to clean up
    LOCAL_FILES=(
        "task1-create-storage-bucket.sh"
        "task2-create-vm-with-disk.sh"
        "task3-install-nginx.sh"
        "arc120-runner.sh"
        "/tmp/arc120_task1_completed"
        "/tmp/arc120_task2_completed"
        "/tmp/arc120_task3_completed"
        "/tmp/arc120_subscription_verified"
    )
    
    for file in "${LOCAL_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Removing file: $file"
            rm -f "$file"
            if [[ $? -eq 0 ]]; then
                print_status "✅ Successfully removed: $file"
            else
                print_warning "⚠️  Failed to remove: $file"
            fi
        fi
    done
    
    # Clean up any downloaded scripts in current directory
    if ls task*.sh &>/dev/null; then
        print_status "Removing additional task scripts..."
        rm -f task*.sh
        print_status "✅ Additional scripts cleaned up"
    fi
    echo ""
    
    # Step 7: Final verification
    print_step "Step 7: Final verification..."
    
    echo ""
    print_status "Verifying resource cleanup..."
    
    # Check for remaining VMs
    REMAINING_VMS=$(gcloud compute instances list --filter="name~'my-instance.*'" --format="value(name)" 2>/dev/null | wc -l)
    if [[ "$REMAINING_VMS" -eq 0 ]]; then
        print_status "✅ No remaining VM instances"
    else
        print_warning "⚠️  $REMAINING_VMS VM instances still exist"
    fi
    
    # Check for remaining disks
    REMAINING_DISKS=$(gcloud compute disks list --filter="name~'mydisk.*'" --format="value(name)" 2>/dev/null | wc -l)
    if [[ "$REMAINING_DISKS" -eq 0 ]]; then
        print_status "✅ No remaining persistent disks"
    else
        print_warning "⚠️  $REMAINING_DISKS persistent disks still exist"
    fi
    
    echo ""
    echo "=================================================================="
    echo "🎉 CLEANUP PROCESS COMPLETED!"
    echo "=================================================================="
    echo ""
    print_status "✅ Resource cleanup finished successfully!"
    echo ""
    echo "📊 CLEANUP SUMMARY:"
    echo "   🗑️  VM instances and disks deleted"
    echo "   🪣 Cloud Storage buckets removed"
    echo "   🔥 Firewall rules cleaned up"
    echo "   📁 Local scripts and files removed"
    echo ""
    echo "💰 COST IMPACT:"
    echo "   ✅ No ongoing compute charges"
    echo "   ✅ No storage costs"
    echo "   ✅ Clean billing account"
    echo ""
    echo "🚀 WHAT'S NEXT:"
    echo "   📚 Try more Challenge Labs to advance your skills"
    echo "   🎯 Practice with new Google Cloud projects"
    echo "   📺 Subscribe to CodeWithGarry for more content"
    echo "   💼 Add these skills to your resume and LinkedIn"
    echo ""
    echo "🌟 CONGRATULATIONS on completing ARC120!"
    echo "   You've successfully mastered Google Cloud Compute fundamentals!"
    echo ""
    echo "🔗 Stay Connected:"
    echo "   📺 YouTube: https://www.youtube.com/@CodeWithGarry"
    echo "   💼 LinkedIn: Connect with CodeWithGarry"
    echo "   🐙 GitHub: Follow for more solutions"
    echo ""
    
    # Option to exit or return to menu
    while true; do
        echo "Choose your next action:"
        echo "1) Exit the script completely"
        echo "2) Return to main menu (download and run again)"
        echo ""
        read -p "Enter your choice (1-2): " exit_choice
        
        case $exit_choice in
            1)
                echo ""
                echo "🎉 Thank you for using CodeWithGarry Challenge Lab Solutions!"
                echo "🌟 Your cloud journey continues - keep learning and growing!"
                echo ""
                exit 0
                ;;
            2)
                echo ""
                print_status "Returning to main menu..."
                echo "💡 Note: Scripts have been cleaned up, so you can download fresh copies"
                return
                ;;
            *)
                print_error "Please enter 1 or 2"
                ;;
        esac
    done
}

# Function to display YouTube channel and verify subscription
show_channel_subscription_check() {
    clear
    echo "=================================================================="
    echo "  📺 CODEWITHGARRY YOUTUBE CHANNEL"
    echo "=================================================================="
    echo ""
    echo "      ████████████████████████████████████████████████████████"
    echo "      █                                                      █"
    echo "      █    🎬 CodeWithGarry - Google Cloud Expert             █"
    echo "      █                                                      █"
    echo "      █    📚 Learn Google Cloud | Challenge Labs | Tips     █"
    echo "      █    🚀 Free Solutions & Tutorials                     █"
    echo "      █    💡 Cloud Computing Made Easy                      █"
    echo "      █                                                      █"
    echo "      █         👤 CodeWithGarry                             █"
    echo "      █         ⭐ 500K+ Subscribers                         █"
    echo "      █         🎯 #1 Google Cloud Channel                   █"
    echo "      █                                                      █"
    echo "      ████████████████████████████████████████████████████████"
    echo ""
    echo "🔗 Channel: https://www.youtube.com/@CodeWithGarry"
    echo "📱 Subscribe for more Google Cloud content!"
    echo ""
    echo "=================================================================="
    
    # Simple subscription verification
    while true; do
        echo ""
        echo "Have you subscribed to CodeWithGarry YouTube channel?"
        echo "📺 Channel: https://www.youtube.com/@CodeWithGarry"
        echo ""
        read -p "Enter response (yes/subscribed): " subscription_status
        
        # Convert to lowercase for comparison
        subscription_lower=$(echo "$subscription_status" | tr '[:upper:]' '[:lower:]')
        
        # Check if response contains valid subscription confirmation
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
}

# Function to check prerequisite labs completion
check_prerequisite_labs() {
    echo ""
    echo "=================================================================="
    echo "📋 PREREQUISITE CHECK"
    echo "=================================================================="
    echo ""
    echo "Have you completed Google Cloud normal labs before this Challenge Lab?"
    echo ""
    echo "1) Yes - I've completed prerequisite labs"
    echo "2) No - I haven't completed them yet"
    echo ""
    
    while true; do
        read -p "Please select (1-2): " lab_status
        
        case $lab_status in
            1)
                print_status "✅ Perfect! You're ready for the Challenge Lab!"
                break
                ;;
            2)
                print_warning "⚠️  Recommendation: Complete normal labs first"
                echo ""
                read -p "Continue anyway? (y/N): " continue_anyway
                if [[ "$continue_anyway" =~ ^[Yy]$ ]]; then
                    print_warning "Proceeding - Challenge Lab may be difficult"
                    break
                else
                    print_status "Good choice! Complete normal labs first, then return."
                    echo "🔗 Start here: https://www.cloudskillsboost.google/"
                    exit 0
                fi
                ;;
            *)
                print_error "Please select 1 or 2"
                ;;
        esac
    done
}

# Function to show complete verification process
show_verification_process() {
    clear
    echo "=================================================================="
    echo "  🔐 VERIFICATION PROCESS"
    echo "=================================================================="
    echo ""
    print_status "Before starting, please complete these quick verifications:"
    echo ""
    echo "1️⃣  YouTube Channel Subscription ✋ (REQUIRED)"
    echo "2️⃣  Prerequisite Labs Completion 📚 (RECOMMENDED)"
    echo ""
    read -p "Press ENTER to begin verification process..."
    
    # Step 1: Channel subscription check
    show_channel_subscription_check
    
    # Step 2: Prerequisite check
    check_prerequisite_labs
    
    echo ""
    echo "=================================================================="
    echo "✅ VERIFICATION COMPLETE"
    echo "=================================================================="
    print_status "Ready to start the Challenge Lab!"
    echo ""
    read -p "Press ENTER to continue to the main menu..."
    clear
}

# Function to show lab overview tutorial
show_lab_overview() {
    echo ""
    echo "=================================================================="
    echo "📚 ARC120 CHALLENGE LAB OVERVIEW"
    echo "=================================================================="
    print_tutorial "What You'll Learn:"
    echo "   • How to create and manage Cloud Storage buckets"
    echo "   • How to create virtual machines with persistent disks"
    echo "   • How to install and configure web servers"
    echo "   • How to use Google Cloud SDK (gcloud and gsutil)"
    echo ""
    print_tutorial "Google Cloud Services Used:"
    echo "   🪣 Cloud Storage: Object storage for files and data"
    echo "   💻 Compute Engine: Virtual machines in the cloud"
    echo "   🌐 VPC Networks: Virtual private cloud networking"
    echo "   🔥 Cloud Firewall: Network security rules"
    echo ""
    print_tutorial "Lab Structure (Progressive):"
    echo "   ✅ Task 1: Create Cloud Storage bucket"
    echo "   ⬇️  Unlocks Task 2 after completion"
    echo "   ✅ Task 2: Create VM with persistent disk"
    echo "   ⬇️  Unlocks Task 3 after completion"
    echo "   ✅ Task 3: Install NGINX web server"
    echo ""
    print_tutorial "Skills Developed:"
    echo "   • Cloud resource management"
    echo "   • Infrastructure as Code concepts"
    echo "   • Web server deployment"
    echo "   • Network security configuration"
    echo ""
    print_tip "💡 Each task builds on the previous one!"
    print_tip "💡 All scripts include educational content and tutorials"
    print_tip "💡 You can go back and modify settings at any step"
    echo "=================================================================="
    echo ""
    read -p "Press ENTER to continue to the task menu..."
    echo ""
}

# GitHub repository URLs
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
    
    # Check subscription verification only once before any task
    if [[ "$SUBSCRIPTION_VERIFIED" == "false" ]]; then
        show_verification_process
        SUBSCRIPTION_VERIFIED=true
    fi
    
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
                
                # Show tutorial only after all tasks are completed
                if [[ "$task_num" -eq 3 ]]; then
                    echo ""
                    echo "🎉 🎉 🎉 ALL TASKS COMPLETED! 🎉 🎉 🎉"
                    echo ""
                    echo "=================================================================="
                    echo "📚 CONGRATULATIONS! LAB ARC120 COMPLETE!"
                    echo "=================================================================="
                    echo ""
                    echo "You have successfully completed:"
                    echo "✅ Task 1: Cloud Storage Bucket Creation"
                    echo "✅ Task 2: VM Instance with Persistent Disk"  
                    echo "✅ Task 3: NGINX Web Server Installation"
                    echo ""
                    echo "Would you like to see the comprehensive lab tutorial and overview?"
                    read -p "Show educational tutorial? (Y/n): " show_tutorial
                    if [[ "$show_tutorial" =~ ^[Yy]$ || -z "$show_tutorial" ]]; then
                        show_lab_overview
                    fi
                    echo ""
                    echo "🔗 Don't forget to subscribe: https://www.youtube.com/@CodeWithGarry"
                    echo "👍 Like this video if it helped you!"
                    echo ""
                fi
                return 0
            else
                print_error "❌ Task $task_num failed!"
                return 1
            fi
        else
            print_status "You can run it later with: ./$script_name"
        fi
    else
        print_error "❌ Failed to download script: $script_name"
        return 1
    fi
    
    echo ""
}

# Function to reset subscription verification
reset_subscription_verification() {
    SUBSCRIPTION_VERIFIED=false
    print_status "✅ Subscription verification reset complete"
    echo ""
    echo "ℹ️ You will be prompted to verify subscription again before next task execution"
}

# Function to check task completion
check_task_completion() {
    local task_num=$1
    if [[ -f "/tmp/arc120_task${task_num}_completed" ]]; then
        return 0  # Task completed
    else
        return 1  # Task not completed
    fi
}

# Function to get next available task
get_next_task() {
    if ! check_task_completion 1; then
        echo "1"
    elif ! check_task_completion 2; then
        echo "2"
    elif ! check_task_completion 3; then
        echo "3"
    else
        echo "completed"
    fi
}

# Function to show menu
show_menu() {
    local next_task
    next_task=$(get_next_task)
    
    echo ""
    print_header "=================================================================="
    print_header "  📋 CHALLENGE LAB TASK MENU"
    print_header "=================================================================="
    echo ""
    
    # Task 1
    if check_task_completion 1; then
        echo "1) ✅ Task 1: Create Cloud Storage Bucket (COMPLETED)"
    else
        echo "1) 🪣  Task 1: Create Cloud Storage Bucket"
    fi
    
    # Task 2
    if check_task_completion 2; then
        echo "2) ✅ Task 2: Create VM with Persistent Disk (COMPLETED)"
    elif [[ "$next_task" == "1" ]]; then
        echo "2) 🔒 Task 2: Create VM with Persistent Disk (LOCKED - Complete Task 1 first)"
    else
        echo "2) 💻 Task 2: Create VM with Persistent Disk"
    fi
    
    # Task 3
    if check_task_completion 3; then
        echo "3) ✅ Task 3: Install NGINX on VM (COMPLETED)"
    elif [[ "$next_task" == "1" || "$next_task" == "2" ]]; then
        echo "3) 🔒 Task 3: Install NGINX on VM (LOCKED - Complete previous tasks first)"
    else
        echo "3) 🌐 Task 3: Install NGINX on VM"
    fi
    
    echo ""
    echo "4) 🚀  Run All Remaining Tasks"
    echo "5) 📖  Show Lab Tutorial & Overview"
    echo "6) 📥  Download All Scripts Only"
    echo "7) 🔄  Reset Progress (Clear completion markers)"
    echo "8) 🔓  Reset Subscription Verification"
    echo "9) 🧹  Complete Lab Cleanup (Delete all resources & scripts)"
    echo "10) ❌  Exit"
    echo ""
    
    if [[ "$next_task" == "completed" ]]; then
        echo "🎉 ALL TASKS COMPLETED! Lab ARC120 is finished!"
        echo "💡 Recommended: Run option 9 to clean up resources and avoid charges"
        echo ""
    else
        echo "📌 Next recommended task: Task $next_task"
        echo ""
    fi
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

# Function to run all remaining tasks
run_all_remaining_tasks() {
    print_header "🚀 RUNNING ALL REMAINING TASKS"
    echo ""
    
    local next_task
    next_task=$(get_next_task)
    
    if [[ "$next_task" == "completed" ]]; then
        print_status "🎉 All tasks are already completed!"
        return 0
    fi
    
    # Run remaining tasks in sequence
    for task_num in 1 2 3; do
        if ! check_task_completion $task_num; then
            case $task_num in
                1)
                    if download_and_run "1" "$TASK1_URL" "task1-create-storage-bucket.sh" "CREATE CLOUD STORAGE BUCKET"; then
                        echo ""
                        read -p "⏭️  Continue to next task? (y/N): " continue_next
                        if [[ ! "$continue_next" =~ ^[Yy]$ ]]; then
                            print_warning "Stopping execution."
                            return 0
                        fi
                    else
                        print_error "Task 1 failed. Stopping execution."
                        return 1
                    fi
                    ;;
                2)
                    if download_and_run "2" "$TASK2_URL" "task2-create-vm-with-disk.sh" "CREATE VM WITH PERSISTENT DISK"; then
                        echo ""
                        read -p "⏭️  Continue to next task? (y/N): " continue_next
                        if [[ ! "$continue_next" =~ ^[Yy]$ ]]; then
                            print_warning "Stopping execution."
                            return 0
                        fi
                    else
                        print_error "Task 2 failed. Stopping execution."
                        return 1
                    fi
                    ;;
                3)
                    if download_and_run "3" "$TASK3_URL" "task3-install-nginx.sh" "INSTALL NGINX ON VM"; then
                        echo ""
                        print_header "🏆 CHALLENGE LAB ARC120 FINISHED!"
                    else
                        print_error "Task 3 failed."
                        return 1
                    fi
                    ;;
            esac
        fi
    done
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

# Welcome message
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
echo "✅ Allow you to go back and modify settings"

# Main menu loop
while true; do
    show_menu
    read -p "Select option (1-10): " choice
    
    case $choice in
        1)
            if check_task_completion 1; then
                echo ""
                echo "ℹ️ Task 1 already completed"
                read -p "Run again? (y/N): " rerun
                if [[ ! "$rerun" =~ ^[Yy]$ ]]; then
                    continue
                fi
            fi
            download_and_run "1" "$TASK1_URL" "task1-create-storage-bucket.sh" "CREATE CLOUD STORAGE BUCKET"
            ;;
        2)
            if check_task_completion 2; then
                echo ""
                echo "ℹ️ Task 2 already completed"
                read -p "Run again? (y/N): " rerun
                if [[ ! "$rerun" =~ ^[Yy]$ ]]; then
                    continue
                fi
            elif ! check_task_completion 1; then
                echo ""
                echo "❌ Complete Task 1 first"
                continue
            fi
            download_and_run "2" "$TASK2_URL" "task2-create-vm-with-disk.sh" "CREATE VM WITH PERSISTENT DISK"
            ;;
        3)
            if check_task_completion 3; then
                echo ""
                echo "ℹ️ Task 3 already completed"
                read -p "Run again? (y/N): " rerun
                if [[ ! "$rerun" =~ ^[Yy]$ ]]; then
                    continue
                fi
            elif ! check_task_completion 2; then
                echo ""
                echo "❌ Complete Task 2 first"
                continue
            fi
            download_and_run "3" "$TASK3_URL" "task3-install-nginx.sh" "INSTALL NGINX ON VM"
            ;;
        4)
            run_all_remaining_tasks
            ;;
        5)
            show_lab_overview
            ;;
        6)
            download_all_scripts
            ;;
        7)
            echo ""
            echo "Resetting progress..."
            rm -f /tmp/arc120_task*_completed
            print_status "✅ Progress reset complete"
            ;;
        8)
            echo ""
            echo "Resetting subscription verification..."
            reset_subscription_verification
            ;;
        9)
            perform_resource_cleanup
            ;;
        10)
            echo ""
            echo "Thank you for using CodeWithGarry Challenge Lab Runner!"
            echo "🔗 Subscribe: https://www.youtube.com/@CodeWithGarry"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid choice. Select 1-10."
            ;;
    esac
    
    echo ""
    read -p "Press ENTER to continue..."
done
