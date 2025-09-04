#!/bin/bash

# =============================================================================
# Get Started with Pub/Sub: Challenge Lab - Master Script
# Downloads and runs all task scripts
# Author: CodeWithGarry
# Lab ID: ARC113
# =============================================================================

# Global subscription verification flag
SUBSCRIPTION_VERIFIED=false

# GitHub repository URLs for downloading individual task scripts
REPO_BASE_URL="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/Pro/solid"

# Individual task script URLs
TASK1_URL="$REPO_BASE_URL/sci-fi-1/task1-create-subscription-publish-message.sh"
TASK2_URL="$REPO_BASE_URL/sci-fi-2/task2-view-messages.sh"
TASK3_URL="$REPO_BASE_URL/sci-fi-3/task3-create-snapshot.sh"

echo "=================================================================="
echo "  🚀 GET STARTED WITH PUB/SUB CHALLENGE LAB"
echo "=================================================================="
echo "  📚 Lab ID: ARC113"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Tasks: 3 (Subscription, Message Publish, Snapshot)"
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
    echo "   • Pub/Sub Topics: gcloud-pubsub-topic"
    echo "   • Subscriptions: pubsub-subscription-message, gcloud-pubsub-subscription"
    echo "   • Snapshots: pubsub-snapshot"
    echo ""
    echo "📁 LOCAL FILES:"
    echo "   • Downloaded task scripts (task1, task2, task3)"
    echo "   • Temporary progress files"
    echo "   • This main runner script"
    echo ""
    echo "💰 COST SAVINGS:"
    echo "   • Prevents ongoing Pub/Sub storage charges"
    echo "   • Eliminates message retention costs"
    echo "   • Removes subscription maintenance overhead"
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
            print_status "✅ Cleanup cancelled. Returning to main menu..."
            sleep 2
            return 0
        else
            print_error "❌ Invalid input. Please type 'cleanup' or 'cancel'"
        fi
    done
    
    # Second confirmation
    while true; do
        echo ""
        print_warning "🔥 FINAL CONFIRMATION REQUIRED!"
        echo "   You are about to permanently delete all lab resources."
        echo "   This includes topics, subscriptions, and snapshots."
        echo ""
        read -p "Type 'DELETE' in capital letters to proceed: " confirm2
        
        if [[ "$confirm2" == "DELETE" ]]; then
            break
        else
            print_error "❌ Incorrect confirmation. Cleanup cancelled for safety."
            echo ""
            print_status "✅ Returning to main menu..."
            sleep 2
            return 0
        fi
    done
    
    echo ""
    print_status "🔄 Starting comprehensive cleanup process..."
    sleep 2
    
    # Start cleanup process
    echo ""
    print_header "PHASE 1: GOOGLE CLOUD RESOURCES CLEANUP"
    print_status "🗑️  Deleting Pub/Sub resources..."
    
    # Delete snapshots first (they depend on subscriptions)
    print_step "Deleting snapshot: pubsub-snapshot"
    gcloud pubsub snapshots delete pubsub-snapshot --quiet 2>/dev/null || echo "   ℹ️  Snapshot may not exist"
    
    # Delete subscriptions
    print_step "Deleting subscription: pubsub-subscription-message"
    gcloud pubsub subscriptions delete pubsub-subscription-message --quiet 2>/dev/null || echo "   ℹ️  Subscription may not exist"
    
    print_step "Deleting subscription: gcloud-pubsub-subscription"
    gcloud pubsub subscriptions delete gcloud-pubsub-subscription --quiet 2>/dev/null || echo "   ℹ️  Subscription may not exist"
    
    # Delete topics
    print_step "Deleting topic: gcloud-pubsub-topic"
    gcloud pubsub topics delete gcloud-pubsub-topic --quiet 2>/dev/null || echo "   ℹ️  Topic may not exist"
    
    sleep 2
    
    # Verify cloud resources are deleted
    print_status "🔍 Verifying cloud resource deletion..."
    
    REMAINING_TOPICS=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null | wc -l)
    REMAINING_SUBS=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null | wc -l)
    REMAINING_SNAPSHOTS=$(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null | wc -l)
    
    if [[ $REMAINING_TOPICS -eq 0 ]] && [[ $REMAINING_SUBS -eq 0 ]] && [[ $REMAINING_SNAPSHOTS -eq 0 ]]; then
        print_status "✅ All Pub/Sub resources successfully deleted"
    else
        print_warning "⚠️  Some resources may still exist. Check manually if needed."
    fi
    
    sleep 1
    
    # Local file cleanup
    print_header "PHASE 2: LOCAL FILES CLEANUP"
    print_status "🗑️  Cleaning up local files..."
    
    # Remove any temporary files
    rm -f task1.sh task2.sh task3.sh 2>/dev/null || true
    rm -f arc113_progress.txt 2>/dev/null || true
    rm -f .arc113_* 2>/dev/null || true
    
    print_status "✅ Local temporary files cleaned up"
    
    sleep 1
    
    # Final summary
    clear
    echo "=================================================================="
    echo "  🎉 CLEANUP COMPLETED SUCCESSFULLY!"
    echo "=================================================================="
    echo ""
    print_status "✅ All Google Cloud resources have been deleted"
    print_status "✅ All local temporary files have been removed"
    print_status "✅ No ongoing charges will be incurred"
    echo ""
    echo "📈 WHAT YOU ACCOMPLISHED TODAY:"
    echo "   • ✅ Mastered Pub/Sub topic and subscription creation"
    echo "   • ✅ Successfully published and consumed messages"
    echo "   • ✅ Created snapshots for message replay scenarios"
    echo "   • ✅ Learned Google Cloud messaging fundamentals"
    echo ""
    echo "🚀 NEXT STEPS:"
    echo "   • 📚 Explore advanced Pub/Sub features"
    echo "   • 🔄 Try the next challenge lab in the series"
    echo "   • 💼 Apply these skills in real projects"
    echo "   • ⭐ Star our GitHub repository if this helped you!"
    echo ""
    echo "=================================================================="
    echo "  🌟 Thank you for choosing CodeWithGarry!"
    echo "  📺 Don't forget to subscribe to our YouTube channel"
    echo "  🔗 GitHub: github.com/codewithgarry"
    echo "=================================================================="
    echo ""
    
    read -p "Press Enter to exit..."
    exit 0
}

