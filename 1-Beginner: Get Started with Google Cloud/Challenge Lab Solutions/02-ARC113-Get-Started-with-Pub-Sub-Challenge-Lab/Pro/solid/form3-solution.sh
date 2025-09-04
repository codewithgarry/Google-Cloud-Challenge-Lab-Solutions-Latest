#!/bin/bash

# =============================================================================
# ARC113 Form 3: Scheduler Integration - Complete Solution
# =============================================================================
# 
# 🎯 Tasks: Set up Pub/Sub → Create Scheduler job → Verify results
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 
# ✨ Features:
# - Automated Pub/Sub infrastructure setup
# - Smart Cloud Scheduler configuration
# - Real-time message verification
# - Production-ready monitoring
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
readonly TOPIC_NAME="scheduler-topic"
readonly SUBSCRIPTION_NAME="scheduler-subscription"
readonly JOB_NAME="pubsub-scheduler-job"

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

# Progress indicator
show_progress() {
    local duration=$1
    local message=$2
    
    for ((i=1; i<=duration; i++)); do
        printf "\r${CYAN}$message... %d/%d seconds${NC}" "$i" "$duration"
        sleep 1
    done
    printf "\r%*s\r" $((${#message} + 20)) " "
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
        "cloudscheduler.googleapis.com"
        "appengine.googleapis.com"
    )
    
    for api in "${apis[@]}"; do
        print_step "Enabling $api..."
        gcloud services enable "$api" --quiet
    done
    
    print_success "All APIs enabled"
}

# Task 1: Set up Cloud Pub/Sub
setup_pubsub() {
    print_header "Task 1: Setting up Cloud Pub/Sub Infrastructure"
    
    # Create topic
    print_step "Creating Pub/Sub topic: $TOPIC_NAME"
    if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_info "Topic '$TOPIC_NAME' already exists"
    else
        gcloud pubsub topics create "$TOPIC_NAME" --quiet
        print_success "Topic created: $TOPIC_NAME"
    fi
    
    # Create subscription with optimized settings
    print_step "Creating subscription: $SUBSCRIPTION_NAME"
    if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        print_info "Subscription '$SUBSCRIPTION_NAME' already exists"
    else
        gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
            --topic="$TOPIC_NAME" \
            --ack-deadline=60 \
            --message-retention-duration=7d \
            --quiet
        print_success "Subscription created: $SUBSCRIPTION_NAME"
    fi
    
    # Test basic Pub/Sub functionality
    print_step "Testing Pub/Sub setup..."
    local test_message="Initial test message from CodeWithGarry - $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    gcloud pubsub topics publish "$TOPIC_NAME" --message="$test_message" --quiet
    
    # Verify message was published
    sleep 2
    local received_count
    received_count=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" \
        --limit=1 --auto-ack --format="value(message.messageId)" --quiet 2>/dev/null | wc -l)
    
    if [[ "$received_count" -gt 0 ]]; then
        print_success "Pub/Sub infrastructure test passed!"
    else
        print_warning "Test message not immediately available (normal for new subscriptions)"
    fi
}

# Task 2: Create Cloud Scheduler job
create_scheduler_job() {
    print_header "Task 2: Creating Cloud Scheduler Job"
    
    print_step "Setting up Cloud Scheduler job: $JOB_NAME"
    
    # Check if App Engine app exists (required for Cloud Scheduler)
    if ! gcloud app describe &>/dev/null; then
        print_step "Creating App Engine application (required for Cloud Scheduler)..."
        gcloud app create --region="$LOCATION" --quiet || {
            print_warning "App Engine app creation failed or already exists in different region"
        }
    fi
    
    # Create scheduler job
    if gcloud scheduler jobs describe "$JOB_NAME" --location="$LOCATION" &>/dev/null; then
        print_info "Scheduler job '$JOB_NAME' already exists"
    else
        # Create comprehensive message payload
        local current_time
        current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        
        local message_payload
        message_payload='{
            "source": "cloud-scheduler",
            "message": "Automated message from CodeWithGarry ARC113 Solution",
            "timestamp": "'$current_time'",
            "job_name": "'$JOB_NAME'",
            "lab_id": "ARC113",
            "sequence": 1,
            "metadata": {
                "created_by": "codewithgarry",
                "lab_form": "form3",
                "region": "'$LOCATION'",
                "project": "'$(gcloud config get-value project)'"
            }
        }'
        
        # Create the job with every 2 minutes schedule
        gcloud scheduler jobs create pubsub "$JOB_NAME" \
            --schedule="*/2 * * * *" \
            --topic="$TOPIC_NAME" \
            --message-body="$message_payload" \
            --location="$LOCATION" \
            --time-zone="UTC" \
            --description="ARC113 Lab Scheduler Job by CodeWithGarry" \
            --quiet
        
        print_success "Scheduler job created: $JOB_NAME"
        print_info "Schedule: Every 2 minutes"
        print_info "Location: $LOCATION"
    fi
    
    # Trigger the job immediately for testing
    print_step "Triggering scheduler job for immediate test..."
    gcloud scheduler jobs run "$JOB_NAME" --location="$LOCATION" --quiet
    print_success "Scheduler job triggered successfully"
}

# Task 3: Verify results
verify_results() {
    print_header "Task 3: Verifying Scheduler Integration Results"
    
    print_step "Monitoring scheduled messages..."
    print_info "Waiting for messages from Cloud Scheduler..."
    
    local total_messages=0
    local verification_attempts=6
    local wait_time=10
    
    for ((attempt=1; attempt<=verification_attempts; attempt++)); do
        print_step "Verification attempt $attempt/$verification_attempts"
        
        # Pull messages from subscription
        local messages_output
        messages_output=$(gcloud pubsub subscriptions pull "$SUBSCRIPTION_NAME" \
            --limit=10 \
            --auto-ack \
            --format="table(message.data.decode('base64'),message.publishTime,message.messageId)" \
            --quiet 2>/dev/null || echo "")
        
        local message_count
        message_count=$(echo "$messages_output" | grep -c "cloud-scheduler" 2>/dev/null || echo "0")
        
        if [[ "$message_count" -gt 0 ]]; then
            total_messages=$((total_messages + message_count))
            print_success "Received $message_count scheduled messages (Total: $total_messages)"
            
            # Show sample message content
            if [[ "$attempt" -eq 1 ]] && [[ -n "$messages_output" ]]; then
                print_info "Sample message received:"
                echo "$messages_output" | head -3
            fi
        else
            print_info "No new messages in this attempt"
        fi
        
        # Wait before next attempt (except for last one)
        if [[ $attempt -lt $verification_attempts ]]; then
            show_progress $wait_time "Waiting for next check"
        fi
    done
    
    # Final verification
    echo ""
    if [[ $total_messages -gt 0 ]]; then
        print_success "✅ Scheduler integration verified! Received $total_messages messages total"
        print_success "✅ Cloud Scheduler is successfully publishing messages to Pub/Sub"
    else
        print_warning "No scheduler messages detected yet"
        print_info "This may be normal - scheduler jobs can take a few minutes to start"
        print_info "You can manually check with: gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack"
    fi
    
    # Show scheduler job status
    print_step "Checking scheduler job status..."
    local job_status
    job_status=$(gcloud scheduler jobs describe "$JOB_NAME" --location="$LOCATION" \
        --format="value(state,scheduleTime,lastAttemptTime)" 2>/dev/null || echo "unknown")
    print_info "Job status: $job_status"
}

# Comprehensive verification
verify_completion() {
    print_header "Verifying Form 3 Completion"
    
    local all_good=true
    
    # Check topic
    if gcloud pubsub topics describe "$TOPIC_NAME" &>/dev/null; then
        print_success "✅ Scheduler topic exists: $TOPIC_NAME"
    else
        print_error "❌ Scheduler topic missing: $TOPIC_NAME"
        all_good=false
    fi
    
    # Check subscription
    if gcloud pubsub subscriptions describe "$SUBSCRIPTION_NAME" &>/dev/null; then
        print_success "✅ Scheduler subscription exists: $SUBSCRIPTION_NAME"
    else
        print_error "❌ Scheduler subscription missing: $SUBSCRIPTION_NAME"
        all_good=false
    fi
    
    # Check scheduler job
    if gcloud scheduler jobs describe "$JOB_NAME" --location="$LOCATION" &>/dev/null; then
        print_success "✅ Scheduler job exists: $JOB_NAME"
        
        # Check job state
        local job_state
        job_state=$(gcloud scheduler jobs describe "$JOB_NAME" --location="$LOCATION" \
            --format="value(state)" 2>/dev/null)
        print_info "Job state: $job_state"
    else
        print_error "❌ Scheduler job missing: $JOB_NAME"
        all_good=false
    fi
    
    echo ""
    if [[ "$all_good" == true ]]; then
        print_success "🎉 All Form 3 tasks completed successfully!"
        print_info "Cloud Scheduler will continue sending messages every 2 minutes"
        print_info "Monitor with: gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack"
    else
        print_error "Some tasks are incomplete. Please check the errors above."
        return 1
    fi
}

# Main execution
main() {
    clear
    print_header "ARC113 Form 3: Scheduler Integration"
    print_color "$CYAN" "🚀 Complete Solution by CodeWithGarry"
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
    setup_pubsub
    create_scheduler_job
    verify_results
    verify_completion
    
    echo ""
    print_header "Monitoring Commands"
    print_color "$WHITE" "Use these commands to monitor your setup:"
    print_color "$CYAN" "• Check messages: gcloud pubsub subscriptions pull $SUBSCRIPTION_NAME --auto-ack"
    print_color "$CYAN" "• Job status: gcloud scheduler jobs describe $JOB_NAME --location=$LOCATION"
    print_color "$CYAN" "• Trigger manually: gcloud scheduler jobs run $JOB_NAME --location=$LOCATION"
    echo ""
    print_color "$WHITE" "🙏 Thank you for using CodeWithGarry's solution!"
    print_color "$CYAN" "📺 Subscribe: https://youtube.com/@codewithgarry"
    echo ""
}

# Execute main function
main "$@"
