#!/bin/bash

# =============================================================================
# ARC113 Challenge Lab - Task 1: Create subscription and publish message
# Author: CodeWithGarry
# Lab ID: ARC113
# Task: Create subscription and publish first message to Pub/Sub topic
# =============================================================================

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

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

clear
echo "=================================================================="
echo "  🎯 TASK 1: CREATE SUBSCRIPTION & PUBLISH MESSAGE"
echo "=================================================================="
echo "  📚 Lab ID: ARC113"
echo "  👨‍💻 Author: CodeWithGarry"
echo "  🎯 Goal: Create Pub/Sub subscription and publish message"
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
TOPIC_NAME=${TOPIC_NAME:-"myTopic"}
SUBSCRIPTION_NAME=${SUBSCRIPTION_NAME:-"mySubscription"}
MESSAGE_BODY=${MESSAGE_BODY:-"Hello World"}

print_header "📋 Lab Configuration:"
echo "   🏷️  Topic Name: $TOPIC_NAME"
echo "   📫 Subscription Name: $SUBSCRIPTION_NAME"
echo "   💬 Message: $MESSAGE_BODY"
echo ""

# Step 1: Create Pub/Sub subscription
print_step "Step 1: Creating Pub/Sub subscription..."

print_status "Creating subscription '$SUBSCRIPTION_NAME' for topic '$TOPIC_NAME'..."

if gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" --topic="$TOPIC_NAME" 2>/dev/null; then
    print_success "✅ Subscription '$SUBSCRIPTION_NAME' created successfully!"
else
    # Check if subscription already exists
    if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        print_warning "⚠️  Subscription '$SUBSCRIPTION_NAME' already exists"
        print_status "Continuing with existing subscription..."
    else
        print_error "❌ Failed to create subscription '$SUBSCRIPTION_NAME'"
        print_status "This might be because:"
        echo "   • Topic '$TOPIC_NAME' doesn't exist"
        echo "   • Insufficient permissions"
        echo "   • Network connectivity issues"
        exit 1
    fi
fi

echo ""

# Step 2: Publish message to topic
print_step "Step 2: Publishing message to topic..."

print_status "Publishing message '$MESSAGE_BODY' to topic '$TOPIC_NAME'..."

if MESSAGE_ID=$(gcloud pubsub topics publish "$TOPIC_NAME" --message="$MESSAGE_BODY" 2>/dev/null); then
    print_success "✅ Message published successfully!"
    print_status "Message ID: $MESSAGE_ID"
else
    print_error "❌ Failed to publish message to topic '$TOPIC_NAME'"
    print_status "This might be because:"
    echo "   • Topic '$TOPIC_NAME' doesn't exist"
    echo "   • Insufficient permissions"
    echo "   • Network connectivity issues"
    exit 1
fi

echo ""

# Step 3: Verify subscription and message
print_step "Step 3: Verifying subscription and message..."

print_status "Checking subscription details..."
if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
    print_success "✅ Subscription '$SUBSCRIPTION_NAME' is active"
    
    # Show subscription details
    echo ""
    print_header "📊 Subscription Details:"
    gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" --format="table(
        name.basename():label=NAME,
        topic.basename():label=TOPIC,
        ackDeadlineSeconds:label=ACK_DEADLINE,
        messageRetentionDuration:label=RETENTION
    )"
else
    print_error "❌ Subscription verification failed"
    exit 1
fi

echo ""

# Step 4: Quick message pull test (optional)
print_step "Step 4: Testing message delivery..."

print_status "Attempting to pull messages from subscription..."
PULLED_MESSAGES=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" --limit=1 --auto-ack --format="value(message.data)" 2>/dev/null | base64 -d 2>/dev/null)

if [[ -n "$PULLED_MESSAGES" ]]; then
    print_success "✅ Message successfully received: $PULLED_MESSAGES"
else
    print_warning "⚠️  No messages pulled (this is normal if messages were already consumed)"
fi

echo ""

# Final success message
echo "=================================================================="
print_success "🎉 TASK 1 COMPLETED SUCCESSFULLY!"
echo "=================================================================="
echo ""
print_status "✅ What was accomplished:"
echo "   • Created Pub/Sub subscription '$SUBSCRIPTION_NAME'"
echo "   • Published message '$MESSAGE_BODY' to topic '$TOPIC_NAME'"
echo "   • Verified subscription is working correctly"
echo ""
print_status "🚀 Next Steps:"
echo "   • Task 2: Pull and view messages from subscription"
echo "   • Task 3: Create snapshot of subscription"
echo ""
print_status "💡 Pro Tips:"
echo "   • Messages are retained based on subscription settings"
echo "   • Use --auto-ack to automatically acknowledge pulled messages"
echo "   • Monitor subscription metrics in Cloud Console"
echo ""

# Mark task as completed
touch /tmp/arc113_task1_completed
print_status "📋 Task 1 completion recorded"

echo "=================================================================="
print_header "🔗 Subscribe to CodeWithGarry for more tutorials!"
print_header "   YouTube: https://www.youtube.com/@CodeWithGarry"
echo "=================================================================="