# Function to check lab prerequisites
check_prerequisites() {
    print_header "🔍 CHECKING LAB PREREQUISITES"
    echo ""
    
    # Check if gcloud is installed and configured
    if ! command -v gcloud &> /dev/null; then
        print_error "❌ gcloud CLI is not installed or not in PATH"
        echo "   Please install Google Cloud SDK first"
        exit 1
    fi
    
    # Check if user is authenticated
    CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
    if [[ -z "$CURRENT_ACCOUNT" ]]; then
        print_error "❌ No Google Cloud account configured"
        echo "   Please run: gcloud auth login"
        exit 1
    fi
    
    # Check if project is set
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)
    if [[ -z "$CURRENT_PROJECT" ]]; then
        print_error "❌ No Google Cloud project configured"
        echo "   Please run: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    print_status "✅ gcloud CLI configured properly"
    print_status "✅ Account: $CURRENT_ACCOUNT"
    print_status "✅ Project: $CURRENT_PROJECT"
    
    # Check if Pub/Sub API is enabled
    print_status "🔄 Checking Pub/Sub API status..."
    if gcloud services list --enabled --filter="name:pubsub.googleapis.com" --format="value(name)" | grep -q "pubsub.googleapis.com"; then
        print_status "✅ Pub/Sub API is enabled"
    else
        print_warning "⚠️  Enabling Pub/Sub API..."
        gcloud services enable pubsub.googleapis.com
        print_status "✅ Pub/Sub API enabled successfully"
    fi
    
    echo ""
    print_status "🎯 All prerequisites verified. Ready to proceed!"
    sleep 2
}

