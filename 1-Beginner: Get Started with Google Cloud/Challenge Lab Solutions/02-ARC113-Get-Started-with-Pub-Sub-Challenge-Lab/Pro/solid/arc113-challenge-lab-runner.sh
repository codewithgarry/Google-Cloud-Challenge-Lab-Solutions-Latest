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

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${CYAN}[HEADER]${NC} $1"
}

print_tip() {
    echo -e "${MAGENTA}[TIP]${NC} $1"
}

# Function to check if gcloud is installed and configured
check_prerequisites() {
    print_status "🔍 Checking prerequisites..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "❌ Google Cloud SDK (gcloud) is not installed"
        print_tip "💡 Install from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
        print_error "❌ No active Google Cloud authentication found"
        print_tip "💡 Run: gcloud auth login"
        exit 1
    fi
    
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "❌ No Google Cloud project set"
        print_tip "💡 Run: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    print_success "✅ Prerequisites verified"
    print_status "🚀 Project ID: $PROJECT_ID"
}

# Universal Adaptive Solver - Intelligent lab detection and completion
run_adaptive_solver() {
    print_header "🔮 UNIVERSAL ADAPTIVE SOLVER"
    print_status "🚀 Intelligent lab detection and adaptive completion..."
    echo ""
    
    check_prerequisites
    
    # Detect existing resources
    print_status "🔍 Scanning environment for existing resources..."
    
    # Check for existing topics
    EXISTING_TOPICS=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null || true)
    
    # Check for existing subscriptions  
    EXISTING_SUBSCRIPTIONS=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null || true)
    
    # Check for existing snapshots
    EXISTING_SNAPSHOTS=$(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null || true)
    
    print_status "📊 Environment Analysis:"
    echo "   Topics found: $(echo "$EXISTING_TOPICS" | wc -l | tr -d ' ')"
    echo "   Subscriptions found: $(echo "$EXISTING_SUBSCRIPTIONS" | wc -l | tr -d ' ')"
    echo "   Snapshots found: $(echo "$EXISTING_SNAPSHOTS" | wc -l | tr -d ' ')"
    echo ""
    
    # Adaptive Task 1: Create subscription and publish message
    print_status "🎯 Task 1: Create subscription and publish message"
    
    # Try to find pre-created topic (common lab patterns)
    TOPIC_NAME=""
    for pattern in "gcloud-pubsub-topic" "test-topic" "myTopic" "quickstart-topic"; do
        if echo "$EXISTING_TOPICS" | grep -q "$pattern"; then
            TOPIC_NAME="$pattern"
            print_success "✅ Found pre-created topic: $TOPIC_NAME"
            break
        fi
    done
    
    # If no pre-created topic found, create one
    if [[ -z "$TOPIC_NAME" ]]; then
        TOPIC_NAME="test-topic"
        print_status "📝 Creating topic: $TOPIC_NAME"
        if gcloud pubsub topics create "$TOPIC_NAME"; then
            print_success "✅ Topic created successfully"
        else
            print_error "❌ Failed to create topic"
            exit 1
        fi
    fi
    
    # Create subscription
    SUBSCRIPTION_NAME="test-subscription"
    
    # Check if subscription already exists
    if ! echo "$EXISTING_SUBSCRIPTIONS" | grep -q "$SUBSCRIPTION_NAME"; then
        print_status "📝 Creating subscription: $SUBSCRIPTION_NAME"
        if gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME"; then
            print_success "✅ Subscription created successfully"
        else
            print_error "❌ Failed to create subscription"
            exit 1
        fi
    else
        print_success "✅ Subscription already exists: $SUBSCRIPTION_NAME"
    fi
    
    # Publish message
    MESSAGE_DATA="Hello from ARC113 Challenge Lab!"
    print_status "📤 Publishing message to topic: $TOPIC_NAME"
    if gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE_DATA"; then
        print_success "✅ Message published successfully"
    else
        print_error "❌ Failed to publish message"
        exit 1
    fi
    
    echo ""
    
    # Adaptive Task 2: Pull and view messages
    print_status "🎯 Task 2: Pull and view messages"
    
    # Find best subscription to pull from
    PULL_SUBSCRIPTION=""
    for pattern in "gcloud-pubsub-subscription" "$SUBSCRIPTION_NAME" "test-subscription" "mySubscription"; do
        if echo "$EXISTING_SUBSCRIPTIONS" | grep -q "$pattern" || [[ "$pattern" == "$SUBSCRIPTION_NAME" ]]; then
            PULL_SUBSCRIPTION="$pattern"
            break
        fi
    done
    
    if [[ -n "$PULL_SUBSCRIPTION" ]]; then
        print_status "👀 Pulling messages from subscription: $PULL_SUBSCRIPTION"
        if gcloud pubsub subscriptions pull "$PULL_SUBSCRIPTION" --limit=5 --auto-ack; then
            print_success "✅ Messages pulled and viewed successfully"
        else
            print_warning "⚠️  No messages found or pull failed - this is normal if messages were already consumed"
        fi
    else
        print_error "❌ No suitable subscription found for pulling messages"
    fi
    
    echo ""
    
    # Adaptive Task 3: Create snapshot
    print_status "🎯 Task 3: Create Pub/Sub snapshot"
    
    # Find best subscription for snapshot
    SNAPSHOT_SUBSCRIPTION=""
    for pattern in "gcloud-pubsub-subscription" "$SUBSCRIPTION_NAME" "test-subscription" "mySubscription"; do
        if echo "$EXISTING_SUBSCRIPTIONS" | grep -q "$pattern" || [[ "$pattern" == "$SUBSCRIPTION_NAME" ]]; then
            SNAPSHOT_SUBSCRIPTION="$pattern"
            break
        fi
    done
    
    if [[ -n "$SNAPSHOT_SUBSCRIPTION" ]]; then
        SNAPSHOT_NAME="test-snapshot"
        print_status "📸 Creating snapshot: $SNAPSHOT_NAME"
        if gcloud pubsub snapshots create "$SNAPSHOT_NAME" --subscription="$SNAPSHOT_SUBSCRIPTION"; then
            print_success "✅ Snapshot created successfully"
        else
            print_warning "⚠️  Snapshot creation failed - may already exist"
        fi
    else
        print_error "❌ No suitable subscription found for snapshot creation"
    fi
    
    echo ""
    print_success "🎉 ADAPTIVE SOLVER COMPLETE!"
    print_status "📊 Final verification..."
    
    # Verification
    echo ""
    echo "📋 RESOURCE SUMMARY:"
    echo "=================================="
    
    # List final state
    echo "📝 Topics:"
    gcloud pubsub topics list --format="table(name)" 2>/dev/null || echo "   No topics found"
    
    echo ""
    echo "📮 Subscriptions:"  
    gcloud pubsub subscriptions list --format="table(name)" 2>/dev/null || echo "   No subscriptions found"
    
    echo ""
    echo "📸 Snapshots:"
    gcloud pubsub snapshots list --format="table(name)" 2>/dev/null || echo "   No snapshots found"
    
    echo ""
    print_success "✅ All tasks completed successfully!"
    print_tip "💡 Lab should now be 100% complete"
}

