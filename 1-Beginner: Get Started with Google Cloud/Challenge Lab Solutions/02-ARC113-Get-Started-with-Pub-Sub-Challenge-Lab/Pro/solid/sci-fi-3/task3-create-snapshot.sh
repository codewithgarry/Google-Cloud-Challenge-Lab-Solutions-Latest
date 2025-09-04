#!/bin/bash

# =============================================================================
# ARC113 Challenge Lab - Task 3: Create snapshot of subscription
# Author: CodeWithGarry
# Lab ID: ARC113
# Task: Create snapshot of subscription for message backup and replay
# =============================================================================

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

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

clear
echo "=================================================================="
echo "  🎯 TASK 3: CREATE SUBSCRIPTION SNAPSHOT"
echo "=================================================================="
echo "  📚 Lab ID: ARC113"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Goal: Create snapshot for message backup and replay"
echo "=================================================================="
echo ""

# Check if gcloud is configured
print_step "Checking gcloud configuration..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [[ -z "$PROJECT_ID" ]]; then
    print_error "❌ gcloud is not configured with a project"
    print_status "Please run: gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_success "✅ Working in project: $PROJECT_ID"
echo ""

# Get lab variables from environment or use defaults
print_status "🔍 Scanning for existing resources in the lab..."
EXISTING_TOPICS=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null)
EXISTING_SUBS=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null)
EXISTING_SNAPSHOTS=$(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null)

echo ""
print_header "📋 Lab Configuration Setup"
echo ""

# Interactive topic name selection
if [[ -n "$EXISTING_TOPICS" ]]; then
    print_status "🎯 Found existing topics in your project:"
    echo "$EXISTING_TOPICS" | sed 's/^/   • /'
    echo ""
fi

while true; do
    echo "🤔 Choose the topic name:"
    echo "   [1] 🎯 Use lab-provided topic (gcloud-pubsub-topic)"
    echo "   [2] 📝 Enter topic name manually"
    echo "   [3] 🔍 Auto-detect from existing topics"
    echo ""
    read -p "Select option (1-3): " topic_choice
    
    case $topic_choice in
        1)
            TOPIC_NAME="gcloud-pubsub-topic"
            print_status "✅ Using lab-provided topic: $TOPIC_NAME"
            break
            ;;
        2)
            echo ""
            read -p "📝 Enter the topic name: " custom_topic
            if [[ -n "$custom_topic" ]]; then
                TOPIC_NAME="$custom_topic"
                print_status "✅ Using custom topic: $TOPIC_NAME"
                break
            else
                print_error "❌ Topic name cannot be empty. Please try again."
            fi
            ;;
        3)
            if [[ -n "$EXISTING_TOPICS" ]]; then
                TOPIC_NAME=$(echo "$EXISTING_TOPICS" | head -1)
                print_status "✅ Auto-detected topic: $TOPIC_NAME"
                break
            else
                print_warning "⚠️  No existing topics found. Please choose option 1 or 2."
            fi
            ;;
        *)
            print_error "❌ Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done

echo ""

# Interactive subscription name selection
if [[ -n "$EXISTING_SUBS" ]]; then
    print_status "🎯 Found existing subscriptions in your project:"
    echo "$EXISTING_SUBS" | sed 's/^/   • /'
    echo ""
fi

while true; do
    echo "🤔 Choose the subscription for snapshot creation:"
    echo "   [1] 🎯 Use lab-required subscription (gcloud-pubsub-subscription)"
    echo "   [2] 📝 Enter subscription name manually"
    echo "   [3] 🔍 Auto-detect from existing subscriptions"
    echo ""
    read -p "Select option (1-3): " sub_choice
    
    case $sub_choice in
        1)
            SUBSCRIPTION_NAME="gcloud-pubsub-subscription"
            print_status "✅ Using lab-required subscription: $SUBSCRIPTION_NAME"
            break
            ;;
        2)
            echo ""
            read -p "📝 Enter the subscription name: " custom_sub
            if [[ -n "$custom_sub" ]]; then
                SUBSCRIPTION_NAME="$custom_sub"
                print_status "✅ Using custom subscription: $SUBSCRIPTION_NAME"
                break
            else
                print_error "❌ Subscription name cannot be empty. Please try again."
            fi
            ;;
        3)
            if [[ -n "$EXISTING_SUBS" ]]; then
                SUBSCRIPTION_NAME=$(echo "$EXISTING_SUBS" | head -1)
                print_status "✅ Auto-detected subscription: $SUBSCRIPTION_NAME"
                break
            else
                print_warning "⚠️  No existing subscriptions found. Please choose option 1 or 2."
            fi
            ;;
        *)
            print_error "❌ Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done

echo ""

