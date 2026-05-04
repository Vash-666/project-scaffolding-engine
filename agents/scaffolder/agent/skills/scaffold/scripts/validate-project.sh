#!/bin/bash

# Project Scaffolding Engine - Validation Script
# Version: 1.0
# Date: April 20, 2026

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../../../config"
LOG_FILE="/tmp/validate-$(date +%Y%m%d-%H%M%S).log"

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

# Load configuration
load_config() {
    if [ ! -f "$CONFIG_DIR/template-config.json" ]; then
        log_error "Configuration file not found: $CONFIG_DIR/template-config.json"
        return 1
    fi
    
    # Parse JSON using jq
    CONFIG=$(cat "$CONFIG_DIR/template-config.json")
    
    # Extract performance targets
    TOTAL_TIME_TARGET=$(echo "$CONFIG" | jq -r '.performanceTargets.totalTime')
    SUCCESS_RATE_TARGET=$(echo "$CONFIG" | jq -r '.performanceTargets.successRate')
    QUALITY_SCORE_TARGET=$(echo "$CONFIG" | jq -r '.performanceTargets.qualityScore')
    VULNERABILITY_FREE_TARGET=$(echo "$CONFIG" | jq -r '.performanceTargets.vulnerabilityFreeRate')
    
    return 0
}

# Validation functions
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

validate_typescript() {
    local project_dir="$1"
    
    log_info "Validating TypeScript configuration..."
    
    if [ -f "$project_dir/tsconfig.json" ]; then
        # Check if TypeScript compiles
        cd "$project_dir"
        if npx tsc --noEmit 2>/dev/null; then
            log_success "TypeScript compilation successful"
            return 0
        else
            log_error "TypeScript compilation failed"
            return 1
        fi
    else
        log_warning "No tsconfig.json found, skipping TypeScript validation"
        return 0
    fi
}

validate_eslint() {
    local project_dir="$1"
    
    log_info "Running ESLint validation..."
    
    if [ -f "$project_dir/.eslintrc.json" ] || [ -f "$project_dir/.eslintrc.js" ]; then
        cd "$project_dir"
        if npx eslint . --quiet 2>/dev/null; then
            log_success "ESLint validation passed"
            return 0
        else
            # Try to get error count
            local error_count=$(npx eslint . --format=json 2>/dev/null | jq '.[0].errorCount // 0')
            if [ "$error_count" -gt 0 ]; then
                log_warning "ESLint found $error_count errors (will attempt auto-fix)"
                # Try auto-fix
                if npx eslint . --fix 2>/dev/null; then
                    log_success "ESLint auto-fix successful"
                    return 0
                else
                    log_error "ESLint validation failed with unfixable errors"
                    return 1
                fi
            else
                log_success "ESLint validation passed (warnings only)"
                return 0
            fi
        fi
    else
        log_warning "No ESLint configuration found, skipping ESLint validation"
        return 0
    fi
}

validate_dependencies() {
    local project_dir="$1"
    
    log_info "Validating dependencies..."
    
    if [ -f "$project_dir/package.json" ]; then
        cd "$project_dir"
        
        # Check for package.json validity
        if ! jq empty package.json 2>/dev/null; then
            log_error "Invalid package.json"
            return 1
        fi
        
        # Check for node_modules (optional - might not be installed yet)
        if [ -d "node_modules" ]; then
            # Check for missing dependencies
            if npx npm-check 2>/dev/null | grep -q "Missing"; then
                log_warning "Some dependencies may be missing"
                return 0  # Not a critical failure
            fi
        fi
        
        log_success "Dependencies validation passed"
        return 0
    else
        log_error "No package.json found"
        return 1
    fi
}

validate_build() {
    local project_dir="$1"
    local template_type="$2"
    
    log_info "Validating build process..."
    
    cd "$project_dir"
    
    case "$template_type" in
        "nextjs-fullstack")
            if npx next build 2>&1 | grep -q "Error"; then
                log_error "Next.js build failed"
                return 1
            fi
            ;;
        "express-react")
            # Build client
            if [ -d "client" ]; then
                cd "client"
                if npx vite build 2>&1 | grep -q "error"; then
                    log_error "Vite build failed"
                    return 1
                fi
                cd ..
            fi
            
            # Build server
            if [ -d "server" ]; then
                cd "server"
                if ! npx tsc 2>/dev/null; then
                    log_error "TypeScript compilation failed for server"
                    return 1
                fi
                cd ..
            fi
            ;;
    esac
    
    log_success "Build validation passed"
    return 0
}

calculate_quality_score() {
    local passed_checks=$1
    local total_checks=$2
    
    # Simple quality score calculation (0-10 scale)
    local score=$(echo "scale=1; $passed_checks * 10 / $total_checks" | bc)
    echo "$score"
}

# Main validation function
validate_project() {
    local project_dir="$1"
    local template_type="$2"
    
    local start_time=$(date +%s)
    
    log_info "Starting project validation: $project_dir"
    log_info "Template type: $template_type"
    
    # Load configuration
    load_config || return 1
    
    # Create log file
    echo "=== Project Validation Log ===" > "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Project: $project_dir" >> "$LOG_FILE"
    echo "Template: $template_type" >> "$LOG_FILE"
    echo "=============================" >> "$LOG_FILE"
    
    # Run validations
    local checks_passed=0
    local total_checks=5
    
    # 1. File structure validation
    if validate_file_structure "$project_dir" "$template_type"; then
        ((checks_passed++))
    fi
    
    # 2. TypeScript validation
    if validate_typescript "$project_dir"; then
        ((checks_passed++))
    fi
    
    # 3. ESLint validation
    if validate_eslint "$project_dir"; then
        ((checks_passed++))
    fi
    
    # 4. Dependencies validation
    if validate_dependencies "$project_dir"; then
        ((checks_passed++))
    fi
    
    # 5. Build validation
    if validate_build "$project_dir" "$template_type"; then
        ((checks_passed++))
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Calculate quality score
    local quality_score=$(calculate_quality_score "$checks_passed" "$total_checks")
    
    # Generate validation report
    log_info "=== Validation Report ==="
    log_info "Checks passed: $checks_passed/$total_checks"
    log_info "Quality score: $quality_score/10"
    log_info "Validation time: ${duration}s"
    log_info "Target quality: $QUALITY_SCORE_TARGET/10"
    
    # Check if quality meets target
    if (( $(echo "$quality_score >= $QUALITY_SCORE_TARGET" | bc -l) )); then
        log_success "✅ Project validation PASSED with score $quality_score/10"
        echo "$quality_score"
        return 0
    else
        log_error "❌ Project validation FAILED with score $quality_score/10 (target: $QUALITY_SCORE_TARGET/10)"
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
    if validate_project "$project_dir" "$template_type"; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"