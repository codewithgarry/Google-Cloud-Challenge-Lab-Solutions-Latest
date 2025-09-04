#!/bin/bash

# sci-fi-2: Subscription and Message Management  
# ARC113 Challenge Lab - Task 2 & 3 Solution
# Version: 2.1.0

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/subscription-manager.log"

# Default configurations
SUBSCRIPTION_PATTERNS=("mySubscription" "test-subscription" "subscription1" "schema-subscription")
MESSAGE_PATTERNS=("Hello World" "Test message" "My first message" "Schema test message")
DEFAULT_SUBSCRIPTION_NAME="mySubscription"
DEFAULT_MESSAGE="Hello World"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🚀 sci-fi-2: Subscription Manager                  ║${NC}"
    echo -e "${PURPLE}║               ARC113 Task 2&3 - Advanced Solution                 ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Auto-detect subscription name
auto_detect_subscription() {
    local detected_subscription=""
    
    for pattern in "${SUBSCRIPTION_PATTERNS[@]}"; do
        if gcloud pubsub subscriptions describe "$pattern" &>/dev/null; then
            detected_subscription="$pattern"
            break
        fi
    done
    
    if [[ -n "$detected_subscription" ]]; then
        echo "$detected_subscription"
    else
        echo "$DEFAULT_SUBSCRIPTION_NAME"
    fi
}

# Auto-detect topic name
auto_detect_topic() {
    local topic_list
    topic_list=$(gcloud pubsub topics list --format="value(name.basename())" 2>/dev/null | head -1)
    
    if [[ -n "$topic_list" ]]; then
        echo "$topic_list"
    else
        echo "myTopic"
    fi
}

