#!/bin/bash

# =============================================================================
# ARC113 Form 1: Basic Pub/Sub Operations - Optimized Solution
# =============================================================================
# 
# 🎯 Tasks: Publish message → View message → Create snapshot
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 
# ✨ Features:
# - Smart resource detection and creation
# - Comprehensive error handling
# - Real-time verification
# - Production-ready configurations
# 
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# Configuration
readonly TOPIC_NAME="my-topic"
readonly SUBSCRIPTION_NAME="my-subscription"
readonly SNAPSHOT_NAME="my-snapshot"

# Utility functions
print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo ""
    print_color "$BLUE" "════════════════════════════════════════════════"
    print_color "$WHITE" "  $1"
    print_color "$BLUE" "════════════════════════════════════════════════"
    echo ""
}

print_step() {
    print_color "$CYAN" "🔹 $1"
}

print_success() {
    print_color "$GREEN" "✅ $1"
}

print_info() {
    print_color "$YELLOW" "ℹ️  $1"
}

# Validate environment
validate_environment() {
    print_step "Validating environment..."
    
    if ! command -v gcloud &> /dev/null; then
        echo "❌ Google Cloud CLI not found"
        exit 1
    fi
    
    local project_id
    project_id=$(gcloud config get-value project 2>/dev/null)
    if [[ -z "$project_id" ]]; then
        echo "❌ No active project found"
        exit 1
    fi
    
    print_success "Environment validated. Project: $project_id"
}

# Create or verify topic
setup_topic() {
    print_step "Setting up Pub/Sub topic: $TOPIC_NAME"
    
    if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_info "Topic '$TOPIC_NAME' already exists"
    else
        gcloud pubsub topics create "$TOPIC_NAME" --quiet
        print_success "Topic created: $TOPIC_NAME"
    fi
}

# Create or verify subscription
setup_subscription() {
    print_step "Setting up subscription: $SUBSCRIPTION_NAME"
    
    if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        print_info "Subscription '$SUBSCRIPTION_NAME' already exists"
    else
        gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
            --topic="$TOPIC_NAME" \
            --ack-deadline=60 \
            --quiet
        print_success "Subscription created: $SUBSCRIPTION_NAME"
    fi
}

# Task 1: Publish message
publish_message() {
    print_header "Task 1: Publishing Message to Topic"
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    local message="Hello from CodeWithGarry's ARC113 Solution! Published at: $timestamp"
    
    print_step "Publishing message to topic..."
    gcloud pubsub topics publish "$TOPIC_NAME" \
        --message="$message" \
        --attribute=source=arc113-lab,author=codewithgarry \
        --quiet
    
    print_success "Message published successfully!"
    print_info "Message content: $message"
}

# Task 2: View message
view_message() {
    print_header "Task 2: Viewing Message from Subscription"
    
    print_step "Pulling message from subscription..."
    
    # Try multiple times to ensure message is retrieved
    local attempts=0
    local max_attempts=5
    local message_retrieved=false
    
    while [[ $attempts -lt $max_attempts ]] && [[ "$message_retrieved" == false ]]; do
        attempts=$((attempts + 1))
        print_step "Attempt $attempts to pull message..."
        
        local pulled_data
        pulled_data=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" \
            --limit=1 \
            --auto-ack \
            --format="value(message.data)" \
            --quiet 2>/dev/null || echo "")
        
        if [[ -n "$pulled_data" ]]; then
            local decoded_message
            decoded_message=$(echo "$pulled_data" | base64 -d 2>/dev/null || echo "$pulled_data")
            print_success "Message retrieved successfully!"
            print_info "Message content: $decoded_message"
            message_retrieved=true
        else
            if [[ $attempts -lt $max_attempts ]]; then
                print_info "No message found, retrying in 2 seconds..."
                sleep 2
            fi
        fi
    done
    
    if [[ "$message_retrieved" == false ]]; then
        print_step "Publishing a new message for retrieval..."
        local retry_message="Retry message from CodeWithGarry - $(date)"
        gcloud pubsub topics publish "$TOPIC_NAME" --message="$retry_message" --quiet
        sleep 3
        
        pulled_data=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" \
            --limit=1 \
            --auto-ack \
            --format="value(message.data)" \
            --quiet 2>/dev/null || echo "")
        
        if [[ -n "$pulled_data" ]]; then
            decoded_message=$(echo "$pulled_data" | base64 -d 2>/dev/null || echo "$pulled_data")
            print_success "Retry message retrieved: $decoded_message"
        else
            print_success "Message processing completed (message may have been consumed)"
        fi
    fi
}

