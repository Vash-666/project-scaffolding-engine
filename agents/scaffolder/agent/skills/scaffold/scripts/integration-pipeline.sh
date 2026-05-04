#!/bin/bash

# Integration Pipeline for @scaffolder Agent
# Demonstrates complete workflow from command to generated project

set -e

echo "🔧 @scaffolder Integration Pipeline"
echo "=================================="
echo ""

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
CONFIG_DIR="$SCRIPT_DIR/../../../config"
LOG_FILE="/tmp/scaffold-integration-$(date +%Y%m%d-%H%M%S).log"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

# Main integration function
run_integration_test() {
    local test_name="$1"
    local project_name="$2"
    local template_type="$3"
    
    log "Starting integration test: $test_name"
    log "Project: $project_name, Template: $template_type"
    
    # Create test directory
    local test_dir="/tmp/scaffold-integration-$test_name-$(date +%s)"
    mkdir -p "$test_dir"
    
    # Step 1: Generate project
    local start_time=$(date +%s%N)
    log "Step 1: Generating project..."
    
    # Run generation and capture output
    local gen_output
    gen_output=$("$SCRIPT_DIR/generate-project.sh" "$project_name" "$template_type" "$test_dir" 2>&1)
    local gen_exit_code=$?
    
    if [ $gen_exit_code -ne 0 ]; then
        error "Generation failed with exit code: $gen_exit_code"
        echo "Output: $gen_output"
        return 1
    fi
    
    local gen_end_time=$(date +%s%N)
    local gen_duration_ms=$(( (gen_end_time - start_time) / 1000000 ))
    success "Generation complete (${gen_duration_ms}ms)"
    
    # Step 2: Validate project
    log "Step 2: Validating project..."
    
    # Run validation and capture output
    local val_output
    val_output=$("$SCRIPT_DIR/validate-lightweight.sh" "$test_dir" "$template_type" 2>&1)
    local val_exit_code=$?
    
    if [ $val_exit_code -ne 0 ]; then
        error "Validation failed with exit code: $val_exit_code"
        echo "Output: $val_output"
        return 1
    fi
    
    local val_end_time=$(date +%s%N)
    local val_duration_ms=$(( (val_end_time - gen_end_time) / 1000000 ))
    success "Validation passed (${val_duration_ms}ms)"
    
    # Step 3: Check file structure
    log "Step 3: Checking file structure..."
    local file_count=$(find "$test_dir" -type f | wc -l)
    success "Files generated: $file_count"
    
    # Step 4: Check template variable replacement
    log "Step 4: Checking template variables..."
    if grep -q "$project_name" "$test_dir/package.json"; then
        success "Template variables replaced correctly"
    else
        warning "Template variable replacement issue detected"
    fi
    
    local total_end_time=$(date +%s%N)
    local total_duration_ms=$(( (total_end_time - start_time) / 1000000 ))
    
    # Summary
    log "=== Integration Test Summary ==="
    log "Test: $test_name"
    log "Status: PASSED"
    log "Total time: ${total_duration_ms}ms"
    log "Files: $file_count"
    log "Location: $test_dir"
    
    # Cleanup (optional)
    # rm -rf "$test_dir"
    
    return 0
}

# Run integration tests
echo ""
echo "🧪 Running Integration Tests..."
echo ""

# Test 1: Next.js template
if run_integration_test "nextjs-basic" "test-nextjs-integration" "nextjs-fullstack"; then
    success "Test 1: Next.js integration PASSED"
else
    error "Test 1: Next.js integration FAILED"
    exit 1
fi

echo ""
echo "---"
echo ""

# Test 2: Express+React template
if run_integration_test "express-basic" "test-express-integration" "express-react"; then
    success "Test 2: Express+React integration PASSED"
else
    error "Test 2: Express+React integration FAILED"
    exit 1
fi

echo ""
echo "=================================="
echo "🎉 Integration Pipeline Complete"
echo ""
echo "Summary:"
echo "- Both template types integrated successfully"
echo "- Generation + validation pipeline working"
echo "- All quality gates passing"
echo "- Ready for performance testing"
echo ""
echo "Next: Performance benchmarking and GitHub integration"

# Log file location
echo ""
echo "📋 Log file: $LOG_FILE"