# Validate subscription name
validate_subscription_name() {
    local subscription_name="$1"
    
    if [[ ! "$subscription_name" =~ ^[a-zA-Z]([a-zA-Z0-9_-]*[a-zA-Z0-9])?$ ]]; then
        echo -e "${RED}❌ Invalid subscription name format${NC}"
        return 1
    fi
    
    if [[ ${#subscription_name} -gt 255 ]]; then
        echo -e "${RED}❌ Subscription name too long (max 255 chars)${NC}"
        return 1
    fi
    
    return 0
}

# Create subscription with advanced configuration
create_subscription_advanced() {
    local subscription_name="$1"
    local topic_name="$2"
    local ack_deadline="${3:-10s}"
    local retention_duration="${4:-7d}"
    local enable_ordering="${5:-false}"
    
    echo -e "${CYAN}Creating advanced subscription: ${WHITE}$subscription_name${NC}"
    log "Creating advanced subscription: $subscription_name for topic: $topic_name"
    
    # Build create command
    local create_cmd="gcloud pubsub subscriptions create \"$subscription_name\" --topic=\"$topic_name\""
    
    # Add advanced configurations
    create_cmd+=" --ack-deadline=\"$ack_deadline\""
    create_cmd+=" --message-retention-duration=\"$retention_duration\""
    
    if [[ "$enable_ordering" == "true" ]]; then
        create_cmd+=" --enable-message-ordering"
        echo -e "${BLUE}  └─ Message ordering enabled${NC}"
    fi
    
    echo -e "${BLUE}  └─ Ack deadline: $ack_deadline${NC}"
    echo -e "${BLUE}  └─ Retention: $retention_duration${NC}"
    
    # Execute creation
    if eval "$create_cmd" 2>/dev/null; then
        echo -e "${GREEN}✅ Advanced subscription created successfully${NC}"
        log "Advanced subscription created successfully: $subscription_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Subscription might already exist${NC}"
        log "Advanced subscription creation failed or already exists: $subscription_name"
        return 1
    fi
}

# Create basic subscription
create_subscription_basic() {
    local subscription_name="$1"
    local topic_name="$2"
    
    echo -e "${CYAN}Creating basic subscription: ${WHITE}$subscription_name${NC}"
    log "Creating basic subscription: $subscription_name for topic: $topic_name"
    
    if gcloud pubsub subscriptions create "$subscription_name" --topic="$topic_name" 2>/dev/null; then
        echo -e "${GREEN}✅ Subscription created successfully${NC}"
        log "Basic subscription created successfully: $subscription_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Subscription might already exist${NC}"
        log "Basic subscription creation failed or already exists: $subscription_name"
        return 1
    fi
}

# Publish message with advanced options
publish_message_advanced() {
    local topic_name="$1"
    local message="$2"
    local attributes="${3:-}"
    local ordering_key="${4:-}"
    
    echo -e "${CYAN}Publishing advanced message to: ${WHITE}$topic_name${NC}"
    log "Publishing advanced message to topic: $topic_name"
    
    # Build publish command
    local publish_cmd="gcloud pubsub topics publish \"$topic_name\" --message=\"$message\""
    
    # Add attributes if specified
    if [[ -n "$attributes" ]]; then
        publish_cmd+=" --attribute=\"$attributes\""
        echo -e "${BLUE}  └─ Attributes: $attributes${NC}"
    fi
    
    # Add ordering key if specified
    if [[ -n "$ordering_key" ]]; then
        publish_cmd+=" --ordering-key=\"$ordering_key\""
        echo -e "${BLUE}  └─ Ordering key: $ordering_key${NC}"
    fi
    
    echo -e "${BLUE}  └─ Message: \"$message\"${NC}"
    
    # Execute publishing
    if eval "$publish_cmd" 2>/dev/null; then
        echo -e "${GREEN}✅ Message published successfully${NC}"
        log "Advanced message published successfully"
        return 0
    else
        echo -e "${RED}❌ Failed to publish message${NC}"
        log "Advanced message publishing failed"
        return 1
    fi
}

# Publish basic message
publish_message_basic() {
    local topic_name="$1"
    local message="$2"
    
    echo -e "${CYAN}Publishing message to: ${WHITE}$topic_name${NC}"
    echo -e "${BLUE}  └─ Message: \"$message\"${NC}"
    log "Publishing basic message to topic: $topic_name"
    
    if gcloud pubsub topics publish "$topic_name" --message="$message" 2>/dev/null; then
        echo -e "${GREEN}✅ Message published successfully${NC}"
        log "Basic message published successfully"
        return 0
    else
        echo -e "${RED}❌ Failed to publish message${NC}"
        log "Basic message publishing failed"
        return 1
    fi
}

# Pull messages with advanced options
pull_messages_advanced() {
    local subscription_name="$1"
    local max_messages="${2:-1}"
    local auto_ack="${3:-true}"
    local return_immediately="${4:-false}"
    
    echo -e "${CYAN}Pulling messages from: ${WHITE}$subscription_name${NC}"
    log "Pulling messages from subscription: $subscription_name"
    
    # Build pull command
    local pull_cmd="gcloud pubsub subscriptions pull \"$subscription_name\" --limit=\"$max_messages\""
    
    if [[ "$auto_ack" == "true" ]]; then
        pull_cmd+=" --auto-ack"
        echo -e "${BLUE}  └─ Auto-acknowledge enabled${NC}"
    fi
    
    if [[ "$return_immediately" == "true" ]]; then
        pull_cmd+=" --max-wait=1s"
        echo -e "${BLUE}  └─ Return immediately${NC}"
    fi
    
    echo -e "${BLUE}  └─ Max messages: $max_messages${NC}"
    
    # Execute pull
    echo -e "${CYAN}Waiting for message propagation...${NC}"
    sleep 2
    
    if eval "$pull_cmd" 2>/dev/null; then
        echo -e "${GREEN}✅ Messages pulled successfully${NC}"
        log "Messages pulled successfully"
        return 0
    else
        echo -e "${YELLOW}⚠️  No messages available or already consumed${NC}"
        log "No messages available for pulling"
        return 1
    fi
}

# Pull basic message
pull_message_basic() {
    local subscription_name="$1"
    
    echo -e "${CYAN}Pulling message from: ${WHITE}$subscription_name${NC}"
    log "Pulling basic message from subscription: $subscription_name"
    
    echo -e "${CYAN}Waiting for message propagation...${NC}"
    sleep 2
    
    if gcloud pubsub subscriptions pull "$subscription_name" --auto-ack --limit=1 2>/dev/null; then
        echo -e "${GREEN}✅ Message pulled successfully${NC}"
        log "Basic message pulled successfully"
        return 0
    else
        echo -e "${YELLOW}⚠️  No messages available or already consumed${NC}"
        log "No messages available for basic pulling"
        return 1
    fi
}

# Verify subscription
verify_subscription() {
    local subscription_name="$1"
    
    echo -e "${CYAN}Verifying subscription: ${WHITE}$subscription_name${NC}"
    log "Verifying subscription: $subscription_name"
    
    if gcloud pubsub subscriptions describe "$subscription_name" &>/dev/null; then
        echo -e "${GREEN}✅ Subscription verification passed${NC}"
        
        # Show subscription details
        echo -e "${BLUE}Subscription Details:${NC}"
        gcloud pubsub subscriptions describe "$subscription_name" --format="table(name,topic,ackDeadlineSeconds,messageRetentionDuration)"
        
        log "Subscription verification passed: $subscription_name"
        return 0
    else
        echo -e "${RED}❌ Subscription verification failed${NC}"
        log "Subscription verification failed: $subscription_name"
        return 1
    fi
}

# List subscriptions
list_subscriptions() {
    echo -e "${CYAN}Current subscriptions in project:${NC}"
    log "Listing all subscriptions"
    
    if gcloud pubsub subscriptions list --format="table(name.basename(),topic.basename(),ackDeadlineSeconds)" 2>/dev/null; then
        echo ""
    else
        echo -e "${YELLOW}⚠️  No subscriptions found or access denied${NC}"
    fi
}

# Main workflow for subscription and messaging
main_workflow() {
    local subscription_name="${1:-}"
    local topic_name="${2:-}"
    local message="${3:-}"
    local advanced_mode="${4:-false}"
    
    show_banner
    
    # Auto-detect if parameters not provided
    if [[ -z "$subscription_name" ]]; then
        subscription_name=$(auto_detect_subscription)
        echo -e "${BLUE}ℹ️  Auto-detected subscription name: ${WHITE}$subscription_name${NC}"
    fi
    
    if [[ -z "$topic_name" ]]; then
        topic_name=$(auto_detect_topic)
        echo -e "${BLUE}ℹ️  Auto-detected topic name: ${WHITE}$topic_name${NC}"
    fi
    
    if [[ -z "$message" ]]; then
        message="$DEFAULT_MESSAGE"
        echo -e "${BLUE}ℹ️  Using default message: ${WHITE}\"$message\"${NC}"
    fi
    
    # Validate subscription name
    if ! validate_subscription_name "$subscription_name"; then
        exit 1
    fi
    
    echo ""
    
    # Create subscription
    if [[ "$advanced_mode" == "true" ]]; then
        create_subscription_advanced "$subscription_name" "$topic_name" "10s" "7d" "false"
    else
        create_subscription_basic "$subscription_name" "$topic_name"
    fi
    
    echo ""
    
    # Publish message
    if [[ "$advanced_mode" == "true" ]]; then
        publish_message_advanced "$topic_name" "$message" "source=automated,lab=ARC113" ""
    else
        publish_message_basic "$topic_name" "$message"
    fi
    
    echo ""
    
    # Pull message
    if [[ "$advanced_mode" == "true" ]]; then
        pull_messages_advanced "$subscription_name" "1" "true" "false"
    else
        pull_message_basic "$subscription_name"
    fi
    
    echo ""
    
    # Verify subscription
    verify_subscription "$subscription_name"
    
    echo ""
    
    # List all subscriptions
    list_subscriptions
    
    echo -e "${GREEN}🎉 sci-fi-2 tasks completed successfully!${NC}"
    log "sci-fi-2 tasks completed successfully"
}

# Interactive mode
interactive_mode() {
    show_banner
    
    echo -e "${WHITE}Subscription and Message Configuration:${NC}"
    echo ""
    
    # Get subscription name
    echo -e "${CYAN}Enter subscription name (or press Enter for auto-detection):${NC}"
    read -p "Subscription Name: " subscription_name
    
    if [[ -z "$subscription_name" ]]; then
        subscription_name=$(auto_detect_subscription)
        echo -e "${BLUE}Using auto-detected: $subscription_name${NC}"
    fi
    
    # Get topic name
    echo -e "${CYAN}Enter topic name (or press Enter for auto-detection):${NC}"
    read -p "Topic Name: " topic_name
    
    if [[ -z "$topic_name" ]]; then
        topic_name=$(auto_detect_topic)
        echo -e "${BLUE}Using auto-detected: $topic_name${NC}"
    fi
    
    # Get message
    echo -e "${CYAN}Enter message content (or press Enter for default):${NC}"
    read -p "Message: " message
    
    if [[ -z "$message" ]]; then
        message="$DEFAULT_MESSAGE"
        echo -e "${BLUE}Using default: \"$message\"${NC}"
    fi
    
    # Ask for advanced features
    echo -e "${CYAN}Enable advanced features? (y/n):${NC}"
    read -p "Advanced mode: " advanced_choice
    
    local advanced_mode="false"
    if [[ "$advanced_choice" =~ ^[Yy]$ ]]; then
        advanced_mode="true"
    fi
    
    echo ""
    main_workflow "$subscription_name" "$topic_name" "$message" "$advanced_mode"
}

# Command line argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --subscription)
                SUBSCRIPTION_NAME="$2"
                shift 2
                ;;
            --topic)
                TOPIC_NAME="$2"
                shift 2
                ;;
            --message)
                MESSAGE="$2"
                shift 2
                ;;
            --advanced)
                ADVANCED_MODE="true"
                shift
                ;;
            --interactive)
                interactive_mode
                exit 0
                ;;
            --list)
                list_subscriptions
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    echo -e "${WHITE}sci-fi-2: Subscription Manager${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --subscription NAME   Specify subscription name"
    echo "  --topic NAME          Specify topic name"
    echo "  --message TEXT        Specify message content"
    echo "  --advanced            Enable advanced features"
    echo "  --interactive         Run in interactive mode"
    echo "  --list                List all existing subscriptions"
    echo "  --help, -h            Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                                              # Auto-detect and execute"
    echo "  $0 --subscription mySub --topic myTopic        # Specify names"
    echo "  $0 --message \"Custom message\" --advanced      # Custom message with advanced features"
    echo "  $0 --interactive                               # Interactive mode"
    echo ""
}

# Initialize variables
SUBSCRIPTION_NAME=""
TOPIC_NAME=""
MESSAGE=""
ADVANCED_MODE="false"

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse arguments
    parse_arguments "$@"
    
    # Run main workflow
    main_workflow "$SUBSCRIPTION_NAME" "$TOPIC_NAME" "$MESSAGE" "$ADVANCED_MODE"
fi
