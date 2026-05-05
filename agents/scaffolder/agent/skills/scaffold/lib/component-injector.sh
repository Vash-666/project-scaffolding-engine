#!/bin/bash
#
# Component Injector - P002
# Injects feature-specific components into generated projects
#

# Base directory for feature component templates
FEATURE_COMPONENTS_DIR="${SKILLS_DIR}/templates/feature-components"

# Inject a single feature into the project
inject_feature() {
    local feature_name="$1"
    local project_path="$2"
    local injected_count=0
    
    local feature_dir="${FEATURE_COMPONENTS_DIR}/${feature_name}"
    
    # Check if feature template exists
    if [[ ! -d "$feature_dir" ]]; then
        echo "⚠️  Feature template not found: ${feature_name}"
        return 1
    fi
    
    echo "📦 Injecting feature: ${feature_name}"
    
    # Copy all files from feature template to project
    # Preserve directory structure
    find "$feature_dir" -type f | while read -r source_file; do
        # Get relative path from feature_dir
        local rel_path="${source_file#$feature_dir/}"
        local target_file="${project_path}/src/${rel_path}"
        
        # Create target directory if needed
        local target_dir=$(dirname "$target_file")
        mkdir -p "$target_dir"
        
        # Copy file
        cp "$source_file" "$target_file"
        echo "   ✓ ${rel_path}"
        ((injected_count++))
    done
    
    echo "   Injected ${injected_count} files"
    return 0
}

# Inject multiple features from a features array
inject_all_features() {
    local features_json="$1"
    local project_path="$2"
    local success_count=0
    
    echo ""
    echo "🎯 Injecting feature components..."
    echo ""
    
    # Parse features from JSON array
    # Extract feature names from JSON like: ["contact_form","auth"]
    local features=$(echo "$features_json" | grep -oE '"[^"]+"' | tr -d '"' | grep -v '^\[' | grep -v '^\]$')
    
    for feature in $features; do
        # Map feature names to directory names
        local feature_dir="$feature"
        
        # Handle special mappings if needed
        case "$feature" in
            contact_form) feature_dir="contact-form" ;;
            auth|authentication) feature_dir="auth-pages" ;;
            data_table) feature_dir="data-table" ;;
        esac
        
        if inject_feature "$feature_dir" "$project_path"; then
            ((success_count++))
        fi
    done
    
    echo ""
    echo "✅ Feature injection complete: ${success_count} feature(s) added"
    echo ""
    
    return $success_count
}

# Check if a feature template exists
feature_exists() {
    local feature_name="$1"
    local feature_dir="${FEATURE_COMPONENTS_DIR}/${feature_name}"
    [[ -d "$feature_dir" ]]
}

# List available features
list_available_features() {
    echo "Available feature components:"
    if [[ -d "$FEATURE_COMPONENTS_DIR" ]]; then
        for dir in "$FEATURE_COMPONENTS_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                local feature=$(basename "$dir")
                echo "  • $feature"
            fi
        done
    else
        echo "  (none found)"
    fi
}

# Export functions for use in other scripts
export -f inject_feature
export -f inject_all_features
export -f feature_exists
export -f list_available_features