# Interactive snapshot name selection
while true; do
    echo "🤔 Choose the snapshot name:"
    echo "   [1] 🎯 Use lab-required snapshot (pubsub-snapshot)"
    echo "   [2] 📝 Enter custom snapshot name manually"
    echo "   [3] 🔄 Use default (mySnapshot)"
    echo ""
    read -p "Select option (1-3): " snap_choice
    
    case $snap_choice in
        1)
            SNAPSHOT_NAME="pubsub-snapshot"
            print_status "✅ Using lab-required snapshot: $SNAPSHOT_NAME"
            break
            ;;
        2)
            echo ""
            read -p "📝 Enter your snapshot name: " custom_snap
            if [[ -n "$custom_snap" ]]; then
                SNAPSHOT_NAME="$custom_snap"
                print_status "✅ Using custom snapshot: $SNAPSHOT_NAME"
                break
            else
                print_error "❌ Snapshot name cannot be empty. Please try again."
            fi
            ;;
        3)
            SNAPSHOT_NAME="mySnapshot"
            print_status "✅ Using default snapshot: $SNAPSHOT_NAME"
            break
            ;;
        *)
            print_error "❌ Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
done

echo ""

# Summary confirmation
print_header "📋 Configuration Summary:"
echo "   🏷️  Topic Name: $TOPIC_NAME"
echo "   📫 Subscription Name: $SUBSCRIPTION_NAME"
echo "   📸 Snapshot Name: $SNAPSHOT_NAME"
echo ""

read -p "🤔 Proceed with this configuration? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    print_warning "⚠️  Configuration cancelled by user"
    exit 0
fi

echo ""

# Check if previous tasks were completed
if [[ ! -f "/tmp/arc113_task1_completed" ]]; then
    print_warning "⚠️  Task 1 completion marker not found"
fi

if [[ ! -f "/tmp/arc113_task2_completed" ]]; then
    print_warning "⚠️  Task 2 completion marker not found"
fi

echo ""

# Step 1: Verify subscription exists
print_step "Step 1: Verifying subscription exists..."

if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
    print_success "✅ Subscription '$SUBSCRIPTION_NAME' found"
    
    # Show subscription details
    print_header "📊 Current Subscription Details:"
    gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="table(
        name.basename():label=NAME,
        topic.basename():label=TOPIC,
        numUndeliveredMessages:label=UNDELIVERED,
        ackDeadlineSeconds:label=ACK_DEADLINE
    )"
else
    print_error "❌ Subscription '$SUBSCRIPTION_NAME' not found"
    print_status "Please ensure Tasks 1 and 2 were completed successfully"
    exit 1
fi

echo ""

# Step 2: Prepare subscription for snapshot (add messages if needed)
print_step "Step 2: Preparing subscription for snapshot..."

# Check current message count
UNDELIVERED_MESSAGES=$(gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="value(numUndeliveredMessages)" 2>/dev/null)

if [[ -z "$UNDELIVERED_MESSAGES" || "$UNDELIVERED_MESSAGES" -eq 0 ]]; then
    print_warning "⚠️  No undelivered messages in subscription"
    print_status "Publishing test messages for snapshot demonstration..."
    
    # Publish multiple test messages
    for i in {1..3}; do
        MESSAGE="Snapshot test message $i - $(date '+%Y-%m-%d %H:%M:%S')"
        if gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE" &>/dev/null; then
            print_status "✅ Published message $i: $MESSAGE"
        else
            print_error "❌ Failed to publish test message $i"
        fi
    done
    
    print_status "Waiting 3 seconds for message propagation..."
    sleep 3
    
    # Verify messages are available
    NEW_COUNT=$(gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="value(numUndeliveredMessages)" 2>/dev/null)
    print_success "✅ Subscription now has $NEW_COUNT undelivered message(s)"
else
    print_success "✅ Subscription has $UNDELIVERED_MESSAGES undelivered message(s)"
fi

echo ""

# Step 3: Create snapshot
print_step "Step 3: Creating snapshot of subscription..."

print_status "Creating snapshot '$SNAPSHOT_NAME' from subscription '$SUBSCRIPTION_NAME'..."

if gcloud pubsub snapshots create "$SNAPSHOT_NAME" --subscription="$SUBSCRIPTION_NAME" 2>/dev/null; then
    print_success "✅ Snapshot '$SNAPSHOT_NAME' created successfully!"
else
    # Check if snapshot already exists
    if gcloud pubsub snapshots describe "$SNAPSHOT_NAME" &>/dev/null; then
        print_warning "⚠️  Snapshot '$SNAPSHOT_NAME' already exists"
        print_status "Deleting existing snapshot and creating new one..."
        
        if gcloud pubsub snapshots delete "$SNAPSHOT_NAME" --quiet 2>/dev/null; then
            print_status "✅ Existing snapshot deleted"
            
            if gcloud pubsub snapshots create "$SNAPSHOT_NAME" --subscription="$SUBSCRIPTION_NAME" 2>/dev/null; then
                print_success "✅ New snapshot '$SNAPSHOT_NAME' created successfully!"
            else
                print_error "❌ Failed to create new snapshot"
                exit 1
            fi
        else
            print_error "❌ Failed to delete existing snapshot"
            exit 1
        fi
    else
        print_error "❌ Failed to create snapshot '$SNAPSHOT_NAME'"
        print_status "This might be because:"
        echo "   • Subscription '$SUBSCRIPTION_NAME' doesn't exist"
        echo "   • Insufficient permissions"
        echo "   • Network connectivity issues"
        exit 1
    fi
