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

# Function to show inter-task verification (between tasks)
show_inter_task_verification() {
    local current_task=$1
    local next_task=$2
    
    echo ""
    echo "=================================================================="
    echo "  🎯 TASK $current_task COMPLETED → TASK $next_task"
    echo "=================================================================="
    echo ""
    echo "       📺 Don't forget to LIKE & SUBSCRIBE! 👍"
    echo ""
    echo "      ████████████████████████████████████████"
    echo "      █    🎬 CodeWithGarry YouTube Channel    █"
    echo "      █                                        █"
    echo "      █    👍 LIKE this solution if helpful    █"
    echo "      █    🔔 SUBSCRIBE for more content       █"
    echo "      █    💬 COMMENT your feedback           █"
    echo "      █                                        █"
    echo "      ████████████████████████████████████████"
    echo ""
    echo "🔗 https://www.youtube.com/@CodeWithGarry"
    echo ""
    
    # Simple subscription reminder
    read -p "Quick check - Are you subscribed to CodeWithGarry? (yes): " quick_check
    
    if [[ -z "$quick_check" || "$quick_check" =~ ^[Yy] ]]; then
        print_status "✅ Awesome! Thanks for your support!"
    fi
    
    echo ""
    print_status "🚀 Ready to proceed to Task $next_task!"
    read -p "Press ENTER to continue..."
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
                
                # Show inter-task verification if not the last task
                if [[ "$task_num" -lt 3 ]]; then
                    local next_task_num=$((task_num + 1))
                    show_inter_task_verification "$task_num" "$next_task_num"
                fi
                return 0
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
    local next_task=$(get_next_task)
    
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
        echo "2) � Task 2: Create VM with Persistent Disk (LOCKED - Complete Task 1 first)"
    else
        echo "2) �💻 Task 2: Create VM with Persistent Disk"
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
    echo "5) �  Show Lab Tutorial & Overview"
    echo "6) �📥  Download All Scripts Only"
    echo "7) 🔄  Reset Progress (Clear completion markers)"
    echo "8) ❌  Exit"
    echo ""
    
    if [[ "$next_task" == "completed" ]]; then
        echo "🎉 ALL TASKS COMPLETED! Lab ARC120 is finished!"
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
    
    local next_task=$(get_next_task)
    
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
                        # Final celebration with channel promotion
                        echo "=================================================================="
                        echo "🎉 CONGRATULATIONS! ALL TASKS COMPLETED! 🎉"
                        echo "=================================================================="
                        echo ""
                        echo "      🏆 ARC120 Challenge Lab COMPLETED! 🏆"
                        echo ""
                        echo "      Thanks for using CodeWithGarry's solution!"
                        echo ""
                        echo "      ████████████████████████████████████████"
                        echo "      █    🎬 CodeWithGarry YouTube Channel    █"
                        echo "      █                                        █"
                        echo "      █    👍 LIKE this video if it helped     █"
                        echo "      █    🔔 SUBSCRIBE for more labs          █"
                        echo "      █    💬 SHARE with your friends          █"
                        echo "      █                                        █"
                        echo "      ████████████████████████████████████████"
                        echo ""
                        echo "🔗 https://www.youtube.com/@CodeWithGarry"
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

# Function to run all tasks
run_all_tasks() {
    run_all_remaining_tasks
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

# Show verification process first
show_verification_process

# Show welcome message
echo ""
print_header "👋 Welcome to the Challenge Lab Automation Script!"
echo ""
echo "This script will help you complete all tasks in ARC120:"
echo "• Task 1: Create Cloud Storage Bucket"
echo "• Task 2: Create VM with Persistent Disk"  
echo "• Task 3: Install NGINX on VM"
echo ""
# Initial setup and tutorial
echo "📖 Would you like to see the lab overview and tutorial?"
read -p "Show tutorial? (Y/n): " show_intro_tutorial
if [[ "$show_intro_tutorial" =~ ^[Yy]$ || -z "$show_intro_tutorial" ]]; then
    show_lab_overview
fi

echo "Each script will:"
echo "✅ Prompt for required lab-specific values"
echo "✅ Validate inputs and configurations"
echo "✅ Execute the task with error handling"
echo "✅ Provide verification and next steps"
echo "✅ Include educational content and tutorials"
echo "✅ Allow you to go back and modify settings"

# Main menu loop
while true; do
    show_menu
    read -p "Select option (1-8): " choice
    
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
            echo "Thank you for using CodeWithGarry Challenge Lab Runner!"
            echo "� Subscribe: https://www.youtube.com/@CodeWithGarry"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ Invalid choice. Select 1-8."
            ;;
    esac
    
    echo ""
    read -p "Press ENTER to continue..."
done
