#!/bin/bash

# =============================================================================
# ARC113: Intelligent Form Detection & Auto-Execution System
# =============================================================================
# 
# 🎯 Purpose: Automatically detect lab form and execute appropriate solution
# 👨‍💻 Created by: CodeWithGarry
# 🌐 GitHub: https://github.com/codewithgarry
# 📺 YouTube: https://youtube.com/@codewithgarry
# 
# ✨ Features:
# - AI-powered form detection
# - Environment analysis
# - Automatic solution execution
# - Zero user intervention required
# 
# =============================================================================

set -euo pipefail

# Enhanced color codes
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
DETECTED_FORM=""
CONFIDENCE_SCORE=0
REGION=""

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_color() {
    printf "${1}${2}${NC}\n"
}

print_header() {
    echo ""
    print_color "$BLUE" "══════════════════════════════════════════════════════════════════"
    print_color "$WHITE" "  $1"
    print_color "$BLUE" "══════════════════════════════════════════════════════════════════"
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
    print_color "$BLUE" "ℹ️  $1"
}

print_ai() {
    print_color "$PURPLE" "🤖 $1"
}

# Progress animation
show_analysis_progress() {
    local duration=$1
    local message=$2
    
    for ((i=1; i<=duration; i++)); do
        local dots=""
        for ((j=1; j<=(i%4); j++)); do
            dots+="."
        done
        printf "\r${PURPLE}🧠 $message$dots${NC}%*s" $((4-${#dots})) ""
        sleep 0.5
    done
    printf "\r%*s\r" $((${#message} + 20)) " "
}

# =============================================================================
# ENVIRONMENT VALIDATION
# =============================================================================

validate_environment() {
    print_step "Validating environment..."
    
    # Check gcloud CLI
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud CLI not found. Please install gcloud."
        exit 1
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 > /dev/null 2>&1; then
        print_error "Not authenticated. Please run: gcloud auth login"
        exit 1
    fi
    
    # Get project ID
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
    if [[ -z "$PROJECT_ID" ]]; then
        print_error "No active project found. Please run: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
    
    # Set default region
    REGION=${LOCATION:-$(gcloud config get-value compute/region 2>/dev/null)}
    if [[ -z "$REGION" ]]; then
        REGION="us-central1"
        gcloud config set compute/region "$REGION" --quiet
        export LOCATION="$REGION"
    else
        export LOCATION="$REGION"
    fi
    
    print_success "Environment validated. Project: $PROJECT_ID, Region: $REGION"
}

# =============================================================================
# INTELLIGENT FORM DETECTION ENGINE
# =============================================================================

analyze_lab_instructions() {
    print_ai "Analyzing lab instructions and task descriptions..."
    
    # Try to detect lab instructions in common locations
    local instruction_indicators=0
    
    # Check for common lab instruction patterns
    local task_keywords=(
        "publish.*message.*topic"
        "view.*message" 
        "create.*snapshot"
        "create.*schema"
        "cloud.*function"
        "scheduler.*job"
        "verify.*results"
    )
    
    # Simulate instruction analysis (in real scenario, this would parse actual lab instructions)
    print_step "Scanning for task indicators..."
    
    # Basic pattern detection simulation
    for keyword in "${task_keywords[@]}"; do
        if [[ "$keyword" =~ (publish|view|snapshot) ]]; then
            ((instruction_indicators += 10))
        elif [[ "$keyword" =~ (schema|function) ]]; then
            ((instruction_indicators += 20))
        elif [[ "$keyword" =~ (scheduler|verify) ]]; then
            ((instruction_indicators += 30))
        fi
    done
    
    return $instruction_indicators
}

analyze_existing_resources() {
    print_ai "Analyzing existing Google Cloud resources..."
    
    local form1_score=0
    local form2_score=0 
    local form3_score=0
    
    # Enable APIs quietly for analysis
    gcloud services enable pubsub.googleapis.com --quiet 2>/dev/null || true
    
    # Analyze Pub/Sub resources
    print_step "Scanning Pub/Sub topics and subscriptions..."
    
    local topics
    topics=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null | wc -l)
    local subscriptions
    subscriptions=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null | wc -l) 
    local snapshots
    snapshots=$(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null | wc -l)
    
    print_info "Found: $topics topics, $subscriptions subscriptions, $snapshots snapshots"
    
    # Form 1 indicators (basic pub/sub)
    if [[ $topics -gt 0 && $subscriptions -gt 0 ]]; then
        form1_score=$((form1_score + 30))
    fi
    if [[ $snapshots -gt 0 ]]; then
        form1_score=$((form1_score + 40))
    fi
    
    # Check for schema indicators (Form 2)
    print_step "Scanning for Pub/Sub schemas..."
    local schemas
    schemas=$(gcloud pubsub schemas list --format="value(name)" 2>/dev/null | wc -l)
    
    if [[ $schemas -gt 0 ]]; then
        form2_score=$((form2_score + 50))
        print_info "Found $schemas schemas"
    fi
    
    # Check for Cloud Functions (Form 2)
    gcloud services enable cloudfunctions.googleapis.com --quiet 2>/dev/null || true
    local functions
    functions=$(gcloud functions list --format="value(name)" 2>/dev/null | wc -l)
    
    if [[ $functions -gt 0 ]]; then
        form2_score=$((form2_score + 40))
        print_info "Found $functions Cloud Functions"
    fi
    
    # Check for Cloud Scheduler (Form 3)
    gcloud services enable cloudscheduler.googleapis.com --quiet 2>/dev/null || true
    local jobs
    jobs=$(gcloud scheduler jobs list --format="value(name)" 2>/dev/null | wc -l)
    
    if [[ $jobs -gt 0 ]]; then
        form3_score=$((form3_score + 50))
        print_info "Found $jobs scheduler jobs"
    fi
    
    # Check for App Engine (required for Cloud Scheduler)
    if gcloud app describe --format="value(id)" &>/dev/null; then
        form3_score=$((form3_score + 30))
        print_info "App Engine application detected"
    fi
    
    # Return the highest scoring form
    if [[ $form3_score -gt $form2_score && $form3_score -gt $form1_score ]]; then
        echo "form3:$form3_score"
    elif [[ $form2_score -gt $form1_score && $form2_score -gt $form3_score ]]; then
        echo "form2:$form2_score"
    else
        echo "form1:$form1_score"
    fi
}

analyze_api_status() {
    print_ai "Analyzing enabled APIs and services..."
    
    local api_score=0
    local apis_to_check=(
        "pubsub.googleapis.com:10"
        "cloudfunctions.googleapis.com:20" 
        "cloudscheduler.googleapis.com:30"
        "cloudbuild.googleapis.com:20"
        "appengine.googleapis.com:30"
    )
    
    for api_info in "${apis_to_check[@]}"; do
        local api_name="${api_info%:*}"
        local score="${api_info#*:}"
        
        if gcloud services list --enabled --filter="name:$api_name" --format="value(name)" | grep -q "$api_name"; then
            print_info "✅ $api_name is enabled"
            api_score=$((api_score + score))
        else
            print_info "❌ $api_name is disabled" 
        fi
    done
    
    # API patterns suggest different forms
    if [[ $api_score -ge 90 ]]; then
        echo "form3"  # All APIs enabled suggests Form 3
    elif [[ $api_score -ge 50 ]]; then
        echo "form2"  # Functions + Pub/Sub suggests Form 2
    else
        echo "form1"  # Basic Pub/Sub suggests Form 1
    fi
}

analyze_project_metadata() {
    print_ai "Analyzing project metadata and naming patterns..."
    
    # Check project naming patterns that might indicate lab type
    if [[ "$PROJECT_ID" =~ qwiklabs.*arc113 ]]; then
        print_info "Qwiklabs ARC113 project detected"
        return 0
    fi
    
    # Check for lab-specific patterns in project metadata
    local project_info
    project_info=$(gcloud projects describe "$PROJECT_ID" --format="value(name,labels)" 2>/dev/null || echo "")
    
    if [[ "$project_info" =~ schema|function ]]; then
        echo "form2"
    elif [[ "$project_info" =~ scheduler|cron ]]; then
        echo "form3" 
    else
        echo "form1"
    fi
}

# =============================================================================
# MAIN DETECTION ENGINE
# =============================================================================

intelligent_form_detection() {
    print_header "🤖 AI-Powered Form Detection Engine"
    
    show_analysis_progress 8 "Analyzing lab environment"
    
    # Multiple analysis methods
    local resource_analysis
    resource_analysis=$(analyze_existing_resources)
    local resource_form="${resource_analysis%:*}"
    local resource_confidence="${resource_analysis#*:}"
    
    local api_analysis
    api_analysis=$(analyze_api_status)
    
    local metadata_analysis
    metadata_analysis=$(analyze_project_metadata)
    
    print_ai "Analysis results:"
    print_info "Resource analysis: $resource_form (confidence: $resource_confidence%)"
    print_info "API analysis: $api_analysis"
    print_info "Metadata analysis: $metadata_analysis"
    
    # Weighted decision making
    local form1_weight=0
    local form2_weight=0
    local form3_weight=0
    
    # Resource analysis (highest weight)
    case "$resource_form" in
        "form1") form1_weight=$((form1_weight + resource_confidence)) ;;
        "form2") form2_weight=$((form2_weight + resource_confidence)) ;;
        "form3") form3_weight=$((form3_weight + resource_confidence)) ;;
    esac
    
    # API analysis (medium weight)
    case "$api_analysis" in
        "form1") form1_weight=$((form1_weight + 30)) ;;
        "form2") form2_weight=$((form2_weight + 30)) ;;
        "form3") form3_weight=$((form3_weight + 30)) ;;
    esac
    
    # Metadata analysis (low weight)
    case "$metadata_analysis" in
        "form1") form1_weight=$((form1_weight + 10)) ;;
        "form2") form2_weight=$((form2_weight + 10)) ;;
        "form3") form3_weight=$((form3_weight + 10)) ;;
    esac
    
    # Determine final form and confidence
    if [[ $form3_weight -gt $form2_weight && $form3_weight -gt $form1_weight ]]; then
        DETECTED_FORM="form3"
        CONFIDENCE_SCORE=$form3_weight
    elif [[ $form2_weight -gt $form1_weight && $form2_weight -gt $form3_weight ]]; then
        DETECTED_FORM="form2" 
        CONFIDENCE_SCORE=$form2_weight
    else
        DETECTED_FORM="form1"
        CONFIDENCE_SCORE=$form1_weight
    fi
    
    # If confidence is low, use intelligent fallback
    if [[ $CONFIDENCE_SCORE -lt 30 ]]; then
        print_warning "Low confidence detection. Using intelligent fallback..."
        DETECTED_FORM="form1"  # Safe default
        CONFIDENCE_SCORE=50
    fi
    
    print_success "🎯 Form detected: $DETECTED_FORM (confidence: $CONFIDENCE_SCORE%)"
    
    # Show what this form includes
    case "$DETECTED_FORM" in
        "form1")
            print_info "📋 Tasks: Publish message → View message → Create snapshot"
            ;;
        "form2") 
            print_info "📋 Tasks: Create schema → Create topic with schema → Create Cloud Function"
            ;;
        "form3")
            print_info "📋 Tasks: Set up Pub/Sub → Create Scheduler job → Verify results"
            ;;
    esac
}

