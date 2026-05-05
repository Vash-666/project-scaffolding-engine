#!/bin/bash
#
# Project Parser - CAP-001
# Parse natural language into structured project requirements
#

# Parse user input into structured format
parse_project_request() {
    local input="$1"
    
    # Initialize with defaults
    local project_type="generic"
    local features='["basic_setup"]'
    local suggested_template="nextjs-fullstack"
    local auth_required="false"
    local database_required="false"
    
    # Detect project type
    if echo "$input" | grep -qi "blog"; then
        project_type="blog"
        suggested_template="nextjs-fullstack"
        features='["content_management", "markdown_support"]'
    elif echo "$input" | grep -qi "dashboard"; then
        project_type="dashboard"
        suggested_template="nextjs-fullstack"
        features='["data_visualization", "admin_interface"]'
    elif echo "$input" | grep -qi "api"; then
        project_type="api-service"
        suggested_template="express-react"
        features='["rest_api", "database_integration"]'
    fi
    
    # Detect features
    if echo "$input" | grep -qi "auth"; then
        auth_required="true"
        features=$(echo "$features" | sed 's/\]$/,"user_authentication"]/')
    fi
    
    if echo "$input" | grep -qi "database"; then
        database_required="true"
        features=$(echo "$features" | sed 's/\]$/,"database_integration"]/')
    fi
    
    # P002: New feature detection
    if echo "$input" | grep -qi "contact"; then
        features=$(echo "$features" | sed 's/\]$/,"contact_form"]/')
    fi
    
    if echo "$input" | grep -qi "portfolio"; then
        features=$(echo "$features" | sed 's/\]$/,"portfolio"]/')
    fi
    
    if echo "$input" | grep -qi "data table\|datatable\|data grid"; then
        features=$(echo "$features" | sed 's/\]$/,"data_table"]/')
    fi
    
    if echo "$input" | grep -qi "export\|download"; then
        features=$(echo "$features" | sed 's/\]$/,"export"]/')
    fi
    
    # Output structured JSON
    printf '{\n  "project_type": "%s",\n  "features": %s,\n  "suggested_template": "%s",\n  "auth_required": %s,\n  "database_required": %s,\n  "original_input": "%s"\n}\n' \
        "$project_type" "$features" "$suggested_template" "$auth_required" "$database_required" "$input"
}

# Generate customization hints
generate_customizations() {
    local json="$1"
    
    echo "Recommended customizations:"
    
    if echo "$json" | grep -q '"project_type": "blog"'; then
        echo "  - Add blog post schema"
        echo "  - Add comment system"
        echo "  - Add RSS feed"
    elif echo "$json" | grep -q '"project_type": "dashboard"'; then
        echo "  - Add chart components"
        echo "  - Add data tables"
        echo "  - Add export functionality"
    elif echo "$json" | grep -q '"project_type": "api-service"'; then
        echo "  - Add API documentation"
        echo "  - Add rate limiting"
        echo "  - Add request logging"
    fi
    
    if echo "$json" | grep -q '"auth_required": true'; then
        echo "  - Add authentication routes"
        echo "  - Add protected middleware"
    fi
    
    if echo "$json" | grep -q '"database_required": true'; then
        echo "  - Add database models"
        echo "  - Add migration scripts"
    fi
}