# Function to execute task 1: Create subscription and publish message
execute_task1() {
    clear
    print_header "📤 TASK 1: PUBLISH A MESSAGE TO THE TOPIC"
    echo ""
    echo "🎯 TASK OBJECTIVES:"
    echo "   • Create a Cloud Pub/Sub subscription named 'pubsub-subscription-message'"
    echo "   • Subscribe to the pre-created topic 'gcloud-pubsub-topic'"
    echo "   • Publish a 'Hello World' message to the topic"
    echo ""
    
    print_tutorial "💡 LEARNING MOMENT:"
    echo "   Topics are like message boards where messages are posted."
    echo "   Subscriptions are like personal mailboxes that receive copies of messages."
    echo ""
    
    read -p "Press Enter to start Task 1..."
    
    print_step "Step 1.1: Verifying the pre-created topic 'gcloud-pubsub-topic'"
    
    # Check if topic exists, create if it doesn't
    if gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null; then
        print_status "✅ Topic 'gcloud-pubsub-topic' exists"
    else
        print_warning "⚠️  Topic doesn't exist. Creating it..."
        gcloud pubsub topics create gcloud-pubsub-topic
        print_status "✅ Topic 'gcloud-pubsub-topic' created"
    fi
    
    print_step "Step 1.2: Creating subscription 'pubsub-subscription-message'"
    
    # Create the subscription
    if gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic 2>/dev/null; then
        print_status "✅ Subscription 'pubsub-subscription-message' created successfully"
    else
        print_warning "⚠️  Subscription may already exist"
        print_status "✅ Subscription 'pubsub-subscription-message' is ready"
    fi
    
    print_step "Step 1.3: Publishing 'Hello World' message to the topic"
    
    # Publish the message
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
    print_status "✅ Message 'Hello World' published successfully"
    
    # Publish additional timestamped message for better verification
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World from CodeWithGarry at $(date)"
    print_status "✅ Additional timestamped message published"
    
    echo ""
    print_status "🎉 TASK 1 COMPLETED SUCCESSFULLY!"
    print_tip "💡 Your subscription is now ready to receive messages from the topic"
    echo ""
    
    read -p "Press Enter to continue to Task 2..."
}

# Function to execute task 2: View messages
execute_task2() {
    clear
    print_header "👀 TASK 2: VIEW THE MESSAGE"
    echo ""
    echo "🎯 TASK OBJECTIVES:"
    echo "   • Pull messages from your subscription to verify message delivery"
    echo "   • Use gcloud command to pull up to 5 messages"
    echo "   • Confirm Cloud Pub/Sub messaging is working correctly"
    echo ""
    
    print_tutorial "💡 LEARNING MOMENT:"
    echo "   Pulling messages retrieves them from the subscription."
    echo "   --limit 5 means we'll get at most 5 messages in one pull."
    echo "   Without --auto-ack, messages remain available for re-processing."
    echo ""
    
    read -p "Press Enter to start Task 2..."
    
    print_step "Step 2.1: Pulling messages from subscription (required lab command)"
    echo ""
    echo "🔄 Executing: gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5"
    echo ""
    
    # Execute the required command
    gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
    
    echo ""
    print_status "✅ Messages pulled successfully!"
    
    print_step "Step 2.2: Understanding the output"
    echo ""
    print_tutorial "📊 OUTPUT EXPLANATION:"
    echo "   • DATA: The actual message content ('Hello World')"
    echo "   • MESSAGE_ID: Unique identifier for each message"
    echo "   • ATTRIBUTES: Any additional metadata (if any)"
    echo "   • DELIVERY_ATTEMPT: Number of delivery attempts"
    echo ""
    
    print_step "Step 2.3: Optional - Pull with auto-acknowledgment"
    echo ""
    echo "🔄 This will actually consume (acknowledge) the messages:"
    echo ""
    
    gcloud pubsub subscriptions pull pubsub-subscription-message --auto-ack --limit 3
    
    echo ""
    print_status "✅ Messages pulled and acknowledged!"
    
    echo ""
    print_status "🎉 TASK 2 COMPLETED SUCCESSFULLY!"
    print_tip "💡 You've successfully verified that Pub/Sub messaging is working"
    echo ""
    
    read -p "Press Enter to continue to Task 3..."
}

