#!/bin/bash

# Fix Verification System: Automated Issue Detection and Resolution
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
LOG_FILE="${SCRIPT_DIR}/verification.log"
FIXES_APPLIED=0

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🔧 Fix Verification System                         ║${NC}"
    echo -e "${PURPLE}║              Automated Issue Detection & Resolution               ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    echo -e "${CYAN}Checking prerequisites...${NC}"
    log "Starting prerequisite checks"
    
    local issues_found=0
    
    # Check gcloud installation
    if ! command -v gcloud &> /dev/null; then
        echo -e "${RED}❌ gcloud CLI not found${NC}"
        echo -e "${YELLOW}Fix: Install Google Cloud SDK${NC}"
        echo "curl https://sdk.cloud.google.com | bash"
        issues_found=$((issues_found + 1))
    else
        echo -e "${GREEN}✅ gcloud CLI found${NC}"
    fi
    
    # Check authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
        echo -e "${RED}❌ Not authenticated with gcloud${NC}"
        echo -e "${YELLOW}Fix: Run authentication${NC}"
        echo "gcloud auth login"
        issues_found=$((issues_found + 1))
    else
        echo -e "${GREEN}✅ gcloud authentication active${NC}"
    fi
    
    # Check project configuration
    local project_id
    project_id=$(gcloud config get-value project 2>/dev/null || echo "")
    if [[ -z "$project_id" ]]; then
        echo -e "${RED}❌ No project configured${NC}"
        echo -e "${YELLOW}Fix: Set project${NC}"
        echo "gcloud config set project YOUR_PROJECT_ID"
        issues_found=$((issues_found + 1))
    else
        echo -e "${GREEN}✅ Project configured: $project_id${NC}"
    fi
    
    # Check Pub/Sub API
    if ! gcloud services list --enabled --filter="name:pubsub.googleapis.com" --format="value(name)" | grep -q pubsub; then
        echo -e "${YELLOW}⚠️  Pub/Sub API not enabled${NC}"
        echo -e "${BLUE}Attempting to enable Pub/Sub API...${NC}"
        
        if gcloud services enable pubsub.googleapis.com --quiet 2>/dev/null; then
            echo -e "${GREEN}✅ Pub/Sub API enabled${NC}"
            FIXES_APPLIED=$((FIXES_APPLIED + 1))
        else
            echo -e "${RED}❌ Failed to enable Pub/Sub API${NC}"
            issues_found=$((issues_found + 1))
        fi
    else
        echo -e "${GREEN}✅ Pub/Sub API enabled${NC}"
    fi
    
    # Check permissions
    echo -e "${CYAN}Checking permissions...${NC}"
    if gcloud pubsub topics list --limit=1 &>/dev/null; then
        echo -e "${GREEN}✅ Pub/Sub permissions verified${NC}"
    else
        echo -e "${RED}❌ Insufficient Pub/Sub permissions${NC}"
        echo -e "${YELLOW}Required roles: Pub/Sub Admin or Editor${NC}"
        issues_found=$((issues_found + 1))
    fi
    
    log "Prerequisites check completed. Issues found: $issues_found"
    return $issues_found
}

# Verify script integrity
verify_scripts() {
    echo -e "${CYAN}Verifying script integrity...${NC}"
    log "Starting script verification"
    
    local issues_found=0
    local scripts=(
        "arc113-challenge-lab-runner.sh"
        "sci-fi-1/topic-creator.sh"
        "sci-fi-2/subscription-manager.sh"
        "sci-fi-3/advanced-features.sh"
        "test-system.sh"
    )
    
    for script in "${scripts[@]}"; do
        local script_path="${SCRIPT_DIR}/$script"
        
        if [[ -f "$script_path" ]]; then
            echo -e "${GREEN}✅ Found: $script${NC}"
            
            # Check if script is executable
            if [[ ! -x "$script_path" ]]; then
                echo -e "${YELLOW}⚠️  Making executable: $script${NC}"
                chmod +x "$script_path"
                FIXES_APPLIED=$((FIXES_APPLIED + 1))
            fi
            
            # Basic syntax check
            if ! bash -n "$script_path" 2>/dev/null; then
                echo -e "${RED}❌ Syntax error in: $script${NC}"
                issues_found=$((issues_found + 1))
            fi
        else
            echo -e "${RED}❌ Missing: $script${NC}"
            issues_found=$((issues_found + 1))
        fi
    done
    
    log "Script verification completed. Issues found: $issues_found"
    return $issues_found
}

