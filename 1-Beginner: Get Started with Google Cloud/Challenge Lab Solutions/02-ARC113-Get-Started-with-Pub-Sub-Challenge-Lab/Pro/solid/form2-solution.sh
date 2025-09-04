#!/bin/bash

# =============================================================================
# ARC113 Form 2: Schema and Cloud Functions - Advanced Solution
# =============================================================================
# 
# 🎯 Tasks: Create schema → Create topic with schema → Create Cloud Function
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 
# ✨ Features:
# - Advanced schema validation
# - Production-ready Cloud Functions
# - Comprehensive error handling
# - Intelligent resource management
# 
# =============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# Configuration
readonly SCHEMA_NAME="my-schema"
readonly TOPIC_NAME="schema-topic"
readonly FUNCTION_NAME="pubsub-function"
readonly SUBSCRIPTION_NAME="function-subscription"

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

print_warning() {
    print_color "$YELLOW" "⚠️  $1"
}

print_error() {
    print_color "$RED" "❌ $1"
}

print_info() {
    print_color "$YELLOW" "ℹ️  $1"
}

# Validate environment and get region
validate_environment() {
    print_step "Validating environment..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI not found"
        exit 1
    fi
    
    local project_id
    project_id=$(gcloud config get-value project 2>/dev/null)
    if [[ -z "$project_id" ]]; then
        print_error "No active project found"
        exit 1
    fi
    
    # Set default region if not set
    local region
    region=${LOCATION:-$(gcloud config get-value compute/region 2>/dev/null)}
    if [[ -z "$region" ]]; then
        region="us-central1"
        gcloud config set compute/region "$region" --quiet
        export LOCATION="$region"
    else
        export LOCATION="$region"
    fi
    
    print_success "Environment validated. Project: $project_id, Region: $LOCATION"
}

# Enable required APIs
enable_apis() {
    print_step "Enabling required APIs..."
    
    local apis=(
        "pubsub.googleapis.com"
        "cloudfunctions.googleapis.com"
        "cloudbuild.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        print_step "Enabling $api..."
        gcloud services enable "$api" --quiet
    done
    
    print_success "All APIs enabled"
}

# Task 1: Create Pub/Sub schema
create_schema() {
    print_header "Task 1: Creating Pub/Sub Schema"
    
    print_step "Creating JSON schema: $SCHEMA_NAME"
    
    if gcloud pubsub schemas describe "$SCHEMA_NAME" &>/dev/null; then
        print_info "Schema '$SCHEMA_NAME' already exists"
        return 0
    fi
    
    # Create comprehensive JSON schema
    local schema_file
    schema_file=$(mktemp)
    
    cat > "$schema_file" << 'EOF'
{
  "type": "object",
  "properties": {
    "message": {
      "type": "string",
      "description": "The main message content",
      "minLength": 1
    },
    "timestamp": {
      "type": "string",
      "description": "ISO 8601 timestamp",
      "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$"
    },
    "source": {
      "type": "string",
      "description": "Message source identifier",
      "enum": ["arc113-lab", "cloud-scheduler", "manual", "automated"]
    },
    "priority": {
      "type": "string",
      "description": "Message priority level",
      "enum": ["low", "medium", "high", "critical"],
      "default": "medium"
    },
    "metadata": {
      "type": "object",
      "description": "Additional metadata",
      "properties": {
        "lab_id": {"type": "string"},
        "user": {"type": "string"},
        "version": {"type": "string"}
      }
    }
  },
  "required": ["message", "timestamp", "source"],
  "additionalProperties": false
}
EOF
    
    # Create the schema
    gcloud pubsub schemas create "$SCHEMA_NAME" \
        --type=json \
        --definition-file="$schema_file" \
        --quiet
    
    rm -f "$schema_file"
    print_success "Schema created: $SCHEMA_NAME"
    
    # Verify schema
    local schema_info
    schema_info=$(gcloud pubsub schemas describe "$SCHEMA_NAME" --format="value(name,type)" 2>/dev/null)
    print_info "Schema details: $schema_info"
}

# Task 2: Create topic with schema
create_topic_with_schema() {
    print_header "Task 2: Creating Topic with Schema Validation"
    
    print_step "Creating schema-enabled topic: $TOPIC_NAME"
    
    if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_info "Topic '$TOPIC_NAME' already exists"
        return 0
    fi
    
    # Create topic with schema validation
    gcloud pubsub topics create "$TOPIC_NAME" \
        --schema="$SCHEMA_NAME" \
        --message-encoding=json \
        --quiet
    
    print_success "Schema-enabled topic created: $TOPIC_NAME"
    
    # Create subscription for testing
    if ! gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
            --topic="$TOPIC_NAME" \
            --ack-deadline=60 \
            --quiet
        print_success "Test subscription created: $SUBSCRIPTION_NAME"
    fi
    
    # Test schema validation with a valid message
    print_step "Testing schema validation..."
    local test_message
    test_message='{
        "message": "Schema validation test from CodeWithGarry",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "source": "arc113-lab",
        "priority": "medium",
        "metadata": {
            "lab_id": "ARC113",
            "user": "codewithgarry",
            "version": "1.0"
        }
    }'
    
    gcloud pubsub topics publish "$TOPIC_NAME" \
        --message="$test_message" \
        --quiet
    
    print_success "Schema validation test passed!"
}