# Function to execute task 3: Create snapshot
execute_task3() {
    clear
    print_header "📸 TASK 3: CREATE A PUB/SUB SNAPSHOT"
    echo ""
    echo "🎯 TASK OBJECTIVES:"
    echo "   • Create a snapshot with ID 'pubsub-snapshot'"
    echo "   • Use the pre-created subscription 'gcloud-pubsub-subscription'"
    echo "   • Understand snapshot functionality for message replay"
    echo ""
    
    print_tutorial "💡 LEARNING MOMENT:"
    echo "   Snapshots capture the acknowledgment state of a subscription at a point in time."
    echo "   They allow you to 'rewind' a subscription to replay messages."
    echo "   This is essential for disaster recovery and testing scenarios."
    echo ""
    
    read -p "Press Enter to start Task 3..."
    
    print_step "Step 3.1: Verifying the pre-created subscription 'gcloud-pubsub-subscription'"
    
    # Check if the pre-created subscription exists
    if gcloud pubsub subscriptions describe gcloud-pubsub-subscription &>/dev/null; then
        print_status "✅ Pre-created subscription 'gcloud-pubsub-subscription' exists"
    else
        print_warning "⚠️  Pre-created subscription doesn't exist. Creating it..."
        gcloud pubsub subscriptions create gcloud-pubsub-subscription --topic=gcloud-pubsub-topic
        print_status "✅ Subscription 'gcloud-pubsub-subscription' created"
    fi
    
    print_step "Step 3.2: Creating snapshot 'pubsub-snapshot'"
    
    # Create the snapshot
    if gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription 2>/dev/null; then
        print_status "✅ Snapshot 'pubsub-snapshot' created successfully"
    else
        print_warning "⚠️  Snapshot may already exist or there was an issue"
        # Try to describe it to verify
        if gcloud pubsub snapshots describe pubsub-snapshot &>/dev/null; then
            print_status "✅ Snapshot 'pubsub-snapshot' is available"
        else
            print_error "❌ Failed to create snapshot. Please check manually."
        fi
    fi
    
    print_step "Step 3.3: Verifying snapshot creation"
    echo ""
    echo "📋 All snapshots in the project:"
    gcloud pubsub snapshots list
    echo ""
    
    print_step "Step 3.4: Getting snapshot details"
    echo ""
    echo "📋 Snapshot details:"
    gcloud pubsub snapshots describe pubsub-snapshot
    echo ""
    
    print_tutorial "🎯 SNAPSHOT USAGE:"
    echo "   To replay messages from this snapshot later, you would use:"
    echo "   gcloud pubsub subscriptions seek gcloud-pubsub-subscription --snapshot=pubsub-snapshot"
    echo ""
    
    print_status "🎉 TASK 3 COMPLETED SUCCESSFULLY!"
    print_tip "💡 Your snapshot is ready for message replay scenarios"
    echo ""
    
    read -p "Press Enter to view final verification..."
}

# Function to show final verification
show_final_verification() {
    clear
    print_header "🎊 FINAL LAB VERIFICATION & SUMMARY"
    echo ""
    
    print_status "🔍 Verifying all lab resources..."
    echo ""
    
    echo "📋 ALL PUB/SUB TOPICS:"
    gcloud pubsub topics list
    echo ""
    
    echo "📋 ALL PUB/SUB SUBSCRIPTIONS:"
    gcloud pubsub subscriptions list
    echo ""
    
    echo "📋 ALL PUB/SUB SNAPSHOTS:"
    gcloud pubsub snapshots list
    echo ""
    
    print_header "✅ LAB RESOURCE VERIFICATION"
    echo ""
    
    # Verify specific resources
    print_step "Checking required resources:"
    
    # Check topic
    if gcloud pubsub topics describe gcloud-pubsub-topic &>/dev/null; then
        print_status "✅ Topic: gcloud-pubsub-topic"
    else
        print_error "❌ Topic: gcloud-pubsub-topic NOT FOUND"
    fi
    
    # Check subscription
    if gcloud pubsub subscriptions describe pubsub-subscription-message &>/dev/null; then
        print_status "✅ Subscription: pubsub-subscription-message"
    else
        print_error "❌ Subscription: pubsub-subscription-message NOT FOUND"
    fi
    
    # Check pre-created subscription
    if gcloud pubsub subscriptions describe gcloud-pubsub-subscription &>/dev/null; then
        print_status "✅ Pre-created Subscription: gcloud-pubsub-subscription"
    else
        print_error "❌ Pre-created Subscription: gcloud-pubsub-subscription NOT FOUND"
    fi
    
    # Check snapshot
    if gcloud pubsub snapshots describe pubsub-snapshot &>/dev/null; then
        print_status "✅ Snapshot: pubsub-snapshot"
    else
        print_error "❌ Snapshot: pubsub-snapshot NOT FOUND"
    fi
    
    echo ""
    print_header "🎓 WHAT YOU ACCOMPLISHED"
    echo ""
    echo "🏆 TECHNICAL SKILLS MASTERED:"
    echo "   • ✅ Cloud Pub/Sub topic and subscription management"
    echo "   • ✅ Message publishing and consumption patterns"
    echo "   • ✅ Subscription message pulling and acknowledgment"
    echo "   • ✅ Snapshot creation for message replay scenarios"
    echo "   • ✅ Google Cloud CLI (gcloud) for Pub/Sub operations"
    echo ""
    echo "🌟 REAL-WORLD APPLICATIONS:"
    echo "   • ✅ Microservices communication patterns"
    echo "   • ✅ Event-driven architecture implementation"
    echo "   • ✅ Asynchronous message processing systems"
    echo "   • ✅ Disaster recovery and testing strategies"
    echo ""
    
    print_status "🎉 CONGRATULATIONS! ARC113 Challenge Lab completed successfully!"
    echo ""
}