fi

echo ""

# Step 4: Verify snapshot details
print_step "Step 4: Verifying snapshot details..."

print_header "📸 Snapshot Information:"
gcloud pubsub snapshots describe "$SNAPSHOT_NAME" --format="table(
    name.basename():label=SNAPSHOT_NAME,
    topic.basename():label=TOPIC,
    expireTime:label=EXPIRES
)"

echo ""

# Step 5: List all snapshots in project
print_step "Step 5: Listing all snapshots in project..."

print_header "📋 All Snapshots in Project:"
SNAPSHOT_LIST=$(gcloud pubsub snapshots list --format="table(
    name.basename():label=SNAPSHOT,
    topic.basename():label=TOPIC,
    expireTime:label=EXPIRES
)" 2>/dev/null)

if [[ -n "$SNAPSHOT_LIST" && "$SNAPSHOT_LIST" != *"Listed 0 items"* ]]; then
    echo "$SNAPSHOT_LIST"
else
    print_warning "⚠️  No snapshots found in project"
fi

echo ""

# Step 6: Demonstrate snapshot usage
print_step "Step 6: Demonstrating snapshot usage..."

print_header "💡 Snapshot Use Cases and Commands:"
echo ""
echo "🔹 Seek subscription to snapshot (restore messages):"
echo "   gcloud pubsub subscriptions seek $SUBSCRIPTION_NAME --snapshot=$SNAPSHOT_NAME"
echo ""
echo "🔹 Create new subscription from snapshot:"
echo "   gcloud pubsub subscriptions create new-sub --topic=$TOPIC_NAME"
echo "   gcloud pubsub subscriptions seek new-sub --snapshot=$SNAPSHOT_NAME"
echo ""
echo "🔹 List all snapshots:"
echo "   gcloud pubsub snapshots list"
echo ""
echo "🔹 Delete snapshot:"
echo "   gcloud pubsub snapshots delete $SNAPSHOT_NAME"

echo ""

# Step 7: Optional - Demonstrate snapshot seek
print_step "Step 7: Optional snapshot seek demonstration..."

echo ""
read -p "🤔 Would you like to demonstrate seeking to snapshot? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Demonstrating snapshot seek..."
    
    # First, consume current messages
    print_status "Consuming current messages..."
    gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --auto-ack --limit=10 &>/dev/null
    
    BEFORE_COUNT=$(gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="value(numUndeliveredMessages)" 2>/dev/null)
    print_status "Messages before seek: $BEFORE_COUNT"
    
    # Seek to snapshot
    print_status "Seeking subscription to snapshot..."
    if gcloud pubsub subscriptions seek "$SUBSCRIPTION_NAME" --snapshot="$SNAPSHOT_NAME" 2>/dev/null; then
        print_success "✅ Successfully sought to snapshot"
        
        sleep 2
        AFTER_COUNT=$(gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="value(numUndeliveredMessages)" 2>/dev/null)
        print_status "Messages after seek: $AFTER_COUNT"
        
        if [[ "$AFTER_COUNT" -gt "$BEFORE_COUNT" ]]; then
            print_success "✅ Snapshot seek restored messages!"
        fi
    else
        print_error "❌ Failed to seek to snapshot"
    fi
else
    print_status "Skipping snapshot seek demonstration"
fi

echo ""

# Final success message
echo "=================================================================="
print_success "🎉 TASK 3 COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo ""
print_status "✅ What was accomplished:"
echo "   • Verified subscription '$SUBSCRIPTION_NAME' exists"
echo "   • Created snapshot '$SNAPSHOT_NAME' of subscription"
echo "   • Verified snapshot creation and details"
echo "   • Learned about snapshot use cases and commands"
echo ""
print_status "🎊 CHALLENGE LAB COMPLETE!"
echo "   • All 3 tasks completed successfully"
echo "   • Pub/Sub subscription, messaging, and snapshots mastered"
echo ""
print_status "💡 Pro Tips:"
echo "   • Snapshots expire after 7 days by default"
echo "   • Use snapshots for message replay and backup"
echo "   • Seek operations allow time-travel for message processing"
echo "   • Snapshots preserve subscription state and message order"
echo ""

# Mark task as completed
touch /tmp/arc113_task3_completed
print_status "📋 Task 3 completion recorded"

# Mark entire lab as completed
touch /tmp/arc113_lab_completed
print_status "🎯 Entire ARC113 lab marked as completed!"

echo "=================================================================="
print_header "🔗 Subscribe to CodeWithGarry for more tutorials!"
print_header "   YouTube: https://www.youtube.com/@CodeWithGarry"
echo "=================================================================="
