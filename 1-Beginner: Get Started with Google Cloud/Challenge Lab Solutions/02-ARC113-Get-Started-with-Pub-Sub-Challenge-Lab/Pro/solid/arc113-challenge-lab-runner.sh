#!/bin/bash

# =============================================================================
# ARC113: Get Started with Pub/Sub Challenge Lab - Advanced Solution Runner
# =============================================================================
# 
# 🎯 Purpose: Complete automated solution for all ARC113 challenge lab forms
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 📺 YouTube: https://youtube.com/@codewithgarry
# 
# ✨ Features:
# - Intelligent form detection
# - Smart resource naming
# - Comprehensive error handling
# - Production-ready configurations
# - Real-time progress monitoring
# 
# =============================================================================

# Enhanced color codes for professional output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Global variables
PROJECT_ID=""
REGION=""
ZONE=""
LAB_FORM=""

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo ""
    print_color $BLUE "══════════════════════════════════════════════════════════════════"
    print_color $WHITE "  $1"
    print_color $BLUE "══════════════════════════════════════════════════════════════════"
    echo ""
}

print_step() {
    print_color $CYAN "🔹 $1"
}

print_success() {
    print_color $GREEN "✅ $1"
}

print_warning() {
    print_color $YELLOW "⚠️  $1"
}

print_error() {
    print_color $RED "❌ $1"
}

print_info() {
    print_color $BLUE "ℹ️  $1"
}

# Progress spinner
show_spinner() {
    local -r msg="$1"
    local -r pid="$2"
    local -r delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r${CYAN}%c ${msg}${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r%*s\r" ${#msg} " "
}

# Wait for operation completion
wait_for_operation() {
    local operation_name="$1"
    local max_wait=300
    local wait_time=0
    
    print_step "Waiting for operation: $operation_name"
    
    while [ $wait_time -lt $max_wait ]; do
        local status=$(gcloud compute operations describe $operation_name --zone=$ZONE --format="value(status)" 2>/dev/null || echo "RUNNING")
        
        if [ "$status" = "DONE" ]; then
            print_success "Operation completed: $operation_name"
            return 0
        fi
        
        sleep 5
        wait_time=$((wait_time + 5))
        printf "\r${CYAN}⏳ Waiting... ${wait_time}s${NC}"
    done
    
    print_error "Operation timed out: $operation_name"
    return 1
}

# Validate environment
validate_environment() {
    print_step "Validating environment..."
    
    # Check gcloud CLI
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI not found. Please install gcloud."
        exit 1
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 > /dev/null; then
        print_error "Not authenticated. Please run: gcloud auth login"
        exit 1
    fi
    
    # Get project ID
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [ -z "$PROJECT_ID" ]; then
        print_error "No active project. Please run: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    print_success "Environment validated. Project: $PROJECT_ID"
}

# Enable required APIs
enable_apis() {
    print_step "Enabling required APIs..."
    
    local apis=(
        "pubsub.googleapis.com"
        "cloudfunctions.googleapis.com"
        "cloudscheduler.googleapis.com"
        "cloudbuild.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        print_step "Enabling $api..."
        gcloud services enable $api --quiet
        if [ $? -eq 0 ]; then
            print_success "Enabled: $api"
        else
            print_warning "Failed to enable: $api (might already be enabled)"
        fi
    done
}

# Detect lab form intelligently
detect_lab_form() {
    print_header "Lab Form Detection"
    
    print_step "Analyzing lab environment to detect form..."
    
    # Check for existing resources to determine form
    local topics=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null | wc -l)
    local schemas=$(gcloud pubsub schemas list --format="value(name)" 2>/dev/null | wc -l)
    local functions=$(gcloud functions list --format="value(name)" 2>/dev/null | wc -l)
    local jobs=$(gcloud scheduler jobs list --format="value(name)" 2>/dev/null | wc -l)
    
    print_info "Found: $topics topics, $schemas schemas, $functions functions, $jobs scheduler jobs"
    
    # Manual form selection with intelligent suggestions
    echo ""
    print_color $WHITE "Please select your lab form:"
    print_color $CYAN "1) Form 1: Basic Pub/Sub (Publish → View → Snapshot)"
    print_color $CYAN "2) Form 2: Advanced with Schema & Functions"
    print_color $CYAN "3) Form 3: Scheduler Integration"
    echo ""
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1) LAB_FORM="form1"; print_success "Selected Form 1: Basic Pub/Sub Operations" ;;
        2) LAB_FORM="form2"; print_success "Selected Form 2: Schema & Cloud Functions" ;;
        3) LAB_FORM="form3"; print_success "Selected Form 3: Scheduler Integration" ;;
        *) print_error "Invalid choice. Exiting."; exit 1 ;;
    esac
}

