#!/bin/bash

# =============================================================================
# Get Started with Pub/Sub: Challenge Lab - Master Script
# Downloads and runs all task scripts
# Author: CodeWithGarry
# Lab ID: ARC113
# =============================================================================

# Global subscription verification flag
SUBSCRIPTION_VERIFIED=false

echo "=================================================================="
echo "  🚀 GET STARTED WITH PUB/SUB CHALLENGE LAB"
echo "=================================================================="
echo "  📚 Lab ID: ARC113"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Tasks: 3 (Create Subscription + Publish, View Message, Create Snapshot)"
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
    echo "🌟 Thank you for completing the ARC113 Challenge Lab!"
    echo "💡 This cleanup will help you avoid unnecessary charges and maintain a clean environment"
    echo ""
    print_warning "⚠️  IMPORTANT: This action will permanently delete:"
    echo ""
    echo "🗑️  GOOGLE CLOUD RESOURCES:"
    echo "   • Pub/Sub Topic: gcloud-pubsub-topic (if created)"
    echo "   • Subscription: pubsub-subscription-message"
    echo "   • Snapshot: pubsub-snapshot"
    echo "   • Pre-created subscription: gcloud-pubsub-subscription"
    echo ""
    echo "📁 LOCAL FILES:"
    echo "   • Downloaded task scripts (task1, task2, task3)"
    echo "   • Temporary progress files"
    echo "   • This main runner script"
    echo ""
    echo "💰 COST SAVINGS:"
    echo "   • Eliminates Pub/Sub storage costs"
    echo "   • Removes snapshot storage charges"
    echo "   • Clean billing account"
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
    
    # Step 2: Delete snapshots
    print_step "Step 2: Deleting Pub/Sub snapshots..."
    
    SNAPSHOTS=$(gcloud pubsub snapshots list --format="value(name)" --filter="name:*pubsub-snapshot*" 2>/dev/null)
    
    if [[ -n "$SNAPSHOTS" ]]; then
        echo "$SNAPSHOTS" | while read -r snapshot_name; do
            if [[ -n "$snapshot_name" ]]; then
                print_status "Deleting snapshot: $(basename "$snapshot_name")"
                gcloud pubsub snapshots delete "$snapshot_name" --quiet 2>/dev/null
                
                if [[ $? -eq 0 ]]; then
                    print_status "✅ Successfully deleted snapshot: $(basename "$snapshot_name")"
                else
                    print_warning "⚠️  Failed to delete snapshot: $(basename "$snapshot_name")"
                fi
            fi
        done
    else
        print_status "ℹ️  No snapshots found matching 'pubsub-snapshot'"
    fi
    echo ""
    
    # Step 3: Delete subscriptions
    print_step "Step 3: Deleting Pub/Sub subscriptions..."
    
    SUBSCRIPTIONS=$(gcloud pubsub subscriptions list --format="value(name)" --filter="name:*pubsub-subscription*" 2>/dev/null)
    
    if [[ -n "$SUBSCRIPTIONS" ]]; then
        echo "$SUBSCRIPTIONS" | while read -r subscription_name; do
            if [[ -n "$subscription_name" ]]; then
                print_status "Deleting subscription: $(basename "$subscription_name")"
                gcloud pubsub subscriptions delete "$subscription_name" --quiet 2>/dev/null
                
                if [[ $? -eq 0 ]]; then
                    print_status "✅ Successfully deleted subscription: $(basename "$subscription_name")"
                else
                    print_warning "⚠️  Failed to delete subscription: $(basename "$subscription_name")"
                fi
            fi
        done
    else
        print_status "ℹ️  No subscriptions found matching 'pubsub-subscription'"
    fi
    echo ""
    
    # Step 4: Delete topics (only if user created them)
    print_step "Step 4: Cleaning up Pub/Sub topics..."
    
    TOPICS=$(gcloud pubsub topics list --format="value(name)" --filter="name:*gcloud-pubsub-topic*" 2>/dev/null)
    
    if [[ -n "$TOPICS" ]]; then
        echo "$TOPICS" | while read -r topic_name; do
            if [[ -n "$topic_name" ]]; then
                print_status "Found topic: $(basename "$topic_name")"
                read -p "Delete this topic? (y/N): " delete_topic
                if [[ "$delete_topic" =~ ^[Yy]$ ]]; then
                    gcloud pubsub topics delete "$topic_name" --quiet 2>/dev/null
                    print_status "✅ Deleted topic: $(basename "$topic_name")"
                fi
            fi
        done
    else
        print_status "ℹ️  No custom topics found"
    fi
    echo ""
    
    # Step 5: Clean up local files
    print_step "Step 5: Cleaning up local files and scripts..."
    
    # List of files to clean up
    LOCAL_FILES=(
        "task1-create-subscription-publish.sh"
        "task2-view-message.sh"
        "task3-create-snapshot.sh"
        "arc113-runner.sh"
        "/tmp/arc113_task1_completed"
        "/tmp/arc113_task2_completed"
        "/tmp/arc113_task3_completed"
        "/tmp/arc113_subscription_verified"
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
    
    # Step 6: Final verification
    print_step "Step 6: Final verification..."
    
    echo ""
    print_status "Verifying resource cleanup..."
    
    # Check for remaining subscriptions
    REMAINING_SUBS=$(gcloud pubsub subscriptions list --filter="name:*pubsub-subscription*" --format="value(name)" 2>/dev/null | wc -l)
    if [[ "$REMAINING_SUBS" -eq 0 ]]; then
        print_status "✅ No remaining subscriptions"
    else
        print_warning "⚠️  $REMAINING_SUBS subscriptions still exist"
    fi
    
    # Check for remaining snapshots
    REMAINING_SNAPS=$(gcloud pubsub snapshots list --filter="name:*pubsub-snapshot*" --format="value(name)" 2>/dev/null | wc -l)
    if [[ "$REMAINING_SNAPS" -eq 0 ]]; then
        print_status "✅ No remaining snapshots"
    else
        print_warning "⚠️  $REMAINING_SNAPS snapshots still exist"
    fi
    
    echo ""
    echo "=================================================================="
    echo "🎉 CLEANUP PROCESS COMPLETED!"
    echo "=================================================================="
    echo ""
    print_status "✅ Resource cleanup finished successfully!"
    echo ""
    echo "📊 CLEANUP SUMMARY:"
    echo "   🗑️  Pub/Sub subscriptions and snapshots deleted"
    echo "   📚 Local scripts and files removed"
    echo "   💰 Clean billing account"
    echo ""
    echo "🚀 WHAT'S NEXT:"
    echo "   📚 Try more Challenge Labs to advance your skills"
    echo "   🎯 Practice with new Google Cloud projects"
    echo "   📺 Subscribe to CodeWithGarry for more content"
    echo "   💼 Add these skills to your resume and LinkedIn"
    echo ""
    echo "🌟 CONGRATULATIONS on completing ARC113!"
    echo "   You've successfully mastered Google Cloud Pub/Sub fundamentals!"
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
    echo "📚 ARC113 CHALLENGE LAB OVERVIEW"
    echo "=================================================================="
    print_tutorial "What You'll Learn:"
    echo "   • How to create and manage Pub/Sub subscriptions"
    echo "   • How to publish messages to Pub/Sub topics"
    echo "   • How to pull and view messages from subscriptions"
    echo "   • How to create snapshots for message replay"
    echo ""
    print_tutorial "Google Cloud Services Used:"
    echo "   📮 Cloud Pub/Sub: Asynchronous messaging service"
    echo "   📚 Subscriptions: Message delivery endpoints"
    echo "   📷 Snapshots: Point-in-time message backups"
    echo "   🔗 Topics: Message distribution channels"
    echo ""
    print_tutorial "Lab Structure (Progressive):"
    echo "   ✅ Task 1: Create subscription and publish message"
    echo "   ⬇️  Unlocks Task 2 after completion"
    echo "   ✅ Task 2: View the published message"
    echo "   ⬇️  Unlocks Task 3 after completion"
    echo "   ✅ Task 3: Create snapshot for message replay"
    echo ""
    print_tutorial "Skills Developed:"
    echo "   • Asynchronous messaging concepts"
    echo "   • Message queuing and delivery"
    echo "   • Event-driven architecture"
    echo "   • Message replay capabilities"
    echo ""
    print_tip "💡 Each task builds on the previous one!"
    print_tip "💡 All scripts include educational content and tutorials"
    print_tip "💡 You can go back and modify settings at any step"
    echo "=================================================================="
    echo ""
    read -p "Press ENTER to continue to the task menu..."
    echo ""
}