# Health check for existing resources
health_check_resources() {
    echo -e "${CYAN}Performing resource health check...${NC}"
    log "Starting resource health check"
    
    local issues_found=0
    
    # Check for orphaned test resources
    echo -e "${BLUE}Checking for test resources...${NC}"
    
    local test_topics
    test_topics=$(gcloud pubsub topics list --filter="name:*test*" --format="value(name.basename())" 2>/dev/null || echo "")
    
    if [[ -n "$test_topics" ]]; then
        echo -e "${YELLOW}⚠️  Found test topics:${NC}"
        echo "$test_topics"
        echo -e "${BLUE}Recommendation: Clean up test resources${NC}"
    fi
    
    local test_subscriptions
    test_subscriptions=$(gcloud pubsub subscriptions list --filter="name:*test*" --format="value(name.basename())" 2>/dev/null || echo "")
    
    if [[ -n "$test_subscriptions" ]]; then
        echo -e "${YELLOW}⚠️  Found test subscriptions:${NC}"
        echo "$test_subscriptions"
        echo -e "${BLUE}Recommendation: Clean up test resources${NC}"
    fi
    
    # Check for resource quotas
    echo -e "${BLUE}Checking resource usage...${NC}"
    
    local topic_count
    topic_count=$(gcloud pubsub topics list --format="value(name)" 2>/dev/null | wc -l || echo "0")
    
    local subscription_count
    subscription_count=$(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null | wc -l || echo "0")
    
    echo -e "${CYAN}Current usage:${NC}"
    echo -e "  Topics: $topic_count"
    echo -e "  Subscriptions: $subscription_count"
    
    if [[ $topic_count -gt 100 ]]; then
        echo -e "${YELLOW}⚠️  High topic count: $topic_count${NC}"
        issues_found=$((issues_found + 1))
    fi
    
    if [[ $subscription_count -gt 100 ]]; then
        echo -e "${YELLOW}⚠️  High subscription count: $subscription_count${NC}"
        issues_found=$((issues_found + 1))
    fi
    
    log "Resource health check completed. Issues found: $issues_found"
    return $issues_found
}

# Fix common issues
auto_fix_issues() {
    echo -e "${CYAN}Attempting automatic fixes...${NC}"
    log "Starting automatic fixes"
    
    # Fix script permissions
    echo -e "${BLUE}Fixing script permissions...${NC}"
    find "$SCRIPT_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true
    
    # Create missing directories
    local required_dirs=(
        "sci-fi-1"
        "sci-fi-2" 
        "sci-fi-3"
        "config"
        "logs"
    )
    
    for dir in "${required_dirs[@]}"; do
        local dir_path="${SCRIPT_DIR}/$dir"
        if [[ ! -d "$dir_path" ]]; then
            echo -e "${BLUE}Creating directory: $dir${NC}"
            mkdir -p "$dir_path"
            FIXES_APPLIED=$((FIXES_APPLIED + 1))
        fi
    done
    
    # Enable required APIs
    echo -e "${BLUE}Ensuring required APIs are enabled...${NC}"
    if gcloud services enable pubsub.googleapis.com --quiet 2>/dev/null; then
        echo -e "${GREEN}✅ Pub/Sub API confirmed enabled${NC}"
    fi
    
    log "Automatic fixes completed. Fixes applied: $FIXES_APPLIED"
}