# Task 3: Create Cloud Function with Pub/Sub trigger
create_cloud_function() {
    print_header "Task 3: Creating Cloud Function with Pub/Sub Trigger"
    
    print_step "Preparing Cloud Function: $FUNCTION_NAME"
    
    if gcloud functions describe "$FUNCTION_NAME" --region="$LOCATION" &>/dev/null; then
        print_info "Function '$FUNCTION_NAME' already exists"
        return 0
    fi
    
    # Create temporary directory for function source
    local function_dir
    function_dir=$(mktemp -d)
    
    # Create advanced main.py
    cat > "$function_dir/main.py" << 'EOF'
import base64
import json
import logging
import os
from datetime import datetime
from typing import Dict, Any

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def pubsub_function(event: Dict[str, Any], context) -> str:
    """
    Advanced Cloud Function triggered by Pub/Sub messages.
    Processes schema-validated messages with comprehensive error handling.
    
    Args:
        event: Pub/Sub event data
        context: Cloud Function context
        
    Returns:
        str: Processing result message
    """
    try:
        # Log function trigger
        logger.info(f"Function triggered at: {datetime.now().isoformat()}")
        logger.info(f"Event ID: {context.eventId}")
        logger.info(f"Event Type: {context.eventType}")
        
        # Extract and decode message
        message_data = None
        if 'data' in event:
            encoded_data = event['data']
            decoded_bytes = base64.b64decode(encoded_data)
            message_data = decoded_bytes.decode('utf-8')
            logger.info(f"Raw message: {message_data}")
        
        # Parse JSON message (schema-validated)
        parsed_message = None
        if message_data:
            try:
                parsed_message = json.loads(message_data)
                logger.info("Message successfully parsed as JSON")
                
                # Process specific fields
                if 'message' in parsed_message:
                    logger.info(f"Message content: {parsed_message['message']}")
                
                if 'timestamp' in parsed_message:
                    logger.info(f"Message timestamp: {parsed_message['timestamp']}")
                
                if 'source' in parsed_message:
                    logger.info(f"Message source: {parsed_message['source']}")
                
                if 'priority' in parsed_message:
                    priority = parsed_message['priority']
                    logger.info(f"Message priority: {priority}")
                    
                    # Handle high priority messages
                    if priority == 'high' or priority == 'critical':
                        logger.warning(f"High priority message detected: {priority}")
                
                if 'metadata' in parsed_message:
                    metadata = parsed_message['metadata']
                    logger.info(f"Message metadata: {json.dumps(metadata)}")
                
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse JSON: {e}")
                return f"JSON parsing failed: {e}"
        
        # Log message attributes
        if 'attributes' in event and event['attributes']:
            logger.info(f"Message attributes: {event['attributes']}")
        
        # Simulate message processing
        processing_result = process_message(parsed_message)
        logger.info(f"Processing result: {processing_result}")
        
        # Log successful completion
        logger.info("Message processed successfully")
        return "Message processed successfully by CodeWithGarry's function"
        
    except Exception as e:
        logger.error(f"Error processing message: {str(e)}")
        logger.error(f"Event data: {event}")
        raise e

def process_message(message: Dict[str, Any]) -> str:
    """
    Process the parsed message content.
    
    Args:
        message: Parsed message dictionary
        
    Returns:
        str: Processing result
    """
    if not message:
        return "Empty message processed"
    
    # Simulate different processing based on message content
    source = message.get('source', 'unknown')
    priority = message.get('priority', 'medium')
    
    if source == 'arc113-lab':
        return f"Lab message processed with priority: {priority}"
    elif source == 'cloud-scheduler':
        return f"Scheduled message processed with priority: {priority}"
    else:
        return f"Message from {source} processed with priority: {priority}"

# Health check endpoint for monitoring
def health_check(request):
    """Health check endpoint for monitoring the function."""
    return {
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'function': 'pubsub-function',
        'version': '1.0'
    }
EOF
    
    # Create requirements.txt
    cat > "$function_dir/requirements.txt" << 'EOF'
functions-framework==3.*
google-cloud-logging==3.*
EOF
    
    # Deploy the function
    print_step "Deploying Cloud Function (this may take 2-3 minutes)..."
    
    # Change to function directory and deploy
    (
        cd "$function_dir" || exit 1
        gcloud functions deploy "$FUNCTION_NAME" \
            --runtime=python39 \
            --trigger-topic="$TOPIC_NAME" \
            --entry-point=pubsub_function \
            --region="$LOCATION" \
            --memory=256MB \
            --timeout=60s \
            --set-env-vars="PROJECT_ID=$(gcloud config get-value project)" \
            --quiet
    ) || {
        print_error "Function deployment failed"
        rm -rf "$function_dir"
        return 1
    }
    
    # Clean up
    rm -rf "$function_dir"
    
    print_success "Cloud Function deployed: $FUNCTION_NAME"
    
    # Test the function
    print_step "Testing Cloud Function integration..."
    local test_message
    test_message='{
        "message": "Test message for Cloud Function from CodeWithGarry",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "source": "arc113-lab",
        "priority": "high",
        "metadata": {
            "lab_id": "ARC113",
            "user": "codewithgarry",
            "test": "function-integration"
        }
    }'
    
    gcloud pubsub topics publish "$TOPIC_NAME" \
        --message="$test_message" \
        --quiet
    
    print_success "Test message sent to trigger function"
    print_info "Function logs can be viewed with: gcloud functions logs read $FUNCTION_NAME --region=$LOCATION"
}

