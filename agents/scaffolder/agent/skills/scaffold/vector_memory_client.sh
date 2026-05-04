#!/bin/bash
#
# Vector Memory Client for @scaffolder
# Bash wrapper to query Python vector memory service
#

# Query vector memory from bash scripts
query_memory() {
    local query="$1"
    local top_k="${2:-5}"
    
    # Call Python query script
    python3 /Users/rohitvashist/.openclaw/agents/shared/vector-memory/agent_query.py "$query" 2>/dev/null | grep -A1 "^\d\+\."
}

# Get relevant context for project type
get_project_context() {
    local project_type="$1"
    
    case "$project_type" in
        blog)
            query_memory "blog best practices authentication" 3
            ;;
        dashboard)
            query_memory "dashboard data visualization admin" 3
            ;;
        api-service)
            query_memory "API service REST backend patterns" 3
            ;;
        *)
            query_memory "project scaffolding best practices" 3
            ;;
    esac
}

# Get quality requirements from memory
get_quality_requirements() {
    query_memory "quality gates requirements standards" 3
}
