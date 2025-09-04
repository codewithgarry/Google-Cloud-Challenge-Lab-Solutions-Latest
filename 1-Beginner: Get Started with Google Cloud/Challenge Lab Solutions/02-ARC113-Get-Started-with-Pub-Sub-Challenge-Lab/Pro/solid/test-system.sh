#!/bin/bash

# Test System: Comprehensive Testing Framework for ARC113
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
LOG_FILE="${SCRIPT_DIR}/test-results.log"
TEST_PREFIX="arc113-test"
CLEANUP_ON_SUCCESS=true

# Test statistics
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
START_TIME=""

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Display banner
show_banner() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    🧪 ARC113 Testing Framework                    ║${NC}"
    echo -e "${PURPLE}║                     Comprehensive Test Suite                      ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Initialize test environment
init_test_environment() {
    echo -e "${CYAN}Initializing test environment...${NC}"
    START_TIME=$(date +%s)
    
    # Clear previous test results
    > "$LOG_FILE"
    
    # Reset counters
    TESTS_RUN=0
    TESTS_PASSED=0
    TESTS_FAILED=0
    
    log "Test environment initialized"
    echo -e "${GREEN}✅ Test environment ready${NC}"
    echo ""
}

# Test helper functions
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -e "${CYAN}Running test: ${WHITE}$test_name${NC}"
    log "Starting test: $test_name"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if "$test_function"; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        log "PASSED: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        log "FAILED: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Cleanup test resources