# Verify all components
verify_completion() {
    print_header "Verifying Form 2 Completion"
    
    local all_good=true
    
    # Check schema
    if gcloud pubsub schemas describe "$SCHEMA_NAME" &>/dev/null; then
        print_success "✅ Schema exists: $SCHEMA_NAME"
    else
        print_error "❌ Schema missing: $SCHEMA_NAME"
        all_good=false
    fi
    
    # Check topic with schema
    local topic_info
    topic_info=$(gcloud pubsub topics describe "$TOPIC_NAME" --format="value(schemaSettings.schema)" 2>/dev/null)
    if [[ -n "$topic_info" ]]; then
        print_success "✅ Schema-enabled topic exists: $TOPIC_NAME"
        print_info "Schema: $topic_info"
    else
        print_error "❌ Schema-enabled topic missing: $TOPIC_NAME"
        all_good=false
    fi
    
    # Check Cloud Function
    if gcloud functions describe "$FUNCTION_NAME" --region="$LOCATION" &>/dev/null; then
        print_success "✅ Cloud Function exists: $FUNCTION_NAME"
        
        # Check function trigger
        local trigger_info
        trigger_info=$(gcloud functions describe "$FUNCTION_NAME" --region="$LOCATION" --format="value(eventTrigger.eventType,eventTrigger.resource)" 2>/dev/null)
        print_info "Function trigger: $trigger_info"
    else
        print_error "❌ Cloud Function missing: $FUNCTION_NAME"
        all_good=false
    fi
    
    echo ""
    if [[ "$all_good" == true ]]; then
        print_success "🎉 All Form 2 tasks completed successfully!"
        print_info "Schema validation is active on topic: $TOPIC_NAME"
        print_info "Cloud Function will process all messages published to the topic"
    else
        print_error "Some tasks are incomplete. Please check the errors above."
        return 1
    fi
}

# Main execution
main() {
    clear
    print_header "ARC113 Form 2: Schema and Cloud Functions"
    print_color "$CYAN" "🚀 Advanced Solution by CodeWithGarry"
    echo ""
    
    # Check if LOCATION is set
    if [[ -z "${LOCATION:-}" ]]; then
        print_warning "LOCATION environment variable not set"
        print_info "Using default region: us-central1"
        export LOCATION="us-central1"
    fi
    
    # Execute all tasks
    validate_environment
    enable_apis
    create_schema
    create_topic_with_schema
    create_cloud_function
    verify_completion
    
    echo ""
    print_color "$WHITE" "🙏 Thank you for using CodeWithGarry's solution!"
    print_color "$CYAN" "📺 Subscribe: https://youtube.com/@codewithgarry"
    print_info "Function logs: gcloud functions logs read $FUNCTION_NAME --region=$LOCATION"
    echo ""
}

# Execute main function
main "$@"
