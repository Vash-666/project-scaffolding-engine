#!/bin/bash

# Lightweight Project Validation Script
# Version for MVP - meets < 2 minute total workflow target
# Only validates file structure and syntax, doesn't require dependency installation

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../../config"
LOG_FILE="/tmp/validate-light-$(date +%Y%m%d-%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Lightweight validation functions
validate_file_structure() {
    local project_dir="$1"
    local template_type="$2"
    
    log_info "Validating file structure for $template_type template..."
    
    # Basic checks
    if [ ! -d "$project_dir" ]; then
        log_error "Project directory not found: $project_dir"
        return 1
    fi
    
    # Check for essential files based on template type
    case "$template_type" in
        "nextjs-fullstack")
            essential_files=(
                "package.json"
                "tsconfig.json"
                "next.config.js"
                "tailwind.config.ts"
                "src/app/page.tsx"
                "src/app/layout.tsx"
                ".eslintrc.json"
                ".prettierrc"
            )
            ;;
        "express-react")
            essential_files=(
                "package.json"
                "client/package.json"
                "server/package.json"
                "client/src/App.tsx"
                "server/src/index.ts"
                ".eslintrc.json"
                ".prettierrc"
            )
            ;;
        *)
            log_error "Unknown template type: $template_type"
            return 1
            ;;
    esac
    
    local missing_files=()
    for file in "${essential_files[@]}"; do
        if [ ! -f "$project_dir/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "Missing essential files: ${missing_files[*]}"
        return 1
    fi
    
    log_success "File structure validation passed"
    return 0
}

validate_json_syntax() {
    local project_dir="$1"
    
    log_info "Validating JSON syntax..."
    
    # Check all JSON files for valid syntax
    local json_files=$(find "$project_dir" -name "*.json" -type f)
    local invalid_files=()
    
    for file in $json_files; do
        if ! jq empty "$file" 2>/dev/null; then
            invalid_files+=("$file")
        fi
    done
    
    if [ ${#invalid_files[@]} -gt 0 ]; then
        log_error "Invalid JSON syntax in files: ${invalid_files[*]}"
        return 1
    fi
    
    log_success "JSON syntax validation passed"
    return 0
}

validate_template_variables() {
    local project_dir="$1"
    
    log_info "Checking for unresolved template variables..."
    
    # Check for common template variables that should have been replaced
    local unresolved_vars=$(grep -r "PROJECT_NAME\|CURRENT_YEAR\|CURRENT_DATE" "$project_dir" --include="*.json" --include="*.md" --include="*.ts" --include="*.tsx" --include="*.js" 2>/dev/null || true)
    
    if [ -n "$unresolved_vars" ]; then
        log_warning "Found unresolved template variables (may be intentional):"
        echo "$unresolved_vars" | head -5 | while read line; do
            echo "  $line"
        done
        if [ $(echo "$unresolved_vars" | wc -l) -gt 5 ]; then
            echo "  ... and $(($(echo "$unresolved_vars" | wc -l) - 5)) more"
        fi
        return 0  # Not a critical failure
    fi
    
    log_success "Template variable replacement validated"
    return 0
}

calculate_quality_score() {
    local passed_checks=$1
    local total_checks=$2
    
    # Simple quality score calculation (0-10 scale)
    local score=$(echo "scale=1; $passed_checks * 10 / $total_checks" | bc 2>/dev/null || echo "0")
    echo "$score"
}

# Main validation function
validate_project_lightweight() {
    local project_dir="$1"
    local template_type="$2"
    
    local start_time=$(date +%s)
    
    log_info "Starting lightweight project validation: $project_dir"
    log_info "Template type: $template_type"
    
    # Create log file
    echo "=== Lightweight Validation Log ===" > "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Project: $project_dir" >> "$LOG_FILE"
    echo "Template: $template_type" >> "$LOG_FILE"
    echo "================================" >> "$LOG_FILE"
    
    # Run lightweight validations
    local checks_passed=0
    local total_checks=3
    
    # 1. File structure validation
    if validate_file_structure "$project_dir" "$template_type"; then
        ((checks_passed++))
    fi
    
    # 2. JSON syntax validation
    if validate_json_syntax "$project_dir"; then
        ((checks_passed++))
    fi
    
    # 3. Template variable validation
    if validate_template_variables "$project_dir"; then
        ((checks_passed++))
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Calculate quality score
    local quality_score=$(calculate_quality_score "$checks_passed" "$total_checks")
    
    # Generate validation report
    log_info "=== Lightweight Validation Report ==="
    log_info "Checks passed: $checks_passed/$total_checks"
    log_info "Quality score: $quality_score/10"
    log_info "Validation time: ${duration}s"
    log_info "Target quality: 9.0/10"
    
    # Check if quality meets target
    if (( $(echo "$quality_score >= 9.0" | bc -l 2>/dev/null || echo "0") )); then
        log_success "✅ Project validation PASSED with score $quality_score/10"
        echo "$quality_score"
        return 0
    else
        log_error "❌ Project validation FAILED with score $quality_score/10 (target: 9.0/10)"
        return 1
    fi
}

# Main execution
main() {
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <project-directory> <template-type>"
        echo "Available templates: nextjs-fullstack, express-react"
        echo "Example: $0 ./my-app nextjs-fullstack"
        exit 1
    fi
    
    local project_dir="$1"
    local template_type="$2"
    
    # Validate project
    if validate_project_lightweight "$project_dir" "$template_type"; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"