cleanup_test_resources() {
    echo -e "${CYAN}Cleaning up test resources...${NC}"
    log "Starting cleanup"
    
    # Clean up topics
    gcloud pubsub topics list --filter="name:*${TEST_PREFIX}*" --format="value(name)" | while read -r topic; do
        if [[ -n "$topic" ]]; then
            echo -e "${YELLOW}Deleting topic: $(basename "$topic")${NC}"
            gcloud pubsub topics delete "$topic" --quiet 2>/dev/null || true
        fi
    done
    
    # Clean up subscriptions
    gcloud pubsub subscriptions list --filter="name:*${TEST_PREFIX}*" --format="value(name)" | while read -r subscription; do
        if [[ -n "$subscription" ]]; then
            echo -e "${YELLOW}Deleting subscription: $(basename "$subscription")${NC}"
            gcloud pubsub subscriptions delete "$subscription" --quiet 2>/dev/null || true
        fi
    done
    
    # Clean up snapshots
    gcloud pubsub snapshots list --filter="name:*${TEST_PREFIX}*" --format="value(name)" | while read -r snapshot; do
        if [[ -n "$snapshot" ]]; then
            echo -e "${YELLOW}Deleting snapshot: $(basename "$snapshot")${NC}"
            gcloud pubsub snapshots delete "$snapshot" --quiet 2>/dev/null || true
        fi
    done
    
    log "Cleanup completed"
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Unit Tests
test_topic_creation() {
    local test_topic="${TEST_PREFIX}-topic-$$"
    
    # Test topic creation
    if gcloud pubsub topics create "$test_topic" &>/dev/null; then
        # Verify topic exists
        if gcloud pubsub topics describe "$test_topic" &>/dev/null; then
            # Cleanup
            gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
            return 0
        fi
    fi
    
    return 1
}

test_subscription_creation() {
    local test_topic="${TEST_PREFIX}-topic-$$"
    local test_subscription="${TEST_PREFIX}-subscription-$$"
    
    # Create topic first
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    # Test subscription creation
    if gcloud pubsub subscriptions create "$test_subscription" --topic="$test_topic" &>/dev/null; then
        # Verify subscription exists
        if gcloud pubsub subscriptions describe "$test_subscription" &>/dev/null; then
            # Cleanup
            gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null
            gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
            return 0
        fi
    fi
    
    # Cleanup on failure
    gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
    return 1
}

test_message_publishing() {
    local test_topic="${TEST_PREFIX}-topic-$$"
    local test_message="test-message-$(date +%s)"
    
    # Create topic
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    # Test message publishing
    if gcloud pubsub topics publish "$test_topic" --message="$test_message" &>/dev/null; then
        # Cleanup
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
        return 0
    fi
    
    # Cleanup on failure
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
    return 1
}

test_snapshot_creation() {
    local test_topic="${TEST_PREFIX}-topic-$$"
    local test_subscription="${TEST_PREFIX}-subscription-$$"
    local test_snapshot="${TEST_PREFIX}-snapshot-$$"
    
    # Create topic and subscription
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    if ! gcloud pubsub subscriptions create "$test_subscription" --topic="$test_topic" &>/dev/null; then
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Test snapshot creation
    if gcloud pubsub snapshots create "$test_snapshot" --subscription="$test_subscription" &>/dev/null; then
        # Verify snapshot exists
        if gcloud pubsub snapshots describe "$test_snapshot" &>/dev/null; then
            # Cleanup
            gcloud pubsub snapshots delete "$test_snapshot" --quiet &>/dev/null
            gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null
            gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
            return 0
        fi
    fi
    
    # Cleanup on failure
    gcloud pubsub snapshots delete "$test_snapshot" --quiet &>/dev/null || true
    gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
    return 1
}

# Integration Tests
test_end_to_end_workflow() {
    local test_topic="${TEST_PREFIX}-e2e-topic-$$"
    local test_subscription="${TEST_PREFIX}-e2e-subscription-$$"
    local test_snapshot="${TEST_PREFIX}-e2e-snapshot-$$"
    local test_message="e2e-test-message-$(date +%s)"
    
    # Step 1: Create topic
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    # Step 2: Create subscription
    if ! gcloud pubsub subscriptions create "$test_subscription" --topic="$test_topic" &>/dev/null; then
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Step 3: Publish message
    if ! gcloud pubsub topics publish "$test_topic" --message="$test_message" &>/dev/null; then
        gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Step 4: Pull message
    sleep 2  # Wait for message propagation
    local received_message
    received_message=$(gcloud pubsub subscriptions pull "$test_subscription" --limit=1 --auto-ack --format="value(message.data)" 2>/dev/null | base64 -d || echo "")
    
    if [[ "$received_message" != "$test_message" ]]; then
        gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Step 5: Create snapshot
    if ! gcloud pubsub snapshots create "$test_snapshot" --subscription="$test_subscription" &>/dev/null; then
        gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null || true
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Cleanup
    gcloud pubsub snapshots delete "$test_snapshot" --quiet &>/dev/null
    gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
    
    return 0
}

test_script_execution() {
    local main_script="${SCRIPT_DIR}/arc113-challenge-lab-runner.sh"
    
    if [[ ! -f "$main_script" ]]; then
        echo "Main script not found: $main_script"
        return 1
    fi
    
    # Test script with help option
    if "$main_script" --help &>/dev/null; then
        return 0
    fi
    
    return 1
}

test_modular_scripts() {
    local topic_script="${SCRIPT_DIR}/sci-fi-1/topic-creator.sh"
    local subscription_script="${SCRIPT_DIR}/sci-fi-2/subscription-manager.sh"
    local advanced_script="${SCRIPT_DIR}/sci-fi-3/advanced-features.sh"
    
    # Test topic creator script
    if [[ -f "$topic_script" ]]; then
        if ! "$topic_script" --help &>/dev/null; then
            return 1
        fi
    fi
    
    # Test subscription manager script
    if [[ -f "$subscription_script" ]]; then
        if ! "$subscription_script" --help &>/dev/null; then
            return 1
        fi
    fi
    
    # Test advanced features script
    if [[ -f "$advanced_script" ]]; then
        if ! "$advanced_script" --help &>/dev/null; then
            return 1
        fi
    fi
    
    return 0
}

# Performance Tests
test_performance_benchmark() {
    local test_topic="${TEST_PREFIX}-perf-topic-$$"
    local test_subscription="${TEST_PREFIX}-perf-subscription-$$"
    local message_count=10
    
    # Setup
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    if ! gcloud pubsub subscriptions create "$test_subscription" --topic="$test_topic" &>/dev/null; then
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1
    fi
    
    # Performance test
    local start_time end_time duration
    start_time=$(date +%s)
    
    # Publish messages
    for ((i=1; i<=message_count; i++)); do
        gcloud pubsub topics publish "$test_topic" --message="perf-test-$i" &>/dev/null
    done
    
    # Pull messages
    sleep 2
    gcloud pubsub subscriptions pull "$test_subscription" --limit="$message_count" --auto-ack &>/dev/null
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "Performance: $message_count messages in ${duration}s"
    log "Performance test: $message_count messages in ${duration}s"
    
    # Cleanup
    gcloud pubsub subscriptions delete "$test_subscription" --quiet &>/dev/null
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
    
    # Pass if duration is reasonable (less than 30 seconds)
    if [[ $duration -lt 30 ]]; then
        return 0
    fi
    
    return 1
}

# Error Handling Tests
test_error_handling() {
    local invalid_topic="invalid/topic/name"
    
    # Test invalid topic name
    if gcloud pubsub topics create "$invalid_topic" &>/dev/null; then
        gcloud pubsub topics delete "$invalid_topic" --quiet &>/dev/null || true
        return 1  # Should have failed
    fi
    
    # Test duplicate resource creation
    local test_topic="${TEST_PREFIX}-dup-topic-$$"
    
    # Create topic
    if ! gcloud pubsub topics create "$test_topic" &>/dev/null; then
        return 1
    fi
    
    # Try to create same topic again (should fail gracefully)
    if gcloud pubsub topics create "$test_topic" &>/dev/null; then
        gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null || true
        return 1  # Should have failed
    fi
    
    # Cleanup
    gcloud pubsub topics delete "$test_topic" --quiet &>/dev/null
    
    return 0
}

# Run all unit tests
run_unit_tests() {
    echo -e "${BLUE}Running Unit Tests...${NC}"
    echo ""
    
    run_test "Topic Creation" test_topic_creation
    run_test "Subscription Creation" test_subscription_creation
    run_test "Message Publishing" test_message_publishing
    run_test "Snapshot Creation" test_snapshot_creation
    
    echo ""
}

# Run integration tests
run_integration_tests() {
    echo -e "${BLUE}Running Integration Tests...${NC}"
    echo ""
    
    run_test "End-to-End Workflow" test_end_to_end_workflow
    run_test "Script Execution" test_script_execution
    run_test "Modular Scripts" test_modular_scripts
    
    echo ""
}

# Run performance tests
run_performance_tests() {
    echo -e "${BLUE}Running Performance Tests...${NC}"
    echo ""
    
    run_test "Performance Benchmark" test_performance_benchmark
    
    echo ""
}

# Run error handling tests
run_error_tests() {
    echo -e "${BLUE}Running Error Handling Tests...${NC}"
    echo ""
    
    run_test "Error Handling" test_error_handling
    
    echo ""
}

# Display test results summary
show_test_summary() {
    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - START_TIME))
    
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                         Test Results Summary                      ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${WHITE}Test Statistics:${NC}"
    echo -e "${CYAN}Total Tests Run:    ${WHITE}$TESTS_RUN${NC}"
    echo -e "${GREEN}Tests Passed:       ${WHITE}$TESTS_PASSED${NC}"
    echo -e "${RED}Tests Failed:        ${WHITE}$TESTS_FAILED${NC}"
    echo -e "${BLUE}Execution Time:     ${WHITE}${duration}s${NC}"
    echo ""
    
    # Calculate success rate
    local success_rate=0
    if [[ $TESTS_RUN -gt 0 ]]; then
        success_rate=$((TESTS_PASSED * 100 / TESTS_RUN))
    fi
    
    echo -e "${WHITE}Success Rate:       ${WHITE}${success_rate}%${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
        log "All tests passed successfully"
    else
        echo -e "${RED}⚠️  Some tests failed. Check logs for details.${NC}"
        log "Some tests failed: $TESTS_FAILED out of $TESTS_RUN"
    fi
    
    echo ""
    echo -e "${BLUE}Detailed logs available in: ${WHITE}$LOG_FILE${NC}"
}