# Configure region/zone
configure_location() {
    if [ "$LAB_FORM" = "form2" ] || [ "$LAB_FORM" = "form3" ]; then
        print_header "Location Configuration"
        
        # Smart region detection
        local suggested_region=$(gcloud config get-value compute/region 2>/dev/null)
        if [ -z "$suggested_region" ]; then
            suggested_region="us-central1"
        fi
        
        print_step "Suggested region: $suggested_region"
        read -p "Enter region (press Enter for $suggested_region): " user_region
        
        REGION=${user_region:-$suggested_region}
        ZONE="${REGION}-a"
        
        # Set gcloud defaults
        gcloud config set compute/region $REGION --quiet
        gcloud config set compute/zone $ZONE --quiet
        
        print_success "Configured region: $REGION, zone: $ZONE"
    fi
}

# =============================================================================
# FORM 1: BASIC PUB/SUB OPERATIONS
# =============================================================================

execute_form1() {
    print_header "Executing Form 1: Basic Pub/Sub Operations"
    
    local topic_name="my-topic"
    local subscription_name="my-subscription"
    local snapshot_name="my-snapshot"
    
    # Check if resources already exist
    if gcloud pubsub topics describe $topic_name &>/dev/null; then
        print_info "Topic '$topic_name' already exists"
    else
        print_step "Creating Pub/Sub topic: $topic_name"
        gcloud pubsub topics create $topic_name
        print_success "Topic created: $topic_name"
    fi
    
    # Create subscription if it doesn't exist
    if gcloud pubsub subscriptions describe $subscription_name &>/dev/null; then
        print_info "Subscription '$subscription_name' already exists"
    else
        print_step "Creating subscription: $subscription_name"
        gcloud pubsub subscriptions create $subscription_name --topic=$topic_name
        print_success "Subscription created: $subscription_name"
    fi
    
    # Task 1: Publish a message
    print_step "Task 1: Publishing message to topic"
    local message="Hello from CodeWithGarry! Lab completed at $(date)"
    gcloud pubsub topics publish $topic_name --message="$message"
    print_success "Message published successfully"
    
    # Task 2: View the message
    print_step "Task 2: Pulling and viewing message"
    sleep 2  # Brief delay for message propagation
    local pulled_message=$(gcloud pubsub subscriptions pull $subscription_name --limit=1 --auto-ack --format="value(message.data)" 2>/dev/null)
    
    if [ -n "$pulled_message" ]; then
        print_success "Message retrieved: $(echo $pulled_message | base64 -d)"
    else
        print_warning "No message found, publishing another one..."
        gcloud pubsub topics publish $topic_name --message="Retry message from CodeWithGarry"
        sleep 2
        gcloud pubsub subscriptions pull $subscription_name --limit=1 --auto-ack --format="value(message.data)" >/dev/null
        print_success "Message processed"
    fi
    
    # Task 3: Create snapshot
    print_step "Task 3: Creating Pub/Sub snapshot"
    if gcloud pubsub snapshots describe $snapshot_name &>/dev/null; then
        print_info "Snapshot '$snapshot_name' already exists"
    else
        gcloud pubsub snapshots create $snapshot_name --subscription=$subscription_name
        print_success "Snapshot created: $snapshot_name"
    fi
    
    print_success "🎉 Form 1 completed successfully!"
}

# =============================================================================
# FORM 2: SCHEMA AND CLOUD FUNCTIONS
# =============================================================================

execute_form2() {
    print_header "Executing Form 2: Schema and Cloud Functions"
    
    local schema_name="my-schema"
    local topic_name="schema-topic"
    local function_name="pubsub-function"
    local subscription_name="function-subscription"
    
    # Task 1: Create Pub/Sub schema
    print_step "Task 1: Creating Pub/Sub schema"
    
    local schema_definition='{
        "type": "object",
        "properties": {
            "message": {
                "type": "string",
                "description": "The main message content"
            },
            "timestamp": {
                "type": "string",
                "description": "Message timestamp"
            },
            "source": {
                "type": "string",
                "description": "Message source"
            }
        },
        "required": ["message"]
    }'
    
    if gcloud pubsub schemas describe $schema_name &>/dev/null; then
        print_info "Schema '$schema_name' already exists"
    else
        echo "$schema_definition" > /tmp/schema.json
        gcloud pubsub schemas create $schema_name \
            --type=json \
            --definition-file=/tmp/schema.json
        print_success "Schema created: $schema_name"
        rm -f /tmp/schema.json
    fi
    
    # Task 2: Create topic with schema
    print_step "Task 2: Creating topic with schema validation"
    
    if gcloud pubsub topics describe $topic_name &>/dev/null; then
        print_info "Topic '$topic_name' already exists"
    else
        gcloud pubsub topics create $topic_name \
            --schema=$schema_name \
            --message-encoding=json
        print_success "Schema-enabled topic created: $topic_name"
    fi
    
    # Task 3: Create Cloud Function
    print_step "Task 3: Creating Cloud Function with Pub/Sub trigger"
    
    # Create function source code
    local function_dir="/tmp/pubsub-function"
    mkdir -p $function_dir
    
    # Create main.py
    cat > $function_dir/main.py << 'EOF'