# GitHub repository URLs - Updated for ARC113
REPO_BASE_URL="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/Pro/solid"

# Script URLs
TASK1_URL="$REPO_BASE_URL/sci-fi-1/topic-creator.sh"
TASK2_URL="$REPO_BASE_URL/sci-fi-2/subscription-manager.sh"
TASK3_URL="$REPO_BASE_URL/sci-fi-3/advanced-features.sh"

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
                
                # Mark task as completed
                touch "/tmp/arc113_task${task_num}_completed"
                
                # Show tutorial only after all tasks are completed
                if [[ "$task_num" -eq 3 ]]; then
                    echo ""
                    echo "🎉 🎉 🎉 ALL TASKS COMPLETED! 🎉 🎉 🎉"
                    echo ""
                    echo "=================================================================="
                    echo "📚 CONGRATULATIONS! LAB ARC113 COMPLETE!"
                    echo "=================================================================="
                    echo ""
                    echo "You have successfully completed:"
                    echo "✅ Task 1: Create Subscription and Publish Message"
                    echo "✅ Task 2: View the Published Message"  
                    echo "✅ Task 3: Create Snapshot for Message Replay"
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
    if [[ -f "/tmp/arc113_task${task_num}_completed" ]]; then
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
        echo "1) ✅ Task 1: Create Subscription and Publish Message (COMPLETED)"
    else
        echo "1) 📮 Task 1: Create Subscription and Publish Message"
    fi
    
    # Task 2
    if check_task_completion 2; then
        echo "2) ✅ Task 2: View the Published Message (COMPLETED)"
    elif [[ "$next_task" == "1" ]]; then
        echo "2) 🔒 Task 2: View the Published Message (LOCKED - Complete Task 1 first)"
    else
        echo "2) 👀 Task 2: View the Published Message"
    fi
    
    # Task 3
    if check_task_completion 3; then
        echo "3) ✅ Task 3: Create Snapshot for Message Replay (COMPLETED)"
    elif [[ "$next_task" == "1" || "$next_task" == "2" ]]; then
        echo "3) 🔒 Task 3: Create Snapshot for Message Replay (LOCKED - Complete previous tasks first)"
    else
        echo "3) 📷 Task 3: Create Snapshot for Message Replay"
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
        echo "🎉 ALL TASKS COMPLETED! Lab ARC113 is finished!"
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
    curl -sL "$TASK1_URL" -o "task1-create-subscription-publish.sh"
    chmod +x "task1-create-subscription-publish.sh"
    
    # Download Task 2
    print_status "Downloading Task 2 script..."
    curl -sL "$TASK2_URL" -o "task2-view-message.sh"
    chmod +x "task2-view-message.sh"
    
    # Download Task 3
    print_status "Downloading Task 3 script..."
    curl -sL "$TASK3_URL" -o "task3-create-snapshot.sh"
    chmod +x "task3-create-snapshot.sh"
    
    print_status "✅ All scripts downloaded and made executable!"
    echo ""
    echo "Available scripts:"
    echo "- task1-create-subscription-publish.sh"
    echo "- task2-view-message.sh"
    echo "- task3-create-snapshot.sh"
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
                    if download_and_run "1" "$TASK1_URL" "task1-create-subscription-publish.sh" "CREATE SUBSCRIPTION AND PUBLISH MESSAGE"; then
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
                    if download_and_run "2" "$TASK2_URL" "task2-view-message.sh" "VIEW THE PUBLISHED MESSAGE"; then
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
                    if download_and_run "3" "$TASK3_URL" "task3-create-snapshot.sh" "CREATE SNAPSHOT FOR MESSAGE REPLAY"; then
                        echo ""
                        print_header "🏆 CHALLENGE LAB ARC113 FINISHED!"
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
echo "This script will help you complete all tasks in ARC113:"
echo "• Task 1: Create Subscription and Publish Message"
echo "• Task 2: View the Published Message"  
echo "• Task 3: Create Snapshot for Message Replay"
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
            download_and_run "1" "$TASK1_URL" "task1-create-subscription-publish.sh" "CREATE SUBSCRIPTION AND PUBLISH MESSAGE"
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
            download_and_run "2" "$TASK2_URL" "task2-view-message.sh" "VIEW THE PUBLISHED MESSAGE"
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
            download_and_run "3" "$TASK3_URL" "task3-create-snapshot.sh" "CREATE SNAPSHOT FOR MESSAGE REPLAY"
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
            rm -f /tmp/arc113_task*_completed
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