# Main test execution
run_all_tests() {
    show_banner
    init_test_environment
    
    run_unit_tests
    run_integration_tests
    run_performance_tests
    run_error_tests
    
    if [[ "$CLEANUP_ON_SUCCESS" == "true" && $TESTS_FAILED -eq 0 ]]; then
        cleanup_test_resources
    fi
    
    show_test_summary
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --unit)
                init_test_environment
                run_unit_tests
                show_test_summary
                exit 0
                ;;
            --integration)
                init_test_environment
                run_integration_tests
                show_test_summary
                exit 0
                ;;
            --performance)
                init_test_environment
                run_performance_tests
                show_test_summary
                exit 0
                ;;
            --error)
                init_test_environment
                run_error_tests
                show_test_summary
                exit 0
                ;;
            --cleanup)
                cleanup_test_resources
                exit 0
                ;;
            --no-cleanup)
                CLEANUP_ON_SUCCESS=false
                shift
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
    echo -e "${WHITE}ARC113 Testing Framework${NC}"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  $0 [OPTIONS]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --unit            Run only unit tests"
    echo "  --integration     Run only integration tests"
    echo "  --performance     Run only performance tests"
    echo "  --error           Run only error handling tests"
    echo "  --cleanup         Clean up test resources and exit"
    echo "  --no-cleanup      Don't cleanup resources after successful tests"
    echo "  --help, -h        Show this help message"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  $0                # Run all tests"
    echo "  $0 --unit         # Run only unit tests"
    echo "  $0 --no-cleanup   # Run all tests but keep resources"
    echo ""
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Parse arguments or run all tests
    if [[ $# -eq 0 ]]; then
        run_all_tests
    else
        parse_arguments "$@"
        run_all_tests
    fi
fi