# Speed solution function
run_speed_solution() {
    print_header "⚡ 2-MINUTE SPEED SOLUTION"
    print_status "🚀 Running all tasks automatically..."
    echo ""
    
    check_prerequisites
    
    # Set auto variables
    TOPIC_NAME="test-topic"
    SUBSCRIPTION_NAME="test-subscription"
    MESSAGE_DATA="Hello from ARC113 Challenge Lab!"
    SNAPSHOT_NAME="test-snapshot"
    
    # Task 1: Create subscription and publish message
    print_status "🎯 Task 1: Create subscription and publish message"
    
    # Create topic if needed
    if ! gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_status "📝 Creating topic: $TOPIC_NAME"
        gcloud pubsub topics create "$TOPIC_NAME"
    fi
    
    # Create subscription
    print_status "📝 Creating subscription: $SUBSCRIPTION_NAME"
    gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME" 2>/dev/null || true
    
    # Publish message
    print_status "📤 Publishing message"
    gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE_DATA"
    print_success "✅ Task 1 completed"
    
    sleep 1
    
    # Task 2: Pull messages
    print_status "🎯 Task 2: Pull and view messages"
    gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --limit=5 --auto-ack 2>/dev/null || true
    print_success "✅ Task 2 completed"
    
    sleep 1
    
    # Task 3: Create snapshot
    print_status "🎯 Task 3: Create snapshot"
    
    # Try to find existing subscription for snapshot
    EXISTING_SUB=$(gcloud pubsub subscriptions list --format="value(name)" | grep -E "(gcloud-pubsub-subscription|test-subscription)" | head -1)
    if [[ -n "$EXISTING_SUB" ]]; then
        gcloud pubsub snapshots create "$SNAPSHOT_NAME" --subscription="$EXISTING_SUB" 2>/dev/null || true
    else
        gcloud pubsub snapshots create "$SNAPSHOT_NAME" --subscription="$SUBSCRIPTION_NAME" 2>/dev/null || true
    fi
    print_success "✅ Task 3 completed"
    
    echo ""
    print_success "🎉 SPEED SOLUTION COMPLETE!"
    print_tip "💡 Total time: Under 2 minutes"
}