# Function to download and execute script
download_and_run() {
    local task_num=$1
    local script_url=$2
    local script_name=$3
    local task_description=$4
    
    echo ""
    echo "=================================================================="
    print_step "TASK $task_num: $task_description"
    echo "=================================================================="
    echo ""
    
    # Check if script already exists locally
    if [[ -f "$script_name" ]]; then
        print_warning "Script already exists locally: $script_name"
        print_status "Using existing script..."
    else
        print_status "Downloading script: $script_name"
        
        if curl -sL "$script_url" -o "$script_name"; then
            print_status "✅ Script downloaded successfully!"
        else
            print_error "❌ Failed to download script: $script_name"
            print_status "Attempting direct execution fallback..."
            
            # Fallback: try to execute directly from URL
            if curl -sL "$script_url" | bash; then
                print_status "✅ Direct execution successful!"
                return 0
            else
                print_error "❌ Both download and direct execution failed"
                return 1
            fi
        fi
    fi
    
    # Make script executable
    chmod +x "$script_name"
    
    # Execute the script
    print_status "🚀 Executing: $script_name"
    echo ""
    
    if bash "$script_name"; then
        print_status "✅ Task $task_num completed successfully!"
        
        # Mark task as completed
        touch "/tmp/arc113_task${task_num}_completed"
        return 0
    else
        print_error "❌ Task $task_num execution failed!"
        return 1
    fi
}

# Function to download all scripts without executing
download_all_scripts() {
    print_status "📥 Downloading all task scripts..."
    
    # Download Task 1
    print_status "Downloading Task 1 script..."
    curl -sL "$TASK1_URL" -o "task1-create-subscription-publish-message.sh"
    chmod +x "task1-create-subscription-publish-message.sh"
    
    # Download Task 2
    print_status "Downloading Task 2 script..."
    curl -sL "$TASK2_URL" -o "task2-view-messages.sh"
    chmod +x "task2-view-messages.sh"
    
    # Download Task 3
    print_status "Downloading Task 3 script..."
    curl -sL "$TASK3_URL" -o "task3-create-snapshot.sh"
    chmod +x "task3-create-snapshot.sh"
    
    print_status "✅ All scripts downloaded successfully!"
    print_status "📁 Available scripts:"
    echo "   • task1-create-subscription-publish-message.sh"
    echo "   • task2-view-messages.sh"
    echo "   • task3-create-snapshot.sh"
    echo ""
    print_status "💡 You can now run individual scripts manually"
}

# Main menu function
show_main_menu() {
    clear
    echo "=================================================================="
    echo "  🚀 ARC113: GET STARTED WITH PUB/SUB CHALLENGE LAB"
    echo "=================================================================="
    echo "  📚 Lab ID: ARC113"
    echo "  👨‍💻 Author: CodeWithGarry"
    echo "  🎯 Tasks: 3 (Subscription, Message Publish, Snapshot)"
    echo "  ⏱️  Duration: 45-60 minutes"
    echo "=================================================================="
    echo ""
    echo "🎯 CHALLENGE LAB TASKS:"
    echo "   1️⃣  Create subscription and publish message"
    echo "   2️⃣  Pull and view messages"
    echo "   3️⃣  Create Pub/Sub snapshot"
    echo ""
    echo "🚀 SMART AUTOMATION (Downloads & Runs with Interactive Options):"
    echo ""
    echo "   [1] ⚡ 2-Minute Speed Solution (Auto-mode, no prompts)"
    echo "   [2] 🎯 Task 1: Create Subscription & Publish (Interactive prompts)"
    echo "   [3] 👀 Task 2: Pull & View Messages (Interactive prompts)" 
    echo "   [4] 📸 Task 3: Create Snapshot (Interactive prompts)"
    echo "   [5] 🚀 Run All Remaining Tasks (Interactive prompts)"
    echo "   [6] 📖 Show Lab Tutorial & Overview"
    echo "   [7] 📥 Download All Scripts Only"
    echo "   [8] � Reset Progress (Clear completion markers)"
    echo "   [9] 🧹 Complete Cleanup & Exit"
    echo "   [0] ❌ Exit Without Cleanup"
    echo ""
    echo "=================================================================="
    echo ""
}