# Validate lab environment
validate_lab_environment() {
    echo -e "${CYAN}Validating lab environment...${NC}"
    log "Starting lab environment validation"
    
    local issues_found=0
    
    # Test basic Pub/Sub operations
    echo -e "${BLUE}Testing basic operations...${NC}"
    
    local test_topic="validation-test-$$"
    local test_subscription="validation-test-$$"
    
    # Test topic creation
    if gcloud pubsub topics create "$test_topic" &>/dev/null; then
        echo -e "${GREEN}✅ Topic creation works${NC}"
        
        # Test subscription creation
        if gcloud pubsub subscriptions create "$test_subscription" --topic="$test_topic" &>/dev/null; then
            echo -e "${GREEN}✅ Subscription creation works${NC}"
            
            # Test message publishing
            if gcloud pubsub topics publish "$test_topic" --message="validation test" &>/dev/null; then
                echo -e "${GREEN}✅ Message publishing works${NC}"
                
                # Test message pulling
                sleep 2
                if gcloud pubsub subscriptions pull "$test_subscription" --limit=1 --auto-ack &>/dev/null; then
                    echo -e "${GREEN}✅ Message pulling works${NC}"
                else
                    echo -e "${YELLOW}⚠️  Message pulling failed (may be timing issue)${NC}"
                fi
            else
                echo -e "${RED}❌ Message publishing failed${NC}"
                issues_found=$((issues_found + 1))
            fi
            
            # Cleanup subscription
            gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
        else
            echo -e "${RED}❌ Subscription creation failed${NC}"
            issues_found=$((issues_found + 1))
        fi
        
        # Cleanup topic
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
    else
        echo -e "${RED}❌ Topic creation failed${NC}"
        issues_found=$((issues_found + 1))
    fi
    
    log "Lab environment validation completed. Issues found: $issues_found"
    return $issues_found
}

# Performance diagnostics
performance_diagnostics() {
    echo -e "${CYAN}Running performance diagnostics...${NC}"
    log "Starting performance diagnostics"
    
    # Test API response times
    echo -e "${BLUE}Testing API response times...${NC}"
    
    local start_time end_time duration
    
    # Test topics list
    start_time=$(date +%s%N)
    gcloud pubsub topics list --limit=1 &>/dev/null
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
    
    echo -e "${CYAN}Topics list API: ${WHITE}${duration}ms${NC}"
    
    if [[ $duration -gt 5000 ]]; then
        echo -e "${YELLOW}⚠️  Slow API response detected${NC}"
    fi
    
    # Test subscriptions list
    start_time=$(date +%s%N)
    gcloud pubsub subscriptions list --limit=1 &>/dev/null
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))
    
    echo -e "${CYAN}Subscriptions list API: ${WHITE}${duration}ms${NC}"
    
    if [[ $duration -gt 5000 ]]; then
        echo -e "${YELLOW}⚠️  Slow API response detected${NC}"
    fi
    
    log "Performance diagnostics completed"
}

