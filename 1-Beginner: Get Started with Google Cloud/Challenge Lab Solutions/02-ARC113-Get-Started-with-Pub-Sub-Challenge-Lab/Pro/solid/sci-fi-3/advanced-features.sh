#!/bin/bash

# sci-fi-3: Advanced Features and Snapshot Management
# ARC113 Challenge Lab - Task 4 & 5 Solution  
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
LOG_FILE="${SCRIPT_DIR}/advanced-features.log"

# Default configurations
SNAPSHOT_PATTERNS=("snapshot-1" "my-snapshot" "test-snapshot" "backup-snapshot")
DEFAULT_SNAPSHOT_NAME="snapshot-1"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🚀 sci-fi-3: Advanced Features                     ║${NC}"
    echo -e "${PURPLE}║               ARC113 Task 4&5 - Advanced Solution                 ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Auto-detect subscription name for snapshot creation
auto_detect_subscription() {
    local subscription_list
    subscription_list=$(gcloud pubsub subscriptions list --format="value(name.basename())" 2>/dev/null | head -1)
    
    if [[ -n "$subscription_list" ]]; then
        echo "$subscription_list"
    else
        echo "mySubscription"
    fi
}

# Validate snapshot name
validate_snapshot_name() {
    local snapshot_name="$1"
    
    if [[ ! "$snapshot_name" =~ ^[a-zA-Z]([a-zA-Z0-9_-]*[a-zA-Z0-9])?$ ]]; then
        echo -e "${RED}❌ Invalid snapshot name format${NC}"
        return 1
    fi
    
    if [[ ${#snapshot_name} -gt 255 ]]; then
        echo -e "${RED}❌ Snapshot name too long (max 255 chars)${NC}"
        return 1
    fi
    
    return 0
}

# Create snapshot with advanced configuration
create_snapshot_advanced() {
    local snapshot_name="$1"
    local subscription_name="$2"
    local expiration_policy="${3:-}"
    local labels="${4:-}"
    
    echo -e "${CYAN}Creating advanced snapshot: ${WHITE}$snapshot_name${NC}"
    log "Creating advanced snapshot: $snapshot_name from subscription: $subscription_name"
    
    # Build create command
    local create_cmd="gcloud pubsub snapshots create \"$snapshot_name\" --subscription=\"$subscription_name\""
    
    # Add expiration policy if specified
    if [[ -n "$expiration_policy" ]]; then
        create_cmd+=" --expiration-policy=\"$expiration_policy\""
        echo -e "${BLUE}  └─ Expiration policy: $expiration_policy${NC}"
    fi
    
    # Add labels if specified
    if [[ -n "$labels" ]]; then
        create_cmd+=" --labels=\"$labels\""
        echo -e "${BLUE}  └─ Labels: $labels${NC}"
    fi
    
    echo -e "${BLUE}  └─ Source subscription: $subscription_name${NC}"
    
    # Execute creation
    if eval "$create_cmd" 2>/dev/null; then
        echo -e "${GREEN}✅ Advanced snapshot created successfully${NC}"
        log "Advanced snapshot created successfully: $snapshot_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Snapshot might already exist${NC}"
        log "Advanced snapshot creation failed or already exists: $snapshot_name"
        return 1
    fi
}

# Create basic snapshot
create_snapshot_basic() {
    local snapshot_name="$1"
    local subscription_name="$2"
    
    echo -e "${CYAN}Creating basic snapshot: ${WHITE}$snapshot_name${NC}"
    echo -e "${BLUE}  └─ Source subscription: $subscription_name${NC}"
    log "Creating basic snapshot: $snapshot_name from subscription: $subscription_name"
    
    if gcloud pubsub snapshots create "$snapshot_name" --subscription="$subscription_name" 2>/dev/null; then
        echo -e "${GREEN}✅ Snapshot created successfully${NC}"
        log "Basic snapshot created successfully: $snapshot_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Snapshot might already exist${NC}"
        log "Basic snapshot creation failed or already exists: $snapshot_name"
        return 1
    fi
}

# Perform seek operation (advanced feature)
perform_seek_operation() {
    local subscription_name="$1"
    local snapshot_name="$2"
    
    echo -e "${CYAN}Performing seek operation...${NC}"
    echo -e "${BLUE}  └─ Subscription: $subscription_name${NC}"
    echo -e "${BLUE}  └─ Target snapshot: $snapshot_name${NC}"
    log "Performing seek operation: subscription=$subscription_name, snapshot=$snapshot_name"
    
    if gcloud pubsub subscriptions seek "$subscription_name" --snapshot="$snapshot_name" 2>/dev/null; then
        echo -e "${GREEN}✅ Seek operation completed successfully${NC}"
        log "Seek operation completed successfully"
        return 0
    else
        echo -e "${RED}❌ Seek operation failed${NC}"
        log "Seek operation failed"
        return 1
    fi
}

# Test message flow (advanced feature)
test_message_flow() {
    local topic_name="$1"
    local subscription_name="$2"
    local test_messages=("Test message 1" "Test message 2" "Test message 3")
    
    echo -e "${CYAN}Testing message flow...${NC}"
    log "Testing message flow: topic=$topic_name, subscription=$subscription_name"
    
    # Publish test messages
    for i in "${!test_messages[@]}"; do
        local message="${test_messages[$i]}"
        echo -e "${BLUE}  └─ Publishing: \"$message\"${NC}"
        
        if gcloud pubsub topics publish "$topic_name" --message="$message" 2>/dev/null; then
            echo -e "${GREEN}    ✅ Message $((i+1)) published${NC}"
        else
            echo -e "${RED}    ❌ Failed to publish message $((i+1))${NC}"
        fi
        
        sleep 1
    done
    
    echo ""
    echo -e "${CYAN}Pulling test messages...${NC}"
    sleep 2
    
    # Pull messages
    if gcloud pubsub subscriptions pull "$subscription_name" --auto-ack --limit=3 2>/dev/null; then
        echo -e "${GREEN}✅ Message flow test completed successfully${NC}"
        log "Message flow test completed successfully"
        return 0
    else
        echo -e "${YELLOW}⚠️  Some messages might not be available${NC}"
        log "Message flow test completed with warnings"
        return 1
    fi
}

# Monitor subscription metrics (advanced feature)
monitor_subscription_metrics() {
    local subscription_name="$1"
    
    echo -e "${CYAN}Monitoring subscription metrics...${NC}"
    log "Monitoring subscription metrics: $subscription_name"
    
    # Get subscription details
    echo -e "${BLUE}Subscription Configuration:${NC}"
    if gcloud pubsub subscriptions describe "$subscription_name" --format="yaml" 2>/dev/null; then
        echo ""
    else
        echo -e "${RED}❌ Failed to get subscription details${NC}"
        return 1
    fi
    
    # Check message count (if available)
    echo -e "${CYAN}Checking message backlog...${NC}"
    if gcloud pubsub subscriptions describe "$subscription_name" --format="value(numUndeliveredMessages)" 2>/dev/null; then
        echo -e "${GREEN}✅ Metrics retrieved successfully${NC}"
        log "Subscription metrics retrieved successfully"
        return 0
    else
        echo -e "${YELLOW}⚠️  Metrics might not be immediately available${NC}"
        log "Subscription metrics retrieval completed with warnings"
        return 1
    fi
}

# Verify snapshot creation
verify_snapshot() {
    local snapshot_name="$1"
    
    echo -e "${CYAN}Verifying snapshot: ${WHITE}$snapshot_name${NC}"
    log "Verifying snapshot: $snapshot_name"
    
    if gcloud pubsub snapshots describe "$snapshot_name" &>/dev/null; then
        echo -e "${GREEN}✅ Snapshot verification passed${NC}"
        
        # Show snapshot details
        echo -e "${BLUE}Snapshot Details:${NC}"
        gcloud pubsub snapshots describe "$snapshot_name" --format="table(name,subscription,expirePolicy.ttl)"
        
        log "Snapshot verification passed: $snapshot_name"
        return 0
    else
        echo -e "${RED}❌ Snapshot verification failed${NC}"
        log "Snapshot verification failed: $snapshot_name"
        return 1
    fi
}

# List all snapshots
list_snapshots() {
    echo -e "${CYAN}Current snapshots in project:${NC}"
    log "Listing all snapshots"
    
    if gcloud pubsub snapshots list --format="table(name.basename(),subscription.basename(),expirePolicy.ttl)" 2>/dev/null; then
        echo ""
    else
        echo -e "${YELLOW}⚠️  No snapshots found or access denied${NC}"
    fi
}

# Cleanup resources (advanced feature)
cleanup_test_resources() {
    local cleanup_mode="${1:-safe}"
    
    echo -e "${CYAN}Cleanup mode: ${WHITE}$cleanup_mode${NC}"
    log "Starting cleanup with mode: $cleanup_mode"
    
    if [[ "$cleanup_mode" == "aggressive" ]]; then
        echo -e "${YELLOW}⚠️  Aggressive cleanup will remove test resources${NC}"
        echo -e "${RED}This operation cannot be undone!${NC}"
        
        read -p "Are you sure? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            echo -e "${BLUE}Cleanup cancelled${NC}"
            return 0
        fi
        
        # List resources to be deleted
        echo -e "${CYAN}Resources that will be deleted:${NC}"
        gcloud pubsub snapshots list --filter="name:test*" --format="value(name.basename())"
        
        # Perform cleanup
        echo -e "${CYAN}Performing cleanup...${NC}"
        gcloud pubsub snapshots list --filter="name:test*" --format="value(name.basename())" | while read snapshot; do
            if [[ -n "$snapshot" ]]; then
                echo -e "${YELLOW}Deleting snapshot: $snapshot${NC}"
                gcloud pubsub snapshots delete "$snapshot" --quiet 2>/dev/null || true
            fi
        done
        
        echo -e "${GREEN}✅ Aggressive cleanup completed${NC}"
    else
        echo -e "${BLUE}Safe cleanup - no resources will be deleted${NC}"
        echo -e "${CYAN}To perform aggressive cleanup, use: $0 --cleanup=aggressive${NC}"
    fi
    
    log "Cleanup completed with mode: $cleanup_mode"
}

# Main workflow for advanced features
main_workflow() {
    local snapshot_name="${1:-}"
    local subscription_name="${2:-}"
    local advanced_mode="${3:-false}"
    local enable_testing="${4:-false}"
    
    show_banner
    
    # Auto-detect if parameters not provided
    if [[ -z "$snapshot_name" ]]; then
        snapshot_name="$DEFAULT_SNAPSHOT_NAME"
        echo -e "${BLUE}ℹ️  Using default snapshot name: ${WHITE}$snapshot_name${NC}"
    fi
    
    if [[ -z "$subscription_name" ]]; then
        subscription_name=$(auto_detect_subscription)
        echo -e "${BLUE}ℹ️  Auto-detected subscription name: ${WHITE}$subscription_name${NC}"
    fi
    
    # Validate snapshot name
    if ! validate_snapshot_name "$snapshot_name"; then
        exit 1
    fi
    
    echo ""
    
    # Create snapshot
    if [[ "$advanced_mode" == "true" ]]; then
        create_snapshot_advanced "$snapshot_name" "$subscription_name" "never" "env=lab,purpose=backup"
    else
        create_snapshot_basic "$snapshot_name" "$subscription_name"
    fi
    
    echo ""
    
    # Verify snapshot
    verify_snapshot "$snapshot_name"
    
    echo ""
    
    # Advanced features
    if [[ "$advanced_mode" == "true" ]]; then
        echo -e "${CYAN}Running advanced features...${NC}"
        
        # Monitor subscription metrics
        monitor_subscription_metrics "$subscription_name"
        echo ""
        
        # Test message flow if enabled
        if [[ "$enable_testing" == "true" ]]; then
            local topic_name
            topic_name=$(gcloud pubsub subscriptions describe "$subscription_name" --format="value(topic.basename())" 2>/dev/null)
            
            if [[ -n "$topic_name" ]]; then
                test_message_flow "$topic_name" "$subscription_name"
                echo ""
                
                # Perform seek operation back to snapshot
                perform_seek_operation "$subscription_name" "$snapshot_name"
                echo ""
            fi
        fi
    fi
    
    # List all snapshots
    list_snapshots
    
    echo -e "${GREEN}🎉 sci-fi-3 tasks completed successfully!${NC}"
    log "sci-fi-3 tasks completed successfully"
}

# Interactive mode
interactive_mode() {
    show_banner
    
    echo -e "${WHITE}Advanced Features Configuration:${NC}"
    echo ""
    
    # Get snapshot name
    echo -e "${CYAN}Enter snapshot name (or press Enter for default):${NC}"
    read -p "Snapshot Name: " snapshot_name
    
    if [[ -z "$snapshot_name" ]]; then
        snapshot_name="$DEFAULT_SNAPSHOT_NAME"
        echo -e "${BLUE}Using default: $snapshot_name${NC}"
    fi
    
    # Get subscription name
    echo -e "${CYAN}Enter subscription name (or press Enter for auto-detection):${NC}"
    read -p "Subscription Name: " subscription_name
    
    if [[ -z "$subscription_name" ]]; then
        subscription_name=$(auto_detect_subscription)
        echo -e "${BLUE}Using auto-detected: $subscription_name${NC}"
    fi
    
    # Ask for advanced features
    echo -e "${CYAN}Enable advanced features? (y/n):${NC}"
    read -p "Advanced mode: " advanced_choice
    
    local advanced_mode="false"
    local enable_testing="false"
    
    if [[ "$advanced_choice" =~ ^[Yy]$ ]]; then
        advanced_mode="true"
        
        echo -e "${CYAN}Enable message flow testing? (y/n):${NC}"
        read -p "Testing mode: " testing_choice
        
        if [[ "$testing_choice" =~ ^[Yy]$ ]]; then
            enable_testing="true"
        fi
    fi
    
    echo ""
    main_workflow "$snapshot_name" "$subscription_name" "$advanced_mode" "$enable_testing"
}

# Command line argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --snapshot)
                SNAPSHOT_NAME="$2"
                shift 2
                ;;
            --subscription)
                SUBSCRIPTION_NAME="$2"
                shift 2
                ;;
            --advanced)
                ADVANCED_MODE="true"
                shift
                ;;
            --enable-testing)
                ENABLE_TESTING="true"
                shift
                ;;
            --cleanup)
                cleanup_test_resources "${2:-safe}"
                exit 0
                ;;
            --interactive)
                interactive_mode
                exit 0
                ;;
            --list)
                list_snapshots
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
    echo -e "${WHITE}sci-fi-3: Advanced Features${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --snapshot NAME       Specify snapshot name"
    echo "  --subscription NAME   Specify subscription name"
    echo "  --advanced            Enable advanced features"
    echo "  --enable-testing      Enable message flow testing"
    echo "  --cleanup [MODE]      Cleanup test resources (safe|aggressive)"
    echo "  --interactive         Run in interactive mode"
    echo "  --list                List all existing snapshots"
    echo "  --help, -h            Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                                              # Auto-detect and execute"
    echo "  $0 --snapshot mySnapshot --subscription mySub  # Specify names"
    echo "  $0 --advanced --enable-testing                 # Full featured mode"
    echo "  $0 --cleanup=aggressive                        # Remove test resources"
    echo "  $0 --interactive                               # Interactive mode"
    echo ""
}

# Initialize variables
SNAPSHOT_NAME=""
SUBSCRIPTION_NAME=""
ADVANCED_MODE="false"
ENABLE_TESTING="false"

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse arguments
    parse_arguments "$@"
    
    # Run main workflow
    main_workflow "$SNAPSHOT_NAME" "$SUBSCRIPTION_NAME" "$ADVANCED_MODE" "$ENABLE_TESTING"
fi