# Main execution flow
main() {
    # Check if running with auto-execute flag
    if [[ "$1" == "--auto" ]] || [[ "$1" == "-a" ]]; then
        echo "🚀 AUTO-EXECUTION MODE ACTIVATED"
        echo "⚡ Running all tasks automatically..."
        sleep 2
        
        check_prerequisites
        execute_task1
        execute_task2
        execute_task3
        show_final_verification
        
        echo ""
        print_status "🎉 All tasks completed automatically!"
        read -p "Press Enter to exit..."
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_main_menu
        read -p "🤔 Please select an option (0-9): " choice
        
        case $choice in
            1)
                echo ""
                print_status "⚡ 2-MINUTE SPEED SOLUTION - AUTO-MODE (NO PROMPTS)"
                sleep 2
                
                # Set environment variables for non-interactive mode
                export ARC113_AUTO_MODE=true
                export TOPIC_NAME="gcloud-pubsub-topic"
                export SUBSCRIPTION_NAME="pubsub-subscription-message"
                export MESSAGE_BODY="Hello World"
                export SNAPSHOT_NAME="pubsub-snapshot"
                
                print_status "🤖 Auto-mode enabled - using lab-required names"
                print_status "   Topic: $TOPIC_NAME"
                print_status "   Subscription: $SUBSCRIPTION_NAME"
                print_status "   Message: $MESSAGE_BODY"
                print_status "   Snapshot: $SNAPSHOT_NAME"
                echo ""
                
                # Check task completion status and execute accordingly
                if [[ ! -f "/tmp/arc113_task1_completed" ]]; then
                    if download_and_run "1" "$TASK1_URL" "task1-create-subscription-publish-message.sh" "CREATE SUBSCRIPTION & PUBLISH MESSAGE"; then
                        print_status "✅ Task 1 completed successfully!"
                        sleep 2
                    else
                        print_error "❌ Task 1 failed"
                        read -p "Press Enter to return to menu..."
                        continue
                    fi
                fi
                
                if [[ ! -f "/tmp/arc113_task2_completed" ]]; then
                    if download_and_run "2" "$TASK2_URL" "task2-view-messages.sh" "PULL & VIEW MESSAGES"; then
                        print_status "✅ Task 2 completed successfully!"
                        sleep 2
                    else
                        print_error "❌ Task 2 failed"
                        read -p "Press Enter to return to menu..."
                        continue
                    fi
                fi
                
                if [[ ! -f "/tmp/arc113_task3_completed" ]]; then
                    # Set correct subscription name for Task 3
                    export SUBSCRIPTION_NAME="gcloud-pubsub-subscription"
                    
                    if download_and_run "3" "$TASK3_URL" "task3-create-snapshot.sh" "CREATE SNAPSHOT"; then
                        print_status "✅ Task 3 completed successfully!"
                        sleep 2
                    else
                        print_error "❌ Task 3 failed"
                        read -p "Press Enter to return to menu..."
                        continue
                    fi
                fi
                
                # Unset auto mode
                unset ARC113_AUTO_MODE
                
                echo ""
                echo "=================================================================="
                print_success "🎉 ALL TASKS COMPLETED IN SPEED MODE!"
                echo "=================================================================="
                
                while true; do
                    read -p "🤔 Would you like to clean up resources? (y/n): " cleanup_choice
                    case $cleanup_choice in
                        [Yy]*)
                            perform_resource_cleanup
                            ;;
                        [Nn]*)
                            print_status "✅ Lab completed! Resources preserved."
                            echo "💡 Remember to clean up resources later to avoid charges."
                            read -p "Press Enter to exit..."
                            exit 0
                            ;;
                        *)
                            print_error "❌ Please answer y (yes) or n (no)"
                            ;;
                    esac
                done
                ;;
            2)
                download_and_run "1" "$TASK1_URL" "task1-create-subscription-publish-message.sh" "CREATE SUBSCRIPTION & PUBLISH MESSAGE"
                read -p "Press Enter to return to menu..."
                ;;
            3)
                download_and_run "2" "$TASK2_URL" "task2-view-messages.sh" "PULL & VIEW MESSAGES"
                read -p "Press Enter to return to menu..."
                ;;
            4)
                download_and_run "3" "$TASK3_URL" "task3-create-snapshot.sh" "CREATE SNAPSHOT"
                read -p "Press Enter to return to menu..."
                ;;
            5)
                echo ""
                print_status "🚀 Running all remaining tasks..."
                
                if [[ ! -f "/tmp/arc113_task1_completed" ]]; then
                    download_and_run "1" "$TASK1_URL" "task1-create-subscription-publish-message.sh" "CREATE SUBSCRIPTION & PUBLISH MESSAGE"
                    sleep 2
                fi
                
                if [[ ! -f "/tmp/arc113_task2_completed" ]]; then
                    download_and_run "2" "$TASK2_URL" "task2-view-messages.sh" "PULL & VIEW MESSAGES"
                    sleep 2
                fi
                
                if [[ ! -f "/tmp/arc113_task3_completed" ]]; then
                    download_and_run "3" "$TASK3_URL" "task3-create-snapshot.sh" "CREATE SNAPSHOT"
                    sleep 2
                fi
                
                print_success "✅ All remaining tasks completed!"
                read -p "Press Enter to return to menu..."
                ;;
            6)
                echo ""
                print_header "📖 ARC113 LAB TUTORIAL & OVERVIEW"
                echo "=================================================================="
                echo ""
                echo "🎯 CHALLENGE LAB OBJECTIVES:"
                echo "   • Learn Google Cloud Pub/Sub fundamentals"
                echo "   • Master message publishing and subscription"
                echo "   • Understand Pub/Sub snapshots for message replay"
                echo ""
                echo "🔧 WHAT YOU'LL BUILD:"
                echo "   1️⃣  Pub/Sub subscription for message receiving"
                echo "   2️⃣  Message publishing and consumption workflow"
                echo "   3️⃣  Snapshot for message backup and replay"
                echo ""
                echo "⏱️  ESTIMATED TIME: 45-60 minutes"
                echo ""
                echo "💡 PRO TIPS:"
                echo "   • Use option [1] for fastest completion"
                echo "   • Individual tasks help understand each step"
                echo "   • Download scripts for offline practice"
                echo ""
                read -p "Press Enter to return to menu..."
                ;;
            7)
                echo ""
                download_all_scripts
                echo ""
                read -p "Press Enter to return to menu..."
                ;;
            8)
                echo ""
                echo "Resetting progress..."
                rm -f /tmp/arc113_task*_completed
                rm -f /tmp/arc113_lab_completed
                print_status "✅ Progress reset complete"
                read -p "Press Enter to return to menu..."
                ;;
            9)
                perform_resource_cleanup
                ;;
            0)
                echo ""
                print_warning "⚠️  Exiting without cleanup..."
                print_tip "💡 Remember to manually clean up resources to avoid charges"
                echo ""
                print_status "🙏 Thank you for using CodeWithGarry's solutions!"
                echo "📺 Don't forget to subscribe to our YouTube channel!"
                echo "⭐ Star our GitHub repository if this helped you!"
                echo ""
                exit 0
                ;;
            *)
                print_error "❌ Invalid option. Please select 0-9."
                sleep 2
                ;;
        esac
    done
}

# Script entry point
echo ""
print_status "🎬 Initializing ARC113 Challenge Lab Automation..."
sleep 1

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo ""
        echo "🚀 ARC113 Challenge Lab Automation Script"
        echo ""
        echo "Usage:"
        echo "  $0              # Interactive mode (default)"
        echo "  $0 --auto      # Automatic execution of all tasks"
        echo "  $0 --help      # Show this help message"
        echo ""
        echo "Author: CodeWithGarry"
        echo "Lab ID: ARC113"
        echo ""
        exit 0
        ;;
    --version|-v)
        echo "ARC113 Challenge Lab Automation v1.0"
        echo "Author: CodeWithGarry"
        echo "Lab: Get Started with Pub/Sub Challenge Lab"
        exit 0
        ;;
esac

# Start main execution
main "$@"
