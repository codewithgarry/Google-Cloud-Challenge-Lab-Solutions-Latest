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
# Check if running in auto-mode (non-interactive)
if [[ "$ARC113_AUTO_MODE" == "true" ]]; then
    print_status "🤖 Running in AUTO-MODE - using pre-configured values"
    
    # Use environment variables set by the main script
    TOPIC_NAME=${TOPIC_NAME:-"gcloud-pubsub-topic"}
    SUBSCRIPTION_NAME=${SUBSCRIPTION_NAME:-"pubsub-subscription-message"}
    MESSAGE_BODY=${MESSAGE_BODY:-"Hello World"}
    
    print_header "📋 Auto-Mode Configuration:"
    echo "   🏷️  Topic Name: $TOPIC_NAME"
    echo "   📫 Subscription Name: $SUBSCRIPTION_NAME"
    echo "   💬 Message: $MESSAGE_BODY"
    echo ""
    
else
    # Interactive mode - show prompts
    # Check for lab-provided topic names first
    print_status "🔍 Scanning for existing topics in the lab..."
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
        echo "🤔 Choose how to set the topic name:"
        echo "   [1] 🎯 Use lab-provided topic (gcloud-pubsub-topic)"
        echo "   [2] 📝 Enter custom topic name manually"
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
                read -p "📝 Enter your topic name: " custom_topic
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
    while true; do
        echo "🤔 Choose how to set the subscription name:"
        echo "   [1] 🎯 Use lab-required subscription (pubsub-subscription-message)"
        echo "   [2] 📝 Enter custom subscription name manually"
        echo "   [3] 🔄 Use default (mySubscription)"
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
                read -p "📝 Enter your subscription name: " custom_sub
                if [[ -n "$custom_sub" ]]; then
                    SUBSCRIPTION_NAME="$custom_sub"
                    print_status "✅ Using custom subscription: $SUBSCRIPTION_NAME"
                    break
                else
                    print_error "❌ Subscription name cannot be empty. Please try again."
                fi
                ;;
            3)
                SUBSCRIPTION_NAME="mySubscription"
                print_status "✅ Using default subscription: $SUBSCRIPTION_NAME"
                break
                ;;
            *)
                print_error "❌ Invalid choice. Please select 1, 2, or 3."
                ;;
        esac
    done

    echo ""

    # Interactive message content selection
    while true; do
        echo "🤔 Choose the message content:"
        echo "   [1] 📨 Use default message (Hello World)"
        echo "   [2] 📝 Enter custom message manually"
        echo "   [3] 🎲 Use timestamp message"
        echo ""
        read -p "Select option (1-3): " msg_choice
        
        case $msg_choice in
            1)
                MESSAGE_BODY="Hello World"
                print_status "✅ Using default message: $MESSAGE_BODY"
                break
                ;;
            2)
                echo ""
                read -p "📝 Enter your message content: " custom_msg
                if [[ -n "$custom_msg" ]]; then
                    MESSAGE_BODY="$custom_msg"
                    print_status "✅ Using custom message: $MESSAGE_BODY"
                    break
                else
                    print_error "❌ Message cannot be empty. Please try again."
                fi
                ;;
            3)
                MESSAGE_BODY="Test message sent at $(date '+%Y-%m-%d %H:%M:%S')"
                print_status "✅ Using timestamp message: $MESSAGE_BODY"
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
    echo "   💬 Message: $MESSAGE_BODY"
    echo ""

    read -p "🤔 Proceed with this configuration? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_warning "⚠️  Configuration cancelled by user"
        exit 0
    fi

    echo ""
fi

# Step 1: Check if topic exists, create if needed
print_step "Step 1: Ensuring topic exists..."

print_status "Checking if topic '$TOPIC_NAME' exists..."
if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
    print_success "✅ Topic '$TOPIC_NAME' already exists"
else
    print_warning "⚠️  Topic '$TOPIC_NAME' doesn't exist, creating it..."
    if gcloud pubsub topics create "$TOPIC_NAME" 2>/dev/null; then
        print_success "✅ Topic '$TOPIC_NAME' created successfully!"
    else
        print_error "❌ Failed to create topic '$TOPIC_NAME'"
        
        # Try alternative topic names that might work in the lab
        print_status "🔄 Trying alternative topic names..."
        
        for alt_topic in "gcloud-pubsub-topic" "pubsub-topic" "myTopic"; do
            if gcloud pubsub topics describe "$alt_topic" &>/dev/null; then
                TOPIC_NAME="$alt_topic"
                print_success "✅ Found existing topic: $TOPIC_NAME"
                break
            fi
        done
        
        # If still no topic found, try creating with alternative name
        if ! gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
            TOPIC_NAME="gcloud-pubsub-topic"
            print_status "🔄 Attempting to create topic: $TOPIC_NAME"
            if gcloud pubsub topics create "$TOPIC_NAME" 2>/dev/null; then
                print_success "✅ Topic '$TOPIC_NAME' created successfully!"
            else
                print_error "❌ Failed to create any topic. Please check permissions."
                exit 1
            fi
        fi
    fi
fi

echo ""

# Step 2: Create Pub/Sub subscription
print_step "Step 2: Creating Pub/Sub subscription..."

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

# Step 3: Publish message to topic
print_step "Step 3: Publishing message to topic..."

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

# Step 4: Verify subscription and message
print_step "Step 4: Verifying subscription and message..."

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

# Step 5: Quick message pull test (optional)
print_step "Step 5: Testing message delivery..."

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