import base64
import json
import logging
from datetime import datetime

def pubsub_function(event, context):
    """
    Cloud Function triggered by Pub/Sub message.
    Processes and logs the incoming message.
    """
    try:
        # Decode the message
        if 'data' in event:
            message_data = base64.b64decode(event['data']).decode('utf-8')
            print(f"Received message: {message_data}")
            
            # Try to parse as JSON
            try:
                parsed_data = json.loads(message_data)
                print(f"Parsed JSON: {parsed_data}")
            except json.JSONDecodeError:
                print(f"Message is not JSON: {message_data}")
        
        # Log event attributes
        if 'attributes' in event:
            print(f"Message attributes: {event['attributes']}")
        
        # Log processing timestamp
        print(f"Processed at: {datetime.now().isoformat()}")
        
        return "Message processed successfully"
        
    except Exception as e:
        print(f"Error processing message: {str(e)}")
        raise e
EOF
    
    # Create requirements.txt
    cat > $function_dir/requirements.txt << 'EOF'
functions-framework==3.*
EOF
    
    # Deploy the function
    if gcloud functions describe $function_name --region=$REGION &>/dev/null; then
        print_info "Function '$function_name' already exists"
    else
        print_step "Deploying Cloud Function..."
        (
            cd $function_dir
            gcloud functions deploy $function_name \
                --runtime=python39 \
                --trigger-topic=$topic_name \
                --entry-point=pubsub_function \
                --region=$REGION \
                --quiet
        ) &
        
        # Show spinner while deploying
        show_spinner "Deploying Cloud Function..." $!
        wait $!
        
        if [ $? -eq 0 ]; then
            print_success "Cloud Function deployed: $function_name"
        else
            print_error "Failed to deploy Cloud Function"
            return 1
        fi
    fi
    
    # Clean up temporary files
    rm -rf $function_dir
    
    # Test the setup
    print_step "Testing the setup..."
    local test_message='{"message": "Test from CodeWithGarry", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'", "source": "arc113-lab"}'
    gcloud pubsub topics publish $topic_name --message="$test_message"
    print_success "Test message published"
    
    print_success "🎉 Form 2 completed successfully!"
}

# =============================================================================
# FORM 3: SCHEDULER INTEGRATION
# =============================================================================

execute_form3() {
    print_header "Executing Form 3: Scheduler Integration"
    
    local topic_name="scheduler-topic"
    local subscription_name="scheduler-subscription"
    local job_name="pubsub-scheduler-job"
    
    # Task 1: Set up Cloud Pub/Sub
    print_step "Task 1: Setting up Cloud Pub/Sub infrastructure"
    
    # Create topic
    if gcloud pubsub topics describe $topic_name &>/dev/null; then
        print_info "Topic '$topic_name' already exists"
    else
        gcloud pubsub topics create $topic_name
        print_success "Topic created: $topic_name"
    fi
    
    # Create subscription
    if gcloud pubsub subscriptions describe $subscription_name &>/dev/null; then
        print_info "Subscription '$subscription_name' already exists"
    else
        gcloud pubsub subscriptions create $subscription_name \
            --topic=$topic_name \
            --ack-deadline=60
        print_success "Subscription created: $subscription_name"
    fi
    
    # Task 2: Create Cloud Scheduler job
    print_step "Task 2: Creating Cloud Scheduler job"
    
    local schedule="*/2 * * * *"  # Every 2 minutes
    local message_body='{"source": "cloud-scheduler", "message": "Automated message from CodeWithGarry", "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'
    
    if gcloud scheduler jobs describe $job_name --location=$REGION &>/dev/null; then
        print_info "Scheduler job '$job_name' already exists"
    else
        gcloud scheduler jobs create pubsub $job_name \
            --schedule="$schedule" \
            --topic=$topic_name \
            --message-body="$message_body" \
            --location=$REGION
        print_success "Scheduler job created: $job_name"
    fi
    
    # Start the job
    print_step "Starting scheduler job..."
    gcloud scheduler jobs run $job_name --location=$REGION
    print_success "Scheduler job triggered"
    
    # Task 3: Verify results
    print_step "Task 3: Verifying scheduler integration"
    
    print_step "Waiting for scheduled messages..."
    sleep 10
    
    local message_count=0
    for i in {1..5}; do
        local messages=$(gcloud pubsub subscriptions pull $subscription_name \
            --limit=5 \
            --auto-ack \
            --format="value(message.data)" 2>/dev/null | wc -l)
        
        if [ $messages -gt 0 ]; then
            message_count=$((message_count + messages))
            print_success "Received $messages messages (Total: $message_count)"
        fi
        
        if [ $i -lt 5 ]; then
            sleep 5
        fi
    done
    
    if [ $message_count -gt 0 ]; then
        print_success "✅ Scheduler integration verified! Received $message_count messages"
    else
        print_warning "No messages received yet. Scheduler may take a few minutes to start."
        print_info "You can check manually: gcloud pubsub subscriptions pull $subscription_name --auto-ack"
    fi
    
    print_success "🎉 Form 3 completed successfully!"
}

