#!/bin/bash

# sci-fi-1: Topic Creation and Management
# ARC113 Challenge Lab - Task 1 Solution
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
LOG_FILE="${SCRIPT_DIR}/topic-creation.log"

# Default topic configurations
TOPIC_PATTERNS=("myTopic" "test-topic" "topic1" "schema-topic" "pubsub-topic")
DEFAULT_TOPIC_NAME="myTopic"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                     🚀 sci-fi-1: Topic Creator                    ║${NC}"
    echo -e "${PURPLE}║                    ARC113 Task 1 - Advanced Solution              ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Auto-detect topic name from lab environment
auto_detect_topic() {
    local detected_topic=""
    
    # Try to detect from common patterns
    for pattern in "${TOPIC_PATTERNS[@]}"; do
        if gcloud pubsub topics describe "$pattern" &>/dev/null; then
            detected_topic="$pattern"
            break
        fi
    done
    
    if [[ -n "$detected_topic" ]]; then
        echo "$detected_topic"
    else
        echo "$DEFAULT_TOPIC_NAME"
    fi
}

# Validate topic name
validate_topic_name() {
    local topic_name="$1"
    
    # Check naming conventions
    if [[ ! "$topic_name" =~ ^[a-zA-Z]([a-zA-Z0-9_-]*[a-zA-Z0-9])?$ ]]; then
        echo -e "${RED}❌ Invalid topic name format${NC}"
        return 1
    fi
    
    # Check length
    if [[ ${#topic_name} -gt 255 ]]; then
        echo -e "${RED}❌ Topic name too long (max 255 chars)${NC}"
        return 1
    fi
    
    return 0
}

# Create topic with advanced configuration
create_topic_advanced() {
    local topic_name="$1"
    local schema_id="${2:-}"
    local message_retention="${3:-}"
    
    echo -e "${CYAN}Creating topic: ${WHITE}$topic_name${NC}"
    log "Creating topic: $topic_name"
    
    # Build create command
    local create_cmd="gcloud pubsub topics create \"$topic_name\""
    
    # Add schema if specified
    if [[ -n "$schema_id" ]]; then
        create_cmd+=" --schema=\"$schema_id\""
        echo -e "${BLUE}  └─ Using schema: $schema_id${NC}"
    fi
    
    # Add message retention if specified
    if [[ -n "$message_retention" ]]; then
        create_cmd+=" --message-retention-duration=\"$message_retention\""
        echo -e "${BLUE}  └─ Message retention: $message_retention${NC}"
    fi
    
    # Execute creation
    if eval "$create_cmd" 2>/dev/null; then
        echo -e "${GREEN}✅ Topic created successfully${NC}"
        log "Topic created successfully: $topic_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Topic might already exist${NC}"
        log "Topic creation failed or already exists: $topic_name"
        return 1
    fi
}

# Create topic with basic configuration
create_topic_basic() {
    local topic_name="$1"
    
    echo -e "${CYAN}Creating basic topic: ${WHITE}$topic_name${NC}"
    log "Creating basic topic: $topic_name"
    
    if gcloud pubsub topics create "$topic_name" 2>/dev/null; then
        echo -e "${GREEN}✅ Topic created successfully${NC}"
        log "Basic topic created successfully: $topic_name"
        return 0
    else
        echo -e "${YELLOW}⚠️  Topic might already exist${NC}"
        log "Basic topic creation failed or already exists: $topic_name"
        return 1
    fi
}

# Verify topic creation
verify_topic() {
    local topic_name="$1"
    
    echo -e "${CYAN}Verifying topic: ${WHITE}$topic_name${NC}"
    log "Verifying topic: $topic_name"
    
    if gcloud pubsub topics describe "$topic_name" &>/dev/null; then
        echo -e "${GREEN}✅ Topic verification passed${NC}"
        
        # Show topic details
        echo -e "${BLUE}Topic Details:${NC}"
        gcloud pubsub topics describe "$topic_name" --format="table(name,messageRetentionDuration,schemaSettings.schema)"
        
        log "Topic verification passed: $topic_name"
        return 0
    else
        echo -e "${RED}❌ Topic verification failed${NC}"
        log "Topic verification failed: $topic_name"
        return 1
    fi
}

# List all topics
list_topics() {
    echo -e "${CYAN}Current topics in project:${NC}"
    log "Listing all topics"
    
    if gcloud pubsub topics list --format="table(name.basename(),messageRetentionDuration)" 2>/dev/null; then
        echo ""
    else
        echo -e "${YELLOW}⚠️  No topics found or access denied${NC}"
    fi
}

# Main topic creation workflow
main_workflow() {
    local topic_name="${1:-}"
    local advanced_mode="${2:-false}"
    local schema_id="${3:-}"
    local retention="${4:-}"
    
    show_banner
    
    # Auto-detect if no topic name provided
    if [[ -z "$topic_name" ]]; then
        topic_name=$(auto_detect_topic)
        echo -e "${BLUE}ℹ️  Auto-detected topic name: ${WHITE}$topic_name${NC}"
    fi
    
    # Validate topic name
    if ! validate_topic_name "$topic_name"; then
        exit 1
    fi
    
    # Create topic based on mode
    if [[ "$advanced_mode" == "true" ]]; then
        create_topic_advanced "$topic_name" "$schema_id" "$retention"
    else
        create_topic_basic "$topic_name"
    fi
    
    # Verify creation
    verify_topic "$topic_name"
    
    # List all topics
    list_topics
    
    echo -e "${GREEN}🎉 sci-fi-1 task completed successfully!${NC}"
    log "sci-fi-1 task completed successfully"
}

# Interactive mode
interactive_mode() {
    show_banner
    
    echo -e "${WHITE}Topic Creation Configuration:${NC}"
    echo ""
    
    # Get topic name
    echo -e "${CYAN}Enter topic name (or press Enter for auto-detection):${NC}"
    read -p "Topic Name: " topic_name
    
    if [[ -z "$topic_name" ]]; then
        topic_name=$(auto_detect_topic)
        echo -e "${BLUE}Using auto-detected: $topic_name${NC}"
    fi
    
    # Ask for advanced features
    echo -e "${CYAN}Enable advanced features? (y/n):${NC}"
    read -p "Advanced mode: " advanced_choice
    
    local advanced_mode="false"
    local schema_id=""
    local retention=""
    
    if [[ "$advanced_choice" =~ ^[Yy]$ ]]; then
        advanced_mode="true"
        
        echo -e "${CYAN}Enter schema ID (optional):${NC}"
        read -p "Schema ID: " schema_id
        
        echo -e "${CYAN}Enter message retention duration (optional, e.g., '7d'):${NC}"
        read -p "Retention: " retention
    fi
    
    echo ""
    main_workflow "$topic_name" "$advanced_mode" "$schema_id" "$retention"
}

# Command line argument parsing
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --topic)
                TOPIC_NAME="$2"
                shift 2
                ;;
            --advanced)
                ADVANCED_MODE="true"
                shift
                ;;
            --schema)
                SCHEMA_ID="$2"
                shift 2
                ;;
            --retention)
                RETENTION="$2"
                shift 2
                ;;
            --interactive)
                interactive_mode
                exit 0
                ;;
            --list)
                list_topics
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
    echo -e "${WHITE}sci-fi-1: Topic Creator${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --topic NAME          Specify topic name"
    echo "  --advanced            Enable advanced features"
    echo "  --schema ID           Specify schema ID (requires --advanced)"
    echo "  --retention DURATION  Set message retention (requires --advanced)"
    echo "  --interactive         Run in interactive mode"
    echo "  --list                List all existing topics"
    echo "  --help, -h            Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                                    # Auto-detect and create"
    echo "  $0 --topic myTopic                   # Create specific topic"
    echo "  $0 --topic myTopic --advanced        # Create with advanced features"
    echo "  $0 --interactive                     # Interactive mode"
    echo ""
}

# Initialize variables
TOPIC_NAME=""
ADVANCED_MODE="false"
SCHEMA_ID=""
RETENTION=""

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse arguments
    parse_arguments "$@"
    
    # Run main workflow
    main_workflow "$TOPIC_NAME" "$ADVANCED_MODE" "$SCHEMA_ID" "$RETENTION"
fi
