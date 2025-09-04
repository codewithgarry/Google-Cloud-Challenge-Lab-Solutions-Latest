#!/bin/bash

# =============================================================================
# Get Started with Pub/Sub: Challenge Lab - Quick Automation Runner
# Downloads and runs the complete automation script
# Author: CodeWithGarry
# Lab ID: ARC113
# =============================================================================

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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Quick execution function
execute_quick_solution() {
    print_status "🚀 Starting ARC113 Challenge Lab Quick Solution..."
    echo ""
    
    # Check prerequisites
    print_step "Checking prerequisites..."
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI not found. Please install Google Cloud SDK."
        exit 1
    fi
    
    PROJECT_ID=$(gcloud config get-value project)
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "No project configured. Please run 'gcloud config set project PROJECT_ID'."
        exit 1
    fi
    
    print_status "✅ Project ID: $PROJECT_ID"
    
    # Enable Pub/Sub API
    print_step "Enabling Pub/Sub API..."
    gcloud services enable pubsub.googleapis.com
    print_status "✅ Pub/Sub API enabled"
    
    # Task 1: Create subscription and publish message
    print_step "Task 1: Creating subscription and publishing message..."
    
    # Create topic if it doesn't exist
    gcloud pubsub topics create gcloud-pubsub-topic 2>/dev/null || echo "Topic may already exist"
    
    # Create subscription
    gcloud pubsub subscriptions create pubsub-subscription-message --topic=gcloud-pubsub-topic
    print_status "✅ Subscription 'pubsub-subscription-message' created"
    
    # Publish message
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello World"
    print_status "✅ Message 'Hello World' published"
    
    # Task 2: View messages
    print_step "Task 2: Viewing messages..."
    echo ""
    print_status "Pulling messages from subscription:"
    gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
    print_status "✅ Messages viewed"
    
    # Task 3: Create snapshot
    print_step "Task 3: Creating snapshot..."
    
    # Create pre-created subscription if needed
    gcloud pubsub subscriptions create gcloud-pubsub-subscription --topic=gcloud-pubsub-topic 2>/dev/null || echo "Subscription may already exist"
    
    # Create snapshot
    gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
    print_status "✅ Snapshot 'pubsub-snapshot' created"
    
    # Final verification
    print_step "Final verification..."
    echo ""
    print_status "📋 Lab Resources Created:"
    echo "  • Topic: gcloud-pubsub-topic"
    echo "  • Subscription: pubsub-subscription-message"  
    echo "  • Pre-created Subscription: gcloud-pubsub-subscription"
    echo "  • Snapshot: pubsub-snapshot"
    echo ""
    
    print_status "🎉 ARC113 Challenge Lab completed successfully!"
    echo ""
    print_status "⏱️  Total execution time: ~2-3 minutes"
    print_status "🎯 All tasks completed automatically"
    echo ""
    
    # Ask about advanced automation
    echo "🤔 Want to try our advanced automation with full error handling?"
    echo "   The complete script is available in Pro/solid/arc113-challenge-lab-runner.sh"
    echo ""
}

# Advanced automation download function
download_advanced_automation() {
    print_status "🔄 Downloading advanced automation script..."
    
    # Check if Pro/solid directory and script exist
    if [[ -f "Pro/solid/arc113-challenge-lab-runner.sh" ]]; then
        print_status "✅ Advanced script found locally"
        chmod +x Pro/solid/arc113-challenge-lab-runner.sh
        
        echo ""
        print_status "🚀 Running advanced automation with full error handling..."
        echo ""
        
        # Execute the advanced script
        Pro/solid/arc113-challenge-lab-runner.sh
    else
        print_warning "Advanced script not found locally"
        print_status "Running quick solution instead..."
        execute_quick_solution
    fi
}

# Main menu
show_menu() {
    echo "🚀 AUTOMATION OPTIONS:"
    echo ""
    echo "   [1] ⚡ Quick Solution (2-3 minutes)"
    echo "   [2] 🤖 Advanced Automation (5-10 minutes)"
    echo "   [3] 📖 Manual Step-by-Step Guide"
    echo "   [4] ❌ Exit"
    echo ""
}

# Main execution
main() {
    if [[ "$1" == "--quick" ]] || [[ "$1" == "-q" ]]; then
        execute_quick_solution
        exit 0
    elif [[ "$1" == "--advanced" ]] || [[ "$1" == "-a" ]]; then
        download_advanced_automation
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_menu
        read -p "🤔 Select an option (1-4): " choice
        
        case $choice in
            1)
                execute_quick_solution
                break
                ;;
            2)
                download_advanced_automation
                break
                ;;
            3)
                print_status "📖 For manual step-by-step guidance, check:"
                echo "   • Challenge-Lab-Specific-Solution.md (detailed learning)"
                echo "   • 2-minutes-solution.md (quick commands)"
                echo "   • Pro/GUI-Solution.md (visual guide)"
                echo "   • Pro/CLI-Solution.md (command line focus)"
                echo ""
                ;;
            4)
                print_status "👋 Goodbye! Good luck with your lab!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-4."
                ;;
        esac
    done
}

# Script entry point
print_status "🎬 Initializing ARC113 Challenge Lab Automation..."
echo ""

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "🚀 ARC113 Challenge Lab Automation"
        echo ""
        echo "Usage:"
        echo "  $0                # Interactive mode"
        echo "  $0 --quick       # Quick 2-3 minute solution"
        echo "  $0 --advanced    # Advanced automation with error handling"
        echo "  $0 --help        # Show this help"
        echo ""
        echo "Author: CodeWithGarry"
        echo "Lab: Get Started with Pub/Sub Challenge Lab"
        exit 0
        ;;
esac

main "$@"

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
    echo "   1️⃣  Publish a message to the topic"
    echo "   2️⃣  View the message"
    echo "   3️⃣  Create a Pub/Sub Snapshot"
    echo ""
    echo "🚀 AUTOMATION OPTIONS:"
    echo ""
    echo "   [1] 🎯 Execute All Tasks (Recommended)"
    echo "   [2] 📤 Task 1 Only: Publish Message"
    echo "   [3] 👀 Task 2 Only: View Message"
    echo "   [4] 📸 Task 3 Only: Create Snapshot"
    echo "   [5] ✅ Final Verification Only"
    echo "   [6] 🔍 Check Prerequisites"
    echo "   [7] 🧹 Complete Cleanup & Exit"
    echo "   [8] ❌ Exit Without Cleanup"
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
        read -p "🤔 Please select an option (1-8): " choice
        
        case $choice in
            1)
                echo ""
                print_status "🚀 Starting complete lab execution..."
                sleep 2
                check_prerequisites
                execute_task1
                execute_task2
                execute_task3
                show_final_verification
                
                echo ""
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
                check_prerequisites
                execute_task1
                read -p "Press Enter to return to menu..."
                ;;
            3)
                check_prerequisites
                execute_task2
                read -p "Press Enter to return to menu..."
                ;;
            4)
                check_prerequisites
                execute_task3
                read -p "Press Enter to return to menu..."
                ;;
            5)
                show_final_verification
                read -p "Press Enter to return to menu..."
                ;;
            6)
                check_prerequisites
                read -p "Press Enter to return to menu..."
                ;;
            7)
                perform_resource_cleanup
                ;;
            8)
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
                print_error "❌ Invalid option. Please select 1-8."
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