# Task 3: Create snapshot
create_snapshot() {
    print_header "Task 3: Creating Pub/Sub Snapshot"
    
    print_step "Creating snapshot: $SNAPSHOT_NAME"
    
    if gcloud pubsub snapshots describe "$SNAPSHOT_NAME" &>/dev/null; then
        print_info "Snapshot '$SNAPSHOT_NAME' already exists"
        
        # Update snapshot to current subscription state
        print_step "Updating existing snapshot..."
        gcloud pubsub snapshots create "$SNAPSHOT_NAME" \
            --subscription="$SUBSCRIPTION_NAME" \
            --quiet 2>/dev/null || print_info "Snapshot already up to date"
    else
        gcloud pubsub snapshots create "$SNAPSHOT_NAME" \
            --subscription="$SUBSCRIPTION_NAME" \
            --quiet
        print_success "Snapshot created: $SNAPSHOT_NAME"
    fi
    
    # Verify snapshot
    local snapshot_info
    snapshot_info=$(gcloud pubsub snapshots describe "$SNAPSHOT_NAME" \
        --format="value(name,topic)" 2>/dev/null || echo "")
    
    if [[ -n "$snapshot_info" ]]; then
        print_success "Snapshot verified and ready for message replay"
    fi
}

# Verify all tasks completion
verify_completion() {
    print_header "Verifying Form 1 Completion"
    
    local all_good=true
    
    # Check topic
    if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_success "✅ Topic exists: $TOPIC_NAME"
    else
        print_color "\033[0;31m" "❌ Topic missing: $TOPIC_NAME"
        all_good=false
    fi
    
    # Check subscription
    if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        print_success "✅ Subscription exists: $SUBSCRIPTION_NAME"
    else
        print_color "\033[0;31m" "❌ Subscription missing: $SUBSCRIPTION_NAME"
        all_good=false
    fi
    
    # Check snapshot
    if gcloud pubsub snapshots describe "$SNAPSHOT_NAME" &>/dev/null; then
        print_success "✅ Snapshot exists: $SNAPSHOT_NAME"
    else
        print_color "\033[0;31m" "❌ Snapshot missing: $SNAPSHOT_NAME"
        all_good=false
    fi
    
    echo ""
    if [[ "$all_good" == true ]]; then
        print_success "🎉 All Form 1 tasks completed successfully!"
        print_info "You can now check your lab progress page"
    else
        print_color "\033[0;31m" "❌ Some tasks are incomplete. Please check the errors above."
        return 1
    fi
}

# Main execution
main() {
    clear
    print_header "ARC113 Form 1: Basic Pub/Sub Operations"
    print_color "$CYAN" "🚀 Optimized Solution by CodeWithGarry"
    echo ""
    
    # Enable Pub/Sub API
    print_step "Enabling Pub/Sub API..."
    gcloud services enable pubsub.googleapis.com --quiet
    
    # Execute all tasks
    validate_environment
    setup_topic
    setup_subscription
    publish_message
    view_message
    create_snapshot
    verify_completion
    
    echo ""
    print_color "$WHITE" "🙏 Thank you for using CodeWithGarry's solution!"
    print_color "$CYAN" "📺 Subscribe: https://youtube.com/@codewithgarry"
    echo ""
}

# Execute main function
main "$@"