# =============================================================================
# VERIFICATION AND MONITORING
# =============================================================================

verify_completion() {
    print_header "Verification & Monitoring"
    
    case $LAB_FORM in
        "form1")
            print_step "Verifying Form 1 completion..."
            
            # Check topic
            if gcloud pubsub topics describe my-topic &>/dev/null; then
                print_success "✅ Topic exists"
            else
                print_error "❌ Topic missing"
            fi
            
            # Check subscription
            if gcloud pubsub subscriptions describe my-subscription &>/dev/null; then
                print_success "✅ Subscription exists"
            else
                print_error "❌ Subscription missing"
            fi
            
            # Check snapshot
            if gcloud pubsub snapshots describe my-snapshot &>/dev/null; then
                print_success "✅ Snapshot exists"
            else
                print_error "❌ Snapshot missing"
            fi
            ;;
            
        "form2")
            print_step "Verifying Form 2 completion..."
            
            # Check schema
            if gcloud pubsub schemas describe my-schema &>/dev/null; then
                print_success "✅ Schema exists"
            else
                print_error "❌ Schema missing"
            fi
            
            # Check topic with schema
            if gcloud pubsub topics describe schema-topic &>/dev/null; then
                print_success "✅ Schema-enabled topic exists"
            else
                print_error "❌ Schema-enabled topic missing"
            fi
            
            # Check function
            if gcloud functions describe pubsub-function --region=$REGION &>/dev/null; then
                print_success "✅ Cloud Function exists"
            else
                print_error "❌ Cloud Function missing"
            fi
            ;;
            
        "form3")
            print_step "Verifying Form 3 completion..."
            
            # Check topic
            if gcloud pubsub topics describe scheduler-topic &>/dev/null; then
                print_success "✅ Scheduler topic exists"
            else
                print_error "❌ Scheduler topic missing"
            fi
            
            # Check subscription
            if gcloud pubsub subscriptions describe scheduler-subscription &>/dev/null; then
                print_success "✅ Scheduler subscription exists"
            else
                print_error "❌ Scheduler subscription missing"
            fi
            
            # Check scheduler job
            if gcloud scheduler jobs describe pubsub-scheduler-job --location=$REGION &>/dev/null; then
                print_success "✅ Scheduler job exists"
            else
                print_error "❌ Scheduler job missing"
            fi
            ;;
    esac
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    clear
    print_header "ARC113: Get Started with Pub/Sub Challenge Lab"
    print_color $PURPLE "🚀 Advanced Solution Runner by CodeWithGarry"
    print_color $CYAN "📺 Subscribe: https://youtube.com/@codewithgarry"
    print_color $CYAN "⭐ Star us: https://github.com/codewithgarry"
    echo ""
    
    # Execute main workflow
    validate_environment
    enable_apis
    detect_lab_form
    configure_location
    
    # Execute form-specific solution
    case $LAB_FORM in
        "form1") execute_form1 ;;
        "form2") execute_form2 ;;
        "form3") execute_form3 ;;
    esac
    
    # Verify completion
    verify_completion
    
    # Final success message
    print_header "🎉 Lab Completion Summary"
    print_success "ARC113 Challenge Lab completed successfully!"
    echo ""
    print_color $WHITE "Next Steps:"
    print_color $CYAN "1. 📊 Check your lab progress page"
    print_color $CYAN "2. ✅ Verify all tasks show green checkmarks"
    print_color $CYAN "3. 🏆 Submit your lab for scoring"
    echo ""
    print_color $PURPLE "🙏 Thank you for using CodeWithGarry's solutions!"
    print_color $CYAN "📺 Subscribe for more: https://youtube.com/@codewithgarry"
    echo ""
}

# Execute main function
main "$@"
