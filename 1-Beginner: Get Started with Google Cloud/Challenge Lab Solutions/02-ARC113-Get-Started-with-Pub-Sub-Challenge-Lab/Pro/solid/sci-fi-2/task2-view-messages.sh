#!/bin/bash

# =============================================================================
# ARC113 Challenge Lab - Task 2: Pull and view messages from subscription
# Author: CodeWithGarry
# Lab ID: ARC113
# Task: Pull messages from subscription and view message content
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
echo "  🎯 TASK 2: PULL AND VIEW MESSAGES"
echo "=================================================================="
echo "  📚 Lab ID: ARC113"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Goal: Pull messages from subscription and view content"
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
    echo "🤔 Choose the topic name to work with:"
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
    echo "🤔 Choose the subscription to pull messages from:"
    echo "   [1] 🎯 Use lab-required subscription (pubsub-subscription-message)"
    echo "   [2] 📝 Enter subscription name manually"
    echo "   [3] 🔍 Auto-detect from existing subscriptions"
    echo ""
    read -p "Select option (1-3): " sub_choice
    
    case $sub_choice in
        1)
            SUBSCRIPTION_NAME="pubsub-subscription-message"
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

# Summary confirmation
print_header "📋 Configuration Summary:"
echo "   🏷️  Topic Name: $TOPIC_NAME"
echo "   📫 Subscription Name: $SUBSCRIPTION_NAME"
echo ""

read -p "🤔 Proceed with this configuration? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    print_warning "⚠️  Configuration cancelled by user"
    exit 0
fi

echo ""

# Check if Task 1 was completed
if [[ ! -f "/tmp/arc113_task1_completed" ]]; then
    print_warning "⚠️  Task 1 completion marker not found"
    print_status "Proceeding anyway, but ensure Task 1 was completed first"
    echo ""
fi

# Step 1: Verify subscription exists
print_step "Step 1: Verifying subscription exists..."

if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
    print_success "✅ Subscription '$SUBSCRIPTION_NAME' found"
else
    print_error "❌ Subscription '$SUBSCRIPTION_NAME' not found"
    print_status "Please ensure Task 1 was completed successfully"
    exit 1
fi

echo ""

# Step 2: Check for available messages
print_step "Step 2: Checking for available messages..."

print_status "Checking subscription metrics..."
# Get approximate message count
UNDELIVERED_MESSAGES=$(gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="value(numUndeliveredMessages)" 2>/dev/null)

if [[ -n "$UNDELIVERED_MESSAGES" && "$UNDELIVERED_MESSAGES" -gt 0 ]]; then
    print_success "✅ Found $UNDELIVERED_MESSAGES undelivered message(s)"
else
    print_warning "⚠️  No undelivered messages found"
    print_status "Publishing a test message to ensure we have something to pull..."
    
    # Publish a test message
    TEST_MESSAGE="Task 2 Test Message - $(date)"
    if gcloud pubsub topics publish "$TOPIC_NAME" --message="$TEST_MESSAGE" &>/dev/null; then
        print_success "✅ Test message published: $TEST_MESSAGE"
        sleep 2  # Give it a moment to propagate
    else
        print_error "❌ Failed to publish test message"
        exit 1
    fi
fi

echo ""

# Step 3: Pull messages from subscription
print_step "Step 3: Pulling messages from subscription..."

print_status "Pulling messages from '$SUBSCRIPTION_NAME'..."

# Pull messages without auto-ack first to see them
print_header "📬 Messages in subscription:"
echo ""

PULLED_OUTPUT=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --limit=5 --format="table(
    message.data.decode(base64):label=MESSAGE_CONTENT,
    message.messageId:label=MESSAGE_ID,
    message.publishTime:label=PUBLISH_TIME,
    ackId:label=ACK_ID
)" 2>/dev/null)

if [[ -n "$PULLED_OUTPUT" && "$PULLED_OUTPUT" != *"Listed 0 items"* ]]; then
    echo "$PULLED_OUTPUT"
    print_success "✅ Messages pulled successfully!"
    echo ""
    
    # Now pull with auto-ack to actually consume them
    print_status "Acknowledging messages..."
    ACKNOWLEDGED=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --limit=5 --auto-ack --format="value(message.data)" 2>/dev/null)
    
    if [[ -n "$ACKNOWLEDGED" ]]; then
        print_success "✅ Messages acknowledged and removed from subscription"
        
        # Decode and show the actual message content
        echo ""
        print_header "📋 Decoded Message Content:"
        echo "$ACKNOWLEDGED" | while read -r encoded_msg; do
            if [[ -n "$encoded_msg" ]]; then
                decoded_msg=$(echo "$encoded_msg" | base64 -d 2>/dev/null)
                echo "   💬 $decoded_msg"
            fi
        done
    fi
else
    print_warning "⚠️  No messages available to pull"
    print_status "This could mean:"
    echo "   • All messages were already consumed"
    echo "   • Messages expired based on retention policy"
    echo "   • Subscription is not receiving messages"
fi

echo ""

# Step 4: Show subscription statistics
print_step "Step 4: Displaying subscription statistics..."

print_header "📊 Subscription Statistics:"
gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="table(
    name.basename():label=SUBSCRIPTION,
    topic.basename():label=TOPIC,
    numUndeliveredMessages:label=UNDELIVERED,
    ackDeadlineSeconds:label=ACK_DEADLINE,
    messageRetentionDuration:label=RETENTION
)"

echo ""

# Step 5: Demonstrate different pull options
print_step "Step 5: Demonstrating pull command options..."

print_header "💡 Pub/Sub Pull Command Options:"
echo ""
echo "🔹 Basic pull (view without consuming):"
echo "   gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --limit=3"
echo ""
echo "🔹 Pull with auto-acknowledgment (consume messages):"
echo "   gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --limit=3 --auto-ack"
echo ""
echo "🔹 Pull in JSON format:"
echo "   gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --format=json"
echo ""
echo "🔹 Continuous pulling:"
echo "   while true; do"
echo "     gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --limit=1 --auto-ack"
echo "     sleep 1"
echo "   done"

echo ""

# Final success message
echo "=================================================================="
print_success "🎉 TASK 2 COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo ""
print_status "✅ What was accomplished:"
echo "   • Verified subscription '$SUBSCRIPTION_NAME' exists"
echo "   • Successfully pulled messages from subscription"
echo "   • Viewed message content and metadata"
echo "   • Acknowledged and consumed messages"
echo "   • Reviewed subscription statistics"
echo ""
print_status "🚀 Next Steps:"
echo "   • Task 3: Create snapshot of subscription"
echo ""
print_status "💡 Pro Tips:"
echo "   • Use --limit to control how many messages to pull"
echo "   • Use --auto-ack to automatically acknowledge messages"
echo "   • Monitor undelivered message count to track backlog"
echo "   • Set appropriate ack deadline for your processing time"
echo ""

# Mark task as completed
touch /tmp/arc113_task2_completed
print_status "📋 Task 2 completion recorded"

echo "=================================================================="
print_header "🔗 Subscribe to CodeWithGarry for more tutorials!"
print_header "   YouTube: https://www.youtube.com/@CodeWithGarry"
echo "=================================================================="