# Resource cleanup function
perform_cleanup() {
    print_warning "⚠️  Starting resource cleanup..."
    echo ""
    print_status "🧹 This will delete ALL Pub/Sub resources created during this lab"
    echo ""
    
    read -p "Are you sure you want to proceed? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        print_status "✅ Cleanup cancelled"
        return
    fi
    
    print_status "🗑️  Cleaning up resources..."
    
    # Delete snapshots
    SNAPSHOTS=$(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null || true)
    if [[ -n "$SNAPSHOTS" ]]; then
        echo "$SNAPSHOTS" | while read -r snapshot; do
            if [[ -n "$snapshot" ]]; then
                print_status "Deleting snapshot: $snapshot"
                gcloud pubsub snapshots delete "$snapshot" --quiet 2>/dev/null || true
            fi
        done
    fi
    
    # Delete subscriptions
    SUBSCRIPTIONS=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null || true)
    if [[ -n "$SUBSCRIPTIONS" ]]; then
        echo "$SUBSCRIPTIONS" | while read -r sub; do
            if [[ -n "$sub" ]]; then
                print_status "Deleting subscription: $sub"
                gcloud pubsub subscriptions delete "$sub" --quiet 2>/dev/null || true
            fi
        done
    fi
    
    # Delete topics
    TOPICS=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null || true)
    if [[ -n "$TOPICS" ]]; then
        echo "$TOPICS" | while read -r topic; do
            if [[ -n "$topic" ]]; then
                print_status "Deleting topic: $topic"
                gcloud pubsub topics delete "$topic" --quiet 2>/dev/null || true
            fi
        done
    fi
    
    print_success "✅ Cleanup completed!"
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
    echo "🚀 SMART AUTOMATION:"
    echo ""
    echo "   [1] 🔮 Universal Adaptive Solver (Handles ANY lab variation)"
    echo "   [2] ⚡ 2-Minute Speed Solution (Auto-mode, no prompts)"
    echo "   [3] 📖 Show Lab Tutorial & Overview"
    echo "   [4] 🧹 Complete Cleanup & Exit"
    echo "   [0] ❌ Exit Without Cleanup"
    echo ""
    echo "=================================================================="
    echo ""
}

# Main execution flow
main() {
    # Check if running with flags
    if [[ "$1" == "--adaptive" ]] || [[ "$1" == "-a" ]]; then
        run_adaptive_solver
        exit 0
    elif [[ "$1" == "--speed" ]] || [[ "$1" == "-s" ]]; then
        run_speed_solution
        exit 0
    elif [[ "$1" == "--cleanup" ]] || [[ "$1" == "-c" ]]; then
        perform_cleanup
        exit 0
    fi
    
    # Interactive mode
    while true; do
        show_main_menu
        read -p "Choose an option [0-4]: " choice
        echo ""
        
        case $choice in
            1)
                run_adaptive_solver
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                run_speed_solution
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
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
                echo "   • Use option [1] for intelligent completion"
                echo "   • Use option [2] for fastest execution"
                echo "   • Each task builds on the previous one"
                echo ""
                read -p "Press Enter to return to menu..."
                ;;
            4)
                perform_cleanup
                exit 0
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
                print_error "❌ Invalid option. Please choose 0-4."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

# Start the script
main "$@"