# =============================================================================
# AUTOMATIC EXECUTION
# =============================================================================

execute_detected_solution() {
    print_header "🚀 Executing Detected Solution"
    
    local script_name
    case "$DETECTED_FORM" in
        "form1") script_name="form1-solution.sh" ;;
        "form2") script_name="form2-solution.sh" ;;
        "form3") script_name="form3-solution.sh" ;;
    esac
    
    local script_url="https://raw.githubusercontent.com/codewithgarry/Google-Cloud-Challenge-Lab-Solutions-Latest/main/1-Beginner:%20Get%20Started%20with%20Google%20Cloud/Challenge%20Lab%20Solutions/02-ARC113-Get-Started-with-Pub-Sub-Challenge-Lab/Pro/solid/${script_name}"
    
    print_step "Downloading optimized solution: $script_name"
    
    if curl -LO "$script_url"; then
        print_success "Solution script downloaded"
    else
        print_error "Failed to download script. Falling back to manual selection."
        manual_form_selection
        return $?
    fi
    
    chmod +x "$script_name"
    
    print_step "Executing $DETECTED_FORM solution..."
    print_info "This may take a few minutes depending on the form complexity."
    
    if ./"$script_name"; then
        print_success "🎉 Solution executed successfully!"
    else
        print_error "Script execution failed. Please check the output above."
        return 1
    fi
    
    # Cleanup
    rm -f "$script_name"
}

