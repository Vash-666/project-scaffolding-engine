#!/bin/bash

# Project Scaffolding Engine - Generation Script
# Version: 1.0
# Date: April 20, 2026

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
CONFIG_DIR="$SCRIPT_DIR/../../../config"
LOG_FILE="/tmp/scaffold-$(date +%Y%m%d-%H%M%S).log"

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

# Validation functions
validate_project_name() {
    local name="$1"
    
    # Check length
    if [ ${#name} -lt 1 ] || [ ${#name} -gt 50 ]; then
        log_error "Project name must be 1-50 characters"
        return 1
    fi
    
    # Check pattern (lowercase letters, numbers, hyphens, must start with letter)
    if ! [[ "$name" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
        log_error "Project name must start with lowercase letter, contain only lowercase letters, numbers, or hyphens, and end with letter or number"
        return 1
    fi
    
    # Check reserved words
    local reserved_words=("node" "npm" "test" "build" "dist" "src" "public")
    for word in "${reserved_words[@]}"; do
        if [ "$name" == "$word" ]; then
            log_error "Project name '$name' is a reserved word"
            return 1
        fi
    done
    
    return 0
}

validate_template() {
    local template="$1"
    
    if [ ! -d "$TEMPLATES_DIR/$template" ]; then
        log_error "Template '$template' not found. Available templates:"
        ls -1 "$TEMPLATES_DIR" 2>/dev/null || echo "No templates found"
        return 1
    fi
    
    return 0
}

check_disk_space() {
    local required_mb=500
    local available_mb=$(df -m . | awk 'NR==2 {print $4}')
    
    if [ "$available_mb" -lt "$required_mb" ]; then
        log_error "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
        return 1
    fi
    
    return 0
}

# Main generation function
generate_project() {
    local project_name="$1"
    local template_type="$2"
    local output_dir="$3"
    
    local start_time=$(date +%s)
    
    log_info "Starting project generation: $project_name ($template_type)"
    log_info "Output directory: $output_dir"
    
    # Validate inputs
    validate_project_name "$project_name" || return 1
    validate_template "$template_type" || return 1
    check_disk_space || return 1
    
    # Create project directory
    if [ -d "$output_dir" ]; then
        log_warning "Directory $output_dir already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Operation cancelled"
            return 1
        fi
        rm -rf "$output_dir"
    fi
    
    mkdir -p "$output_dir"
    
    # Copy template files
    log_info "Copying template files..."
    cp -r "$TEMPLATES_DIR/$template_type/." "$output_dir/"
    
    # Process template variables
    log_info "Processing template variables..."
    find "$output_dir" -type f -name "*.json" -o -name "*.md" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | while read -r file; do
        if [ -f "$file" ]; then
            # Replace PROJECT_NAME with actual project name
            sed -i '' "s/PROJECT_NAME/$project_name/g" "$file" 2>/dev/null || true
            # Replace CURRENT_YEAR with current year
            sed -i '' "s/CURRENT_YEAR/$(date +%Y)/g" "$file" 2>/dev/null || true
            # Replace CURRENT_DATE with current date
            sed -i '' "s/CURRENT_DATE/$(date +%Y-%m-%d)/g" "$file" 2>/dev/null || true
        fi
    done
    
    # Update package.json with project name
    if [ -f "$output_dir/package.json" ]; then
        jq --arg name "$project_name" '.name = $name' "$output_dir/package.json" > "$output_dir/package.json.tmp" && mv "$output_dir/package.json.tmp" "$output_dir/package.json"
    fi
    
    # For Express+React template, update workspace package.json files
    if [ "$template_type" == "express-react" ]; then
        if [ -f "$output_dir/package.json" ]; then
            jq --arg name "$project_name" '.name = $name' "$output_dir/package.json" > "$output_dir/package.json.tmp" && mv "$output_dir/package.json.tmp" "$output_dir/package.json"
        fi
        if [ -f "$output_dir/client/package.json" ]; then
            jq --arg name "${project_name}-client" '.name = $name' "$output_dir/client/package.json" > "$output_dir/client/package.json.tmp" && mv "$output_dir/client/package.json.tmp" "$output_dir/client/package.json"
        fi
        if [ -f "$output_dir/server/package.json" ]; then
            jq --arg name "${project_name}-server" '.name = $name' "$output_dir/server/package.json" > "$output_dir/server/package.json.tmp" && mv "$output_dir/server/package.json.tmp" "$output_dir/server/package.json"
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "Project generation completed in ${duration} seconds"
    log_info "Project location: $output_dir"
    
    # Return success
    return 0
}

# Main execution
main() {
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <project-name> <template-type> [output-directory]"
        echo "Available templates: nextjs-fullstack, express-react"
        echo "Example: $0 my-app nextjs-fullstack ./projects"
        exit 1
    fi
    
    local project_name="$1"
    local template_type="$2"
    local output_dir="${3:-./$project_name}"
    
    # Create log file
    echo "=== Project Scaffolding Log ===" > "$LOG_FILE"
    echo "Date: $(date)" >> "$LOG_FILE"
    echo "Project: $project_name" >> "$LOG_FILE"
    echo "Template: $template_type" >> "$LOG_FILE"
    echo "Output: $output_dir" >> "$LOG_FILE"
    echo "==============================" >> "$LOG_FILE"
    
    # Generate project
    if generate_project "$project_name" "$template_type" "$output_dir"; then
        log_success "Project '$project_name' successfully generated"
        echo "$output_dir"
        exit 0
    else
        log_error "Project generation failed"
        exit 1
    fi
}

# Run main function
main "$@"