# Generate diagnostic report
generate_diagnostic_report() {
    local report_file="${SCRIPT_DIR}/diagnostic-report.txt"
    
    echo -e "${CYAN}Generating diagnostic report...${NC}"
    
    {
        echo "ARC113 Diagnostic Report"
        echo "Generated: $(date)"
        echo "========================"
        echo ""
        
        echo "System Information:"
        echo "  OS: $(uname -s)"
        echo "  Shell: $SHELL"
        echo "  gcloud version: $(gcloud version --format="value(Google Cloud SDK)" 2>/dev/null || echo "Not available")"
        echo ""
        
        echo "Project Configuration:"
        echo "  Project ID: $(gcloud config get-value project 2>/dev/null || echo "Not set")"
        echo "  Account: $(gcloud config get-value account 2>/dev/null || echo "Not set")"
        echo "  Region: $(gcloud config get-value compute/region 2>/dev/null || echo "Not set")"
        echo ""
        
        echo "Pub/Sub Resources:"
        echo "  Topics: $(gcloud pubsub topics list --format="value(name)" 2>/dev/null | wc -l || echo "0")"
        echo "  Subscriptions: $(gcloud pubsub subscriptions list --format="value(name)" 2>/dev/null | wc -l || echo "0")"
        echo "  Snapshots: $(gcloud pubsub snapshots list --format="value(name)" 2>/dev/null | wc -l || echo "0")"
        echo ""
        
        echo "Script Status:"
        find "$SCRIPT_DIR" -name "*.sh" -type f -printf "  %f: " -executable -printf "executable" -not -executable -printf "not executable" -printf "\n" 2>/dev/null || echo "  Script check not available"
        echo ""
        
        echo "Recent Fixes Applied: $FIXES_APPLIED"
        
    } > "$report_file"
    
    echo -e "${GREEN}✅ Diagnostic report saved: $report_file${NC}"
    log "Diagnostic report generated: $report_file"
}

# Main verification workflow
main_verification() {
    show_banner
    
    local total_issues=0
    
    # Run all checks
    if ! check_prerequisites; then
        total_issues=$((total_issues + $?))
    fi
    
    echo ""
    
    if ! verify_scripts; then
        total_issues=$((total_issues + $?))
    fi
    
    echo ""
    
    if ! health_check_resources; then
        total_issues=$((total_issues + $?))
    fi
    
    echo ""
    
    # Apply automatic fixes
    auto_fix_issues
    
    echo ""
    
    if ! validate_lab_environment; then
        total_issues=$((total_issues + $?))
    fi
    
    echo ""
    
    performance_diagnostics
    
    echo ""
    
    # Generate report
    generate_diagnostic_report
    
    echo ""
    
    # Summary
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                      Verification Summary                         ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}Issues found: ${WHITE}$total_issues${NC}"
    echo -e "${WHITE}Fixes applied: ${GREEN}$FIXES_APPLIED${NC}"
    echo ""
    
    if [[ $total_issues -eq 0 ]]; then
        echo -e "${GREEN}🎉 System verification passed!${NC}"
        echo -e "${BLUE}All systems are ready for ARC113 lab execution.${NC}"
        log "Verification passed - no issues found"
    else
        echo -e "${YELLOW}⚠️  Issues detected that may affect lab execution.${NC}"
        echo -e "${BLUE}Review the output above and diagnostic report for details.${NC}"
        log "Verification completed with $total_issues issues"
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prerequisites)
                check_prerequisites
                exit $?
                ;;
            --scripts)
                verify_scripts
                exit $?
                ;;
            --health)
                health_check_resources
                exit $?
                ;;
            --fix)
                auto_fix_issues
                exit $?
                ;;
            --validate)
                validate_lab_environment
                exit $?
                ;;
            --performance)
                performance_diagnostics
                exit $?
                ;;
            --report)
                generate_diagnostic_report
                exit $?
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
        shift
    done
}

# Show help
show_help() {
    echo ""
    echo -e "${CYAN}Fix Verification System - Usage Guide${NC}"
    echo ""
    echo "USAGE:"
    echo "  $0 [OPTION]"
    echo ""
    echo "OPTIONS:"
    echo "  --prerequisites    Check system prerequisites only"
    echo "  --scripts          Verify script integrity only"
    echo "  --health           Check resource health only"
    echo "  --fix              Apply automatic fixes only"
    echo "  --validate         Validate lab environment only"
    echo "  --performance      Run performance diagnostics only"
    echo "  --report           Generate diagnostic report only"
    echo "  --help, -h         Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                # Run complete verification"
    echo "  $0 --fix          # Apply automatic fixes"
    echo "  $0 --health       # Check resource health only"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -eq 0 ]]; then
        main_verification
    else
        parse_arguments "$@"
        main_verification
    fi
fi