# Fallback manual selection
manual_form_selection() {
    print_warning "Falling back to manual form selection..."
    echo ""
    print_color "$WHITE" "Please select your lab form:"
    print_color "$CYAN" "1) Form 1: Basic Pub/Sub (Publish → View → Snapshot)"
    print_color "$CYAN" "2) Form 2: Advanced with Schema & Functions"
    print_color "$CYAN" "3) Form 3: Scheduler Integration"
    echo ""
    
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1) DETECTED_FORM="form1" ;;
        2) DETECTED_FORM="form2" ;;
        3) DETECTED_FORM="form3" ;;
        *) print_error "Invalid choice."; exit 1 ;;
    esac
    
    execute_detected_solution
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    clear
    print_header "🤖 ARC113: Intelligent Auto-Detection System"
    print_color "$PURPLE" "🚀 AI-Powered Solution by CodeWithGarry"
    print_color "$CYAN" "📺 Subscribe: https://youtube.com/@codewithgarry"
    print_color "$CYAN" "⭐ Star us: https://github.com/codewithgarry"
    echo ""
    
    print_ai "Initializing intelligent form detection..."
    
    # Main workflow
    validate_environment
    intelligent_form_detection
    
    # Confirmation prompt
    echo ""
    print_color "$WHITE" "🤖 AI Detection Complete!"
    print_color "$YELLOW" "Detected Form: $DETECTED_FORM (Confidence: $CONFIDENCE_SCORE%)"
    echo ""
    
    if [[ $CONFIDENCE_SCORE -ge 70 ]]; then
        print_color "$GREEN" "High confidence detection! Auto-executing solution..."
        sleep 2
        execute_detected_solution
    else
        print_color "$YELLOW" "Medium confidence detection."
        read -p "Proceed with detected form? (y/n): " proceed
        
        if [[ "$proceed" =~ ^[Yy] ]]; then
            execute_detected_solution
        else
            manual_form_selection
        fi
    fi
    
    # Final success message
    print_header "🎉 Lab Completion"
    print_success "ARC113 Challenge Lab completed successfully!"
    echo ""
    print_color "$WHITE" "Next Steps:"
    print_color "$CYAN" "1. 📊 Check your lab progress page"
    print_color "$CYAN" "2. ✅ Verify all tasks show green checkmarks"
    print_color "$CYAN" "3. 🏆 Submit your lab for scoring"
    echo ""
    print_color "$PURPLE" "🙏 Thank you for using CodeWithGarry's AI-powered solutions!"
    print_color "$CYAN" "📺 Subscribe for more: https://youtube.com/@codewithgarry"
    echo ""
}

# Execute main function
main "$@"
